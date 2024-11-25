import Foundation
import SwiftUI
import Combine

@MainActor
final class ContentViewModel: ObservableObject {
    @AppStorage("selectedStatus") var selectedStatus: StatusFilter = .all
    
    @Published var searchQuery: String = ""
    @Published var sortOption: SortOption = .title
    @Published var sortOrder: SortOrder = .ascending
    @Published var selectedBook: BookData?
    
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
        let filteredBooks = FilterHelper.applyStatusFilter(to: books, status: selectedStatus)
        let searchedBooks = FilterHelper.applySearchFilter(to: filteredBooks, query: searchQuery)
        return FilterHelper.applySorting(to: searchedBooks, option: sortOption, order: sortOrder)
    }
    
    func bookCount(for status: StatusFilter) -> Int {
        return FilterHelper.countBooks(for: status, in: books)
    }
    
    func softDeleteBook(_ book: BookData) {
        dataManager.updateBookStatus(book, to: .deleted)
        book.updateDates(for: .deleted)
    }

    func recoverBook(_ book: BookData) {
        dataManager.updateBookStatus(book, to: .unread)
        book.updateDates(for: .unread)
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