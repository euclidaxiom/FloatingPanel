import SwiftUI
import FloatingPanel

import SwiftUI
import FloatingPanel

struct ContentView: View {
    @Environment(\.panelController) private var panelController

    var body: some View {
        VStack {
            if let panelController {
                Text("Compact Height: \(panelController.getPanelSize().compact.height)")
                Text("Expanded Height: \(panelController.getPanelSize().expanded.height)")
            }
        }
    }
}
