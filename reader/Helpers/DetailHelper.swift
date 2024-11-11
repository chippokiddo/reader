import SwiftUI
import SwiftData

struct DetailHelper {
    struct BookDetails {
        var title: String
        var author: String
        var genre: String
        var series: String
        var isbn: String
        var publisher: String
        var status: ReadingStatus
        var month: String
        var day: String
        var year: String
    }
    
    // Load current book details
    static func loadCurrentValues(for book: BookData) -> BookDetails {
        var details = BookDetails(
            title: book.title,
            author: book.author,
            genre: book.genre ?? "",
            series: book.series ?? "",
            isbn: book.isbn ?? "",
            publisher: book.publisher ?? "",
            status: book.status,
            month: "",
            day: "",
            year: ""
        )

        if let publishedDate = book.published {
            let components = Calendar.current.dateComponents([.month, .day, .year], from: publishedDate)
            details.month = String(format: "%02d", components.month ?? 1)
            details.day = String(format: "%02d", components.day ?? 1)
            details.year = String(components.year ?? 2023)
        }

        return details
    }
    
    // Date formatting
    static func formattedMonth(from book: BookData) -> String {
        if let month = Calendar.current.dateComponents([.month], from: book.published ?? Date()).month {
            return String(format: "%02d", month)
        }
        return ""
    }

    static func formattedDay(from book: BookData) -> String {
        if let day = Calendar.current.dateComponents([.day], from: book.published ?? Date()).day {
            return String(format: "%02d", day)
        }
        return ""
    }

    static func formattedYear(from book: BookData) -> String {
        if let year = Calendar.current.dateComponents([.year], from: book.published ?? Date()).year {
            return String(year)
        }
        return ""
    }
}
