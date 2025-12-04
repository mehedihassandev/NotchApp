import SwiftUI
import UniformTypeIdentifiers

struct TrayView: View {
    @State private var droppedFiles: [URL] = []
    @State private var isDropTargeted = false
    @State private var isAirDropHovering = false

    var body: some View {
        HStack(spacing: 14) {
            // Files Tray - Drop Zone
            filesTraySection

            // AirDrop Section
            airDropSection
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    private var filesTraySection: some View {
        HStack(spacing: 16) {
            if droppedFiles.isEmpty {
                // Empty state - icon and label
                Image(systemName: "tray.fill")
                    .font(.system(size: 26, weight: .regular))
                    .foregroundColor(.white.opacity(0.4))

                Text("Files Tray")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.5))
            } else {
                // Show dropped files horizontally
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(droppedFiles, id: \.self) { fileURL in
                            TrayFileChip(fileURL: fileURL, onTap: {
                                NSWorkspace.shared.open(fileURL)
                            }, onDelete: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                    droppedFiles.removeAll { $0 == fileURL }
                                }
                            })
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.black.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                        )
                        .foregroundColor(.white.opacity(isDropTargeted ? 0.4 : 0.2))
                )
        )
        .scaleEffect(isDropTargeted ? 1.01 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDropTargeted)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            return true
        }
    }

    private var airDropSection: some View {
        Button(action: {
            // Open AirDrop via Finder
            let task = Process()
            task.launchPath = "/usr/bin/open"
            task.arguments = ["-b", "com.apple.finder", "airdrop://"]
            try? task.run()
        }) {
            HStack(spacing: 14) {
                // AirDrop Icon - Concentric rings
                ZStack {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                Color.blue.opacity(0.8 - Double(index) * 0.2),
                                lineWidth: 2
                            )
                            .frame(
                                width: CGFloat(12 + index * 9),
                                height: CGFloat(12 + index * 9)
                            )
                    }

                    Circle()
                        .fill(Color.blue)
                        .frame(width: 5, height: 5)
                }
                .frame(width: 36, height: 36)

                Text("AirDrop")
                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.12, green: 0.18, blue: 0.32).opacity(isAirDropHovering ? 1.0 : 0.8),
                                Color(red: 0.08, green: 0.12, blue: 0.28).opacity(isAirDropHovering ? 1.0 : 0.8)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.blue.opacity(isAirDropHovering ? 0.4 : 0.2), lineWidth: 1)
                    )
            )
            .scaleEffect(isAirDropHovering ? 1.02 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAirDropHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isAirDropHovering = hovering
        }
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

// Compact file chip for tray - horizontal style
struct TrayFileChip: View {
    let fileURL: URL
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var fileIcon: NSImage?
    @State private var isHovering = false

    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                HStack(spacing: 6) {
                    if let icon = fileIcon {
                        Image(nsImage: icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 24, height: 24)
                    } else {
                        Image(systemName: "doc.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.white.opacity(0.6))
                    }

                    Text(fileURL.deletingPathExtension().lastPathComponent)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                        .frame(maxWidth: 60)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8, style: .continuous)
                        .fill(Color.white.opacity(isHovering ? 0.12 : 0.06))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .stroke(Color.white.opacity(isHovering ? 0.2 : 0.08), lineWidth: 0.5)
                        )
                )

                // Delete button on hover
                if isHovering {
                    Button(action: onDelete) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 12))
                            .foregroundStyle(.white, .red)
                    }
                    .buttonStyle(.plain)
                    .offset(x: 4, y: -4)
                    .transition(.scale.combined(with: .opacity))
                }
            }
            .scaleEffect(isHovering ? 1.05 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.easeInOut(duration: 0.2)) {
                isHovering = hovering
            }
        }
        .onAppear {
            fileIcon = NSWorkspace.shared.icon(forFile: fileURL.path)
        }
    }
}

#Preview {
    TrayView()
        .frame(width: 500, height: 100)
        .background(Color.black)
}