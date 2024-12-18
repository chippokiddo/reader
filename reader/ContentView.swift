import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var viewModel: ContentViewModel
    
    @Environment(\.openWindow) private var openWindow
    
    @State private var columnVisibility: NavigationSplitViewVisibility = .automatic
    
    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            SidebarView(viewModel: viewModel)
                .frame(width: 200)
        } content: {
            MiddlePanelView(viewModel: viewModel)
                .frame(minWidth: 400, maxWidth: .infinity)
        } detail: {
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            toolbarContent
        }
    }
    
    @ViewBuilder
    private var detailView: some View {
        if let selectedBook = viewModel.selectedBook {
            DetailView(book: selectedBook)
                .frame(minWidth: 450, maxWidth: .infinity)
        } else {
            EmptyDetailView()
                .frame(minWidth: 450, maxWidth: .infinity)
        }
    }
    
    private var toolbarContent: some ToolbarContent {
        ToolbarItemGroup(placement: .automatic) {
            if viewModel.selectedBook != nil {
                BookActionButton(viewModel: viewModel)
            }
        }
    }
}
