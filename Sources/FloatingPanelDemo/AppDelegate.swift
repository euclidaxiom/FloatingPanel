import AppKit
import SwiftUI
import FloatingPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        let contentView = ContentView()
        panelController = FloatingPanelController(rootView: contentView)
        panelController?
            .setupHotkey(
                key: .space,
                modifiers: [.shift, .control, .option, .command]
            )
        panelController?.togglePanel()
    }
}
