#!/usr/bin/env bash
# Builds Relax.app from the Swift package and ad‑hoc codesigns it so it can
# run on the build machine without Gatekeeper friction. No Apple Developer
# account or notarization is required for local use.
#
# Usage:
#   ./build-app.sh                 # release build → build/Relax.app
#   ./build-app.sh debug           # debug build (faster compile)
#   ./build-app.sh --test          # 1‑minute test build → build/Relax-Test.app
#                                  # (separate bundle id, ticks every 5s, rings after 60s)
#
# Output:
#   mac-app/build/Relax.app  (or  Relax-Test.app  with --test)

set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

CONFIG="release"
TEST_MODE=0
for arg in "$@"; do
    case "$arg" in
        --test)        TEST_MODE=1 ;;
        debug|release) CONFIG="$arg" ;;
        *) echo "warning: ignoring unknown arg '$arg'" >&2 ;;
    esac
done

if [[ $TEST_MODE -eq 1 ]]; then
    APP_NAME="Relax-Test"
    BUNDLE_ID="com.nachmanson.relax.test"
    SWIFT_FLAGS=(-Xswiftc -DRELAX_TEST_BUILD)
else
    APP_NAME="Relax"
    BUNDLE_ID="com.nachmanson.relax"
    SWIFT_FLAGS=()
fi

if ! command -v swift >/dev/null 2>&1; then
    echo "error: 'swift' not found. Install Xcode or the Command Line Tools." >&2
    exit 1
fi

# Make sure the bundled bell.mp3 stays in sync with the repo root one.
if [[ ! -f Resources/bell.mp3 && -f ../bell.mp3 ]]; then
    cp ../bell.mp3 Resources/bell.mp3
fi

echo "==> swift build -c $CONFIG ${SWIFT_FLAGS[*]:-}"
swift build -c "$CONFIG" ${SWIFT_FLAGS[@]+"${SWIFT_FLAGS[@]}"}

BIN_DIR="$(swift build -c "$CONFIG" ${SWIFT_FLAGS[@]+"${SWIFT_FLAGS[@]}"} --show-bin-path)"
EXEC="$BIN_DIR/Relax"
if [[ ! -x "$EXEC" ]]; then
    echo "error: built executable not found at $EXEC" >&2
    exit 1
fi

APP="build/${APP_NAME}.app"
echo "==> assembling $APP  (bundle id: $BUNDLE_ID)"
rm -rf "$APP"
mkdir -p "$APP/Contents/MacOS" "$APP/Contents/Resources"

cp "$EXEC" "$APP/Contents/MacOS/${APP_NAME}"

# Specialise the Info.plist for this build (rename + new bundle id).
sed \
    -e "s|<string>com\.nachmanson\.relax</string>|<string>${BUNDLE_ID}</string>|g" \
    -e "s|<string>Relax</string>|<string>${APP_NAME}</string>|g" \
    Resources/Info.plist > "$APP/Contents/Info.plist"

if [[ -f Resources/bell.mp3 ]]; then
    cp Resources/bell.mp3 "$APP/Contents/Resources/bell.mp3"
fi

# Ad‑hoc sign with the special "-" identity. This is enough to satisfy macOS's
# launch requirements on the same machine; sharing with other users still
# requires a Developer ID + notarization (see README → Distribution).
echo "==> codesign --sign - $APP"
codesign --force --deep --sign - "$APP" >/dev/null

echo
echo "Built: $(pwd)/$APP"
echo "Run with:  open '$(pwd)/$APP'"
