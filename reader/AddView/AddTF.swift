import SwiftUI

struct AddTF: View {
    let label: String
    @Binding var text: String
    let placeholder: String?
    var labelWidth: CGFloat = 100 // Default width for alignment

    var body: some View {
        HStack {
            Text(label)
                .frame(width: labelWidth, alignment: .leading)
            TextField(placeholder ?? "", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}
