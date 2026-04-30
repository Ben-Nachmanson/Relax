#!/usr/bin/env bash
# Installs Relax as a LaunchAgent on macOS so it starts at login
# and is restarted automatically by launchd.

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This installer is for macOS only." >&2
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
APP_DIR="$HOME/Library/Application Support/Relax"
AGENT_DIR="$HOME/Library/LaunchAgents"
PLIST_LABEL="com.nachmanson.relax"
PLIST_PATH="$AGENT_DIR/$PLIST_LABEL.plist"

echo "==> Installing Relax to: $APP_DIR"
mkdir -p "$APP_DIR" "$AGENT_DIR"
cp "$SRC_DIR/main.py" "$APP_DIR/"
cp "$SRC_DIR/bell.mp3" "$APP_DIR/"

PYTHON_BIN="$(command -v python3 || true)"
if [[ -z "$PYTHON_BIN" ]]; then
    echo "python3 not found. Install it (e.g. from https://www.python.org/downloads/) and re-run." >&2
    exit 1
fi

echo "==> Creating virtualenv at: $APP_DIR/venv"
"$PYTHON_BIN" -m venv "$APP_DIR/venv"
# shellcheck disable=SC1091
source "$APP_DIR/venv/bin/activate"
pip install --quiet --upgrade pip
pip install --quiet pynput
deactivate

VENV_PYTHON="$APP_DIR/venv/bin/python"

echo "==> Writing LaunchAgent: $PLIST_PATH"
sed \
    -e "s|__PYTHON__|$VENV_PYTHON|g" \
    -e "s|__APPDIR__|$APP_DIR|g" \
    "$SRC_DIR/com.nachmanson.relax.plist.template" > "$PLIST_PATH"

UID_NUM="$(id -u)"
echo "==> Loading LaunchAgent"
# Reload so changes are picked up if it was already installed.
launchctl bootout "gui/$UID_NUM/$PLIST_LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$UID_NUM" "$PLIST_PATH"
launchctl enable "gui/$UID_NUM/$PLIST_LABEL"
launchctl kickstart -k "gui/$UID_NUM/$PLIST_LABEL"

cat <<EOF

==> Done.

Relax is now running and will start automatically every time you log in.

IMPORTANT — grant keyboard permission (one-time):
  macOS will prompt to allow keyboard monitoring. If it does not, open:
    System Settings -> Privacy & Security -> Input Monitoring
  and turn ON the entry for the Python interpreter:
    $VENV_PYTHON
  (You may also need the same entry under "Accessibility".)
  After granting permission, run:
    launchctl kickstart -k gui/$UID_NUM/$PLIST_LABEL

Logs:
  $APP_DIR/relax.log
  $APP_DIR/relax.err.log

To uninstall, run: $SRC_DIR/uninstall.sh
EOF
