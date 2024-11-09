import SwiftData
import Foundation

enum ReadingStatus: String {
    case unread
    case reading
    case read
    case deleted
}

@Model
class BookData: Identifiable {
    @Attribute(.unique) var id: UUID = UUID()
    var title: String
    var author: String
    var published: Date?
    var publisher: String?
    var genre: String?
    var series: String?
    var isbn: String?
    var dateStarted: Date?
    var dateFinished: Date?
    var quotes: String
    var notes: String = ""
    var bookDescription: String?

    @Attribute private var statusRawValue: String
    var status: ReadingStatus {
        get { ReadingStatus(rawValue: statusRawValue) ?? .unread }
        set { statusRawValue = newValue.rawValue }
    }

    init(
        title: String,
        author: String,
        published: Date? = nil,
        publisher: String? = nil,
        genre: String? = nil,
        series: String? = nil,
        isbn: String? = nil,
        bookDescription: String? = nil,
        status: ReadingStatus = .unread,
        quotes: String = "",
        notes: String = ""
    ) {
        self.title = title
        self.author = author
        self.published = published
        self.publisher = publisher
        self.genre = genre
        self.series = series
        self.isbn = isbn
        self.bookDescription = bookDescription
        self.statusRawValue = status.rawValue
        self.quotes = quotes
        self.notes = notes
    }

    private func updateDates(for newStatus: ReadingStatus) {
        switch newStatus {
        case .reading:
            if dateStarted == nil { dateStarted = Date() }
            dateFinished = nil
        case .read:
            if dateStarted == nil { dateStarted = Date() }
            dateFinished = Date()
        case .unread, .deleted:
            dateStarted = nil
            dateFinished = nil
        }
    }
}
