import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Export Formats
private enum ExportFormat {
    case json, csv
    
    var utType: UTType {
        switch self {
        case .json: return .json
        case .csv: return .commaSeparatedText
        }
    }
    
    var fileExtension: String {
        switch self {
        case .json: return "json"
        case .csv: return "csv"
        }
    }
}

// MARK: - Manage Data
struct ImportExportView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var dataManager: DataManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var contentViewModel: ContentViewModel
    
    @State private var importError: String?
    @State private var showingImporter = false
    @State private var isExportHovered: Bool = false
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        Form {
            Section {
                HStack {
                    importExportButtons
                }
                .frame(maxWidth: .infinity, alignment: .center)
            }
            
            Section {
                autoDeleteToggleRow
                
                if contentViewModel.deletionIntervalDays != 0 {
                    deletionIntervalPicker
                }
            }
            
            
            if let error = importError {
                Section {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.callout)
                }
            }
        }
        .formStyle(.grouped)
        .animation(.easeInOut(duration: 0.3), value: contentViewModel.deletionIntervalDays)
        .onDisappear {
            releaseSettingsWindowResources()
            cancellables.removeAll()
        }
    }
    
    // MARK: - Import/Export Buttons
    private var importExportButtons: some View {
        HStack(spacing: 12) {
            // Import Button
            AboutButtons(
                title: "Import Books...",
                systemImage: "square.and.arrow.down",
                action: { showingImporter = true }
            )
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: [.json, .commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleImport(result: result)
            }
            
            // Export Menu
            Menu {
                Button("JSON") { handleExport(format: .json) }
                Button("CSV") { handleExport(format: .csv) }
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.primary)
                    Text("Export Books...")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "chevron.down")
                        .foregroundColor(.primary)
                        .font(.system(size: 12))
                        .padding(.leading, -5)
                }
                .font(.callout)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(isExportHovered ? .gray.opacity(0.2) : .gray.opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isExportHovered ? .gray : .clear, lineWidth: 1)
                )
                .animation(.easeInOut(duration: 0.2), value: isExportHovered)
                .frame(width: 150)
            }
            .buttonStyle(.plain)
            .onHover { hovering in
                isExportHovered = hovering
            }
        }
    }
    
    // MARK: - Auto-delete Toggle
    private var autoDeleteToggleRow: some View {
        Toggle(isOn: Binding<Bool>(
            get: { contentViewModel.deletionIntervalDays != 0 },
            set: { newValue in
                contentViewModel.deletionIntervalDays = newValue ? 7 : 0
            }
        )) {
            Label {
                Text("Auto-delete Books")
            } icon: {
                Image(systemName: "trash")
                    .symbolVariant(.circle.fill)
                    .foregroundStyle(.red)
            }
        }
    }
    
    // MARK: - Auto-delete Interval
    private var deletionIntervalPicker: some View {
        Picker("Delete After", selection: $contentViewModel.deletionIntervalDays) {
            Text("7 days").tag(7)
            Text("14 days").tag(14)
            Text("30 days").tag(30)
        }
        .pickerStyle(.segmented)
        .padding(.vertical, 6)
        .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    // MARK: - Import Functions
    private func handleImport(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let url = urls.first else { return }

            let fileExtension = url.pathExtension.lowercased()

            let importPublisher: AnyPublisher<Void, Error>? = {
                switch fileExtension {
                case "json":
                    return dataManager.importBooks(from: url)
                case "csv":
                    return dataManager.importBooksFromCSV(from: url)
                default:
                    return nil
                }
            }()

            guard let publisher = importPublisher else {
                importError = "Unsupported file format. Please use JSON or CSV."
                return
            }

            publisher
                .sink(receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        self.importError = "Import error: \(error.localizedDescription)"
                    }
                }, receiveValue: {
                    self.handleImportResult(.success(()))
                })
                .store(in: &cancellables)

        case .failure(let error):
            importError = "File selection error: \(error.localizedDescription)"
        }
    }
    
    private func handleImportResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            appState.alertManager?.showImportSuccess()
        case .failure(let error):
            importError = "Import failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Export Functions
    private func handleExport(format: ExportFormat) {
        let panel = NSSavePanel()
        panel.allowedContentTypes = [format.utType]
        panel.nameFieldStringValue = "books-\(DateFormatterUtils.currentDateString()).\(format.fileExtension)"

        guard panel.runModal() == .OK, let url = panel.url else { return }

        let exportPublisher: AnyPublisher<Void, Error> = {
            switch format {
            case .json:
                return dataManager.exportBooks(to: url)
            case .csv:
                return dataManager.exportBooksToCSV(to: url)
            }
        }()

        exportPublisher
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.handleExportResult(.failure(error))
                }
            }, receiveValue: {
                self.handleExportResult(.success(()))
            })
            .store(in: &cancellables)
    }
    
    private func handleExportResult(_ result: Result<Void, Error>) {
        switch result {
        case .success:
            appState.alertManager?.showExportSuccess()
        case .failure(let error):
            importError = "Export failed: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Resource Cleanup
    private func releaseSettingsWindowResources() {
        appState.cleanupPreferencesCache()
    }
}
