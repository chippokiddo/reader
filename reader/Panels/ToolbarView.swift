import SwiftUI

struct ToolbarView: View {
    @ObservedObject var viewModel: ContentViewModel
    @EnvironmentObject var appState: AppState
    
    @State private var showSoftDeleteConfirmation = false
    @State private var showPermanentDeleteConfirmation = false
    @State private var bookToDelete: BookData?

    var body: some View {
        HStack {
            sortMenu
            Spacer()
            addBookButton
            Spacer()
            bookActionButtons
        }
        .alert("This will move the book to deleted.", isPresented: $showSoftDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete") {
                if let book = bookToDelete {
                    viewModel.softDeleteBook(book)
                }
            }
            .tint(.blue)
        }
        .alert("This will permanently delete the book. You can't undo this action.", isPresented: $showPermanentDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete") {
                if let book = bookToDelete {
                    viewModel.permanentlyDeleteBook(book)
                }
            }
            .tint(.blue)
        }
    }
    
    // Sorting menu
    private var sortMenu: some View {
        Menu {
            sortOptions
            Divider()
            sortOrderOptions
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
    
    private var sortOptions: some View {
        Group {
            Button(action: { viewModel.sortOption = .title }) {
                HStack {
                    Text("Title")
                    if viewModel.sortOption == .title {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: { viewModel.sortOption = .author }) {
                HStack {
                    Text("Author")
                    if viewModel.sortOption == .author {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
            Button(action: { viewModel.sortOption = .published }) {
                HStack {
                    Text("Published")
                    if viewModel.sortOption == .published {
                        Spacer()
                        Image(systemName: "checkmark")
                    }
                }
            }
        }
    }
    
    private var sortOrderOptions: some View {
        Group {
            Button(action: { viewModel.sortOrder = .ascending }) {
                HStack {
                    Text("Ascending")
                    if viewModel.sortOrder == .ascending {
                        Spacer()
                        Image(systemName: "arrow.up")
                    }
                }
            }
            Button(action: { viewModel.sortOrder = .descending }) {
                HStack {
                    Text("Descending")
                    if viewModel.sortOrder == .descending {
                        Spacer()
                        Image(systemName: "arrow.down")
                    }
                }
            }
        }
    }
    
    // Add book button
    private var addBookButton: some View {
        Button(action: { appState.isAddingBook = true }) {
            Label("Add Book", systemImage: "plus")
        }
    }

    // Conditional delete/recover options based on selectedBook status
    @ViewBuilder
    private var bookActionButtons: some View {
        if let selectedBook = viewModel.selectedBook {
            if selectedBook.status == .deleted {
                deletedBookActions(selectedBook)
            } else {
                activeBookActions(selectedBook)
            }
        }
    }

    private func deletedBookActions(_ book: BookData) -> some View {
        Menu {
            Button("Recover") {
                viewModel.recoverBook(book)
            }
            Button("Delete", role: .destructive) {
                bookToDelete = book
                showPermanentDeleteConfirmation = true
            }
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }

    private func activeBookActions(_ book: BookData) -> some View {
        Menu {
            Button("Delete", role: .destructive) {
                bookToDelete = book
                showSoftDeleteConfirmation = true
            }
            // Additional options can be added here in the future
        } label: {
            Label("Actions", systemImage: "ellipsis.circle")
        }
    }
}
