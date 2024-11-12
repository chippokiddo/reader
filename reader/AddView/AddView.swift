import SwiftUI

struct AddView: View {
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var appState: AppState
    
    @State var title = ""
    @State var author = ""
    @State var genre = ""
    @State var series = ""
    @State var isbn = ""
    @State var publisher = ""
    @State var published: Date?
    @State var bookDescription = ""
    
    @FocusState var focusedField: Field?

    var body: some View {
        VStack(spacing: 16) {
            header
            Divider()
            formFields
            Divider()
            actionButtons
        }
        .frame(width: 450)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(NSColor.windowBackgroundColor))
        )
        .shadow(radius: 5)
        .onAppear {
            focusedField = .title
        }
    }
    
    var header: some View {
        Text("Add New Book")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top, 20)
    }
    
    var formFields: some View {
        VStack(alignment: .leading, spacing: 10) {
            AddTF(label: "Title", text: $title, placeholder: "Enter book title")
                .focused($focusedField, equals: .title)
            
            AddTF(label: "Author", text: $author, placeholder: "Enter author name")
            AddTF(label: "Genre", text: $genre, placeholder: "Enter genre (optional)")
            AddTF(label: "Series", text: $series, placeholder: "Enter series name (optional)")
            AddTF(label: "ISBN", text: $isbn, placeholder: "Enter ISBN (optional)")
                .focused($focusedField, equals: .isbn)
                .onChange(of: isbn) {
                    isbn = isbn.filter { $0.isNumber }
                }
            AddTF(label: "Publisher", text: $publisher, placeholder: "Enter publisher name (optional)")
            HStack {
                Text("Published Date")
                    .frame(width: 100, alignment: .leading)
                AddDateTF(date: $published)
            }
        }
        .padding(.horizontal)
    }
    
    var actionButtons: some View {
        AddButtons(
            onCancel: { appState.isAddingBook = false },
            onSave: { fetchAndAddBook() },
            isSaveDisabled: title.isEmpty || author.isEmpty || published == nil
        )
    }
    
    func fetchAndAddBook() {
        guard let published = published else { return }
        
        // Capture the necessary properties as constants to avoid capturing 'self' in the async closure
        let capturedTitle = title
        let capturedAuthor = author
        let capturedGenre = genre
        let capturedSeries = series
        let capturedIsbn = isbn
        let capturedPublisher = publisher
        let capturedDescription = bookDescription

        // Create a date formatter for the published date string
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let publishedDate = dateFormatter.string(from: published)
        
        // Start the asynchronous task
        Task {
            // Perform the data fetch in a background context
            let fetchedBook = await dataManager.fetchBookData(
                title: capturedTitle,
                author: capturedAuthor,
                publishedDate: publishedDate
            )
            
            // Switch to the main actor for UI updates and shared data
            await MainActor.run {
                if let book = fetchedBook {
                    // Populate fields from fetched data if available
                    let updatedAuthor = book.author.isEmpty ? capturedAuthor : book.author
                    let updatedPublisher = book.publisher ?? capturedPublisher
                    let updatedDescription = book.bookDescription ?? ""
                    let updatedGenre = book.genre ?? capturedGenre
                    let updatedSeries = book.series ?? capturedSeries
                    let updatedIsbn = book.isbn ?? capturedIsbn
                    
                    // Add the book, using fetched data if available, otherwise using original values
                    dataManager.addBook(
                        title: capturedTitle,
                        author: updatedAuthor,
                        genre: updatedGenre,
                        series: updatedSeries,
                        isbn: updatedIsbn,
                        publisher: updatedPublisher,
                        published: published,
                        description: updatedDescription
                    )
                } else {
                    // Use original values if no fetched data is available
                    dataManager.addBook(
                        title: capturedTitle,
                        author: capturedAuthor,
                        genre: capturedGenre,
                        series: capturedSeries,
                        isbn: capturedIsbn,
                        publisher: capturedPublisher,
                        published: published,
                        description: capturedDescription
                    )
                }
                
                // Close the add view
                appState.isAddingBook = false
            }
        }
    }
}
