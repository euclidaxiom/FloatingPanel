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
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition(),
        visualEffect: VisualEffectConfiguration? = nil,
        cornerRadius: CGFloat? = nil,
        @ViewBuilder content: (FloatingPanelController) -> V
    ) {
        self.panelSize = size
            
        let rootView = content(self)
            
        self.floatingPanel = FloatingPanel(
            rootView: Self
                .styledRootView(
                    rootView,
                    for: self,
                    visualEffect: visualEffect,
                    cornerRadius: cornerRadius
                ),
            size: size,
            position: position
        )
    }

    public convenience init<V: View>(
        rootView: V,
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition(),
        visualEffect: VisualEffectConfiguration? = nil,
        cornerRadius: CGFloat? = nil
    ) {
        self.init(
            size: size,
            position: position,
            visualEffect: visualEffect,
            cornerRadius: cornerRadius,
            content: {
                _ in rootView
            }
        )
    }
    
    public func getPanelSize() -> FloatingPanelSize {
        return panelSize
    }
    
    private var clickOutsideMonitor: Any?

    private func addClickOutsideMonitor() {
        clickOutsideMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self = self, let panel = self.floatingPanel else { return }
            
            let clickLocation = NSEvent.mouseLocation
            let panelFrame = panel.frame
            
            if !panelFrame.contains(clickLocation) {
                DispatchQueue.main.async {
                    self.hidePanel()
                }
            }
        }
    }

    private func removeClickOutsideMonitor() {
        if let monitor = clickOutsideMonitor {
            NSEvent.removeMonitor(monitor)
            clickOutsideMonitor = nil
        }
    }
    
    public func showPanel() {
        guard !isVisible else { return }
        
        floatingPanel?.positionPanel()
        
        floatingPanel?.orderFront(nil)
            
        DispatchQueue.main.async {
            self.floatingPanel?.makeKey()
                
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                if !(self.floatingPanel?.isKeyWindow ?? false) {
                    self.floatingPanel?.makeKey()
                }
            }
        }
        
        addEscapeEventMonitor()
        addClickOutsideMonitor()
        
        isVisible = true
    }
    
    public func hidePanel() {
        guard isVisible else { return }
        
        floatingPanel?.close()
        
        removeEscapeEventMonitor()
        removeClickOutsideMonitor()
        
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
                rootView, for: self,
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
                if event.keyCode == 53 {
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

    }
    
    private static func styledRootView<V: View>(
        _ rootView: V,
        for controller: FloatingPanelController,
        visualEffect: VisualEffectConfiguration?,
        cornerRadius: CGFloat?
    ) -> AnyView {
        AnyView(
            rootView
                .environment(\.panelController, controller)
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

public struct PanelControllerKey: EnvironmentKey {
    public static let defaultValue: FloatingPanelController? = nil
}

public extension EnvironmentValues {
    var panelController: FloatingPanelController? {
        get { self[PanelControllerKey.self] }
        set { self[PanelControllerKey.self] = newValue }
    }
}
