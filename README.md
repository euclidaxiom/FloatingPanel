# FloatingPanel

A lightweight Swift package for creating reusable, protocol-driven floating panels in macOS applications.

This package is designed for building accessory-style applications (e.g., menu bar apps) where the panel is the primary interface, running without a Dock icon.

## Core Concepts

The library is built around two main components:

1.  `FloatingPanel`: An `NSPanel` subclass that hosts your SwiftUI content. It manages the window's appearance, behavior, and animations.
2.  `FloatingPanelController`: The main entry point for using the library. It manages the panel's lifecycle, visibility, hotkey registration, and content updates.

Customization is handled through two simple protocols:

-   `FloatingPanelPosition`: Defines *where* the panel appears on the screen.
-   `FloatingPanelSize`: Defines the panel's `compact` and `expanded` dimensions.

## Application Setup

Since this package is intended for accessory applications, you'll need to configure your app to run without a main window or Dock icon.

### 1. Configure Info.plist

To hide the app's Dock icon and make it a background agent, add the following key-value pair to your project's `Info.plist` file:

**Key:** `Application is agent (UIElement)`
**Value:** `YES`

### 2. Use an AppDelegate

Instead of the standard SwiftUI `App` lifecycle with a `WindowGroup`, you'll use an `AppDelegate` to control the application and set up the panel.

```swift
import SwiftUI

@main
struct YourApp: App {
    // Set the app delegate.
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // An empty scene is used because the panel is managed by the controller.
        Settings {
            EmptyView()
        }
    }
}
```

## Quick Start

In your `AppDelegate`, create and hold a reference to the `FloatingPanelController`.

```swift
import SwiftUI
import FloatingPanel

class AppDelegate: NSObject, NSApplicationDelegate {
    // Hold the controller in a property to keep the panel alive.
    private var panelController: FloatingPanelController?

    func applicationDidFinishLaunching(_ notification: Notification) {
        // 1. Create the view for the panel's content.
        let contentView = ContentView()
        
        // 2. Initialize the controller.
        panelController = FloatingPanelController(rootView: contentView)
        
        // 3. Set up a global hotkey to toggle the panel.
        panelController?.setupHotkey(key: .space, modifiers: [.command, .option])
    }
}
```

## Customization

### Custom Size & Position

Create your own structs conforming to `FloatingPanelSize` and `FloatingPanelPosition` to customize the panel's dimensions and location.

```swift
// A custom size configuration.
struct PanelSize: FloatingPanelSize {
    let compact: CGSize = CGSize(width: 344, height: 57)
    let expanded: CGSize = CGSize(width: 344, height: 344)
}

// A custom position configuration (top-right corner).
struct TopRightCorner: FloatingPanelPosition {
    func calculatePosition(for panelSize: CGSize) -> CGPoint {
        guard let screen = NSScreen.main else { return .zero }
        let screenFrame = screen.visibleFrame
        
        return CGPoint(
            x: screenFrame.maxX - panelSize.width - 20, // 20pts padding
            y: screenFrame.maxY - panelSize.height - 20
        )
    }
}

// Initialize the controller with your custom configurations.
panelController = FloatingPanelController(
    rootView: MyContentView(),
    size: WidePanel(),
    position: TopRightCorner()
)
```

### Updating Content

You can dynamically change the view displayed in the panel at any time.

```swift
func showLoadingState() {
    let loadingView = ProgressView()
    panelController?.updateContentView(loadingView)
}
```

## API Overview

### Protocols

-   `FloatingPanelPosition`: Requires `func calculatePosition(for panelSize: CGSize) -> CGPoint`.
-   `FloatingPanelSize`: Requires `var compact: CGSize` and `var expanded: CGSize`.

### Main Class: `FloatingPanelController`

-   `init<V: View>(rootView:size:position:visualEffect:)`: Creates the panel.
-   `setupHotkey(key:modifiers:)`: Registers a global hotkey.
-   `showPanel()`: Shows the panel.
-   `hidePanel()`: Hides the panel.
-   `togglePanel()`: Toggles visibility.
-   `togglePanelSize()`: Toggles between compact and expanded sizes.
-   `updateContentView<V: View>(_:visualEffect:)`: Swaps the content view.

## Dependencies

-   [HotKey](https://github.com/soffes/HotKey): For registering global hotkeys.
-   [VisualEffectView](https://github.com/euclidaxiom/VisualEffectView): For the native macOS material.
