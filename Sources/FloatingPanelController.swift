import AppKit
import SwiftUI
import VisualEffectView
@preconcurrency import HotKey

/// A controller for managing floating panels with hotkey support
@MainActor
public class FloatingPanelController {
    private var floatingPanel: FloatingPanel?
    private var hotKey: HotKey?
    private var escapeEventMonitor: Any?
    private var isVisible: Bool = false
    
    /// Initialize a new floating panel controller
    /// - Parameters:
    ///   - rootView: The SwiftUI view to display in the panel
    ///   - size: The size configuration for the panel
    ///   - position: The position configuration for the panel
    ///   - visualEffect: The visual effect material to use for the panel background
    public init<V: View>(
        rootView: V,
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition(),
        visualEffect: VisualEffectConfiguration? = nil
    ) {
        // Apply the floating panel style automatically
        let styledView = AnyView(
            rootView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(VisualEffectView(config: visualEffect))
                .ignoresSafeArea()
        )
        
        floatingPanel = FloatingPanel(rootView: styledView, size: size, position: position)
    }
    
    /// Setup a hotkey to show/hide the panel
    /// - Parameters:
    ///   - key: The key to use for the hotkey
    ///   - modifiers: The modifier keys to combine with the main key
    public func setupHotkey(key: Key, modifiers: NSEvent.ModifierFlags = [.command, .shift]) {
        hotKey = HotKey(key: key, modifiers: modifiers)
        hotKey?.keyDownHandler = { [weak self] in
            Task { @MainActor in
                self?.togglePanel()
            }
        }
    }
    
    /// Show the panel
    public func showPanel() {
        guard !isVisible else { return }
        
        floatingPanel?.positionPanel()
        floatingPanel?.makeKeyAndOrderFront(nil)
        addEscapeEventMonitor()
        isVisible = true
    }
    
    /// Hide the panel
    public func hidePanel() {
        guard isVisible else { return }
        
        floatingPanel?.close()
        removeEscapeEventMonitor()
        isVisible = false
    }
    
    /// Toggle the panel visibility
    public func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    /// Toggle the panel size between compact and expanded
    public func togglePanelSize() {
        guard isVisible else { return }
        
        floatingPanel?.toggleSize()
    }
    
    /// Resize the panel to a specific size
    /// - Parameters:
    ///   - size: The target size
    ///   - animated: Whether to animate the resize
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard isVisible else { return }
        
        floatingPanel?.resizeTo(size, animated: animated)
    }
    
    /// Update the content view of the panel
    /// - Parameters:
    ///   - rootView: The new SwiftUI view to display
    ///   - material: The visual effect material to use for the panel background
    public func updateContentView<V: View>(_ rootView: V, visualEffect: VisualEffectConfiguration? = nil) {
        // Apply the floating panel style automatically
        let styledView = AnyView(
            rootView
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(VisualEffectView(config: visualEffect))
                .ignoresSafeArea()
        )
        
        floatingPanel?.updateContentView(styledView)
    }
    
    /// Get the current size of the panel
    /// - Returns: The current panel size
    public func getCurrentSize() -> CGSize? {
        return floatingPanel?.getCurrentSize()
    }
    
    /// Check if the panel is currently in compact size
    /// - Returns: True if the panel is in compact size, false otherwise
    public func isCompact() -> Bool? {
        return floatingPanel?.isCompact()
    }
    
    /// Check if the panel is currently visible
    /// - Returns: True if the panel is visible, false otherwise
    public func isPanelVisible() -> Bool {
        return isVisible
    }
    
    private func addEscapeEventMonitor() {
        guard escapeEventMonitor == nil else { return }
        
        escapeEventMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // 53 is the keycode for Escape
                Task { @MainActor in
                    self?.hidePanel()
                }
                return nil
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
        // Note: removeEscapeEventMonitor() cannot be called from deinit due to MainActor isolation
        // The monitor will be automatically cleaned up by the system
        // hotKey will be automatically deallocated
    }
}
