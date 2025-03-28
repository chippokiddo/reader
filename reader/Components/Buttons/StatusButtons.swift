import SwiftUI
import Combine

// MARK: - Book Status Buttons
struct StatusButtons: View {
    @State private var cancellables = Set<AnyCancellable>()
    
    let books: [BookData]
    let dataManager: DataManager
    
    var body: some View {
        Button(action: {
            updateStatus(for: .unread, label: "Unread")
        }) {
            Label("Unread", systemImage: "book.closed")
        }
        .help("Mark as Unread")
        .accessibilityLabel("Mark as Unread")
        
        Button(action: {
            updateStatus(for: .reading, label: "Reading")
        }) {
            Label("Reading", systemImage: "book")
        }
        .help("Mark as Reading")
        .accessibilityLabel("Mark as Reading")
        
        Button(action: {
            updateStatus(for: .read, label: "Read")
        }) {
            Label("Read", systemImage: "checkmark.circle")
        }
        .help("Mark as Read")
        .accessibilityLabel("Mark as Read")
    }
    
    // MARK: - UI Feedback
    private func updateStatus(for status: ReadingStatus, label: String) {
        for book in books {
            dataManager.updateBookStatus(book, to: status)
                .sink(receiveValue: { _ in })
                .store(in: &cancellables)
        }
    }
}
