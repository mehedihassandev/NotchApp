import SwiftUI
import AppKit
import Combine

// Shared state to manage notch expansion
class NotchState: ObservableObject {
    static let shared = NotchState()
    @Published var isExpanded: Bool = false
}

class NotchWindow: NSWindow {
    private var trackingArea: NSTrackingArea?
    private var cancellables = Set<AnyCancellable>()

    override init(contentRect: NSRect, styleMask style: NSWindow.StyleMask, backing backingStoreType: NSWindow.BackingStoreType, defer flag: Bool) {
        super.init(contentRect: contentRect, styleMask: [.borderless, .fullSizeContentView], backing: backingStoreType, defer: flag)

        // Make window floating and transparent with modern styling
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = true
        self.level = .statusBar
        self.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]

        // Allow mouse events for smooth interaction
        self.isMovableByWindowBackground = false
        self.acceptsMouseMovedEvents = true
        // Initially ignore mouse events when collapsed
        self.ignoresMouseEvents = true

        // Position at top center aligned with notch
        positionWindow()

        // Setup screen change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Observe notch state changes
        NotchState.shared.$isExpanded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExpanded in
                self?.updateMouseEventHandling(isExpanded: isExpanded)
            }
            .store(in: &cancellables)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func screenParametersChanged() {
        positionWindow()
    }

    private func positionWindow() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let notchHeight: CGFloat = getNotchHeight(for: screen)

        // Window dimensions - wider for horizontal Nook layout
        let windowWidth: CGFloat = 580
        let windowHeight: CGFloat = 400 // Height for expanded content

        // Center horizontally, position at EXACT top of screen for hover detection
        let xPos = (screenFrame.width - windowWidth) / 2 + screenFrame.origin.x
        let yPos = screenFrame.maxY - windowHeight

        self.setFrame(
            NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight),
            display: true,
            animate: false
        )

        // Setup tracking area for top-edge hover detection
        setupTrackingArea()
    }

    private func setupTrackingArea() {
        // Remove existing tracking area
        if let existingArea = trackingArea {
            contentView?.removeTrackingArea(existingArea)
        }

        // Create tracking area only for the top 50px of the window (notch area)
        if let contentView = contentView {
            let trackingRect = NSRect(
                x: 0,
                y: contentView.bounds.height - 50, // Only top 50px
                width: contentView.bounds.width,
                height: 50
            )

            trackingArea = NSTrackingArea(
                rect: trackingRect,
                options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
                owner: self,
                userInfo: nil
            )
            contentView.addTrackingArea(trackingArea!)
        }
    }

    private func getNotchHeight(for screen: NSScreen) -> CGFloat {
        // Check for notch on MacBook Pro models (2021+)
        if #available(macOS 12.0, *) {
            // Calculate notch area
            let topSafeArea = screen.safeAreaInsets.top
            return topSafeArea > 0 ? topSafeArea : 0
        }
        return 0
    }

    private func updateMouseEventHandling(isExpanded: Bool) {
        // When collapsed, ignore mouse events to allow clicking through
        // When expanded, capture mouse events for interaction
        self.ignoresMouseEvents = !isExpanded
    }

    // Allow window to receive mouse events even when not key
    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}

class NotchWindowController: NSWindowController {
    convenience init() {
        let window = NotchWindow(
            contentRect: NSRect(x: 0, y: 0, width: 580, height: 400),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)

        // Set up the content view with smooth rendering
        let contentView = NSHostingView(rootView: NotchBarView())
        contentView.layer?.backgroundColor = .clear
        window.contentView = contentView

        // Enable smooth animations
        window.animationBehavior = .utilityWindow
    }

    override func windowDidLoad() {
        super.windowDidLoad()

        // Show window smoothly
        window?.alphaValue = 0
        window?.makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.4
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            window?.animator().alphaValue = 1.0
        }
    }
}

// Extension for smooth window animations
extension NSWindow {
    func smoothResize(to newFrame: NSRect, duration: TimeInterval = 0.3) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(newFrame, display: true)
        }
    }
}
