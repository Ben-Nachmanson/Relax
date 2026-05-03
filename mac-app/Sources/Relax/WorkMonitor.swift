import AppKit
import Combine
import CoreGraphics
import Foundation
import ServiceManagement
import SwiftUI

/// Tracks continuous work time and rings a bell when the user has gone too
/// long without a break.
///
/// Logic mirrors the original `main.py`:
///  - if the user has been idle ≥ `breakSeconds` then `workTime` is reset to 0
///    (the user just had a break, or is having one now);
///  - otherwise `workTime` accumulates;
///  - when `workTime` reaches `bellSeconds` we play `bell.mp3` and reset.
///
/// "Idle" is measured against **keyboard activity only** (matches the original
/// Python script which used `pynput.keyboard.Listener`). Mouse moves, scrolls
/// and clicks deliberately do NOT count as "still working" — leaning back to
/// read the screen counts as a break.
///
/// Idle detection uses `CGEventSource.secondsSinceLastEventType` which, unlike
/// `pynput`, does NOT require Accessibility / Input Monitoring permissions.
final class WorkMonitor: ObservableObject {

    // MARK: - User‑configurable settings (persisted in UserDefaults)

#if RELAX_TEST_BUILD
    @AppStorage("breakSeconds") var breakSeconds: Int = 5 * 60
    @AppStorage("bellSeconds")  var bellSeconds:  Int = 60        // 1‑minute bell for testing
    static let isTestBuild = true
#else
    @AppStorage("breakSeconds") var breakSeconds: Int = 5 * 60
    @AppStorage("bellSeconds")  var bellSeconds:  Int = 60 * 60
    static let isTestBuild = false
#endif

    // MARK: - Live state

    @Published private(set) var workTime: TimeInterval = 0
    @Published private(set) var snoozedUntil: Date? = nil

    // MARK: - Internals

#if RELAX_TEST_BUILD
    private let tickInterval: TimeInterval = 5
#else
    private let tickInterval: TimeInterval = 30
#endif
    private var lastTick = Date()
    private var timer: Timer?
    private var sound: NSSound?

    init() {
        FileHandle.standardError.write(Data(
            "[Relax] starting (testBuild=\(Self.isTestBuild), bell=\(bellSeconds)s, break=\(breakSeconds)s, tick=\(Int(tickInterval))s)\n"
            .utf8))
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    // MARK: - Display helpers

    var iconName: String {
        if isSnoozed { return "bell.slash" }
        return "bell"
    }

    var isSnoozed: Bool {
        if let s = snoozedUntil, s > Date() { return true }
        return false
    }

    /// "Worked 23m of 60m" / "Snoozed for 12m" / "Idle"
    var statusLine: String {
        if let s = snoozedUntil, s > Date() {
            let mins = Int((s.timeIntervalSinceNow / 60).rounded(.up))
            return "Snoozed for \(mins)m"
        }
        let workedMin = Int(workTime / 60)
        let totalMin  = bellSeconds / 60
        if workedMin == 0 { return "Idle (bell every \(totalMin)m)" }
        return "Worked \(workedMin)m of \(totalMin)m"
    }

    // MARK: - Timer

    private func startTimer() {
        timer?.invalidate()
        let t = Timer(timeInterval: tickInterval, repeats: true) { [weak self] _ in
            self?.tick()
        }
        // .common so the timer keeps firing while menus / panels are tracking input.
        RunLoop.main.add(t, forMode: .common)
        timer = t
    }

    private func tick() {
        let now = Date()
        let elapsed = now.timeIntervalSince(lastTick)
        lastTick = now

        // Skip accumulation while snoozed.
        if let s = snoozedUntil {
            if s > now {
                workTime = 0
                return
            } else {
                // Snooze just expired — clear the marker so the icon updates.
                snoozedUntil = nil
            }
        }

        let idle = systemIdleSeconds()

        if idle >= TimeInterval(breakSeconds) {
            // The user has been (or is currently) idle long enough to count as a break.
            workTime = 0
        } else {
            // Cap `elapsed` at our tick interval so a long sleep/wake gap doesn't
            // get attributed as work; the idle check above already handled sleeps.
            workTime += min(elapsed, tickInterval * 2)
        }

#if RELAX_TEST_BUILD
        // Test builds also print to stderr so you can watch ticks when the
        // binary is launched directly (stderr is visible in Terminal but the
        // unified log strips NSLog from non‑privileged GUI apps).
        let idleStr: String = (idle == .greatestFiniteMagnitude)
            ? "∞" : String(format: "%.1f", idle)
        FileHandle.standardError.write(Data(
            "[Relax-Test tick] kbd-idle=\(idleStr)s  workTime=\(Int(workTime))s/\(bellSeconds)s\n"
            .utf8))
#endif

        if workTime >= TimeInterval(bellSeconds) {
            ringBell()
            workTime = 0
        }
    }

    /// Seconds since the last **keyboard** event (keyDown / keyUp / modifier
    /// flag change). Mouse moves, scrolls and clicks are deliberately ignored
    /// so the user has to actually be typing to count as "working".
    /// Returns `.greatestFiniteMagnitude` if no keyboard events have happened
    /// yet in this session, which the caller treats as "idle".
    private func systemIdleSeconds() -> TimeInterval {
        let keyTypes: [CGEventType] = [.keyDown, .keyUp, .flagsChanged]
        var minIdle = TimeInterval.greatestFiniteMagnitude
        for t in keyTypes {
            let s = CGEventSource.secondsSinceLastEventType(.combinedSessionState,
                                                            eventType: t)
            if s < minIdle { minIdle = s }
        }
        return minIdle
    }

    // MARK: - User actions

    func snooze(minutes: Int) {
        snoozedUntil = Date().addingTimeInterval(TimeInterval(minutes * 60))
        workTime = 0
        objectWillChange.send()
    }

    func endSnooze() {
        snoozedUntil = nil
        workTime = 0
        objectWillChange.send()
    }

    func resetTimer() {
        workTime = 0
        objectWillChange.send()
    }

    func setBellMinutes(_ minutes: Int) {
        bellSeconds = max(60, minutes * 60)
        if workTime >= TimeInterval(bellSeconds) {
            workTime = 0
        }
        objectWillChange.send()
    }

    // MARK: - Bell

    private func ringBell() {
        FileHandle.standardError.write(Data(
            "[Relax \(Self.isTestBuild ? "TEST" : "PROD")] BELL RANG (workTime=\(Int(workTime))s, bellSeconds=\(bellSeconds))\n"
            .utf8))
        if let url = Bundle.main.url(forResource: "bell", withExtension: "mp3"),
           let s = NSSound(contentsOf: url, byReference: false) {
            // Retain so the sound isn't deallocated mid‑playback.
            sound = s
            s.play()
        } else {
            NSSound.beep()
        }
    }

    // MARK: - Login item (macOS 13+)

    var launchAtLoginEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    func setLaunchAtLogin(_ enabled: Bool) {
        do {
            if enabled {
                try SMAppService.mainApp.register()
            } else {
                try SMAppService.mainApp.unregister()
            }
        } catch {
            NSLog("Relax: SMAppService toggle failed: \(error.localizedDescription)")
        }
        objectWillChange.send()
    }
}
