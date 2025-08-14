import AppKit
import SwiftUI
import FloatingPanel

import AppKit
import SwiftUI
import FloatingPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        panelController = FloatingPanelController(rootView: EmptyView())

        if let panelController {
            let contentView = ContentView()
                .environment(\.panelController, panelController)
            
            panelController.updateContentView(contentView)
        }

        panelController?.showPanel()
    }
}

