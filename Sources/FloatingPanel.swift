import AppKit
import SwiftUI

/// A reusable floating panel for macOS applications
@MainActor
public class FloatingPanel: NSPanel {
    
    /// Available positions for the floating panel
    public enum Position {
        case center
        case topLeft
        case topRight
        case bottomLeft
        case bottomRight
        case custom(x: CGFloat, y: CGFloat)
    }
    
    /// Available sizes for the floating panel
    public enum PanelSize: Equatable {
        case compact
        case expanded
        case custom(width: CGFloat, height: CGFloat)
        
        var size: CGSize {
            switch self {
            case .compact:
                return CGSize(width: 284, height: 200)
            case .expanded:
                return CGSize(width: 284, height: 600)
            case .custom(let width, let height):
                return CGSize(width: width, height: height)
            }
        }
        
        public static func == (lhs: PanelSize, rhs: PanelSize) -> Bool {
            switch (lhs, rhs) {
            case (.compact, .compact):
                return true
            case (.expanded, .expanded):
                return true
            case (.custom(let lhsWidth, let lhsHeight), .custom(let rhsWidth, let rhsHeight)):
                return lhsWidth == rhsWidth && lhsHeight == rhsHeight
            default:
                return false
            }
        }
    }
    
    private let panelPosition: Position
    private var currentSize: PanelSize = .compact
    
    /// Initialize a new floating panel with a SwiftUI view
    /// - Parameters:
    ///   - rootView: The SwiftUI view to display in the panel
    ///   - size: The initial size of the panel
    ///   - position: The position where the panel should appear
    public init<V: View>(rootView: V, size: PanelSize = .compact, position: Position = .center) {
        self.panelPosition = position
        self.currentSize = size
        
        super.init(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .titled, .fullSizeContentView],
            backing: .buffered,
            defer: true
        )
        
        setContentSize(size.size)
        
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
    
    /// Position the panel on screen based on the specified position
    public func positionPanel() {
        guard let screen = NSScreen.main else { return }
        
        let screenFrame = screen.visibleFrame
        let panelSize = frame.size
        
        let xPosition: CGFloat
        let yPosition: CGFloat
        
        switch panelPosition {
        case .center:
            xPosition = screenFrame.midX - panelSize.width / 2
            yPosition = screenFrame.midY - panelSize.height / 2
        case .topLeft:
            xPosition = screenFrame.minX + 20
            yPosition = screenFrame.maxY - panelSize.height - 20
        case .topRight:
            xPosition = screenFrame.maxX - panelSize.width - 20
            yPosition = screenFrame.maxY - panelSize.height - 20
        case .bottomLeft:
            xPosition = screenFrame.minX + 20
            yPosition = screenFrame.minY + 20
        case .bottomRight:
            xPosition = screenFrame.maxX - panelSize.width - 20
            yPosition = screenFrame.minY + 20
        case .custom(let x, let y):
            xPosition = x
            yPosition = y
        }
        
        setFrameOrigin(NSPoint(x: xPosition, y: yPosition))
    }
    
    /// Toggle between compact and expanded sizes
    public func toggleSize() {
        let newSize: PanelSize = currentSize == .compact ? .expanded : .compact
        resizeTo(newSize, animated: true)
    }
    
    /// Resize the panel to a specific size
    /// - Parameters:
    ///   - size: The target size
    ///   - animated: Whether to animate the resize
    public func resizeTo(_ size: PanelSize, animated: Bool = true) {
        guard currentSize != size else { return }
        
        let newSize = size.size
        let currentFrame = frame
        let newFrame = NSRect(
            x: currentFrame.origin.x - (newSize.width - currentFrame.width) / 2,
            y: currentFrame.origin.y - (newSize.height - currentFrame.height) / 2,
            width: newSize.width,
            height: newSize.height
        )
        
        if animated {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.3
                context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
                animator().setFrame(newFrame, display: true)
            }) {
                self.currentSize = size
                self.setContentSize(newSize)
            }
        } else {
            setFrame(newFrame, display: true)
            setContentSize(newSize)
            currentSize = size
        }
    }
    
    /// Get the current size of the panel
    /// - Returns: The current panel size
    public func getCurrentSize() -> PanelSize {
        return currentSize
    }
    
    /// Update the content view of the panel
    /// - Parameter rootView: The new SwiftUI view to display
    public func updateContentView<V: View>(_ rootView: V) {
        contentView = NSHostingView(rootView: rootView)
    }
}
