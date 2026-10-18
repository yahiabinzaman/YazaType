#!/bin/bash
set -euo pipefail

APP_NAME="YazaType"
INSTALL_DIR="$HOME/Library/Input Methods"
USER_DATA_DIR="$HOME/Library/Application Support/YazaType"
LEGACY_USER_DATA_DIR="$HOME/Library/Application Support/Borno"
PREFS_FILE="$HOME/Library/Preferences/com.yaza.inputmethod.YazaType.plist"
LEGACY_PREFS_FILE="$HOME/Library/Preferences/com.borno.inputmethod.Borno.plist"
SAVED_STATE_DIR="$HOME/Library/Saved Application State/com.yaza.inputmethod.YazaType.savedState"

echo "=== Uninstalling $APP_NAME ==="

# Kill running instance & unload LaunchAgent
for plist in "com.yaza.inputmethod.YazaType.plist" "com.borno.inputmethod.Borno.plist"; do
    LAUNCH_AGENT_PLIST="$HOME/Library/LaunchAgents/$plist"
    launchctl unload "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
    rm -f "$LAUNCH_AGENT_PLIST" 2>/dev/null || true
done

killall "$APP_NAME" 2>/dev/null || true
killall "Borno" 2>/dev/null || true
killall "AvroBangla" 2>/dev/null || true
sleep 1

# Remove the app
for app in "$APP_NAME.app" "Borno.app" "AvroBangla.app"; do
    if [ -d "$INSTALL_DIR/$app" ]; then
        echo ">>> Removing $INSTALL_DIR/$app"
        rm -rf "$INSTALL_DIR/$app"
    fi
    rm -f "/Applications/$app" 2>/dev/null || true
done

# Ask about user data
if [ -d "$USER_DATA_DIR" ] || [ -f "$PREFS_FILE" ] || [ -d "$SAVED_STATE_DIR" ]; then
    echo ""
    echo "User data found:"
    [ -d "$USER_DATA_DIR" ]   && echo "  - $USER_DATA_DIR (learned word selections)"
    [ -f "$PREFS_FILE" ]      && echo "  - $PREFS_FILE (settings)"
    [ -d "$SAVED_STATE_DIR" ] && echo "  - $SAVED_STATE_DIR (welcome window state)"
    echo ""
    read -p "Remove all user data? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        rm -rf "$USER_DATA_DIR"   2>/dev/null || true
        rm -f  "$PREFS_FILE"      2>/dev/null || true
        rm -rf "$SAVED_STATE_DIR" 2>/dev/null || true
        echo ">>> User data removed."
    else
        echo ">>> User data preserved."
    fi
fi

echo ""
echo "=== Uninstall complete ==="
echo "Please log out and log back in to complete removal."
