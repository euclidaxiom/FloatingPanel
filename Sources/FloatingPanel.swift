import AppKit
import SwiftUI

// MARK: - Protocols

/// A protocol that defines the position of the floating panel on the screen.
///
/// Conform to this protocol to create custom positioning logic for the panel.
public protocol FloatingPanelPosition {
    /// Calculates the origin point for the panel based on its size.
    /// - Parameter panelSize: The size of the panel's frame.
    /// - Returns: The `CGPoint` where the panel's top-left corner should be.
    func calculatePosition(for panelSize: CGSize) -> CGPoint
}

/// A protocol that defines the compact and expanded sizes of the floating panel.
///
/// Conform to this protocol to specify custom dimensions for the panel's two states.
public protocol FloatingPanelSize {
    /// The smaller, default size of the panel.
    var compact: CGSize { get }
    /// The larger size of the panel, used when expanded.
    var expanded: CGSize { get }
}

// MARK: - Default Implementations

/// The default position for the panel, centering it horizontally near the top of the screen.
public struct DefaultPanelPosition: FloatingPanelPosition {
    public init() {}
    
    public func calculatePosition(for panelSize: CGSize) -> CGPoint {
        guard let screen = NSScreen.main else { return .zero }
        let screenFrame = screen.visibleFrame
        
        // Center horizontally, place 210 points from the top.
        return CGPoint(
            x: screenFrame.midX - panelSize.width / 2,
            y: screenFrame.maxY - 210
        )
    }
}

/// The default compact and expanded sizes for the panel.
public struct DefaultPanelSize: FloatingPanelSize {
    public let compact: CGSize = CGSize(width: 600, height: 64)
    public let expanded: CGSize = CGSize(width: 600, height: 431)
    
    public init() {}
}

// MARK: - FloatingPanel

/// A custom `NSPanel` subclass that hosts a SwiftUI view and provides floating behavior.
///
/// This panel is the core windowing component of the library. It is typically managed by a `FloatingPanelController`.
@MainActor
public class FloatingPanel: NSPanel {
    
    private let panelPosition: FloatingPanelPosition
    private let panelSize: FloatingPanelSize
    private var currentSize: CGSize
    
    /// Initializes and configures the floating panel.
    /// - Parameters:
    ///   - rootView: The root SwiftUI view to be displayed inside the panel.
    ///   - size: A `FloatingPanelSize` conforming object that defines the panel's dimensions.
    ///   - position: A `FloatingPanelPosition` conforming object that defines the panel's on-screen location.
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
        
        // Allows the panel to be visible on all spaces.
        collectionBehavior = [.canJoinAllSpaces, .stationary]
    }
    
    private func addContentView<V: View>(rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
    
    /// Calculates and sets the panel's position on the screen.
    public func positionPanel() {
        let position = panelPosition.calculatePosition(for: frame.size)
        setFrameOrigin(position)
    }
    
    /// Animates a transition between the compact and expanded sizes.
    public func toggleSize() {
        let newSize = currentSize == panelSize.compact ? panelSize.expanded : panelSize.compact
        resizeTo(newSize, animated: true)
    }
    
    /// Resizes the panel to a specific size, with an optional animation.
    /// - Parameters:
    ///   - size: The target `CGSize` for the panel.
    ///   - animated: If `true`, the resize will be animated. Defaults to `true`.
    public func resizeTo(_ size: CGSize, animated: Bool = true) {
        guard currentSize != size else { return }
        
        let currentFrame = frame
        let newFrame = NSRect(
            x: currentFrame.origin.x - (size.width - currentFrame.width) / 2,
            y: currentFrame.origin.y - (size.height - currentFrame.height), // Anchor resize to the top
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
    
    /// Returns the current size of the panel.
    public func getCurrentSize() -> CGSize {
        return currentSize
    }
    
    /// Checks if the panel is currently at its compact size.
    public func isCompact() -> Bool {
        return currentSize == panelSize.compact
    }
    
    /// Replaces the panel's content with a new SwiftUI view.
    /// - Parameter rootView: The new SwiftUI view to display.
    public func updateContentView<V: View>(_ rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
}