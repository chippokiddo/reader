import SwiftUI

struct FilterHelper {
    static func applyStatusFilter(to books: [BookData], status: StatusFilter) -> [BookData] {
        books.filter { book in
            if status == .all {
                return book.status != ReadingStatus.deleted // Use ReadingStatus directly
            }
            return book.status.rawValue == status.rawValue
        }
    }
    
    static func applySearchFilter(to books: [BookData], query: String) -> [BookData] {
        guard !query.isEmpty else { return books }
        
        return books.filter { book in
            book.title.localizedCaseInsensitiveContains(query) ||
            book.author.localizedCaseInsensitiveContains(query)
        }
    }
    
    static func applySorting(to books: [BookData], option: SortOption, order: SortOrder) -> [BookData] {
        books.sorted { book1, book2 in
            switch option {
            case .title:
                let titleComparison = book1.title.localizedCompare(book2.title)
                return order == .ascending ? titleComparison == .orderedAscending : titleComparison == .orderedDescending
            case .author:
                let authorComparison = book1.author.localizedCompare(book2.author)
                return order == .ascending ? authorComparison == .orderedAscending : authorComparison == .orderedDescending
            case .published:
                let date1 = book1.published ?? Date.distantPast
                let date2 = book2.published ?? Date.distantPast
                return order == .ascending ? date1 < date2 : date1 > date2
            }
        }
    }
}
