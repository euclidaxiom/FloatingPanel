import AppKit
import SwiftUI

public protocol FloatingPanelPosition {
    func calculatePosition(for panelSize: CGSize) -> CGPoint
}

public protocol FloatingPanelSize {
    var compact: CGSize { get }
    var expanded: CGSize { get }
}

public struct DefaultPanelPosition: FloatingPanelPosition {
    public init() {}
    
    public func calculatePosition(for panelSize: CGSize) -> CGPoint {
        guard let screen = NSScreen.main else { return .zero }
        let screenFrame = screen.visibleFrame
        
        return CGPoint(
            x: screenFrame.midX - panelSize.width / 2,
            y: screenFrame.maxY - panelSize.height - 210
        )
    }
}

public struct DefaultPanelSize: FloatingPanelSize {
    public let compact: CGSize = CGSize(width: 600, height: 52)
    public let expanded: CGSize = CGSize(width: 600, height: 431)
    
    public init() {}
}

@MainActor
public class FloatingPanel: NSPanel {
    
    private let panelPosition: FloatingPanelPosition
    private let panelSize: FloatingPanelSize
    private var currentSize: CGSize
    
    public init<V: View>(
        rootView: V,
        size: FloatingPanelSize = DefaultPanelSize(),
        position: FloatingPanelPosition = DefaultPanelPosition()
    ) {
        self.panelPosition = position
        self.panelSize = size
        self.currentSize = size.compact
        
        super.init(
            contentRect: .zero,
            styleMask: [.fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        
        setContentSize(currentSize)
        
        configurePanel()
        addContentView(rootView: rootView)
        positionPanel()
    }
    
    override public var canBecomeKey: Bool {
        return true
    }
    
    private func configurePanel() {
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        level = .floating
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        becomesKeyOnlyIfNeeded = false
//        hidesOnDeactivate = false   // Verificar o que é a aplicação se tornar inativa
        
        collectionBehavior = [.canJoinAllSpaces, .stationary]
    }
    
    private func addContentView<V: View>(rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
    
    public func positionPanel() {
        let position = panelPosition.calculatePosition(for: frame.size)
        setFrameOrigin(position)
    }
    
    public func toggleSize() {
        let newSize = currentSize == panelSize.compact ? panelSize.expanded : panelSize.compact
        resizeTo(newSize, animated: true)
    }
    
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard currentSize != size else { return }
        
        let currentFrame = frame
        let newFrame = NSRect(
            x: currentFrame.origin.x - (size.width - currentFrame.width) / 2,
            y: currentFrame.origin
                .y - (
                    size.height - currentFrame.height
                ),
            // Anchor resize to the top
            width: size.width,
            height: size.height
        )
        
        if animated {
            NSAnimationContext.runAnimationGroup(
                { context in
                    context.duration = 0.1
                    context.timingFunction = CAMediaTimingFunction(
                        name: .easeInEaseOut
                    )
                    animator().setFrame(newFrame, display: true)
                },
                completionHandler: { [weak self] in
                    Task { @MainActor in
                        self?.currentSize = size
                        self?.setContentSize(size)
                    }
                })
        } else {
            setFrame(newFrame, display: true)
            setContentSize(size)
            currentSize = size
        }
    }
    
    public func getCurrentSize() -> CGSize {
        return currentSize
    }
    
    public func isCompact() -> Bool {
        return currentSize == panelSize.compact
    }
    
    public func updateContentView<V: View>(_ rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
}
