import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var viewModel: ContentViewModel
    @EnvironmentObject var overlayManager: OverlayManager
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    @State private var searchText: String = ""
    @State private var selectedBookIDs: Set<UUID> = []
    
    var body: some View {
        ZStack {
            NavigationSplitView(columnVisibility: $columnVisibility) {
                SidebarView(viewModel: viewModel)
                    .frame(width: 225)
            } content: {
                MiddlePanelView(viewModel: viewModel, selectedBookIDs: $selectedBookIDs)
                    .frame(minWidth: 485, maxWidth: .infinity)
            } detail: {
                if selectedBookIDs.count > 1 {
                    let selectedBooks = viewModel.displayedBooks.filter { selectedBookIDs.contains($0.id) }
                    MultipleSelectionView(
                        count: selectedBooks.count,
                        selectedBooks: selectedBooks,
                        viewModel: viewModel,
                        dataManager: dataManager,
                        selectedCollection: viewModel.selectedCollection
                    )
                    .frame(minWidth: 450, maxWidth: .infinity)
                }
                else if let selectedID = selectedBookIDs.first,
                        let selectedBook = viewModel.displayedBooks.first(where: { $0.id == selectedID }) {
                    DetailView(book: selectedBook)
                        .frame(minWidth: 450, maxWidth: .infinity)
                }
                else {
                    EmptyStateView(type: .detail, viewModel: viewModel)
                        .frame(minWidth: 450, maxWidth: .infinity)
                }
            }
            .onChange(of: selectedBookIDs) { oldValue, newValue in
                if oldValue != newValue {
                    appState.selectedBooks = viewModel.displayedBooks.filter { newValue.contains($0.id) }
                }
            }
            .navigationSplitViewStyle(.balanced)
            .searchable(text: $viewModel.searchQuery, placement: .sidebar)
            
            OverlayView()
        }
        .frame(minHeight: 475, maxHeight: .infinity)
        .alert(item: $appState.alertType) { alertType in
            alertType.createAlert(appState: appState)
        }
    }
}
