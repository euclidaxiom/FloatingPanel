import AppKit
import SwiftUI
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
    ///   - size: The initial size of the panel
    ///   - position: The position where the panel should appear
    public init<V: View>(rootView: V, size: FloatingPanel.PanelSize = .compact, position: FloatingPanel.Position = .center) {
        floatingPanel = FloatingPanel(rootView: rootView, size: size, position: position)
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
    public func resizeTo(_ size: FloatingPanel.PanelSize, animated: Bool = true) {
        guard isVisible else { return }
        
        floatingPanel?.resizeTo(size, animated: animated)
    }
    
    /// Update the content view of the panel
    /// - Parameter rootView: The new SwiftUI view to display
    public func updateContentView<V: View>(_ rootView: V) {
        floatingPanel?.updateContentView(rootView)
    }
    
    /// Get the current size of the panel
    /// - Returns: The current panel size
    public func getCurrentSize() -> FloatingPanel.PanelSize? {
        return floatingPanel?.getCurrentSize()
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
