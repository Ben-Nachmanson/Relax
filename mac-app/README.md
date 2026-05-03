# Relax — native macOS app

A SwiftUI menu‑bar version of [Relax](../README.md). It lives quietly in
the status bar, watches the system idle clock, and rings the bell after an
hour of continuous work without a 5‑minute break — same idea as the Python
script, but as a real `.app`.

## Requirements

- macOS 13 (Ventura) or later
- Xcode 15+ **or** Command Line Tools (`xcode-select --install`)

That's it. No Apple Developer account, no notarization, no extra
permissions: idle detection uses `CGEventSource.secondsSinceLastEventType`,
which does **not** require Input Monitoring or Accessibility approval.

## Build & run

```sh
cd mac-app
./build-app.sh
open build/Relax.app
```

A bell icon appears in your menu bar. Click it for status, snooze, "Bell
every…", "Open at login", and Quit.

### Develop in Xcode

Just open the package — Xcode handles the rest:

```sh
open Package.swift
```

Hit ⌘R to run. (When run from Xcode you'll see a Dock icon while debugging;
the production `build-app.sh` build hides it via `LSUIElement`.)

## How it works

| Setting    | Default | Where                              |
| ---------- | ------- | ---------------------------------- |
| Break time | 5 min   | hard‑coded                         |
| Bell every | 60 min  | menu → "Bell every"                |
| Snooze     | —       | menu → "Snooze 15 min" / "1 hour"  |

Every 30 seconds the app asks macOS how long it's been since the last
**keyboard** event. If that idle gap is ≥ the break time, the work counter
resets to zero. Otherwise the elapsed time is added to the counter. When it
reaches the bell interval, `bell.mp3` plays and the counter resets.

Mouse moves, scrolls and clicks are deliberately ignored — only typing
counts as "working", matching the original Python script's behaviour.

Sleep, screen lock, and "step away from the keyboard" all count as breaks
automatically — no special handling needed.

## Test build (rings the bell after 1 minute)

To smoke‑test without waiting an hour, build a separate `Relax-Test.app`
that ticks every 5 s and rings after 60 s of typing:

```sh
./build-app.sh --test
open build/Relax-Test.app
```

Its menu‑bar entry shows "TEST" next to the bell so it's easy to spot
alongside the production app. It uses a separate bundle id
(`com.nachmanson.relax.test`) so its UserDefaults / Login Item state are
fully isolated from the real app. Quit it from its menu when you're done.

## Open at login

The "Open at login" menu toggle uses Apple's modern `SMAppService.mainApp`
API. macOS records the registration per‑app‑bundle, so:

1. Move `Relax.app` to `/Applications/` (drag it from `mac-app/build/`).
2. Click the bell icon → toggle **Open at login**.

You can also manage this from **System Settings → General → Login Items**.

## Project layout

```
mac-app/
├── Package.swift                  # SwiftPM executable target
├── Sources/Relax/
│   ├── RelaxApp.swift             # @main + MenuBarExtra scene
│   ├── WorkMonitor.swift          # idle/work logic, snooze, bell, login item
│   └── MenuContents.swift         # SwiftUI menu UI
├── Resources/
│   ├── Info.plist                 # LSUIElement, bundle id, min OS
│   └── bell.mp3                   # copy of repo‑root bell.mp3
├── build-app.sh                   # build → assemble .app → ad‑hoc sign
└── .gitignore
```

## Distribution (sharing with other users)

`build-app.sh` produces an **ad‑hoc signed** app, which is enough to launch
on the machine that built it but Gatekeeper will block it on someone else's
Mac. To distribute it more widely you'd need to:

1. Enroll in the Apple Developer Program (paid).
2. Get a "Developer ID Application" certificate.
3. Sign with that identity and enable Hardened Runtime:
   `codesign --force --options runtime --sign "Developer ID Application: …" Relax.app`
4. Notarize:
   `xcrun notarytool submit Relax.app.zip --apple-id … --team-id … --password … --wait`
5. Staple: `xcrun stapler staple Relax.app`

That's outside the scope of this repo; Apple's
[Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
docs cover the full flow.

## Relationship to the Python version

The Python script in the repo root still works and is the simplest way to
run Relax without building anything. The native app is an alternative that:

- bundles into a single `.app` you can drag to `/Applications/`,
- doesn't need `pynput` and so doesn't trigger the Input Monitoring
  permission prompt,
- offers snooze and a configurable bell interval through a real UI.
