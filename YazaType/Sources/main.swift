import Cocoa
import InputMethodKit

// Connection name MUST match Info.plist's InputMethodConnectionName
let kConnectionName = "com.yaza.inputmethod.YazaType_Connection"

// IMKServer must be a global to stay alive for the process lifetime
var server: IMKServer!

// Build identifier — check Console.app for "YazaType" to verify which build is running
let lekhoBuildId = "yazatype-v0.2.5"
NSLog("YazaType: starting %@", lekhoBuildId)

func installMainMenu() {
    let mainMenu = NSMenu()

    let appMenuItem = NSMenuItem()
    mainMenu.addItem(appMenuItem)
    let appMenu = NSMenu(title: "YazaType")
    appMenu.addItem(NSMenuItem(
        title: "Close Window",
        action: #selector(NSWindow.performClose(_:)),
        keyEquivalent: "w"))
    appMenu.addItem(NSMenuItem(
        title: "Close Window",
        action: #selector(NSWindow.performClose(_:)),
        keyEquivalent: "q"))
    appMenu.addItem(NSMenuItem(
        title: "Hide YazaType",
        action: #selector(NSApplication.hide(_:)),
        keyEquivalent: "h"))
    appMenuItem.submenu = appMenu

    let editMenuItem = NSMenuItem()
    mainMenu.addItem(editMenuItem)
    let editMenu = NSMenu(title: "Edit")
    editMenu.addItem(NSMenuItem(title: "Undo", action: Selector(("undo:")), keyEquivalent: "z"))
    let redo = NSMenuItem(title: "Redo", action: Selector(("redo:")), keyEquivalent: "z")
    redo.keyEquivalentModifierMask = [.command, .shift]
    editMenu.addItem(redo)
    editMenu.addItem(NSMenuItem.separator())
    editMenu.addItem(NSMenuItem(title: "Cut", action: #selector(NSText.cut(_:)), keyEquivalent: "x"))
    editMenu.addItem(NSMenuItem(title: "Copy", action: #selector(NSText.copy(_:)), keyEquivalent: "c"))
    editMenu.addItem(NSMenuItem(title: "Paste", action: #selector(NSText.paste(_:)), keyEquivalent: "v"))
    editMenu.addItem(NSMenuItem(title: "Select All", action: #selector(NSResponder.selectAll(_:)), keyEquivalent: "a"))
    editMenuItem.submenu = editMenu

    NSApplication.shared.mainMenu = mainMenu
}

installMainMenu()

// Register menu bar icons BEFORE IMKServer loads them (full-color icon, not template)
for name in ["icon", "icon.tiff", "icon.png", "iconTemplate", "iconTemplate.tiff", "iconTemplate.png"] {
    let base = (name as NSString).deletingPathExtension
    let ext = (name as NSString).pathExtension.isEmpty ? nil : (name as NSString).pathExtension
    if let iconPath = Bundle.main.path(forResource: base, ofType: ext),
       let icon = NSImage(contentsOfFile: iconPath) {
        icon.isTemplate = true
        icon.setName(name)
        if ext == nil {
            icon.setName("\(base).tiff")
            icon.setName("\(base).png")
        }
    }
}

autoreleasepool {
    server = IMKServer(name: kConnectionName,
                       bundleIdentifier: Bundle.main.bundleIdentifier!)

    let delegate = AppDelegate()
    NSApplication.shared.delegate = delegate

    NSAppleEventManager.shared().setEventHandler(
        delegate,
        andSelector: #selector(AppDelegate.handleOpenAppEvent(_:withReplyEvent:)),
        forEventClass: AEEventClass(kCoreEventClass),
        andEventID: AEEventID(kAEOpenApplication)
    )
    NSAppleEventManager.shared().setEventHandler(
        delegate,
        andSelector: #selector(AppDelegate.handleOpenAppEvent(_:withReplyEvent:)),
        forEventClass: AEEventClass(kCoreEventClass),
        andEventID: AEEventID(kAEReopenApplication)
    )

    // Keep a strong reference so ARC doesn't release it
    withExtendedLifetime(delegate) {
        NSApplication.shared.run()
    }
}
