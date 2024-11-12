import SwiftUI
import SwiftData

@main
struct readerApp: App {
    private static let sharedModelContainer = createModelContainer()

    @StateObject private var appState = AppState()
    @StateObject private var dataManager: DataManager
    @Environment(\.openWindow) private var openWindow

    // State variables for the update functionality
    @State private var isCheckingForUpdates = false
    @State private var updateMessage: String? = nil
    @State private var showUpdatePrompt = false
    @State private var showUpToDateAlert = false
    @State private var latestVersion: String = ""
    @State private var downloadURL: URL?
    
    init() {
        guard let container = readerApp.sharedModelContainer else {
            fatalError("ModelContainer is not available.")
        }
        _dataManager = StateObject(wrappedValue: DataManager(modelContainer: container))
    }

    var body: some Scene {
        WindowGroup {
            if let container = readerApp.sharedModelContainer {
                ContentView(viewModel: ContentViewModel(dataManager: dataManager))
                    .environmentObject(appState)
                    .environmentObject(dataManager)
                    .environment(\.modelContainer, container)
                    .alert(isPresented: $showUpdatePrompt) {
                        Alert(
                            title: Text("New Version Available"),
                            message: Text("Version \(latestVersion) is available. Would you like to download and install it?"),
                            primaryButton: .default(Text("Update"), action: {
                                if let downloadURL = downloadURL {
                                    downloadAndInstallUpdate(from: downloadURL)
                                }
                            }),
                            secondaryButton: .cancel(Text("Later"))
                        )
                    }
                    .alert(isPresented: $showUpToDateAlert) {
                         Alert(
                             title: Text("No Updates Available"),
                             message: Text("You are already on the latest version."),
                             dismissButton: .default(Text("OK"))
                         )
                     }
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
            CommandGroup(after: .appInfo) {
                Button("Check for updates") {
                    checkForAppUpdates()
                }
            }
        }

        // Define the About panel with a Window scene
        Window("About reader", id: "aboutWindow") {
            AboutView()
        }
        .windowStyle(HiddenTitleBarWindowStyle())
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
    
    // Function to check for updates, showing an alert with the update status
    private func checkForAppUpdates() {
        isCheckingForUpdates = true

        Task {
            do {
                let (latestVersionFound, downloadURLFound) = try await fetchLatestRelease()
                let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"

                if isNewerVersion(latestVersionFound, than: currentVersion) {
                    latestVersion = latestVersionFound
                    downloadURL = downloadURLFound
                    showUpdatePrompt = true
                } else {
                    // Set showUpToDateAlert to true to trigger the "up-to-date" alert
                    showUpToDateAlert = true
                }
            } catch {
                print("Failed to check for updates: \(error.localizedDescription)")
            }

            isCheckingForUpdates = false
        }
    }
    
    // Helper function to compare version strings
    func isNewerVersion(_ newVersion: String, than currentVersion: String) -> Bool {
        let newComponents = newVersion.split(separator: ".").compactMap { Int($0) }
        let currentComponents = currentVersion.split(separator: ".").compactMap { Int($0) }

        for (new, current) in zip(newComponents, currentComponents) {
            if new > current {
                return true // newVersion is greater
            } else if new < current {
                return false // newVersion is not greater
            }
        }

        // If all components so far are equal, but newVersion has more components (e.g., "2.1.1" vs "2.1")
        return newComponents.count > currentComponents.count
    }

     
     // Function to download and install the update
     private func downloadAndInstallUpdate(from downloadURL: URL) {
         Task {
             do {
                 let zipURL = try await downloadUpdate(from: downloadURL)
                 let tempDirectory = FileManager.default.temporaryDirectory
                 let unzipDestination = tempDirectory.appendingPathComponent("UpdatedApp")
                 try unzipFile(at: zipURL, to: unzipDestination)
                 
                 let newAppURL = unzipDestination.appendingPathComponent("reader.app") // Replace with your app's name
                 try replaceAppBundle(with: newAppURL)
                 
                 // Relaunch the app after installing
                 try relaunchApp(at: newAppURL)
                 
             } catch {
                 print("Failed to download or install update:", error)
             }
         }
     }
}
