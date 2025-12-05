import SwiftUI
import SwiftUIIntrospect

// MARK: - SwiftUI Introspect Helpers
/// Helper utilities and examples for using SwiftUIIntrospect
/// This file demonstrates best practices for SwiftUI ↔ AppKit interop

// MARK: - View Extensions

extension View {

    /// Access the underlying NSWindow of a SwiftUI view
    /// - Parameter customize: Closure to customize the window
    /// - Returns: Modified view with window customization applied
    func customizeWindow(_ customize: @escaping (NSWindow) -> Void) -> some View {
        introspect(.window, on: .macOS(.v14, .v15)) { window in
            customize(window)
        }
    }

    /// Access the underlying NSView of a SwiftUI view
    /// - Parameter customize: Closure to customize the view
    /// - Returns: Modified view with NSView customization applied
    func customizeNSView(_ customize: @escaping (NSView) -> Void) -> some View {
        introspect(.view, on: .macOS(.v14, .v15)) { view in
            customize(view)
        }
    }

    /// Access the underlying NSScrollView of a ScrollView
    /// - Parameter customize: Closure to customize the scroll view
    /// - Returns: Modified view with scroll view customization applied
    func customizeScrollView(_ customize: @escaping (NSScrollView) -> Void) -> some View {
        introspect(.scrollView, on: .macOS(.v14, .v15)) { scrollView in
            customize(scrollView)
        }
    }

    /// Access the underlying NSTextField of a TextField
    /// - Parameter customize: Closure to customize the text field
    /// - Returns: Modified view with text field customization applied
    func customizeTextField(_ customize: @escaping (NSTextField) -> Void) -> some View {
        introspect(.textField, on: .macOS(.v14, .v15)) { textField in
            customize(textField)
        }
    }

    /// Access the underlying NSButton of a Button
    /// - Parameter customize: Closure to customize the button
    /// - Returns: Modified view with button customization applied
    func customizeButton(_ customize: @escaping (NSButton) -> Void) -> some View {
        introspect(.button, on: .macOS(.v14, .v15)) { button in
            customize(button)
        }
    }
}

// MARK: - Common Use Cases

extension View {

    /// Make the window floating and always on top
    func floatingWindow() -> some View {
        customizeWindow { window in
            window.level = .floating
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        }
    }

    /// Make the window transparent
    func transparentWindow() -> some View {
        customizeWindow { window in
            window.isOpaque = false
            window.backgroundColor = .clear
        }
    }

    /// Enable vibrancy on the window
    func vibrancyWindow(material: NSVisualEffectView.Material = .hudWindow) -> some View {
        customizeWindow { window in
            let visualEffect = NSVisualEffectView()
            visualEffect.material = material
            visualEffect.blendingMode = .behindWindow
            visualEffect.state = .active

            if let contentView = window.contentView {
                visualEffect.frame = contentView.bounds
                visualEffect.autoresizingMask = [.width, .height]
                contentView.addSubview(visualEffect, positioned: .below, relativeTo: nil)
            }
        }
    }

    /// Disable scroll bounce
    func disableScrollBounce() -> some View {
        customizeScrollView { scrollView in
            scrollView.hasVerticalScroller = true
            scrollView.verticalScrollElasticity = .none
        }
    }

    /// Style a text field with custom appearance
    func styledTextField(
        borderStyle: NSTextField.BezelStyle = .roundedBezel,
        backgroundColor: NSColor = .clear
    ) -> some View {
        customizeTextField { textField in
            textField.bezelStyle = borderStyle
            textField.backgroundColor = backgroundColor
            textField.isBordered = (borderStyle != .squareBezel)
        }
    }
}

// MARK: - Usage Examples (for reference)

/*

 // Example 1: Customize window properties
 struct MyView: View {
     var body: some View {
         VStack {
             Text("Hello")
         }
         .customizeWindow { window in
             window.level = .floating
             window.isOpaque = false
             window.backgroundColor = .clear
         }
     }
 }

 // Example 2: Access NSScrollView
 struct ScrollableContent: View {
     var body: some View {
         ScrollView {
             VStack {
                 ForEach(0..<100) { i in
                     Text("Item \(i)")
                 }
             }
         }
         .customizeScrollView { scrollView in
             scrollView.hasVerticalScroller = true
             scrollView.verticalScrollElasticity = .none
         }
     }
 }

 // Example 3: Style a text field
 struct CustomTextField: View {
     @State private var text = ""

     var body: some View {
         TextField("Enter text", text: $text)
             .styledTextField(
                 borderStyle: .roundedBezel,
                 backgroundColor: .black.withAlphaComponent(0.2)
             )
     }
 }

 // Example 4: Access multiple AppKit properties
 struct AdvancedView: View {
     var body: some View {
         VStack {
             Text("Advanced")
         }
         .customizeWindow { window in
             window.titlebarAppearsTransparent = true
             window.isMovableByWindowBackground = true
             window.standardWindowButton(.closeButton)?.isHidden = true
             window.standardWindowButton(.miniaturizeButton)?.isHidden = true
             window.standardWindowButton(.zoomButton)?.isHidden = true
         }
     }
 }

 // Example 5: Direct introspection when needed
 struct DirectIntrospection: View {
     var body: some View {
         Button("Click Me") {
             print("Clicked")
         }
         .introspect(.button, on: .macOS(.v14, .v15)) { button in
             button.bezelStyle = .rounded
             button.bezelColor = .systemBlue
         }
     }
 }

 */
