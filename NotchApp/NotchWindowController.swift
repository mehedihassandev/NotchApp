import SwiftUI
import AppKit
import Combine

// MARK: - Drop Target View
/// Custom NSView that handles file drag-and-drop detection
final class DropTargetView: NSView {

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        registerForDraggedTypes([.fileURL])
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        registerForDraggedTypes([.fileURL])
    }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard
        if pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) {
            DispatchQueue.main.async {
                NotchState.shared.fileDragEntered()
            }
            return .copy
        }
        return []
    }

    override func draggingUpdated(_ sender: NSDraggingInfo) -> NSDragOperation {
        let pasteboard = sender.draggingPasteboard
        if pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true]) {
            return .copy
        }
        return []
    }

    override func draggingExited(_ sender: NSDraggingInfo?) {
        // We don't reset the state here because the TrayView handles the drop
    }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        // Let SwiftUI handle the actual drop
        return false
    }

    override func draggingEnded(_ sender: NSDraggingInfo) {
        DispatchQueue.main.async {
            NotchState.shared.fileDragExited()
        }
    }
}

// MARK: - Notch Window
/// Custom NSWindow subclass for the notch interface
/// Handles positioning, tracking areas, and mouse event management

final class NotchWindow: NSWindow {

    // MARK: - Private Properties
    private var trackingArea: NSTrackingArea?
    private var cancellables = Set<AnyCancellable>()
    private var dropTargetView: DropTargetView?
    private var dragTrackingTimer: Timer?

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
        setupDragTracking()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        dragTrackingTimer?.invalidate()
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

        // File dragging state changes
        NotchState.shared.$isDraggingFile
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDragging in
                if isDragging {
                    self?.ignoresMouseEvents = false
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Drag Tracking

    private func setupDragTracking() {
        // Monitor for active drag sessions periodically
        dragTrackingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.checkForFileDrag()
        }
    }

    private func checkForFileDrag() {
        // Check if mouse button is pressed (indicates active drag)
        let mouseButtonDown = NSEvent.pressedMouseButtons & 1 != 0

        if mouseButtonDown {
            let pasteboard = NSPasteboard(name: .drag)

            // Check if there's an active drag with file URLs
            let hasFiles = pasteboard.canReadObject(forClasses: [NSURL.self], options: [.urlReadingFileURLsOnly: true])

            if hasFiles {
                // Check if mouse is over the notch area
                let mouseLocation = NSEvent.mouseLocation

                // Get the notch trigger area (top center of screen)
                if let screen = NSScreen.main {
                    let notchArea = NSRect(
                        x: screen.frame.midX - 150,
                        y: screen.frame.maxY - 60,
                        width: 300,
                        height: 60
                    )

                    if notchArea.contains(mouseLocation) && !NotchState.shared.isDraggingFile {
                        DispatchQueue.main.async {
                            NotchState.shared.fileDragEntered()
                        }
                    }
                }
            }
        } else {
            // Mouse button released, reset drag state
            if NotchState.shared.isDraggingFile {
                DispatchQueue.main.async {
                    NotchState.shared.fileDragExited()
                }
            }
        }
    }

    @objc private func screenParametersChanged() {
        positionWindow()
    }

    // MARK: - Setup Drop Target

    func setupDropTarget(in hostingView: NSView) {
        // Create a transparent drop target view that sits on top
        dropTargetView = DropTargetView(frame: hostingView.bounds)
        dropTargetView?.autoresizingMask = [.width, .height]
        dropTargetView?.wantsLayer = true
        dropTargetView?.layer?.backgroundColor = .clear

        if let dropView = dropTargetView {
            hostingView.addSubview(dropView)
        }
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
