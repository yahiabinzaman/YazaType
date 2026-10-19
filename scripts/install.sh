#!/bin/bash
set -euo pipefail

APP_NAME="YazaType"
INSTALL_DIR="$HOME/Library/Input Methods"
REPO_URL="https://github.com/yahiabinzaman/yazatype"
RAW_URL="https://raw.githubusercontent.com/yahiabinzaman/yazatype/main"

echo "======================================================"
echo "    Installing YazaType — Bengali Keyboard for Mac    "
echo "======================================================"
echo ""

# Determine if running inside repo or via curl
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" 2>/dev/null && pwd || echo "")"
LOCAL_APP=""

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/../build/$APP_NAME.app" ]; then
    LOCAL_APP="$SCRIPT_DIR/../build/$APP_NAME.app"
elif [ -d "./build/$APP_NAME.app" ]; then
    LOCAL_APP="./build/$APP_NAME.app"
fi

mkdir -p "$SCRIPT_DIR/../tmp" 2>/dev/null || true
TMP_WORK_DIR=$(mktemp -d "${SCRIPT_DIR:-.}/../tmp/yazatype_install.XXXXXX" 2>/dev/null || mktemp -d "./tmp/yazatype_install.XXXXXX")
trap 'rm -rf "$TMP_WORK_DIR"' EXIT

if [ -n "$LOCAL_APP" ] && [ -d "$LOCAL_APP" ]; then
    echo ">>> Installing from local build..."
    APP_SOURCE="$LOCAL_APP"
else
    echo ">>> Downloading latest YazaType for macOS from GitHub..."
    DMG_DOWNLOAD_URL="$RAW_URL/docs/YazaType.dmg"
    curl -fSL --progress-bar "$DMG_DOWNLOAD_URL" -o "$TMP_WORK_DIR/YazaType.dmg"

    echo ">>> Extracting installer package..."
    hdiutil attach "$TMP_WORK_DIR/YazaType.dmg" -mountpoint "$TMP_WORK_DIR/mnt" -nobrowse -quiet
    
    for pkg_name in "Install YazaType.pkg"; do
        if [ -f "$TMP_WORK_DIR/mnt/$pkg_name" ]; then
            pkgutil --expand-full "$TMP_WORK_DIR/mnt/$pkg_name" "$TMP_WORK_DIR/pkg_expanded" 2>/dev/null || true
            if [ -d "$TMP_WORK_DIR/pkg_expanded/Scripts/YazaType.app" ]; then
                APP_SOURCE="$TMP_WORK_DIR/pkg_expanded/Scripts/YazaType.app"
            elif [ -d "$TMP_WORK_DIR/pkg_expanded/YazaType.app" ]; then
                APP_SOURCE="$TMP_WORK_DIR/pkg_expanded/YazaType.app"
            fi
            break
        fi
    done
    
    if [ -z "${APP_SOURCE:-}" ]; then
        # Direct payload search
        APP_SOURCE=$(find "$TMP_WORK_DIR" -name "YazaType.app" -type d | head -n 1)
    fi
fi

if [ -z "${APP_SOURCE:-}" ] || [ ! -d "$APP_SOURCE" ]; then
    echo "❌ Error: Could not locate YazaType.app payload."
    exit 1
fi

echo ">>> Stopping any existing instances..."
killall "$APP_NAME" 2>/dev/null || true
killall "Borno" 2>/dev/null || true
killall "AvroBangla" 2>/dev/null || true
killall TextInputMenuAgent 2>/dev/null || true
killall TextInputSwitcher 2>/dev/null || true
sleep 1

mkdir -p "$INSTALL_DIR"
rm -rf "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true
rm -rf "$INSTALL_DIR/Borno.app" 2>/dev/null || true
rm -rf "$INSTALL_DIR/AvroBangla.app" 2>/dev/null || true

echo ">>> Copying $APP_NAME.app to $INSTALL_DIR/..."
cp -R "$APP_SOURCE" "$INSTALL_DIR/$APP_NAME.app"

# Detach DMG if mounted
if [ -d "$TMP_WORK_DIR/mnt" ]; then
    hdiutil detach "$TMP_WORK_DIR/mnt" -quiet 2>/dev/null || true
fi

# Clear quarantine attributes
echo ">>> Clearing quarantine security attributes..."
xattr -cr "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

# Clean up any duplicate in /Applications so only 1 copy is indexed
rm -f "/Applications/$APP_NAME.app" 2>/dev/null || true
rm -rf "/Applications/$APP_NAME.app" 2>/dev/null || true
rm -f "/Applications/Borno.app" 2>/dev/null || true
rm -rf "/Applications/Borno.app" 2>/dev/null || true

# Register user LaunchAgent for automatic startup & background keepalive
LAUNCH_AGENT_DIR="$HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.yaza.inputmethod.YazaType.plist"
OLD_LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.borno.inputmethod.Borno.plist"
mkdir -p "$LAUNCH_AGENT_DIR"
launchctl unload "$OLD_LAUNCH_AGENT_PLIST" 2>/dev/null || true
rm -f "$OLD_LAUNCH_AGENT_PLIST" 2>/dev/null || true
launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true

cat <<EOF > "$LAUNCH_AGENT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yaza.inputmethod.YazaType</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/$APP_NAME.app/Contents/MacOS/$APP_NAME</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

# Load and launch IME service
echo ">>> Starting YazaType background service..."
launchctl load "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
open "$INSTALL_DIR/$APP_NAME.app" 2>/dev/null || true

echo ""
echo "======================================================"
echo "          ✅ YazaType successfully installed!         "
echo "======================================================"
echo ""
echo "Setup Instructions:"
echo " 1. Open System Settings -> Keyboard -> Input Sources (Click Edit...)"
echo " 2. Click '+' at the bottom left"
echo " 3. Search for 'YazaType' in the language list and click 'Add'"
echo " 4. Switch anytime using Globe key or Ctrl + Space"
echo ""
echo "Developed & Maintained by Yahia Bin Zaman"
echo "GitHub: https://github.com/yahiabinzaman/yazatype"
echo "======================================================"
