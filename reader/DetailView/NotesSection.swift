import SwiftUI
import SwiftData

struct NotesSection: View {
    @Bindable var book: BookData
    @Binding var newNote: String
    @State private var newPageNumber: String = ""
    @State private var isEditing: Bool = false
    @State private var isAddingNote: Bool = false
    @State private var isCollapsed: Bool = false
    var modelContext: ModelContext

    // Computed property to work with notes as an array
    private var notesArray: [String] {
        book.notes.components(separatedBy: "\n").filter { !$0.isEmpty }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Collapsible toggle icon
                Button(action: { isCollapsed.toggle() }) {
                    HStack {
                        Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                            .font(.body)
                        Text("Notes")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                Spacer()
                
                Button(isEditing ? "Done" : "Edit") {
                    isEditing.toggle()
                }
                .buttonStyle(LinkButtonStyle())
                .disabled(book.status == .deleted)
            }
            .padding(.bottom, 4)
            
            // Display notes if not collapsed
            if !isCollapsed {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(notesArray, id: \.self) { note in
                        let components = note.components(separatedBy: " [p. ")
                        let text = components.first ?? note
                        let pageNumber = components.count > 1 ? components.last?.replacingOccurrences(of: "]", with: "") : nil
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack(alignment: .top) {
                                Text(text)
                                    .font(.body)
                                    .padding(10)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)

                                Spacer()
                                
                                if let page = pageNumber, !page.isEmpty {
                                    Text("p. \(page)")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.1))
                                        .cornerRadius(8)
                                }

                                if isEditing {
                                    Button(action: { removeNote(note) }) {
                                        Image(systemName: "minus.circle.fill")
                                            .foregroundColor(.red)
                                    }
                                    .buttonStyle(BorderlessButtonStyle())
                                }
                            }
                        }
                        .padding(.vertical, 6)
                        
                        if notesArray.last != note {
                            Divider().padding(.horizontal, 8)
                        }
                    }
                }
                .padding(.bottom, isEditing ? 6 : 0)

                if isAddingNote {
                    addNoteForm
                } else {
                    Button(action: { isAddingNote = true }) {
                        Label("Add Note", systemImage: "plus.circle")
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
    }
    
    // MARK: Note form
    private var addNoteForm: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                TextField("Note text", text: $newNote)
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
                    resetAddNoteForm()
                }
                .buttonStyle(PlainButtonStyle())
                .padding(.trailing, 6)

                Button("Save") {
                    saveNote()
                }
                .buttonStyle(DefaultButtonStyle())
                .foregroundColor((newNote.isEmpty || newPageNumber.isEmpty) ? .gray : .accentColor)
                .disabled(newNote.isEmpty || newPageNumber.isEmpty)
            }
            .padding(.top, 6)
        }
    }

    // MARK: Actions
    private func saveNote() {
        let formattedNote = newPageNumber.isEmpty ? newNote : "\(newNote) [p. \(newPageNumber)]"
        addNote(formattedNote)
        resetAddNoteForm()
    }

    private func addNote(_ note: String) {
        book.notes = (notesArray + [note]).joined(separator: "\n") // Update notes as a single string
        try? modelContext.save() // Persist changes
    }

    private func removeNote(_ note: String) {
        book.notes = notesArray.filter { $0 != note }.joined(separator: "\n") // Update notes as a single string
        try? modelContext.save() // Persist changes
    }
    
    private func resetAddNoteForm() {
        newNote = ""
        newPageNumber = ""
        isAddingNote = false
    }
    
    private func filterNumericInput(_ input: String) {
        newPageNumber = input.filter { $0.isNumber }
    }
}
