import SwiftUI
import UniformTypeIdentifiers

struct TrayView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isDropTargeted = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 20) {
                // Drop Zone
                if droppedFiles.isEmpty {
                    emptyDropZone
                } else {
                    filesGrid
                }

                // Quick Actions
                quickActionsSection
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
        }
        .frame(maxHeight: 500)
    }

    private var emptyDropZone: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue.opacity(0.3), Color.purple.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 80, height: 80)
                    .blur(radius: 20)

                Image(systemName: "tray.and.arrow.down.fill")
                    .font(.system(size: 40, weight: .medium))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.8), .white.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            }

            Text("Drop files here")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))

            Text("Quick access to your files from anywhere")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundColor(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .frame(height: 200)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.black.opacity(0.25))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: isDropTargeted ? [] : [8, 8])
                        )
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isDropTargeted ? 0.4 : 0.2),
                                    Color.white.opacity(isDropTargeted ? 0.2 : 0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
        )
        .scaleEffect(isDropTargeted ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDropTargeted)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private var filesGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12)
        ], spacing: 12) {
            ForEach(droppedFiles, id: \.self) { fileURL in
                TrayFileItemView(fileURL: fileURL, onTap: {
                    // Open file
                    NSWorkspace.shared.open(fileURL)
                }, onDelete: {
                    withAnimation {
                        droppedFiles.removeAll { $0 == fileURL }
                    }
                })
            }

            // Add more button
            addMoreButton
        }
        .padding(.vertical, 8)
    }

    private var addMoreButton: some View {
        Button(action: {
            // Could add file picker here
        }) {
            VStack(spacing: 8) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 32))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white.opacity(0.6), .white.opacity(0.4)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )

                Text("Add More")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                style: StrokeStyle(lineWidth: 1, dash: [4, 4])
                            )
                            .foregroundColor(.white.opacity(0.2))
                    )
            )
        }
        .buttonStyle(.plain)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Quick Share")
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(.white.opacity(0.8))

            HStack(spacing: 12) {
                QuickActionButton(icon: "airplayaudio", title: "AirDrop", color: .blue) {
                    // AirDrop functionality
                }

                QuickActionButton(icon: "square.and.arrow.up", title: "Share", color: .green) {
                    // Share sheet
                }

                QuickActionButton(icon: "doc.on.clipboard", title: "Copy", color: .orange) {
                    // Copy to clipboard
                }
            }
        }
        .padding(.top, 8)
    }

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        if !droppedFiles.contains(url) {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                droppedFiles.append(url)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct TrayFileItemView: View {
    let fileURL: URL
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var fileIcon: NSImage?
    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                ZStack(alignment: .topTrailing) {
                    // File icon
                    if let icon = fileIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                    } else {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    // Delete button (shown on hover)
                    if isHovering {
                        Button(action: onDelete) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(.red)
                                .background(
                                    Circle()
                                        .fill(Color.white)
                                        .frame(width: 14, height: 14)
                                )
                        }
                        .buttonStyle(.plain)
                        .offset(x: 8, y: -8)
                        .transition(.scale.combined(with: .opacity))
                    }
                }

                Text(fileURL.lastPathComponent)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(isHovering ? 0.3 : 0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isHovering = hovering
        }
        .onAppear {
            loadFileIcon()
        }
    }

    private func loadFileIcon() {
        fileIcon = NSWorkspace.shared.icon(forFile: fileURL.path)
    }
}

struct QuickActionButton: View {
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
            VStack(spacing: 6) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.3), color.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.black.opacity(0.25))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    TrayView()
        .frame(width: 400, height: 500)
        .background(Color.black)
}
