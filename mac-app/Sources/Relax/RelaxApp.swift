import SwiftUI

@main
struct RelaxApp: App {
    @StateObject private var monitor = WorkMonitor()

    var body: some Scene {
        MenuBarExtra {
            MenuContents(monitor: monitor)
        } label: {
            if WorkMonitor.isTestBuild {
                // Show a tiny "TEST" tag next to the icon so a side‑by‑side
                // test build is obvious in the menu bar.
                Label("TEST", systemImage: monitor.iconName)
            } else {
                Image(systemName: monitor.iconName)
            }
        }
        .menuBarExtraStyle(.menu)
    }
}
