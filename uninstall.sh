#!/usr/bin/env bash
# Removes the Relax LaunchAgent and installed files.

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This uninstaller is for macOS only." >&2
    exit 1
fi

APP_DIR="$HOME/Library/Application Support/Relax"
PLIST_LABEL="com.nachmanson.relax"
PLIST_PATH="$HOME/Library/LaunchAgents/$PLIST_LABEL.plist"
UID_NUM="$(id -u)"

echo "==> Stopping LaunchAgent"
launchctl bootout "gui/$UID_NUM/$PLIST_LABEL" 2>/dev/null || true

echo "==> Removing $PLIST_PATH"
rm -f "$PLIST_PATH"

echo "==> Removing $APP_DIR"
rm -rf "$APP_DIR"

echo "==> Done. Relax has been uninstalled."
