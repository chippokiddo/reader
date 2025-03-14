import SwiftUI

enum SortOption: String, CaseIterable {
    case title = "Title"
    case author = "Author"
    case published = "Published"
}

enum SortOrder {
    case ascending
    case descending
}

struct SortMenuButton: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        Menu {
            Section(header: Text("Sort By")) {
                sortOptionButton(label: "Title", option: .title)
                sortOptionButton(label: "Author", option: .author)
                sortOptionButton(label: "Published", option: .published)
            }
            
            Divider()
            
            Section(header: Text("Order")) {
                sortOrderButton(label: "Ascending", order: .ascending, icon: "arrow.up")
                sortOrderButton(label: "Descending", order: .descending, icon: "arrow.down")
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
    
    private func sortOptionButton(label: String, option: SortOption) -> some View {
        Button(action: { viewModel.sortOption = option }) {
            HStack {
                Text(label)
                Spacer()
                if viewModel.sortOption == option {
                    Image(systemName: "checkmark")
                }
            }
        }
    }
    
    private func sortOrderButton(label: String, order: SortOrder, icon: String) -> some View {
        Button(action: { viewModel.sortOrder = order }) {
            HStack {
                Text(label)
                Spacer()
                if viewModel.sortOrder == order {
                    Image(systemName: icon)
                }
            }
        }
    }
}
