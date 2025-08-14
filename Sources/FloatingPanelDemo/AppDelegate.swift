import AppKit
import SwiftUI
import FloatingPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        panelController = FloatingPanelController { _ in
            ContentView()
        }
        
        panelController?.showPanel()
    }
}

