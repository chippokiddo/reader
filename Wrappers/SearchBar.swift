import SwiftUI
import AppKit

struct SearchBar: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String = "Search"

    func makeNSView(context: Context) -> NSSearchField {
        let searchField = NSSearchField()
        
        searchField.placeholderString = placeholder
        searchField.font = .systemFont(ofSize: 14)
        searchField.focusRingType = .none
        searchField.bezelStyle = .roundedBezel

        searchField.target = context.coordinator
        searchField.action = #selector(Coordinator.textDidChange(_:))
        
        return searchField
    }

    func updateNSView(_ nsView: NSSearchField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: SearchBar

        init(_ parent: SearchBar) {
            self.parent = parent
        }

        @objc func textDidChange(_ sender: NSSearchField) {
            parent.text = sender.stringValue
        }
    }
}
