import SwiftUI

enum StatusFilter: String, CaseIterable, Identifiable {
    case all = "All"
    case unread = "Unread"
    case reading = "Reading"
    case read = "Read"
    case deleted = "Deleted"
    
    var id: String { rawValue }
    
    var iconName: String {
        switch self {
        case .all:
            return "books.vertical"
        case .unread:
            return "book.closed"
        case .reading:
            return "book"
        case .read:
            return "book.closed"
        case .deleted:
            return "trash"
        }
    }
    
    var iconColor: Color {
        switch self {
        case .all:
            return .purple.opacity(0.8)
        case .unread:
            return .gray
        case .reading:
            return .blue.opacity(0.7)
        case .read:
            return .green.opacity(0.7)
        case .deleted:
            return .red.opacity(0.7)
        }
    }
}
