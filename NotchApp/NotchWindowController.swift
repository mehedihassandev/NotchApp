import SwiftUI
import AppKit
import Combine

// MARK: - Notch Window
/// Custom NSWindow subclass for the notch interface
/// Handles positioning, tracking areas, and mouse event management

final class NotchWindow: NSWindow {

    // MARK: - Private Properties
    private var trackingArea: NSTrackingArea?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    override init(
        contentRect: NSRect,
        styleMask style: NSWindow.StyleMask,
        backing backingStoreType: NSWindow.BackingStoreType,
        defer flag: Bool
    ) {
        super.init(
            contentRect: contentRect,
            styleMask: [.borderless, .fullSizeContentView],
            backing: backingStoreType,
            defer: flag
        )

        configureWindow()
        positionWindow()
        setupObservers()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Window Configuration

    private func configureWindow() {
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .statusBar
        collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        isMovableByWindowBackground = false
        acceptsMouseMovedEvents = true
        ignoresMouseEvents = true  // Initially ignore mouse events when collapsed
    }

    // MARK: - Observers

    private func setupObservers() {
        // Screen change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(screenParametersChanged),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil
        )

        // Notch state changes
        NotchState.shared.$isExpanded
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isExpanded in
                self?.updateMouseEventHandling(isExpanded: isExpanded)
            }
            .store(in: &cancellables)
    }

    @objc private func screenParametersChanged() {
        positionWindow()
    }

    // MARK: - Window Positioning

    private func positionWindow() {
        guard let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let windowWidth = AppConstants.Window.width
        let windowHeight = AppConstants.Window.height

        // Center horizontally, position at top of screen
        let xPos = (screenFrame.width - windowWidth) / 2 + screenFrame.origin.x
        let yPos = screenFrame.maxY - windowHeight

        setFrame(
            NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight),
            display: true,
            animate: false
        )

        setupTrackingArea()
    }

    // MARK: - Tracking Area

    private func setupTrackingArea() {
        // Remove existing tracking area
        if let existingArea = trackingArea {
            contentView?.removeTrackingArea(existingArea)
        }

        // Create tracking area for top portion of window (notch area)
        guard let contentView = contentView else { return }

        let trackingRect = NSRect(
            x: 0,
            y: contentView.bounds.height - AppConstants.Window.trackingAreaHeight,
            width: contentView.bounds.width,
            height: AppConstants.Window.trackingAreaHeight
        )

        trackingArea = NSTrackingArea(
            rect: trackingRect,
            options: [.mouseEnteredAndExited, .activeAlways, .inVisibleRect],
            owner: self,
            userInfo: nil
        )

        contentView.addTrackingArea(trackingArea!)
    }

    // MARK: - Mouse Event Handling

    private func updateMouseEventHandling(isExpanded: Bool) {
        // When collapsed, ignore mouse events to allow clicking through
        // When expanded, capture mouse events for interaction
        ignoresMouseEvents = !isExpanded
    }

    // MARK: - Window Properties Override

    override var canBecomeKey: Bool {
        return true
    }

    override var canBecomeMain: Bool {
        return false
    }
}

// MARK: - Notch Window Controller
/// Controller for managing the notch window lifecycle

final class NotchWindowController: NSWindowController {

    // MARK: - Initialization

    convenience init() {
        let window = NotchWindow(
            contentRect: NSRect(
                x: 0,
                y: 0,
                width: AppConstants.Window.width,
                height: AppConstants.Window.height
            ),
            styleMask: [.borderless, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )

        self.init(window: window)

        setupContentView()
        configureWindowBehavior()
    }

    // MARK: - Setup

    private func setupContentView() {
        guard let window = window else { return }

        let contentView = NSHostingView(rootView: NotchBarView())
        contentView.layer?.backgroundColor = .clear
        window.contentView = contentView
    }

    private func configureWindowBehavior() {
        window?.animationBehavior = .utilityWindow
    }

    // MARK: - Lifecycle

    override func windowDidLoad() {
        super.windowDidLoad()
        showWindowAnimated()
    }

    private func showWindowAnimated() {
        window?.fadeIn(duration: AppConstants.Animation.glowDuration)
    }
}
