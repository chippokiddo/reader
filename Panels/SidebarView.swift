import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: ContentViewModel

    var body: some View {
        List(selection: $viewModel.selectedStatus) {
            ForEach(StatusFilter.allCases) { status in
                StatusButton(
                    status: status,
                    selectedStatus: $viewModel.selectedStatus,
                    count: viewModel.bookCount(for: status)
                )
                .listRowBackground(backgroundForStatus(status))
            }
        }
        .listStyle(.sidebar)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [Color(nsColor: .windowBackgroundColor), Color.gray.opacity(0.1)]),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private func backgroundForStatus(_ status: StatusFilter) -> Color {
        viewModel.selectedStatus == status ? Color.accentColor.opacity(0.15) : .clear
    }
}

struct StatusButton: View {
    let status: StatusFilter
    @Binding var selectedStatus: StatusFilter
    let count: Int

    var body: some View {
        Button(action: { handleStatusSelection() }) {
            HStack {
                statusIcon
                statusText
                Spacer()
                statusCount
            }
            .padding(.vertical, 6)
        }
        .buttonStyle(.plain)
    }

    private func handleStatusSelection() {
        withAnimation {
            selectedStatus = status
        }
    }
    
    private var statusIcon: some View {
        Image(systemName: status.iconName)
            .foregroundColor(selectedStatus == status ? .accentColor : .primary)
    }
    
    private var statusText: some View {
        Text(status.rawValue)
            .font(.body)
            .fontWeight(selectedStatus == status ? .semibold : .regular)
    }
    
    private var statusCount: some View {
        Text("\(count)")
            .font(.footnote)
            .foregroundColor(.secondary)
    }
}
