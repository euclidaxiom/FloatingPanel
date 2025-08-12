import AppKit
import SwiftUI

/// Protocol for defining panel positions
public protocol FloatingPanelPosition {
    func calculatePosition(for panelSize: CGSize) -> CGPoint
}

/// Protocol for defining panel sizes
public protocol FloatingPanelSize {
    var compact: CGSize { get }
    var expanded: CGSize { get }
}

/// Default panel position configuration
public struct DefaultPanelPosition: FloatingPanelPosition {
    public init() {}
    
    public func calculatePosition(for panelSize: CGSize) -> CGPoint {
        guard let screen = NSScreen.main else { return .zero }
        
        let screenFrame = screen.visibleFrame
        
        return CGPoint(
            x: screenFrame.midX - panelSize.width / 2,
            y: CGFloat(210)
        )
    }
}

/// Default panel size configuration
public struct DefaultPanelSize: FloatingPanelSize {
    public let compact: CGSize = CGSize(width: 600, height: 64)
    public let expanded: CGSize = CGSize(width: 600, height: 431)
    
    public init() {}
}

/// A reusable floating panel for macOS applications
@MainActor
public class FloatingPanel: NSPanel {
    
    private let panelPosition: FloatingPanelPosition
    private let panelSize: FloatingPanelSize
    private var currentSize: CGSize
    
    /// Initialize a new floating panel with a SwiftUI view
    /// - Parameters:
    ///   - rootView: The SwiftUI view to display in the panel
    ///   - size: The size configuration for the panel
    ///   - position: The position configuration for the panel
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
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        
        setContentSize(currentSize)
        
        configurePanel()
        addContentView(rootView: rootView)
        positionPanel()
    }
    
    private func configurePanel() {
        backgroundColor = .clear
        isOpaque = false
        hasShadow = true
        level = .floating
        titlebarAppearsTransparent = true
        titleVisibility = .hidden
        
        collectionBehavior = [
            .canJoinAllSpaces,
            .stationary
        ]
    }
    
    private func addContentView<V: View>(rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
    
    /// Position the panel on screen based on the position configuration
    public func positionPanel() {
        let position = panelPosition.calculatePosition(for: frame.size)
        setFrameOrigin(position)
    }
    
    /// Toggle between compact and expanded sizes
    public func toggleSize() {
        let newSize = currentSize == panelSize.compact ? panelSize.expanded : panelSize.compact
        resizeTo(newSize, animated: true)
    }
    
    /// Resize the panel to a specific size
    /// - Parameters:
    ///   - size: The target size
    ///   - animated: Whether to animate the resize
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard currentSize != size else { return }
        
        let currentFrame = frame
        let newFrame = NSRect(
            x: currentFrame.origin.x - (size.width - currentFrame.width) / 2,
            y: currentFrame.origin.y - (size.height - currentFrame.height) / 2,
            width: size.width,
            height: size.height
        )
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animator().setFrame(newFrame, display: true)
            }, completionHandler: { [weak self] in
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
    
    /// Get the current size of the panel
    /// - Returns: The current panel size
    public func getCurrentSize() -> CGSize {
        return currentSize
    }
    
    /// Check if the panel is currently in compact size
    /// - Returns: True if the panel is in compact size, false otherwise
    public func isCompact() -> Bool {
        return currentSize == panelSize.compact
    }
    
    /// Update the content view of the panel
    /// - Parameter rootView: The new SwiftUI view to display
    public func updateContentView<V: View>(_ rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
}
