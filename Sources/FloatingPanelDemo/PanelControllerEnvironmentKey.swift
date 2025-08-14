import SwiftUI
import FloatingPanel

private struct PanelControllerKey: EnvironmentKey {
    static let defaultValue: FloatingPanelController? = nil
}

extension EnvironmentValues {
    var panelController: FloatingPanelController? {
        get { self[PanelControllerKey.self] }
        set { self[PanelControllerKey.self] = newValue }
    }
}
