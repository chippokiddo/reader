import SwiftUI

struct SelectEditionSheet: View {
    @Binding var selectedBook: BookTransferData?
    var addBook: (BookTransferData) -> Void
    var cancel: () -> Void // New cancel closure
    let searchResults: [BookTransferData]
    
    var body: some View {
        VStack {
            Text("Select Edition")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)
            
            if searchResults.isEmpty {
                VStack {
                    Text("No editions found.")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                    
                    Button("Dismiss") {
                        cancel()
                    }
                    .buttonStyle(.borderedProminent)
                    .padding()
                }
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(searchResults, id: \.isbn) { book in
                            VStack(alignment: .leading) {
                                Text(book.title).font(.headline)
                                Text("By: \(book.author)").font(.subheadline)
                                Text("Publisher: \(book.publisher ?? "Unknown")").font(.footnote)
                                Text(book.bookDescription ?? "")
                                    .lineLimit(2)
                                    .font(.footnote)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(selectedBook == book ? Color.blue.opacity(0.2) : Color.clear)
                            .cornerRadius(8)
                            .onTapGesture { selectedBook = book }
                        }
                    }
                }
                .padding()
            }
            
            HStack {
                Spacer()
                Button("Cancel") { cancel() } // Uses the cancel closure
                    .buttonStyle(.bordered)
                
                Button("Add") {
                    if let selectedBook = selectedBook {
                        addBook(selectedBook) // Handles addition
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(selectedBook == nil)
                Spacer()
            }
            .padding(.vertical)
        }
    }
}