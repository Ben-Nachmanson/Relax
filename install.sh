#!/usr/bin/env bash
# Installs Relax as a LaunchAgent on macOS so it starts at login
# and is restarted automatically by launchd.

set -euo pipefail

if [[ "$(uname)" != "Darwin" ]]; then
    echo "This installer is for macOS only." >&2
    exit 1
fi

SRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If main.py / bell.mp3 aren't next to this script (e.g. when installed via
# `curl ... | bash` or by downloading just install.sh), fetch the full repo
# into a temporary directory and use that as the source.
if [[ ! -f "$SRC_DIR/main.py" || ! -f "$SRC_DIR/bell.mp3" || ! -f "$SRC_DIR/com.nachmanson.relax.plist.template" ]]; then
    REPO_TARBALL="https://github.com/Ben-Nachmanson/Relax/archive/refs/heads/master.tar.gz"
    TMP_SRC="$(mktemp -d)"
    trap 'rm -rf "$TMP_SRC"' EXIT
    echo "==> Downloading Relax sources from GitHub"
    curl -fsSL "$REPO_TARBALL" | tar -xz -C "$TMP_SRC"
    SRC_DIR="$TMP_SRC/Relax-master"
fi
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
# Use the *resolved* python binary so launchd executes the same file path that
# macOS TCC tracks for Accessibility / Input Monitoring permissions.
REAL_PYTHON="$("$PYTHON_BIN" -c 'import os,sys; print(os.path.realpath(sys.executable))')"

LIB_DIR="$APP_DIR/lib"
echo "==> Installing pynput into: $LIB_DIR"
mkdir -p "$LIB_DIR"
"$REAL_PYTHON" -m pip install --quiet --upgrade --target "$LIB_DIR" --break-system-packages pynput

echo "==> Writing LaunchAgent: $PLIST_PATH"
sed \
    -e "s|__PYTHON__|$REAL_PYTHON|g" \
    -e "s|__APPDIR__|$APP_DIR|g" \
    -e "s|__PYTHONPATH__|$LIB_DIR|g" \
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
    $REAL_PYTHON
  (You may also need the same entry under "Accessibility".)
  After granting permission, run:
    launchctl kickstart -k gui/$UID_NUM/$PLIST_LABEL

  (You may see "This process is not trusted!" in relax.err.log — that warning
  is printed once at startup and can be ignored as long as the bell rings.)

Logs:
  $APP_DIR/relax.log
  $APP_DIR/relax.err.log

To uninstall, run:
  curl -fsSL https://raw.githubusercontent.com/Ben-Nachmanson/Relax/master/uninstall.sh | bash
EOF
