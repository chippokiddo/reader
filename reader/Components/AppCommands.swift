import SwiftUI

struct AppCommands {
    @MainActor static func fileCommands(openWindow: @escaping (String) -> Void) -> some Commands {
        CommandGroup(replacing: .newItem) {
            Button("Add Book") {
                openWindow("addBookWindow")
            }
            .keyboardShortcut("n", modifiers: .command)
        }
    }
    
    @MainActor static func appInfoCommands(appState: AppState) -> some Commands {
        CommandGroup(after: .appInfo) {
            Button("Check for Updates") {
                appState.checkForAppUpdates(isUserInitiated: true)
            }
            .disabled(appState.isCheckingForUpdates)
        }
    }
    
    static func settingsCommands(appState: AppState) -> some Commands {
        CommandGroup(replacing: .appSettings) {
            Button("Preferences...") {
                readerApp.showSettingsWindow(appState: appState) {
                    appState.checkForAppUpdates(isUserInitiated: true)
                }
            }
            .keyboardShortcut(",", modifiers: .command)
        }
    }
    
    @MainActor static func deleteCommands(appState: AppState, viewModel: ContentViewModel) -> some Commands {
        CommandGroup(replacing: CommandGroupPlacement.pasteboard) {
            // Soft Delete
            Button("Delete") {
                if let selectedBook = viewModel.selectedBook {
                    appState.showSoftDeleteConfirmation(for: selectedBook)
                }
            }
            .keyboardShortcut(.delete, modifiers: [])
            .disabled(viewModel.selectedBook == nil)
            
            // Permanent Delete
            Button("Permanently Delete") {
                if let selectedBook = viewModel.selectedBook {
                    appState.showPermanentDeleteConfirmation(for: selectedBook)
                }
            }
            .keyboardShortcut(.delete, modifiers: .command)
            .disabled(viewModel.selectedBook == nil)
        }
    }
}
