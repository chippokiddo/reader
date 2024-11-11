import Foundation
import SwiftUI
import Combine

@MainActor
final class ContentViewModel: ObservableObject {
    @AppStorage("selectedStatus") var selectedStatus: StatusFilter = .all
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .title
    @Published var sortOrder: SortOrder = .ascending
    @Published var selectedBook: BookData? {
        didSet {
            print("Selected book updated: \(selectedBook?.title ?? "None")")
        }
    }
    private var dataManager: DataManager

    // Directly observe books from `DataManager`
    var books: [BookData] {
        dataManager.books
    }

    init(dataManager: DataManager) {
        self.dataManager = dataManager
    }

    // Computed property to apply filters and sorting
    var displayedBooks: [BookData] {
        let filteredBooks = books.filter { book in
            switch selectedStatus {
            case .all: return book.status != .deleted
            case .unread: return book.status == .unread
            case .reading: return book.status == .reading
            case .read: return book.status == .read
            case .deleted: return book.status == .deleted
            }
        }
        
        let searchedBooks = FilterHelper.applySearchFilter(to: filteredBooks, query: searchQuery)
        return FilterHelper.applySorting(to: searchedBooks, option: sortOption, order: sortOrder)
    }

    // Method to get the count of books for a specific status
    func bookCount(for status: StatusFilter) -> Int {
        books.filter { book in
            switch status {
            case .all:
                return book.status != .deleted  // Include all except deleted
            case .unread:
                return book.status == .unread
            case .reading:
                return book.status == .reading
            case .read:
                return book.status == .read
            case .deleted:
                return book.status == .deleted
            }
        }.count
    }
    
    func softDeleteBook(_ book: BookData) {
        book.status = .deleted
        objectWillChange.send() // Trigger an update in SwiftUI
    }

    func recoverBook(_ book: BookData) {
        book.status = .unread
        objectWillChange.send() // Trigger an update in SwiftUI
    }

    func permanentlyDeleteBook(_ book: BookData) {
        let wasDeletedFilter = selectedStatus == .deleted  // Check if current filter is deleted
        dataManager.permanentlyDeleteBook(book)
        // Reapply the deleted filter if it was previously selected
        if wasDeletedFilter {
            selectedStatus = .deleted
        }
    }
}
