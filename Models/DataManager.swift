import Foundation
import Combine
import SwiftData

@MainActor
final class DataManager: ObservableObject {
    @Published var books: [BookData] = []
    let modelContainer: ModelContainer
    private let apiKey = "GOOGLE_BOOKS_API_KEY"
    
    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer
        fetchBooks()  // Initial fetch to populate the books list
    }
    
    func fetchBooks() {
        do {
            books = try modelContainer.mainContext.fetch(FetchDescriptor<BookData>())
            print("Fetched books: \(books)")
        } catch {
            print("Failed to fetch books: \(error)")
            books = []
        }
    }
    
    func fetchBookData(title: String, author: String, publishedDate: String, completion: @escaping (BookData?) -> Void) {
        let query = "intitle:\(title) inauthor:\(author)"
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let url = URL(string: "https://www.googleapis.com/books/v1/volumes?q=\(encodedQuery)&key=\(apiKey)") else {
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }
            do {
                let result = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
                if let matchedBook = result.items.first(where: { $0.volumeInfo.publishedDate.contains(publishedDate) }) {
                    let bookInfo = matchedBook.volumeInfo
                    
                    // Extract ISBN if available
                    let isbn = bookInfo.industryIdentifiers?.first(where: { $0.type == "ISBN_13" || $0.type == "ISBN_10" })?.identifier
                    
                    // Extract series if available (usually stored in subtitle or custom series property)
                    let series = bookInfo.subtitle ?? bookInfo.series  // Use `series` if the API provides it, otherwise try `subtitle`
                    
                    let newBook = BookData(
                        title: bookInfo.title,
                        author: bookInfo.authors?.joined(separator: ", ") ?? "",
                        published: DateFormatter().date(from: publishedDate) ?? Date(),
                        publisher: bookInfo.publisher,
                        genre: bookInfo.categories?.first,
                        series: series,
                        isbn: isbn,
                        bookDescription: bookInfo.description,
                        status: .unread
                    )
                    completion(newBook)
                } else {
                    completion(nil)
                }
            } catch {
                print("Failed to decode JSON: \(error)")
                completion(nil)
            }
        }.resume()
    }

    func addBook(
        title: String,
        author: String,
        genre: String? = nil,
        series: String? = nil,
        isbn: String? = nil,
        publisher: String? = nil,
        published: Date?,
        description: String? = nil  // New description parameter
    ) {
        guard let published = published else { return }
        
        let newBook = BookData(
            title: title,
            author: author,
            published: published,
            publisher: publisher,
            genre: genre,
            series: series,
            isbn: isbn,
            bookDescription: description,  // Set bookDescription here
            status: .unread
        )
        
        modelContainer.mainContext.insert(newBook)
        saveChanges()  // Save and refresh the list
    }
    
    func permanentlyDeleteBook(_ book: BookData) {
        modelContainer.mainContext.delete(book)  // Remove book from the context
        saveChanges()  // Persist changes and refresh the books list
    }

    private func saveChanges() {
        do {
            try modelContainer.mainContext.save()
            fetchBooks()
        } catch {
            print("Failed to save changes: \(error)")
        }
    }
}
