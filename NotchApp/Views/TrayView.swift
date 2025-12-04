import SwiftUI
import UniformTypeIdentifiers

// MARK: - Tray View
/// A file drop zone and quick action tray for the notch interface
/// Supports drag-and-drop file management and AirDrop access

struct TrayView: View {

    // MARK: - State Properties
    @ObservedObject private var notchState = NotchState.shared
    @State private var droppedFiles: [URL] = []
    @State private var isDropTargeted = false
    @State private var isAirDropHovering = false

    // MARK: - Body
    var body: some View {
        HStack(spacing: AppConstants.Layout.padding - 2) {
            filesTraySection
            airDropSection
        }
        .padding(.horizontal, AppConstants.Layout.padding)
        .padding(.vertical, AppConstants.Layout.padding - 2)
    }
}

// MARK: - Files Tray Section
extension TrayView {

    private var filesTraySection: some View {
        HStack(spacing: AppConstants.Layout.spacing) {
            if droppedFiles.isEmpty {
                emptyTrayState
            } else {
                filesScrollView
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(dropZoneBackground)
        .hoverScale(isDropTargeted || notchState.isDraggingFile, scale: 1.01)
        .onDrop(of: [.fileURL], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            // Reset drag state after drop
            DispatchQueue.main.async {
                notchState.fileDragExited()
            }
            return true
        }
    }

    private var emptyTrayState: some View {
        HStack(spacing: AppConstants.Layout.spacing) {
            Image(systemName: notchState.isDraggingFile ? "tray.and.arrow.down.fill" : "tray.fill")
                .font(.system(size: 26, weight: .regular))
                .foregroundColor(notchState.isDraggingFile ? AppTheme.Colors.accentBlue : AppTheme.Colors.textQuaternary)
                .symbolEffect(.bounce, options: .repeating, value: notchState.isDraggingFile)

            Text(notchState.isDraggingFile ? "Drop Files Here" : "Files Tray")
                .font(AppTheme.Typography.headline(13))
                .foregroundColor(notchState.isDraggingFile ? AppTheme.Colors.textSecondary : AppTheme.Colors.textTertiary)
        }
        .animation(AppTheme.Animations.spring, value: notchState.isDraggingFile)
    }

    private var filesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppConstants.Layout.smallSpacing) {
                ForEach(droppedFiles, id: \.self) { fileURL in
                    TrayFileChip(
                        fileURL: fileURL,
                        onTap: {
                            NSWorkspace.shared.open(fileURL)
                        },
                        onDelete: {
                            removeFile(fileURL)
                        }
                    )
                }
            }
        }
    }

    private var dropZoneBackground: some View {
        RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
            .fill(Color.black.opacity(notchState.isDraggingFile || isDropTargeted ? 0.25 : 0.15))
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                    .strokeBorder(
                        style: StrokeStyle(lineWidth: 2, dash: [7, 5])
                    )
                    .foregroundColor(
                        notchState.isDraggingFile || isDropTargeted ?
                            AppTheme.Colors.accentBlue.opacity(0.6) :
                            .white.opacity(0.2)
                    )
            )
            .animation(AppTheme.Animations.spring, value: notchState.isDraggingFile)
            .animation(AppTheme.Animations.spring, value: isDropTargeted)
    }

    // MARK: - Actions

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            _ = provider.loadObject(ofClass: URL.self) { url, error in
                if let url = url {
                    DispatchQueue.main.async {
                        addFile(url)
                    }
                }
            }
        }
    }

    private func addFile(_ url: URL) {
        guard !droppedFiles.contains(url) else { return }

        withAnimation(AppTheme.Animations.spring) {
            droppedFiles.append(url)
        }
    }

    private func removeFile(_ url: URL) {
        withAnimation(AppTheme.Animations.springFast) {
            droppedFiles.removeAll { $0 == url }
        }
    }
}

// MARK: - AirDrop Section
extension TrayView {

    private var airDropSection: some View {
        Button(action: openAirDrop) {
            HStack(spacing: AppConstants.Layout.padding - 2) {
                airDropIcon

                Text("AirDrop")
                    .font(AppTheme.Typography.headline())
                    .foregroundColor(AppTheme.Colors.textPrimary.opacity(0.9))

                Spacer()
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            .frame(width: 160)
            .background(airDropBackground)
            .hoverScale(isAirDropHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isAirDropHovering = hovering
        }
    }

    private var airDropIcon: some View {
        ZStack {
            // Concentric rings
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        AppTheme.Colors.accentBlue.opacity(0.8 - Double(index) * 0.2),
                        lineWidth: 2
                    )
                    .frame(
                        width: CGFloat(12 + index * 9),
                        height: CGFloat(12 + index * 9)
                    )
            }

            // Center dot
            Circle()
                .fill(AppTheme.Colors.accentBlue)
                .frame(width: 5, height: 5)
        }
        .frame(width: 36, height: 36)
    }

    private var airDropBackground: some View {
        RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
            .fill(
                AppTheme.Colors.airDropGradient
                    .opacity(isAirDropHovering ? 1.0 : 0.8)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                    .stroke(
                        AppTheme.Colors.accentBlue.opacity(isAirDropHovering ? 0.4 : 0.2),
                        lineWidth: 1
                    )
            )
    }

    private func openAirDrop() {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["-b", "com.apple.finder", "airdrop://"]
        try? task.run()
    }
}

// MARK: - Tray File Chip
/// A compact file chip displaying file icon and name with hover actions

struct TrayFileChip: View {

    // MARK: - Properties
    let fileURL: URL
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var fileIcon: NSImage?
    @State private var isHovering = false

    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                chipContent

                if isHovering {
                    deleteButton
                }
            }
            .hoverScale(isHovering, scale: 1.05)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(AppTheme.Animations.hover) {
                isHovering = hovering
            }
        }
        .onAppear {
            loadFileIcon()
        }
    }

    // MARK: - Subviews

    private var chipContent: some View {
        HStack(spacing: 6) {
            fileIconView

            Text(fileURL.deletingPathExtension().lastPathComponent)
                .font(AppTheme.Typography.caption())
                .foregroundColor(AppTheme.Colors.textSecondary)
                .lineLimit(1)
                .frame(maxWidth: 60)
        }
        .padding(.horizontal, AppConstants.Layout.smallSpacing)
        .padding(.vertical, 6)
        .cardStyle(isHovering: isHovering, cornerRadius: AppConstants.Layout.smallCornerRadius)
    }

    private var fileIconView: some View {
        Group {
            if let icon = fileIcon {
                Image(nsImage: icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 24, height: 24)
            } else {
                Image(systemName: "doc.fill")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.textTertiary)
            }
        }
    }

    private var deleteButton: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark.circle.fill")
                .font(.system(size: 12))
                .foregroundStyle(.white, .red)
        }
        .buttonStyle(.plain)
        .offset(x: 4, y: -4)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Helpers

    private func loadFileIcon() {
        fileIcon = NSWorkspace.shared.icon(forFile: fileURL.path)
    }
}

// MARK: - Preview
#Preview {
    TrayView()
        .frame(width: 500, height: 100)
        .background(Color.black)
}