# Relax
This script is inspired by [Awarenes](http://iamfutureproof.com/tools/awareness/): The idea is to detect if you work too hard, it will leave you alone otherwise. If you take at least a 5 minute break during an hour nothing happens, otherwise a gong will sound.

## Install on macOS (runs automatically at login, survives reboots)

1. Download or clone this repository.
2. Open Terminal, `cd` into the repo folder, and run:
   ```
   ./install.sh
   ```
   This will:
   - Copy the app to `~/Library/Application Support/Relax`
   - Create a Python virtual environment there and install `pynput`
   - Install a LaunchAgent at `~/Library/LaunchAgents/com.nachmanson.relax.plist`
   - Start it immediately and configure it to start on every login
3. **Grant keyboard permission (one-time).** macOS will prompt the first time, or you can grant it manually:
   - Open **System Settings → Privacy & Security → Input Monitoring**
   - Enable the entry for the Python binary at `~/Library/Application Support/Relax/venv/bin/python`
   - Do the same under **Accessibility** if prompted
   - Then restart the agent:
     ```
     launchctl kickstart -k gui/$(id -u)/com.nachmanson.relax
     ```

Logs are written to `~/Library/Application Support/Relax/relax.log` and `relax.err.log`.

To uninstall:
```
./uninstall.sh
```

## Run manually (any OS)
```
pip3 install pynput playsound
python3 main.py
```
Do not move `main.py` away from `bell.mp3`.

## Native macOS app (SwiftUI menu bar)

A full macOS `.app` lives in [`mac-app/`](./mac-app/). Build and run with:
```
cd mac-app
./build-app.sh
open build/Relax.app
```
Requires macOS 13+ and Xcode (or the Command Line Tools). The native version
needs **no** Input Monitoring / Accessibility permissions — it uses the
system idle clock (`CGEventSource.secondsSinceLastEventType`) instead of
keyboard hooking. See [`mac-app/README.md`](./mac-app/README.md) for details.

## Authors
* **Ben Nachmanson**
* **Lev Nachmanson** [https://github.com/levnach]
