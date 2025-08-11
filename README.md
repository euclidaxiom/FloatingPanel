# FloatingPanel

A reusable floating panel library for macOS applications built with SwiftUI.

## Features

- 🪟 Floating panels that stay on top of other windows
- ⌨️ Hotkey support for showing/hiding panels
- 🎨 Visual effects with native macOS materials
- 📏 Multiple size options (compact, expanded, custom)
- 📍 Flexible positioning (center, corners, custom)
- 🎭 Smooth animations
- 🔄 Easy content updates

## Installation

Add this package to your Xcode project:

```swift
dependencies: [
    .package(url: "path/to/FloatingPanel", from: "1.0.0")
]
```

## Quick Start

### Basic Usage

```swift
import SwiftUI
import FloatingPanel

struct ContentView: View {
    @State private var panelController: FloatingPanelController?
    
    var body: some View {
        VStack {
            Button("Show Panel") {
                showPanel()
            }
        }
        .onAppear {
            setupPanel()
        }
    }
    
    private func setupPanel() {
        let contentView = Text("Hello, Floating Panel!")
            .floatingPanelStyle()
        
        panelController = FloatingPanelController(
            rootView: contentView,
            size: .compact,
            position: .center
        )
        
        // Setup hotkey (Cmd+Shift+Space)
        panelController?.setupHotkey(key: .space, modifiers: [.command, .shift])
    }
    
    private func showPanel() {
        panelController?.showPanel()
    }
}
```

### Using Pre-built Content Views

```swift
// Text content
let textContent = FloatingPanelContent.TextContent("Your message here")

// Loading content
let loadingContent = FloatingPanelContent.LoadingContent("Processing...")

// Error content
let errorContent = FloatingPanelContent.ErrorContent("Something went wrong")

let panelController = FloatingPanelController(rootView: textContent)
```

### Custom Content with Visual Effects

```swift
struct CustomPanelContent: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.fill")
                .font(.title)
                .foregroundStyle(.yellow)
            
            Text("Custom Panel")
                .font(.headline)
            
            Button("Action") {
                // Your action here
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .floatingPanelStyle(material: .popover)
    }
}
```

## API Reference

### FloatingPanel

The main panel class that creates floating windows.

#### Initialization

```swift
init<V: View>(
    rootView: V,
    size: PanelSize = .compact,
    position: Position = .center
)
```

#### Panel Sizes

```swift
enum PanelSize {
    case compact      // 284x200
    case expanded     // 400x300
    case custom(width: CGFloat, height: CGFloat)
}
```

#### Panel Positions

```swift
enum Position {
    case center
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
    case custom(x: CGFloat, y: CGFloat)
}
```

#### Methods

- `positionPanel()` - Reposition the panel on screen
- `toggleSize()` - Toggle between compact and expanded sizes
- `resizeTo(_:animated:)` - Resize to a specific size
- `updateContentView(_:)` - Update the panel content
- `getCurrentSize()` - Get the current panel size

### FloatingPanelController

A controller that manages panel visibility and hotkeys.

#### Initialization

```swift
init<V: View>(
    rootView: V,
    size: FloatingPanel.PanelSize = .compact,
    position: FloatingPanel.Position = .center
)
```

#### Methods

- `setupHotkey(key:modifiers:)` - Setup a hotkey to toggle the panel
- `showPanel()` - Show the panel
- `hidePanel()` - Hide the panel
- `togglePanel()` - Toggle panel visibility
- `togglePanelSize()` - Toggle panel size
- `resizeTo(_:animated:)` - Resize the panel
- `updateContentView(_:)` - Update panel content
- `isPanelVisible()` - Check if panel is visible

### View Extensions

#### floatingPanelBackground

Apply a visual effect background to any view:

```swift
Text("Hello")
    .floatingPanelBackground(material: .popover)
```

#### floatingPanelStyle

Apply complete floating panel styling:

```swift
Text("Hello")
    .floatingPanelStyle(material: .underWindowBackground)
```

## Examples

### Notification Panel

```swift
struct NotificationPanel: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "bell.fill")
                .foregroundStyle(.blue)
            Text(message)
                .font(.body)
        }
        .padding()
        .floatingPanelStyle(material: .hudWindow)
    }
}

// Usage
let notification = NotificationPanel(message: "New message received!")
let controller = FloatingPanelController(
    rootView: notification,
    size: .custom(width: 300, height: 60),
    position: .topRight
)
```

### Quick Actions Panel

```swift
struct QuickActionsPanel: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
            
            Button("Copy") { /* action */ }
            Button("Paste") { /* action */ }
            Button("Cut") { /* action */ }
        }
        .padding()
        .floatingPanelStyle()
    }
}
```

## Requirements

- macOS 13.0+
- Xcode 14.0+
- Swift 5.7+

## Dependencies

- [HotKey](https://github.com/soffes/HotKey) - For global hotkey support
- [VisualEffectView](https://github.com/your-repo/VisualEffectView) - For native macOS visual effects

## License

This project is licensed under the MIT License.
