import AppKit

// MARK: - NSWindow Extensions
/// Utility extensions for window management

extension NSWindow {

    /// Performs a smooth animated resize to a new frame
    /// - Parameters:
    ///   - newFrame: The target frame for the window
    ///   - duration: Animation duration (default: 0.3 seconds)
    func smoothResize(to newFrame: NSRect, duration: TimeInterval = 0.5) {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            self.animator().setFrame(newFrame, display: true)
        }
    }

    /// Fades the window in smoothly
    /// - Parameter duration: Animation duration
    func fadeIn(duration: TimeInterval = 0.55) {
        alphaValue = 0
        makeKeyAndOrderFront(nil)

        NSAnimationContext.runAnimationGroup { context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeOut)
            self.animator().alphaValue = 1.0
        }
    }

    /// Fades the window out smoothly
    /// - Parameters:
    ///   - duration: Animation duration
    ///   - completion: Closure to execute after animation completes
    func fadeOut(duration: TimeInterval = 0.5, completion: (() -> Void)? = nil) {
        NSAnimationContext.runAnimationGroup({ context in
            context.duration = duration
            context.timingFunction = CAMediaTimingFunction(name: .easeIn)
            self.animator().alphaValue = 0
        }, completionHandler: completion)
    }
}

// MARK: - NSScreen Extensions
extension NSScreen {

    /// Returns the notch height for the current screen (MacBook Pro 2021+)
    var notchHeight: CGFloat {
        if #available(macOS 12.0, *) {
            return safeAreaInsets.top > 0 ? safeAreaInsets.top : 0
        }
        return 0
    }

    /// Checks if the screen has a notch
    var hasNotch: Bool {
        notchHeight > 0
    }
}
