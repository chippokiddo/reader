import SwiftUI

struct MiddlePanelView: View {
    @ObservedObject var viewModel: ContentViewModel
    @State private var localSelectedBook: BookData?

    var body: some View {
        VStack {
            searchBar
            bookList
        }
        .navigationTitle("reader")
        .onChange(of: localSelectedBook) {
            viewModel.selectedBook = localSelectedBook
        }
        .onAppear {
            localSelectedBook = viewModel.selectedBook
        }
    }
    
    // MARK: - Subviews
    
    private var searchBar: some View {
        SearchBar(text: $viewModel.searchQuery)
            .padding([.top, .horizontal])
    }
    
    private var bookList: some View {
        List(viewModel.displayedBooks, id: \.id, selection: $localSelectedBook) { book in
            BookRowView(book: book)
                .tag(book)
        }
        .listStyle(.sidebar)
    }
}

