import SwiftUI
import AppKit

struct LiveActionsView: View {
    @State private var showingAlert = false
    @State private var alertMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Music Actions Row (like Spotify Top Songs, Ring Labs, etc.)
            HStack(spacing: 12) {
                MusicActionButton(
                    icon: "sparkles",
                    title: "Spotify Top...",
                    color: Color.green
                ) {
                    openSpotify()
                }

                MusicActionButton(
                    icon: "bell.badge.fill",
                    title: "Ring Labs",
                    color: Color.orange
                ) {
                    // Custom action
                }
            }

            // Quick Actions Grid
            HStack(spacing: 12) {
                RoundActionButton(icon: "video.circle.fill", label: "Mirror") {
                    // Mirror/Camera action
                }

                RoundActionButton(icon: "camera.fill", label: "Screenshot") {
                    takeScreenshot()
                }

                RoundActionButton(icon: "lock.fill", label: "Lock") {
                    lockScreen()
                }

                RoundActionButton(icon: "moon.fill", label: "Sleep") {
                    sleepDisplay()
                }
            }
        }
        .alert("Action Status", isPresented: $showingAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
    }

    private func openSpotify() {
        // Open Spotify app or web
        if let url = URL(string: "spotify://") {
            if NSWorkspace.shared.urlForApplication(toOpen: url) != nil {
                NSWorkspace.shared.open(url)
            } else {
                // Fallback to web
                if let webURL = URL(string: "https://open.spotify.com") {
                    NSWorkspace.shared.open(webURL)
                }
            }
        }
    }

    private func takeScreenshot() {
        // Use screencapture with interactive mode
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture")
            task.arguments = ["-i", "-c"] // -i for interactive, -c to copy to clipboard

            do {
                try task.run()
            } catch {
                print("Screenshot error: \(error)")
            }
        }
    }

    private func lockScreen() {
        // Method 1: Use CGSession (most reliable)
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/System/Library/CoreServices/Menu Extras/User.menu/Contents/Resources/CGSession")
            task.arguments = ["-suspend"]

            do {
                try task.run()
            } catch {
                // Fallback: Use pmset
                let pmsetTask = Process()
                pmsetTask.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
                pmsetTask.arguments = ["displaysleepnow"]

                do {
                    try pmsetTask.run()
                } catch {
                    print("Lock screen error: \(error)")
                }
            }
        }
    }

    private func sleepDisplay() {
        // Use pmset to put display to sleep
        DispatchQueue.global(qos: .userInitiated).async {
            let task = Process()
            task.executableURL = URL(fileURLWithPath: "/usr/bin/pmset")
            task.arguments = ["displaysleepnow"]

            do {
                try task.run()
            } catch {
                print("Sleep display error: \(error)")
            }
        }
    }

    private func emptyTrash() {
        // Use Finder via NSWorkspace
        DispatchQueue.global(qos: .userInitiated).async {
            let source = """
            tell application "Finder"
                set warn to false
                empty trash
            end tell
            """

            var error: NSDictionary?
            if let scriptObject = NSAppleScript(source: source) {
                scriptObject.executeAndReturnError(&error)
                if let error = error {
                    print("Empty trash error: \(error)")
                }
            }
        }
    }
}

// Music Action Button (Horizontal pill-shaped buttons)
struct MusicActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)

                Text(title)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        color.opacity(0.3),
                                        color.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.96 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// Round Action Button (Circle buttons with labels)
struct RoundActionButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    @State private var isHovering = false
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
                action()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.blue.opacity(isHovering ? 0.4 : 0.0),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 30
                            )
                        )
                        .frame(width: 60, height: 60)
                        .blur(radius: 8)

                    // Button circle
                    Circle()
                        .fill(Color.black.opacity(0.25))
                        .frame(width: 48, height: 48)
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(isHovering ? 0.3 : 0.1), lineWidth: 1)
                        )

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    isHovering ? Color.blue : Color.white.opacity(0.8),
                                    isHovering ? Color.blue.opacity(0.7) : Color.white.opacity(0.6)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
    }
}
