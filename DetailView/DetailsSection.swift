import SwiftUI

struct DetailsSection: View {
    @Binding var title: String
    @Binding var author: String
    @Binding var genre: String
    @Binding var series: String
    @Binding var isbn: String
    @Binding var publisher: String
    @Binding var month: String
    @Binding var day: String
    @Binding var year: String
    @Binding var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 24, weight: .bold))
            
            Text("by \(author)")
                .font(.system(size: 16))
                .foregroundColor(.secondary)
            
            if !genre.isEmpty {
                Text("Genre: \(genre)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !series.isEmpty {
                Text("Series: \(series)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !isbn.isEmpty {
                Text("ISBN: \(isbn)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !publisher.isEmpty {
                Text("Publisher: \(publisher)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            if !month.isEmpty, !day.isEmpty, !year.isEmpty {
                Text("Published: \(month)/\(day)/\(year)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }
            
            if !description.isEmpty {  // Display description if not empty
                Text(description)
                    .font(.body)
                    .foregroundColor(.primary)
                    .padding(.top, 10)
            }
        }
    }
}
