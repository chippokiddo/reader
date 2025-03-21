import SwiftUI

struct ReadingTrendsView: View {
    @State private var timeScale: Int = 0 // 0: This Year, 1: All Time
    let books: [BookData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .center, spacing: 8) {
                DashboardSectionHeader("Reading Trends")
                
                Spacer()
                
                Picker("Time Scale", selection: $timeScale) {
                    Text("This Year").tag(0)
                    Text("All Time").tag(1)
                }
                .pickerStyle(SegmentedPickerStyle())
                .labelsHidden()
                .frame(width: 150)
            }
            
            if let streakText = readingStreakText {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(nsColor: NSColor.systemOrange))
                    
                    Text(streakText)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.vertical, 4)
            }
            
            Divider()
                .padding(.vertical, 4)
            
            trendMetricsRow
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: Color.black.opacity(0.07), radius: 2, x: 0, y: 1)
        )
    }
    
    private var trendMetricsRow: some View {
        let yearlyComparison = BookStatisticsService.getBooksReadYearlyComparison(books: books)
        let currentMonth = Calendar.current.component(.month, from: Date())
        let averageBooksPerMonth = yearlyComparison.current > 0
        ? Double(yearlyComparison.current) / Double(currentMonth)
        : 0
        let currentYear = Calendar.current.component(.year, from: Date())
        let remainingMonths = 12 - currentMonth
        let projectedTotal = Double(yearlyComparison.current) + (averageBooksPerMonth * Double(remainingMonths))
        
        return HStack(spacing: 24) {
            TrendMetricView(
                title: "Monthly Average",
                value: String(format: "%.1f", averageBooksPerMonth),
                unit: averageBooksPerMonth == 1.0 ? "book" : "books",
                icon: "chart.xyaxis.line"
            )
            
            Divider().frame(height: 40)
            
            TrendMetricView(
                title: "This Year",
                value: "\(yearlyComparison.current)",
                unit: yearlyComparison.current == 1 ? "book" : "books",
                icon: "calendar"
            )
            
            if yearlyComparison.previous > 0 {
                Divider().frame(height: 40)
                
                TrendMetricView(
                    title: "Last Year",
                    value: "\(yearlyComparison.previous)",
                    unit: yearlyComparison.previous == 1 ? "book" : "books",
                    icon: "calendar.badge.clock"
                )
            }
            
            Divider().frame(height: 40)
            
            TrendMetricView(
                title: "Projected \(currentYear)",
                value: String(format: "%.0f", projectedTotal),
                unit: projectedTotal == 1.0 ? "book" : "books",
                icon: "chart.line.uptrend.xyaxis",
                color: Color(nsColor: NSColor.systemBlue)
            )
        }
    }
    
    private var readingStreakText: String? {
        let details = calculateReadingStreakDetails(books: books)
        let streakMonths = details.streakMonths
        let booksCount = details.booksCount
        return streakMonths > 0
            ? "You've read \(booksCount) \(booksCount == 1 ? "book" : "books") in \(streakMonths) consecutive \(streakMonths == 1 ? "month" : "months")!"
            : nil
    }
    
    private func calculateReadingStreakDetails(books: [BookData]) -> (streakMonths: Int, booksCount: Int) {
        return BookStatisticsService.getLongestStreak(books: books)
    }
}
