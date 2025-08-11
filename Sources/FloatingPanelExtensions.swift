import SwiftUI
import VisualEffectView

/// Extensions to make FloatingPanel easier to use
public extension View {
    
    /// Apply a visual effect background to the view
    /// - Parameter material: The visual effect material to use
    /// - Returns: A view with the visual effect background
    func floatingPanelBackground(material: NSVisualEffectView.Material = .underWindowBackground) -> some View {
        self.background(VisualEffectView(material: material))
    }
    
    /// Make the view suitable for use in a floating panel
    /// - Parameter material: The visual effect material to use
    /// - Returns: A view configured for floating panel use
    func floatingPanelStyle(material: NSVisualEffectView.Material = .underWindowBackground) -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .floatingPanelBackground(material: material)
            .ignoresSafeArea()
    }
}

/// Predefined content views for common floating panel use cases
public struct FloatingPanelContent {
    
    /// A simple text content view for floating panels
    public struct TextContent: View {
        let text: String
        let material: NSVisualEffectView.Material
        
        public init(_ text: String, material: NSVisualEffectView.Material = .underWindowBackground) {
            self.text = text
            self.material = material
        }
        
        public var body: some View {
            VStack {
                Text(text)
                    .foregroundStyle(.secondary)
                    .padding()
            }
        }
    }
    
    /// A loading content view for floating panels
    public struct LoadingContent: View {
        let message: String
        let material: NSVisualEffectView.Material
        
        public init(_ message: String = "Loading...", material: NSVisualEffectView.Material = .underWindowBackground) {
            self.message = message
            self.material = material
        }
        
        public var body: some View {
            VStack(spacing: 16) {
                ProgressView()
                    .scaleEffect(1.2)
                Text(message)
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// An error content view for floating panels
    public struct ErrorContent: View {
        let error: String
        let material: NSVisualEffectView.Material
        
        public init(_ error: String, material: NSVisualEffectView.Material = .underWindowBackground) {
            self.error = error
            self.material = material
        }
        
        public var body: some View {
            VStack(spacing: 16) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title)
                    .foregroundStyle(.red)
                Text(error)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
        }
    }
}
