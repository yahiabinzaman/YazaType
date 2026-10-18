import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {

    @objc func handleOpenAppEvent(_ event: NSAppleEventDescriptor, withReplyEvent replyEvent: NSAppleEventDescriptor) {
        NSLog("YazaType: handleOpenAppEvent called")
        WelcomeWindowController.shared.showWindow()
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        NSLog("YazaType: applicationShouldHandleReopen called")
        WelcomeWindowController.shared.showWindow()
        return true
    }

    func applicationOpenUntitledFile(_ sender: NSApplication) -> Bool {
        return false
    }
}
