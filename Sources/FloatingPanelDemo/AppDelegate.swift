import AppKit
import SwiftUI
import FloatingPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Há como fazer uma implementação em FloatingPanel para que esse trecho, o atual modo de usar o pacote:
        panelController = FloatingPanelController(rootView: EmptyView())
        
        let contentView = ContentView()
            .environment(\.panelController, panelController)
        
        panelController?.updateContentView(contentView)
        
        // Se torne somente essa linha, para diminuir a necessidade de configuração extra para quem for usá-lo:
        // panelController = FloatingPanelController(rootView: ContentView())
        
        // ?
        
        panelController?.showPanel()
    }
}

//MARK: PanelControllerEnvironmentKey
private struct PanelControllerKey: EnvironmentKey {
    static let defaultValue: FloatingPanelController? = nil
}

extension EnvironmentValues {
    var panelController: FloatingPanelController? {
        get { self[PanelControllerKey.self] }
        set { self[PanelControllerKey.self] = newValue }
    }
}
