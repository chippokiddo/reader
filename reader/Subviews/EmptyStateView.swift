import SwiftUI

enum EmptyStateTypes {
    case list // Generic list (default)
    case search // No search results
    case deleted // No deleted books
    case detail // No book selected in detail view
    case unread // No unread books
    case reading // No currently reading books
    case read // No completed books
    case collection // No books in collection
    
    // Icons
    var imageName: String {
        switch self {
        case .list: return "questionmark"
        case .search: return "text.page.badge.magnifyingglass"
        case .deleted: return "trash.slash"
        case .detail: return "book.pages"
        case .unread: return "questionmark"
        case .reading: return "questionmark"
        case .read: return "questionmark"
        case .collection: return "questionmark.folder"
        }
    }
    
    // Title
    var title: String {
        switch self {
        case .list: return "No books found"
        case .search: return "No books found"
        case .deleted: return "No deleted books"
        case .detail: return "Select a book to view details"
        case .unread: return "No unread books"
        case .reading: return "No books currently being read"
        case .read: return "No completed books"
        case .collection: return "No books in your collection"
        }
    }
    
    // Message
    var message: String? {
        switch self {
        case .list: return "It's empty here. Add a new book to get started."
        case .search: return "Try adjusting your search or add a new book."
        case .deleted: return "Looks like you haven’t deleted any books yet."
        case .detail: return nil
        case .unread: return "It's empty here. Add a new book to get started."
        case .reading: return "Start reading a book to track it here."
        case .read: return "No books read yet? Maybe it’s time to change that."
        case .collection: return "It's empty here. Add some books into your collection."
        }
    }
    
    // Spacing
    var spacing: CGFloat {
        switch self {
        case .detail: return 10
        default: return 16
        }
    }
}

struct EmptyStateView: View {
    let type: EmptyStateTypes
    var minWidth: CGFloat? = nil
    var selectedBooks: [BookData] = []
    var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: type.spacing) {
            Spacer()
            
            Image(systemName: type.imageName)
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(type.title)
                .font(.headline)
                .foregroundColor(.secondary)
            
            if let message = type.message {
                Text(message)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(minWidth: minWidth)
        .toolbar {
            ToolbarItem(placement: .automatic) {
                Spacer()
            }
        }
    }
}
