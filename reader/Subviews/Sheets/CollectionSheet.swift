import SwiftUI

// MARK: - Collection Sheet Modes
enum CollectionSheetMode {
    case add
    case rename
    
    var title: String {
        switch self {
        case .add: return "Add New Collection"
        case .rename: return "Rename Collection"
        }
    }
    
    var iconName: String {
        switch self {
        case .add: return "folder.badge.plus"
        case .rename: return "folder"
        }
    }
    
    var actionButtonText: String {
        switch self {
        case .add: return "Add"
        case .rename: return "Save"
        }
    }
}

// MARK: - Collection Sheet
struct CollectionSheet: View {
    @Binding var collectionName: String
    
    @State private var errorMessage: String?
    @State private var typingTimer: Timer?
    
    let mode: CollectionSheetMode
    
    var existingCollectionNames: [String]
    var originalName: String? // Only used in rename mode
    var onAction: () -> Void
    var onCancel: () -> Void
    
    init(mode: CollectionSheetMode,
         collectionName: Binding<String>,
         existingCollectionNames: [String],
         originalName: String? = nil,
         onAction: @escaping () -> Void,
         onCancel: @escaping () -> Void) {
        self.mode = mode
        self._collectionName = collectionName
        self.existingCollectionNames = existingCollectionNames
        self.originalName = originalName
        self.onAction = onAction
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: 0) {
            headerView
            
            Divider()
                .padding(.horizontal)
                .padding(.bottom, 12)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Collection Name")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: mode.iconName)
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                    
                    TextField("Enter name", text: $collectionName)
                        .font(.system(size: 14))
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: collectionName) {
                            typingTimer?.invalidate()
                            typingTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { _ in
                                DispatchQueue.main.async {
                                    _ = validateName()
                                }
                            }
                        }
                        .onSubmit {
                            if validateName() {
                                onAction()
                            }
                        }
                }
                
                if let errorMessage = errorMessage {
                    validationMessageView(message: errorMessage)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .padding(.horizontal, 20)
            .animation(.spring(duration: 0.3), value: errorMessage)
            
            Spacer(minLength: 20)
            
            actionButtonsView
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
        }
        .frame(width: 350, height: 225)
        .background(.windowBackground)
        .cornerRadius(12)
    }
    
    private var headerView: some View {
        HStack {
            Text(mode.title)
                .font(.title3)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 25)
        .padding(.bottom, 14)
    }
    
    private func validationMessageView(message: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: "exclamationmark.circle")
                .foregroundColor(.yellow)
            
            Text(message)
                .foregroundColor(.primary.opacity(0.8))
            
            Spacer()
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.yellow.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.yellow.opacity(0.3), lineWidth: 0.5)
                )
        )
    }
    
    private var actionButtonsView: some View {
        HStack {
            Button(action: {
                onCancel()
            }) {
                Text("Cancel")
                    .foregroundColor(.primary)
                    .frame(minWidth: 80)
            }
            .buttonStyle(.bordered)
            .controlSize(.regular)
            .keyboardShortcut(.cancelAction)
            
            Spacer()
            
            Button(action: {
                if validateName() {
                    onAction()
                }
            }) {
                Text(mode.actionButtonText)
                    .frame(minWidth: 80)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.regular)
            .keyboardShortcut(.defaultAction)
            .disabled(errorMessage != nil || collectionName.isEmpty)
        }
    }
    
    // MARK: - Validation
    private func validateName() -> Bool {
        if collectionName.isEmpty {
            errorMessage = "Name cannot be empty"
            return false
        }
        else if let originalName = originalName, collectionName.lowercased() == originalName.lowercased() {
            // In rename mode, allow the original name
            errorMessage = nil
            return true
        }
        else if existingCollectionNames.contains(where: { $0.lowercased() == collectionName.lowercased() }) {
            errorMessage = "A collection with this name already exists"
            return false
        }
        else {
            errorMessage = nil
            return true
        }
    }
}
