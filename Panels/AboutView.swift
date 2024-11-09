import SwiftUI
import Foundation

struct AboutView: View {
    var body: some View {
        VStack(spacing: 20) {
            // App Icon
            Image(nsImage: NSApp.applicationIconImage)
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(RoundedRectangle(cornerRadius: 16))

            Text("reader")
                .font(.title)
                .bold()
            
            Text("Version \(Bundle.main.appVersion)")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Text("Copyright © 2024 chip")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Buttons
            HStack(spacing: 20) {
                // Common button style
                let buttonBackground = Color.blue.opacity(0.1)
                let buttonCornerRadius: CGFloat = 8

                // GitHub Button
                Link(destination: URL(string: "https://github.com/chippokiddo/reader")!) {
                    Label("GitHub", systemImage: "link")
                        .padding(10)
                        .background(buttonBackground)
                        .cornerRadius(buttonCornerRadius)
                }

                // Support Button
                Link(destination: URL(string: "https://www.buymeacoffee.com/chippo")!) {
                    Label("Support", systemImage: "heart.fill")
                        .padding(10)
                        .background(buttonBackground)
                        .cornerRadius(buttonCornerRadius)
                }
            }
        }
        .padding(40)
        .frame(width: 300, height: 300)
    }
}

extension Bundle {
    var appVersion: String {
        return infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
}
