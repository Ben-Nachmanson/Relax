import AppKit
import SwiftUI

struct MenuContents: View {
    @ObservedObject var monitor: WorkMonitor

    private let bellChoices = [30, 45, 60, 90, 120]

    var body: some View {
        Text(monitor.statusLine)

        Divider()

        if monitor.isSnoozed {
            Button("End snooze") { monitor.endSnooze() }
        } else {
            Button("Snooze 15 minutes") { monitor.snooze(minutes: 15) }
            Button("Snooze 1 hour")     { monitor.snooze(minutes: 60) }
        }
        Button("Reset timer") { monitor.resetTimer() }

        Divider()

        Menu("Bell every") {
            ForEach(bellChoices, id: \.self) { m in
                Button {
                    monitor.setBellMinutes(m)
                } label: {
                    let prefix = (monitor.bellSeconds / 60 == m) ? "✓ " : "  "
                    Text("\(prefix)\(m) minutes")
                }
            }
        }

        Toggle("Open at login", isOn: Binding(
            get: { monitor.launchAtLoginEnabled },
            set: { monitor.setLaunchAtLogin($0) }
        ))

        Divider()

        Button("About Relax") { showAbout() }
        Button("Quit Relax") { NSApp.terminate(nil) }
            .keyboardShortcut("q")
    }

    private func showAbout() {
        NSApp.activate(ignoringOtherApps: true)
        NSApp.orderFrontStandardAboutPanel(options: [
            .applicationName: "Relax",
            .credits: NSAttributedString(
                string: "Take a 5‑minute break every hour, or hear the gong.\n" +
                        "Inspired by Awareness (iamfutureproof.com).",
                attributes: [.foregroundColor: NSColor.labelColor]
            )
        ])
    }
}
