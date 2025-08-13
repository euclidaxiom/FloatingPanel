import SwiftUI
import FloatingPanel

struct ContentView: View {
    var panelController: FloatingPanelController?

    var body: some View {
        VStack {
            Text("Hello, world!")
                .foregroundStyle(.secondary)
                .padding()
        }
    }
}
