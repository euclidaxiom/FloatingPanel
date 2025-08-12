import SwiftUI
import VisualEffectView

public extension View {
    /// Applies a standard floating panel background to a view.
    ///
    /// This is a convenience modifier that wraps the view in a `VisualEffectView`,
    /// which is the standard background for all content within a `FloatingPanel`.
    ///
    /// - Parameter visualEffect: An optional `VisualEffectConfiguration` for customizing the panel's background.
    ///                         If `nil`, the `VisualEffectView` library's default is used.
    /// - Returns: A view with the visual effect background applied.
    func floatingPanelBackground(visualEffect: VisualEffectConfiguration? = nil) -> some View {
        self.background(VisualEffectView(config: visualEffect))
    }
}
