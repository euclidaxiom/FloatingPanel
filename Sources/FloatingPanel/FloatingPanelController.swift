import AppKit
import SwiftUI
import VisualEffectView
@preconcurrency import HotKey

/// Manages the lifecycle and interactions of a `FloatingPanel`.
///
/// This is the main class for consumers of the library. It handles panel creation,
/// visibility, hotkey registration, and content updates.
@MainActor
public class FloatingPanelController {
    private var floatingPanel: FloatingPanel?
    private var hotKey: HotKey?
    private var escapeEventMonitor: Any?
    private var isVisible: Bool = false
    
    /// Initializes the controller and creates the underlying floating panel.
    ///
    /// The `rootView` is automatically styled with a visual effect background and prepared for use in the panel.
    ///
    /// - Parameters:
    ///   - rootView: The SwiftUI view to display as the panel's content.
    ///   - size: A `FloatingPanelSize` object defining the panel's compact and expanded dimensions.
    ///           Defaults to `DefaultPanelSize`.
    ///   - position: A `FloatingPanelPosition` object defining the panel's on-screen location.
    ///             Defaults to `DefaultPanelPosition`.
    ///   - visualEffect: An optional `VisualEffectConfiguration` for customizing the panel's background.
    ///                 If `nil`, the `VisualEffectView` library's default is used.
    ///   - cornerRadius: An optional `CGFloat` for customizing the panel's corner radius.
    ///                   If `nil`, a default value of `16` is used.
    public init<V: View>(
        rootView: V,
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition(),
        visualEffect: VisualEffectConfiguration? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        floatingPanel = FloatingPanel(
            rootView: Self
                .styledRootView(
                    rootView,
                    visualEffect: visualEffect,
                    cornerRadius: cornerRadius
                ),
            size: size,
            position: position
        )
    }
    
    /// Registers a global hotkey to toggle the panel's visibility.
    /// - Parameters:
    ///   - key: The `Key` for the hotkey (e.g., `.space`).
    ///   - modifiers: The modifier flags (e.g., `[.command, .shift]`). Defaults to Command+Shift.
    public func setupHotkey(
        key: Key,
        modifiers: NSEvent.ModifierFlags = [.command, .shift]
    ) {
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            Task { @MainActor in
                self?.togglePanel()
            }
        }
    }
    
    /// Makes the panel visible on the screen.
    public func showPanel() {
        guard !isVisible else { return }
        
        floatingPanel?.positionPanel()
        floatingPanel?.makeKeyAndOrderFront(nil)
        addEscapeEventMonitor()
        isVisible = true
    }
    
    /// Hides the panel.
    public func hidePanel() {
        guard isVisible else { return }
        
        floatingPanel?.close()
        removeEscapeEventMonitor()
        isVisible = false
    }
    
    /// Toggles the panel's visibility. If visible, it's hidden, and vice-versa.
    public func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    /// Toggles the panel's size between its compact and expanded states.
    public func togglePanelSize() {
        guard isVisible else { return }
        floatingPanel?.toggleSize()
    }
    
    /// Resizes the panel to a specific size.
    /// - Parameters:
    ///   - size: The target `CGSize`.
    ///   - animated: If `true`, the resize is animated. Defaults to `true`.
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard isVisible else { return }
        floatingPanel?.resizeTo(size, animated: animated)
    }
    
    /// Updates the panel's content with a new SwiftUI view.
    /// - Parameters:
    ///   - rootView: The new SwiftUI view to display.
    ///   - visualEffect: An optional `VisualEffectConfiguration` to apply to the new content.
    ///   - cornerRadius: An optional `CGFloat` for customizing the panel's corner radius.
    ///                   If `nil`, the previous corner radius is maintained.
    public func updateContentView<V: View>(
        _ rootView: V,
        visualEffect: VisualEffectConfiguration? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        floatingPanel?.updateContentView(
            Self.styledRootView(
                rootView,
                visualEffect: visualEffect,
                cornerRadius: cornerRadius
            )
        )
    }
    
    /// Returns the panel's current size.
    public func getCurrentSize() -> CGSize? {
        return floatingPanel?.getCurrentSize()
    }
    
    /// Checks if the panel is currently in its compact state.
    public func isCompact() -> Bool? {
        return floatingPanel?.isCompact()
    }
    
    /// Checks if the panel is currently visible.
    public func isPanelVisible() -> Bool {
        return isVisible
    }
    
    /// Registers a local event monitor to hide the panel when the Escape key is pressed.
    private func addEscapeEventMonitor() {
        guard escapeEventMonitor == nil else { return }
        
        escapeEventMonitor = NSEvent
            .addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
                if event.keyCode == 53 { // Keycode for Escape
                    Task { @MainActor in
                        self?.hidePanel()
                    }
                    return nil // Swallow the event
                }
                return event
            }
    }
    
    private func removeEscapeEventMonitor() {
        if let monitor = escapeEventMonitor {
            NSEvent.removeMonitor(monitor)
            escapeEventMonitor = nil
        }
    }
    
    deinit {
        // The hotKey and escapeEventMonitor are managed automatically by their respective systems
        // and will be deallocated correctly.
    }
    
    private static func styledRootView<V: View>(
        _ rootView: V,
        visualEffect: VisualEffectConfiguration?,
        cornerRadius: CGFloat?
    ) -> AnyView {
        AnyView(
            rootView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(VisualEffectView(config: visualEffect))
                .mask(
                    RoundedRectangle(
                        cornerRadius: cornerRadius ?? 16,
                        style: .continuous
                    )
                )
                .ignoresSafeArea()
        )
    }
}
