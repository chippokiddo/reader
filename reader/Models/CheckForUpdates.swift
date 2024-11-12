import Foundation
import AppKit

struct GitHubRelease: Decodable {
    let tagName: String
    let assets: [Asset]
    
    private enum CodingKeys: String, CodingKey {
        case tagName = "tag_name"
        case assets
    }
    
    struct Asset: Decodable {
        let browserDownloadURL: URL
        
        private enum CodingKeys: String, CodingKey {
            case browserDownloadURL = "browser_download_url"
        }
    }
}

// Async function to fetch the latest release information from GitHub
func fetchLatestRelease() async throws -> (String, URL) {
    let url = URL(string: "https://api.github.com/repos/chippokiddo/reader/releases/latest")!
    var request = URLRequest(url: url)
    request.addValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
    
    // Perform the network request
    let (data, _) = try await URLSession.shared.data(for: request)
    
    // Decode the JSON response
    let release = try JSONDecoder().decode(GitHubRelease.self, from: data)
    
    // Ensure there’s at least one asset (e.g., .zip or .dmg file)
    guard let downloadURL = release.assets.first?.browserDownloadURL else {
        throw NSError(domain: "No assets available", code: 0, userInfo: nil)
    }
    
    return (release.tagName, downloadURL)
}

// Function to download the update
func downloadUpdate(from url: URL) async throws -> URL {
    let (tempLocalUrl, _) = try await URLSession.shared.download(from: url)
    return tempLocalUrl
}

// Unzips a file using Process (CLI) for compatibility
func unzipFile(at sourceURL: URL, to destinationURL: URL) throws {
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
    process.arguments = [sourceURL.path, "-d", destinationURL.path]
    try process.run()
    process.waitUntilExit()
}

// Function to replace the current app with the downloaded one
func replaceAppBundle(with newAppURL: URL) throws {
    let fileManager = FileManager.default
    let currentAppPath = Bundle.main.bundleURL
    
    // Move the current app to Trash
    let trashURL = fileManager.urls(for: .trashDirectory, in: .userDomainMask).first!
    let movedAppURL = trashURL.appendingPathComponent(currentAppPath.lastPathComponent)
    try fileManager.moveItem(at: currentAppPath, to: movedAppURL)
    
    // Move the new app into Applications
    let applicationsURL = URL(fileURLWithPath: "/Applications")
    let destinationURL = applicationsURL.appendingPathComponent(newAppURL.lastPathComponent)
    try fileManager.moveItem(at: newAppURL, to: destinationURL)
}

// Function to relaunch the app, marked as @MainActor to handle main-thread interactions
@MainActor
func relaunchApp(at appURL: URL) throws {
    let process = Process()
    process.executableURL = appURL.appendingPathComponent("Contents/MacOS/YourAppExecutableName") // Replace with the actual executable name
    try process.run()
    NSApp.terminate(nil)
}

// Main function to check for updates, now prompting the user if an update is available
func checkForUpdates() {
    Task { @MainActor in
        do {
            let (latestVersion, downloadURL) = try await fetchLatestRelease()
            let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
            
            if currentVersion != latestVersion {
                print("Update available!")
                
                let userWantsToUpdate = await promptForUpdate(latestVersion: latestVersion)
                
                if userWantsToUpdate {
                    print("User opted to update.")
                    
                    let zipURL = try await downloadUpdate(from: downloadURL)
                    let tempDirectory = FileManager.default.temporaryDirectory
                    let unzipDestination = tempDirectory.appendingPathComponent("UpdatedApp")
                    try unzipFile(at: zipURL, to: unzipDestination)
                    
                    let newAppURL = unzipDestination.appendingPathComponent("reader.app")
                    try replaceAppBundle(with: newAppURL)
                    
                    // Relaunch the app on the main thread without await
                    try relaunchApp(at: newAppURL)
                    
                } else {
                    print("User declined the update.")
                }
            } else {
                print("Already up-to-date.")
            }
        } catch {
            print("Failed to check or perform update:", error)
        }
    }
}

// Function to prompt the user for an update, now marked as async and @MainActor
@MainActor
func promptForUpdate(latestVersion: String) async -> Bool {
    let alert = NSAlert()
    alert.messageText = "New Update Available"
    alert.informativeText = "reader \(latestVersion) is available. Would you like to update?"
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Update")
    alert.addButton(withTitle: "Cancel")
    
    let response = alert.runModal()
    return response == .alertFirstButtonReturn // Returns true if "Update" is clicked
}
