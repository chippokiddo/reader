import SwiftUI
import SwiftData

struct QuotesSection: View {
    @Bindable var book: BookData
    @Binding var newQuote: String
    @State private var newPageNumber: String = ""
    @State private var isEditing: Bool = false
    @State private var isAddingQuote: Bool = false
    @State private var isCollapsed: Bool = false
    var modelContext: ModelContext

    // Computed property to work with quotes as an array
    private var quotesArray: [String] {
        book.quotes.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Collapsible toggle icon
                Button(action: { isCollapsed.toggle() }) {
                    HStack {
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                            .font(.body)
                        Text("Quotes")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(isEditing ? "Done" : "Edit") {
                    withAnimation { isEditing.toggle() }
                }
                .buttonStyle(LinkButtonStyle())
                .disabled(book.status == .deleted)
            }
            .padding(.bottom, 4)
            
            // Display quotes if not collapsed
            if !isCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(quotesArray, id: \.self) { quote in
                        let components = quote.components(separatedBy: " [p. ")
                        let text = components.first ?? quote
                        let pageNumber = components.count > 1 ? components.last?.replacingOccurrences(of: "]", with: "") : nil
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                // Quote text
                                Text("“\(text)”")
                                    .font(.body)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                                
                                Spacer()
                                
                                // Page number
                                if let page = pageNumber, !page.isEmpty {
                                    Text("p. \(page)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }

                                if isEditing {
                                    Button(action: { withAnimation { removeQuote(quote) } }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                    .transition(.opacity)
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        
                        if quotesArray.last != quote {
                            Divider().padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.bottom, isEditing ? 6 : 0)
                
                // Add quote button
                if isAddingQuote {
                    addQuoteForm
                        .transition(.opacity.combined(with: .move(edge: .bottom)))
                } else {
                    Button(action: { withAnimation { isAddingQuote = true } }) {
                        Label("Add Quote", systemImage: "plus.circle")
                            .font(.callout)
                            .foregroundColor(.accentColor)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .padding(.top, 6)
                    .disabled(book.status == .deleted)
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.windowBackgroundColor))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.25), value: isEditing)
    }
    
    // MARK: Quote form
    private var addQuoteForm: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Quote text", text: $newQuote)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(6)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)

                TextField("Page #", text: $newPageNumber)
                    .textFieldStyle(PlainTextFieldStyle())
                    .padding(6)
                    .frame(width: 60)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                    .onChange(of: newPageNumber) { filterNumericInput(newPageNumber) }
            }

            HStack {
                Button("Cancel") {
                    withAnimation { resetAddQuoteForm() }
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 6)

                Button("Save") {
                    withAnimation { saveQuote() }
                }
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor((newQuote.isEmpty || newPageNumber.isEmpty) ? .gray : .accentColor)
                .disabled(newQuote.isEmpty || newPageNumber.isEmpty)
            }
            .padding(.top, 6)
        }
    }

    // MARK: Actions
    private func saveQuote() {
        let formattedQuote = newPageNumber.isEmpty ? newQuote : "\(newQuote) [p. \(newPageNumber)]"
        addQuote(formattedQuote)
        resetAddQuoteForm()
    }

    private func addQuote(_ quote: String) {
        book.quotes = (quotesArray + [quote]).joined(separator: "\n")
        try? modelContext.save()
    }

    private func removeQuote(_ quote: String) {
        book.quotes = quotesArray.filter { $0 != quote }.joined(separator: "\n")
        try? modelContext.save()
    }
    
    private func resetAddQuoteForm() {
        newQuote = ""
        newPageNumber = ""
        isAddingQuote = false
    }
    
    private func filterNumericInput(_ input: String) {
        newPageNumber = input.filter { $0.isNumber }
    }
}
