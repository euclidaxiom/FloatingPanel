# FloatingPanel

A reusable floating panel library for macOS applications built with SwiftUI.

## Features

- 🪟 Floating panels that stay on top of other windows
- ⌨️ Hotkey support for showing/hiding panels
- 🎨 Visual effects with native macOS materials
- 📏 Protocol-based size configuration (compact + expanded)
- 📍 Protocol-based position configuration
- 🎭 Smooth animations
- 🔄 Easy content updates
- ✨ Automatic styling - no need to remember modifiers
- 🔧 Extensible architecture with protocols

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
        
        panelController = FloatingPanelController(
            rootView: contentView
        )
        
        // Setup hotkey (Cmd+Shift+Space)
        panelController?.setupHotkey(key: .space, modifiers: [.command, .shift])
    }
    
    private func showPanel() {
        panelController?.showPanel()
    }
}
```

### Automatic Styling

The library automatically applies the floating panel styling to your content, so you don't need to remember to use modifiers. The styling includes:

- Full-width and height layout
- Native macOS visual effects
- Proper safe area handling

```swift
// No need to remember modifiers anymore!
let content = Text("Hello, World!")
let controller = FloatingPanelController(rootView: content)

// Custom material is still supported
let controller = FloatingPanelController(
    rootView: content,
    material: .popover
)
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

// You can also customize the material for pre-built content
let panelController = FloatingPanelController(
    rootView: errorContent,
    material: .hudWindow
)
```

### Custom Position and Size Configurations

The library uses protocols for maximum flexibility. You can create custom configurations or use the provided ones:

```swift
// Using built-in configurations
let controller = FloatingPanelController(
    rootView: content,
    size: WidePanelSize(),        // 400x150 → 400x400
    position: TopRightPosition()  // Top-right corner
)

// Custom size configuration
struct MyPanelSize: FloatingPanelSize {
    let compact: CGSize = CGSize(width: 300, height: 100)
    let expanded: CGSize = CGSize(width: 300, height: 500)
}

// Custom position configuration
struct MyPanelPosition: FloatingPanelPosition {
    func calculatePosition(for panelSize: CGSize) -> CGPoint {
        // Your custom positioning logic
        return CGPoint(x: 100, y: 100)
    }
}

let controller = FloatingPanelController(
    rootView: content,
    size: MyPanelSize(),
    position: MyPanelPosition()
)
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
    }
}

// Usage with custom material
let panelController = FloatingPanelController(
    rootView: CustomPanelContent(),
    material: .popover
)

// Usage with custom position and size
let panelController = FloatingPanelController(
    rootView: CustomPanelContent(),
    size: WidePanelSize(),
    position: TopRightPosition(),
    material: .popover
)
```

## API Reference

### Protocols

#### FloatingPanelPosition

Protocol for defining panel positions:

```swift
protocol FloatingPanelPosition {
    func calculatePosition(for panelSize: CGSize) -> CGPoint
}
```

#### FloatingPanelSize

Protocol for defining panel sizes:

```swift
protocol FloatingPanelSize {
    var compact: CGSize { get }
    var expanded: CGSize { get }
}
```

### Built-in Configurations

#### Position Configurations

- `DefaultPanelPosition()` - Centers the panel on screen
- `TopRightPosition()` - Positions in top-right corner
- `BottomLeftPosition()` - Positions in bottom-left corner
- `CustomPosition(x:y:)` - Custom coordinates

#### Size Configurations

- `DefaultPanelSize()` - 284x200 → 284x600
- `WidePanelSize()` - 400x150 → 400x400
- `TallPanelSize()` - 200x300 → 200x600
- `CustomPanelSize(compact:expanded:)` - Custom dimensions

### FloatingPanel

The main panel class that creates floating windows.

#### Initialization

```swift
init<V: View>(
    rootView: V,
    size: FloatingPanelSize = DefaultPanelSize(),
    position: FloatingPanelPosition = DefaultPanelPosition()
)
```

#### Methods

- `positionPanel()` - Reposition the panel on screen
- `toggleSize()` - Toggle between compact and expanded sizes
- `resizeTo(_:animated:)` - Resize to a specific size
- `updateContentView(_:)` - Update the panel content
- `getCurrentSize()` - Get the current panel size
- `isCompact()` - Check if panel is in compact size

### FloatingPanelController

A controller that manages panel visibility and hotkeys.

#### Initialization

```swift
init<V: View>(
    rootView: V,
    size: FloatingPanelSize = DefaultPanelSize(),
    position: FloatingPanelPosition = DefaultPanelPosition(),
    material: NSVisualEffectView.Material = .underWindowBackground
)
```

#### Methods

- `setupHotkey(key:modifiers:)` - Setup a hotkey to toggle the panel
- `showPanel()` - Show the panel
- `hidePanel()` - Hide the panel
- `togglePanel()` - Toggle panel visibility
- `togglePanelSize()` - Toggle panel size
- `resizeTo(_:animated:)` - Resize the panel
- `updateContentView(_:material:)` - Update panel content with optional material
- `getCurrentSize()` - Get the current panel size
- `isCompact()` - Check if panel is in compact size
- `isPanelVisible()` - Check if panel is visible

### View Extensions

#### floatingPanelBackground

Apply a visual effect background to any view:

```swift
Text("Hello")
    .floatingPanelBackground(material: .popover)
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
    }
}

// Usage
let notification = NotificationPanel(message: "New message received!")
let controller = FloatingPanelController(
    rootView: notification,
    size: CustomPanelSize(
        compact: CGSize(width: 300, height: 60),
        expanded: CGSize(width: 300, height: 120)
    ),
    position: TopRightPosition(),
    material: .hudWindow
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
