import SwiftUI

struct BookRowView: View {
    let book: BookData

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            bookTitle
            bookAuthor
        }
        .padding(.vertical, 4)
    }
    
    // MARK: - Subviews
    
    private var bookTitle: some View {
        Text(book.title)
            .font(.headline)
    }
    
    private var bookAuthor: some View {
        Text(book.author)
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
}
