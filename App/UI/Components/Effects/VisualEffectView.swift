import AppKit
import SwiftUI

// MARK: - Visual Effect View
/// NSViewRepresentable wrapper for NSVisualEffectView
/// Provides native macOS blur and vibrancy effects

struct VisualEffectView: NSViewRepresentable {

    // MARK: - Properties
    var material: NSVisualEffectView.Material
    var blendingMode: NSVisualEffectView.BlendingMode
    var state: NSVisualEffectView.State
    var isEmphasized: Bool

    // MARK: - Initialization
    init(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow,
        state: NSVisualEffectView.State = .active,
        isEmphasized: Bool = false
    ) {
        self.material = material
        self.blendingMode = blendingMode
        self.state = state
        self.isEmphasized = isEmphasized
    }

    // MARK: - NSViewRepresentable
    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = state
        view.isEmphasized = isEmphasized
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
        nsView.state = state
        nsView.isEmphasized = isEmphasized
    }
}

// MARK: - Convenience Modifiers
extension View {

    /// Applies a blur background effect
    func blurBackground(
        material: NSVisualEffectView.Material = .hudWindow,
        blendingMode: NSVisualEffectView.BlendingMode = .behindWindow
    ) -> some View {
        background(
            VisualEffectView(material: material, blendingMode: blendingMode)
        )
    }
}

// MARK: - Preview
#Preview {
    ZStack {
        LinearGradient(
            colors: [.blue, .purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )

        VStack(spacing: 20) {
            Text("Blur Effect Demo")
                .foregroundColor(.white)
                .padding()
                .blurBackground()
                .cornerRadius(10)

            Text("HUD Window Material")
                .foregroundColor(.white)
                .padding()
                .background(VisualEffectView(material: .hudWindow))
                .cornerRadius(10)
        }
    }
    .frame(width: 300, height: 200)
}
