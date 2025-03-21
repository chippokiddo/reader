import SwiftUI

// MARK: - Quote Background Styles
enum QuoteBackgroundStyle: String, CaseIterable, Identifiable {
    case light
    case sepia
    case dark
    
    var id: String { self.rawValue }
    
    var backgroundColor: Color {
        switch self {
        case .light: return Color.white
        case .sepia: return Color(red: 249/255, green: 241/255, blue: 228/255)
        case .dark: return Color(white: 0.1)
        }
    }
    
    var quoteTextColor: Color {
        switch self {
        case .light, .sepia: return Color.black
        case .dark: return Color.white
        }
    }
    
    var attributionTextColor: Color {
        switch self {
        case .light, .sepia: return Color.gray
        case .dark: return Color(white: 0.8)
        }
    }
    
    var bookAuthorColor: Color {
        switch self {
        case .light, .sepia: return Color.black
        case .dark: return Color.white
        }
    }
    
    var bookTitleColor: Color {
        switch self {
        case .light, .sepia: return Color.gray
        case .dark: return Color(white: 0.8)
        }
    }
    
    var iconName: String {
        switch self {
        case .light: return "sun.max"
        case .sepia: return "book.closed"
        case .dark: return "moon"
        }
    }
}

// MARK: - Quote Card
struct QuoteCard: View {
    let quote: String
    let attribution: String?
    let book: BookData
    let style: QuoteBackgroundStyle
    var fixedSize: CGSize?
    
    var body: some View {
        ZStack {
            style.backgroundColor
            
            VStack(alignment: .leading, spacing: 0) {
                Image(systemName: "quote.opening")
                    .font(.system(size: 24))
                    .foregroundColor(style.quoteTextColor.opacity(0.3))
                    .padding(.bottom, fixedSize != nil ? 4 : 1)
                    .padding(.leading, 17)
                
                VStack(alignment: .leading, spacing: 16) {
                    quoteTextView
                    bookInfoView
                }
                .padding(.all, 24)
                .frame(width: fixedSize?.width ?? 500)
            }
            .padding(.top, 20)
        }
        .frame(width: fixedSize?.width ?? 500, height: fixedSize?.height)
        .transition(.opacity)
        .id(style)
    }
    
    private var quoteTextView: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(quote)
                .font(.custom("Merriweather-Regular", size: 18))
                .foregroundColor(style.quoteTextColor)
                .lineSpacing(7)
                .fixedSize(horizontal: false, vertical: true)
                .padding(.leading, 16)
                .frame(width: (fixedSize?.width ?? 500) - 48, alignment: .leading)
            
            if let attribution = attribution, !attribution.isEmpty {
                Text("— \(attribution)")
                    .font(.custom("Merriweather-Italic", size: 16))
                    .foregroundColor(style.attributionTextColor)
                    .padding(.leading, 16)
                    .frame(width: (fixedSize?.width ?? 500) - 48, alignment: .leading)
            }
        }
        .overlay(
            Rectangle()
                .fill(style.quoteTextColor.opacity(0.5))
                .frame(width: 3)
            , alignment: .leading
        )
    }
    
    private var bookInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(book.author)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(style.bookAuthorColor)
            
            Text(book.title)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(style.bookTitleColor)
        }
        .frame(width: (fixedSize?.width ?? 500) - 48, alignment: .leading)
    }
}
