import SwiftUI
import AppKit
import Combine
import SwiftUIIntrospect

// MARK: - Notch Window Controller
/// Controller for managing the notch window lifecycle
/// Uses SwiftUIIntrospect for better SwiftUI ↔ AppKit interop

final class NotchWindowController: NSWindowController {

    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var dragTrackingTimer: Timer?
    private var settingsCancellable: AnyCancellable?

    // MARK: - Initialization

    convenience init() {
        let window = NSWindow(
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

        configureWindow()
        setupContentView()
        setupObservers()
        setupDragTracking()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        dragTrackingTimer?.invalidate()
    }

    // MARK: - Window Configuration

    private func configureWindow() {
        guard let window = window else { return }

        window.isOpaque = false
        window.backgroundColor = .clear
        window.hasShadow = true
        window.level = .statusBar
        window.collectionBehavior = [.canJoinAllSpaces, .stationary, .ignoresCycle, .fullScreenAuxiliary]
        window.isMovableByWindowBackground = false
        window.acceptsMouseMovedEvents = true
        window.ignoresMouseEvents = true  // Initially ignore mouse events when collapsed
        window.animationBehavior = .utilityWindow

        positionWindow()
    }

    // MARK: - Setup

    private func setupContentView() {
        guard let window = window else { return }

        let contentView = NSHostingView(
            rootView: NotchBarView()
                .introspect(.window, on: .macOS(.v14, .v15)) { nsWindow in
                    // Additional window configuration via introspection
                    nsWindow.isOpaque = false
                    nsWindow.backgroundColor = .clear
                }
        )
        contentView.layer?.backgroundColor = .clear
        window.contentView = contentView

        // Register for drag and drop
        window.registerForDraggedTypes([.fileURL])
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
                    self?.window?.ignoresMouseEvents = false
                }
            }
            .store(in: &cancellables)

        // Settings changes
        settingsCancellable = SettingsManager.shared.$enableNotch
            .receive(on: DispatchQueue.main)
            .sink { [weak self] enabled in
                self?.window?.alphaValue = enabled ? 1.0 : 0.0
                self?.window?.ignoresMouseEvents = !enabled
            }
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

    // MARK: - Window Positioning

    private func positionWindow() {
        guard let window = window, let screen = NSScreen.main else { return }

        let screenFrame = screen.frame
        let windowWidth = AppConstants.Window.width
        let windowHeight = AppConstants.Window.height

        // Center horizontally, position at top of screen
        let xPos = (screenFrame.width - windowWidth) / 2 + screenFrame.origin.x
        let yPos = screenFrame.maxY - windowHeight

        window.setFrame(
            NSRect(x: xPos, y: yPos, width: windowWidth, height: windowHeight),
            display: true,
            animate: false
        )
    }

    // MARK: - Mouse Event Handling

    private func updateMouseEventHandling(isExpanded: Bool) {
        // When collapsed, ignore mouse events to allow clicking through
        // When expanded, capture mouse events for interaction
        window?.ignoresMouseEvents = !isExpanded
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
