#!/bin/bash
set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
APP_BUNDLE="$PROJECT_ROOT/build/YazaType.app"
PKG_DIR="$PROJECT_ROOT/build/pkg_staging"
DMG_DIR="$PROJECT_ROOT/build/dmg_staging"
VERSION="0.2.5"
PKG_OUTPUT="$PROJECT_ROOT/build/YazaType.pkg"
DMG_OUTPUT="$PROJECT_ROOT/build/YazaType-${VERSION}.dmg"
VOLUME_NAME="YazaType"

if [ ! -d "$APP_BUNDLE" ]; then
    echo "Error: $APP_BUNDLE not found. Run 'make build' first."
    exit 1
fi

echo "=== Creating Installer Package ==="

# Clean up
rm -rf "$PKG_DIR" "$DMG_DIR" "$PKG_OUTPUT"
rm -f "$DMG_OUTPUT"

# --- Step 1: Create the .pkg installer ---

mkdir -p "$PKG_DIR/scripts"

# Bundle the app inside the scripts dir (pkg scripts can access this)
cp -R "$APP_BUNDLE" "$PKG_DIR/scripts/YazaType.app"

# Preinstall: kill the running instance
cat > "$PKG_DIR/scripts/preinstall" << 'SCRIPT'
#!/bin/bash
# Find the real logged-in user (not root)
REAL_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
REAL_HOME=$(eval echo "~$REAL_USER")

# Kill running instances so the old .app can be replaced
killall YazaType 2>/dev/null || true
killall Borno 2>/dev/null || true
killall AvroBangla 2>/dev/null || true
sleep 1

# Remove old installations
rm -rf "$REAL_HOME/Library/Input Methods/YazaType.app" 2>/dev/null || true
rm -rf "$REAL_HOME/Library/Input Methods/Borno.app" 2>/dev/null || true
rm -rf "$REAL_HOME/Library/Input Methods/AvroBangla.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/YazaType.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/Borno.app" 2>/dev/null || true
rm -rf "/Library/Input Methods/AvroBangla.app" 2>/dev/null || true

exit 0
SCRIPT
chmod +x "$PKG_DIR/scripts/preinstall"

# Postinstall: install to user's ~/Library/Input Methods/
cat > "$PKG_DIR/scripts/postinstall" << 'SCRIPT'
#!/bin/bash
# Find the real logged-in user (not root)
REAL_USER=$(stat -f "%Su" /dev/console 2>/dev/null || echo "$USER")
REAL_HOME=$(eval echo "~$REAL_USER")

INSTALL_DIR="$REAL_HOME/Library/Input Methods"
SCRIPT_DIR="$(dirname "$0")"

# Create install directory
mkdir -p "$INSTALL_DIR"

# Copy the app from the scripts directory
cp -R "$SCRIPT_DIR/YazaType.app" "$INSTALL_DIR/"

# Fix ownership (pkg runs as root, so files would be owned by root)
chown -R "$REAL_USER" "$INSTALL_DIR/YazaType.app"

# Clear quarantine flag
xattr -cr "$INSTALL_DIR/YazaType.app" 2>/dev/null || true

# Place a symlink in /Applications/ so the app shows in Launchpad/Spotlight
rm -f "/Applications/YazaType.app" 2>/dev/null || true
rm -rf "/Applications/YazaType.app" 2>/dev/null || true
rm -f "/Applications/Borno.app" 2>/dev/null || true
rm -rf "/Applications/Borno.app" 2>/dev/null || true
ln -sf "$INSTALL_DIR/YazaType.app" "/Applications/YazaType.app"

# Clean up old AvroBangla symlink/app from /Applications/
rm -f "/Applications/AvroBangla.app" 2>/dev/null || true
rm -rf "/Applications/AvroBangla.app" 2>/dev/null || true

# Register user LaunchAgent for automatic startup & background keepalive
LAUNCH_AGENT_DIR="$REAL_HOME/Library/LaunchAgents"
LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.yaza.inputmethod.YazaType.plist"
OLD_LAUNCH_AGENT_PLIST="$LAUNCH_AGENT_DIR/com.borno.inputmethod.Borno.plist"
mkdir -p "$LAUNCH_AGENT_DIR"
chown "$REAL_USER" "$LAUNCH_AGENT_DIR" 2>/dev/null || true

# Remove old Borno launchagent
su "$REAL_USER" -c "launchctl unload '$OLD_LAUNCH_AGENT_PLIST'" 2>/dev/null || true
rm -f "$OLD_LAUNCH_AGENT_PLIST" 2>/dev/null || true

cat <<EOF > "$LAUNCH_AGENT_PLIST"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.yaza.inputmethod.YazaType</string>
    <key>ProgramArguments</key>
    <array>
        <string>$INSTALL_DIR/YazaType.app/Contents/MacOS/YazaType</string>
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
chown "$REAL_USER" "$LAUNCH_AGENT_PLIST" 2>/dev/null || true

su "$REAL_USER" -c "launchctl load '$LAUNCH_AGENT_PLIST'" 2>/dev/null || true

# Kill any auto-relaunched old instance
killall YazaType 2>/dev/null || true
killall Borno 2>/dev/null || true
sleep 0.5

# Launch the NEW binary as the real user
su "$REAL_USER" -c "open '$INSTALL_DIR/YazaType.app'" 2>/dev/null || true

exit 0
SCRIPT
chmod +x "$PKG_DIR/scripts/postinstall"

echo ">>> Building package..."
pkgbuild \
    --nopayload \
    --scripts "$PKG_DIR/scripts" \
    --identifier "com.yaza.inputmethod.YazaType" \
    --version "0.2.5" \
    "$PKG_DIR/YazaType-component.pkg"

# Create a distribution XML for a nicer installer UI
cat > "$PKG_DIR/distribution.xml" << 'DISTXML'
<?xml version="1.0" encoding="utf-8"?>
<installer-gui-script minSpecVersion="2">
    <title>YazaType</title>
    <allowed-os-versions><os-version min="13.0"/></allowed-os-versions>
    <options hostArchitectures="arm64" customize="never" require-scripts="false"/>
    <welcome mime-type="text/plain"><![CDATA[
Welcome to YazaType — Bengali Keyboard for macOS.

This will install the YazaType Bengali keyboard to your Mac.

After installation:
  1. Open System Settings → Keyboard → Input Sources
  2. Click + → search "YazaType" → select YazaType → Add
  3. Use Globe key or Ctrl+Space to switch input methods

Note: If this is a fresh install, you may need to log out
and log back in for the keyboard to appear.
    ]]></welcome>
    <choices-outline>
        <line choice="default">
            <line choice="com.yaza.inputmethod.YazaType"/>
        </line>
    </choices-outline>
    <choice id="default"/>
    <choice id="com.yaza.inputmethod.YazaType" visible="false">
        <pkg-ref id="com.yaza.inputmethod.YazaType"/>
    </choice>
    <pkg-ref id="com.yaza.inputmethod.YazaType"
             version="0.2.5"
             onConclusion="none">YazaType-component.pkg</pkg-ref>
</installer-gui-script>
DISTXML

echo ">>> Building product package..."
productbuild \
    --distribution "$PKG_DIR/distribution.xml" \
    --package-path "$PKG_DIR" \
    "$PKG_OUTPUT"

echo ">>> Package created: $PKG_OUTPUT"

# --- Step 2: Create the DMG ---

echo ""
echo "=== Creating DMG ==="

mkdir -p "$DMG_DIR"
cp "$PKG_OUTPUT" "$DMG_DIR/Install YazaType.pkg"

# Create the DMG
hdiutil create \
    -volname "$VOLUME_NAME" \
    -srcfolder "$DMG_DIR" \
    -ov \
    -format UDZO \
    "$DMG_OUTPUT"

# Clean up staging
rm -rf "$PKG_DIR" "$DMG_DIR"

echo ""
echo "=== Done ==="
echo "DMG: $DMG_OUTPUT ($(du -h "$DMG_OUTPUT" | cut -f1))"
echo "PKG: $PKG_OUTPUT ($(du -h "$PKG_OUTPUT" | cut -f1))"
echo ""
echo "Users just: open DMG → double-click 'Install YazaType.pkg' → done"
