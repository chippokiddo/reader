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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy"
        let publishedDate = dateFormatter.string(from: published)
        
        dataManager.fetchBookData(title: title, author: author, publishedDate: publishedDate) { book in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if let book = book {
                    // Populate fields from the fetched data, except for title
                    self.author = book.author
                    self.publisher = book.publisher ?? ""
                    self.bookDescription = book.bookDescription ?? ""  // Leave empty if no description found
                    self.genre = book.genre ?? ""
                    self.series = book.series ?? ""
                    self.isbn = book.isbn ?? ""
                }
                
                // Add the book, using fetched data if available, otherwise using user input
                dataManager.addBook(
                    title: self.title,
                    author: self.author.isEmpty ? author : self.author,  // Fall back to user input if needed
                    genre: self.genre.isEmpty ? genre : self.genre,
                    series: self.series.isEmpty ? series : self.series,
                    isbn: self.isbn.isEmpty ? isbn : self.isbn,
                    publisher: self.publisher.isEmpty ? publisher : self.publisher,
                    published: published,
                    description: self.bookDescription
                )
                appState.isAddingBook = false
            }
        }
    }
}
