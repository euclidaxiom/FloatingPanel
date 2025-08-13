import SwiftUI

@main
struct FloatingPanelDemoApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        MenuBarExtra("FloatingPanel Demo", systemImage: "square.grid.2x2") {
            Button("Quit") {
                NSApp.terminate(nil)
            }
        }
    }
}
