import SwiftUI
import SwiftData

struct DetailView: View {
    @Bindable var book: BookData
    
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var newQuote: String = ""
    @State private var newNote: String = ""
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                bookDetailsSection
                bookStatusSection
                bookDateInfoSection
                Divider()
                tagsSection
                Divider()
                quotesSection
                Divider()
                notesSection
            }
            .padding()
        }
    }
    
    // MARK: - Subviews
    
    private var bookDetailsSection: some View {
        DetailsSection(
            title: .constant(book.title),
            author: .constant(book.author),
            genre: .constant(book.genre ?? ""),
            series: .constant(book.series ?? ""),
            isbn: .constant(book.isbn ?? ""),
            publisher: .constant(book.publisher ?? ""),
            formattedDate: .constant(formattedDate),
            description: Binding(
                get: { book.bookDescription ?? "" },
                set: { book.bookDescription = $0 }
            )
        )
    }
    
    private var bookStatusSection: some View {
        StatusSection(
            status: Binding<ReadingStatus>(
                get: { book.status },
                set: { newStatus in
                    book.status = newStatus
                    handleStatusChange(newStatus)
                }
            ),
            statusColor: statusColor(for: book.status)
        )
    }
    
    private var bookDateInfoSection: some View {
        VStack(alignment: .leading, spacing: 5) {
            if let dateStarted = book.dateStarted {
                dateTextView(label: "Date Started", date: dateStarted)
            }
            
            if let dateFinished = book.dateFinished {
                dateTextView(label: "Date Finished", date: dateFinished)
            }
        }
    }
    
    private func dateTextView(label: String, date: Date) -> some View {
        Text("\(label): \(formattedDate(date))")
            .font(.subheadline)
            .foregroundColor(.secondary)
    }
    
    private var tagsSection: some View {
        TagsSection(book: book)
    }
    
    private var quotesSection: some View {
        QuotesSection(
            book: book,
            newQuote: $newQuote,
            modelContext: modelContext
        )
    }
    
    private var notesSection: some View {
        NotesSection(
            book: book,
            newNote: $newNote,
            modelContext: modelContext
        )
    }
    
    // MARK: - Helper Methods
    
    private var formattedDate: String {
        guard let published = book.published else { return "" }

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // User's locale preferences
        dateFormatter.timeStyle = .none  // Only show the date

        return dateFormatter.string(from: published)
    }
    
    private func handleStatusChange(_ newStatus: ReadingStatus) {
        DispatchQueue.main.async {
            updateBookDates(for: newStatus)
            saveBookStatusChange()
        }
    }
    
    private func statusColor(for status: ReadingStatus) -> Color {
        switch status {
        case .unread: return .gray
        case .reading: return .blue
        case .read: return .green
        case .deleted: return .red
        }
    }
    
    private func updateBookDates(for newStatus: ReadingStatus) {
        switch newStatus {
        case .unread:
            book.dateStarted = nil
            book.dateFinished = nil
        case .reading:
            book.dateStarted = book.dateStarted ?? Date()
            book.dateFinished = nil
        case .read:
            if book.dateStarted == nil {
                book.dateStarted = Date()
            }
            book.dateFinished = Date()
        case .deleted:
            book.dateStarted = nil
            book.dateFinished = nil
        }
    }
    
    private func saveBookStatusChange() {
        do {
            try modelContext.save()
            print("Book status change saved successfully.")
        } catch {
            print("Failed to save book status change: \(error)")
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
