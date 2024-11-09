import SwiftUI

struct AddButtons: View {
    let onCancel: () -> Void
    let onSave: () -> Void
    let isSaveDisabled: Bool

    var body: some View {
        HStack {
            Spacer()
            
            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
            
            Button("Save", action: onSave)
                .buttonStyle(.borderedProminent)
                .disabled(isSaveDisabled)
                .keyboardShortcut(.defaultAction)
            
            Spacer()
        }
        .padding(.vertical, 10)
    }
}
