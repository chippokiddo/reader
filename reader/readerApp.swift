import SwiftUI
import SwiftData

@main
struct ReaderApp: App {
    private static let sharedModelContainer = createModelContainer()

    @StateObject private var appState = AppState()
    @StateObject private var dataManager: DataManager
    @Environment(\.openWindow) private var openWindow

    init() {
        guard let container = ReaderApp.sharedModelContainer else {
            fatalError("ModelContainer is not available.")
        }
        _dataManager = StateObject(wrappedValue: DataManager(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            if let container = ReaderApp.sharedModelContainer {
                ContentView(viewModel: ContentViewModel(dataManager: dataManager))
                    .environmentObject(appState)
                    .environmentObject(dataManager)
                    .environment(\.modelContainer, container)
            } else {
                Text("Failed to initialize data model")
                    .onAppear {
                        print("Warning: ModelContainer failed to initialize.")
                    }
            }
        }
        .commands {
            CommandGroup(replacing: .appInfo) {
                Button("About reader") {
                    openWindow(id: "aboutWindow")
                }
            }
        }

        // Define the About panel with a Window scene
        Window("About reader", id: "aboutWindow") {
            AboutView()
        }
        .windowStyle(HiddenTitleBarWindowStyle()) // Optional: style the window
        .windowResizability(.contentSize)
    }

    private static func createModelContainer() -> ModelContainer? {
        let schema = Schema([BookData.self])
        do {
            return try ModelContainer(for: schema, configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)])
        } catch {
            print("Error: Could not create ModelContainer - \(error)")
            return nil
        }
    }
}
