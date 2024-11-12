import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataManager: DataManager
    @ObservedObject var viewModel: ContentViewModel
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(viewModel: viewModel)
        } content: {
            MiddlePanelView(viewModel: viewModel)
                .background(Color(nsColor: .windowBackgroundColor))
        } detail: {
            if let selectedBook = viewModel.selectedBook {
                DetailView(book: selectedBook)
                    .background(Color(nsColor: .windowBackgroundColor))
            } else {
                EmptySelectionView()
            }
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarView(viewModel: viewModel)
        }
        .sheet(isPresented: $appState.isAddingBook) {
            AddView()
                .environmentObject(dataManager)
                .padding()
        }
    }
}
