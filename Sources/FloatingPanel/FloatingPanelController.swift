import AppKit
import SwiftUI
import VisualEffectView

@MainActor
public class FloatingPanelController {
    private var floatingPanel: FloatingPanel?
    private var escapeEventMonitor: Any?
    private var isVisible: Bool = false
    private let panelSize: FloatingPanelSize
    
    public init<V: View>(
        rootView: V,
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition(),
        visualEffect: VisualEffectConfiguration? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.panelSize = size
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
    
    public func getPanelSize() -> FloatingPanelSize {
        return panelSize
    }
    
    public func showPanel() {
        guard !isVisible else { return }
        
        floatingPanel?.positionPanel()
        floatingPanel?.makeKeyAndOrderFront(nil)
        addEscapeEventMonitor()
        isVisible = true
    }
    
    public func hidePanel() {
        guard isVisible else { return }
        
        floatingPanel?.close()
        removeEscapeEventMonitor()
        isVisible = false
    }
    
    public func togglePanel() {
        if isVisible {
            hidePanel()
        } else {
            showPanel()
        }
    }
    
    public func togglePanelSize() {
        guard isVisible else { return }
        floatingPanel?.toggleSize()
    }
    
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard isVisible else { return }
        floatingPanel?.resizeTo(size, animated: animated)
    }
    
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
    
    public func getCurrentSize() -> CGSize? {
        return floatingPanel?.getCurrentSize()
    }
    
    public func isCompact() -> Bool? {
        return floatingPanel?.isCompact()
    }
    
    public func isPanelVisible() -> Bool {
        return isVisible
    }
    
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
                        cornerRadius: cornerRadius ?? 52 / 2,
                        style: .continuous
                    )
                )
                .ignoresSafeArea()
        )
    }
}
