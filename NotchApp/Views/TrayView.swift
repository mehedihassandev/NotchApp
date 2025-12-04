import SwiftUI
import UniformTypeIdentifiers
import Combine

// MARK: - Tray Item Model
/// Represents an item stored in the Dropover-style tray
struct TrayItem: Identifiable, Equatable, Codable {
    let id: UUID
    let url: URL
    let dateAdded: Date

    init(url: URL) {
        self.id = UUID()
        self.url = url
        self.dateAdded = Date()
    }

    static func == (lhs: TrayItem, rhs: TrayItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - AirDrop State
/// Manages AirDrop sharing state and animations
class AirDropState: ObservableObject {
    static let shared = AirDropState()

    @Published var isSharing = false
    @Published var isDropTargeted = false
    @Published var droppedFiles: [URL] = []
    @Published var shareProgress: Double = 0
    @Published var pulseAnimation = false

    private init() {}

    func startSharing(files: [URL]) {
        droppedFiles = files
        isSharing = true
        shareProgress = 0

        // Animate progress
        withAnimation(.easeInOut(duration: 0.3)) {
            shareProgress = 0.3
        }
    }

    func completeSharing() {
        withAnimation(.easeOut(duration: 0.2)) {
            shareProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.isSharing = false
                self.droppedFiles = []
                self.shareProgress = 0
            }
        }
    }

    func cancelSharing() {
        withAnimation(.easeOut(duration: 0.2)) {
            isSharing = false
            droppedFiles = []
            shareProgress = 0
        }
    }
}

// MARK: - Tray Storage Manager
/// Manages persistent storage of tray items
class TrayStorageManager: ObservableObject {
    static let shared = TrayStorageManager()

    @Published var items: [TrayItem] = []

    private let storageKey = "NotchApp.TrayItems"

    private init() {
        loadItems()
    }

    func addItem(_ url: URL) {
        guard !items.contains(where: { $0.url == url }) else { return }
        let item = TrayItem(url: url)
        items.append(item)
        saveItems()
    }

    func removeItem(_ item: TrayItem) {
        items.removeAll { $0.id == item.id }
        saveItems()
    }

    func removeItem(at url: URL) {
        items.removeAll { $0.url == url }
        saveItems()
    }

    func clearAll() {
        items.removeAll()
        saveItems()
    }

    private func saveItems() {
        if let data = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }

    private func loadItems() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let savedItems = try? JSONDecoder().decode([TrayItem].self, from: data) else {
            return
        }
        // Filter out items whose files no longer exist
        items = savedItems.filter { FileManager.default.fileExists(atPath: $0.url.path) }
    }
}

// MARK: - Tray View
/// A Dropover-style file shelf for the notch interface
/// Supports drag-and-drop file storage with drag-out capability

struct TrayView: View {

    // MARK: - State Properties
    @ObservedObject private var notchState = NotchState.shared
    @ObservedObject private var storage = TrayStorageManager.shared
    @ObservedObject private var airDropState = AirDropState.shared
    @State private var isDropTargeted = false
    @State private var isAirDropHovering = false
    @State private var isAirDropDropTargeted = false
    @State private var airDropPulse = false

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
            if storage.items.isEmpty {
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
        .onDrop(of: [.fileURL, .url, .text], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
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
            HStack(spacing: AppConstants.Layout.smallSpacing + 4) {
                ForEach(storage.items) { item in
                    TrayFileChip(
                        item: item,
                        onTap: {
                            NSWorkspace.shared.open(item.url)
                        },
                        onDelete: {
                            withAnimation(AppTheme.Animations.springFast) {
                                storage.removeItem(item)
                            }
                        }
                    )
                }
            }
            .padding(.top, 12) // Add top padding for action buttons
            .padding(.trailing, 8) // Extra trailing space
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

    // MARK: - Drop Handling

    private func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            // Handle file URLs
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            withAnimation(AppTheme.Animations.spring) {
                                storage.addItem(url)
                            }
                        }
                    }
                }
            }
            // Handle web URLs
            else if provider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url {
                        DispatchQueue.main.async {
                            withAnimation(AppTheme.Animations.spring) {
                                storage.addItem(url)
                            }
                        }
                    }
                }
            }
        }
    }
}

// MARK: - AirDrop Section
extension TrayView {

    private var airDropSection: some View {
        ZStack {
            // Main AirDrop button/drop zone
            airDropDropZone
        }
        .onDrop(of: [.fileURL, .url], isTargeted: $isAirDropDropTargeted) { providers in
            handleAirDropDrop(providers: providers)
            return true
        }
        .onChange(of: isAirDropDropTargeted) { _, targeted in
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                airDropPulse = targeted
            }
        }
    }

    private var airDropDropZone: some View {
        Button(action: {
            if !storage.items.isEmpty {
                shareAllViaAirDrop()
            } else {
                openAirDrop()
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    // Animated pulse rings when dropping
                    if isAirDropDropTargeted || airDropState.isSharing {
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(
                                    AppTheme.Colors.accentBlue.opacity(0.4 - Double(index) * 0.1),
                                    lineWidth: 1.5
                                )
                                .frame(
                                    width: CGFloat(50 + index * 20),
                                    height: CGFloat(50 + index * 20)
                                )
                                .scaleEffect(airDropPulse || airDropState.isSharing ? 1.2 : 0.8)
                                .opacity(airDropPulse || airDropState.isSharing ? 0 : 0.8)
                                .animation(
                                    .easeOut(duration: 1.5)
                                    .repeatForever(autoreverses: false)
                                    .delay(Double(index) * 0.2),
                                    value: airDropPulse || airDropState.isSharing
                                )
                        }
                    }

                    // Main AirDrop icon with animation
                    airDropAnimatedIcon
                }
                .frame(height: 50)

                // Text label
                Text(airDropLabelText)
                    .font(AppTheme.Typography.caption())
                    .foregroundColor(
                        isAirDropDropTargeted ? AppTheme.Colors.accentBlue : AppTheme.Colors.textSecondary
                    )
                    .lineLimit(1)
                    .animation(.easeInOut(duration: 0.2), value: isAirDropDropTargeted)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 16)
            .frame(width: 140)
            .background(airDropEnhancedBackground)
            .scaleEffect(isAirDropDropTargeted ? 1.05 : (isAirDropHovering ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAirDropDropTargeted)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isAirDropHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isAirDropHovering = hovering
        }
    }

    private var airDropLabelText: String {
        if isAirDropDropTargeted {
            return "Drop to Share"
        } else if airDropState.isSharing {
            return "Sharing..."
        } else if !storage.items.isEmpty {
            return "Share \(storage.items.count) item\(storage.items.count > 1 ? "s" : "")"
        } else {
            return "AirDrop"
        }
    }

    private var airDropAnimatedIcon: some View {
        ZStack {
            // Outer glow when active
            if isAirDropDropTargeted || isAirDropHovering {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                AppTheme.Colors.accentBlue.opacity(0.4),
                                AppTheme.Colors.accentBlue.opacity(0)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 30
                        )
                    )
                    .frame(width: 60, height: 60)
                    .blur(radius: 5)
            }

            // Concentric rings with animation
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .stroke(
                        airDropRingColor(for: index),
                        lineWidth: isAirDropDropTargeted ? 2.5 : 2
                    )
                    .frame(
                        width: CGFloat(14 + index * 10),
                        height: CGFloat(14 + index * 10)
                    )
                    .scaleEffect(isAirDropDropTargeted ? 1.1 : 1.0)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6)
                        .delay(Double(index) * 0.05),
                        value: isAirDropDropTargeted
                    )
            }

            // Center dot with pulse
            Circle()
                .fill(AppTheme.Colors.accentBlue)
                .frame(width: 6, height: 6)
                .scaleEffect(isAirDropDropTargeted ? 1.3 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isAirDropDropTargeted)

            // File count badge when items exist
            if !storage.items.isEmpty && !isAirDropDropTargeted {
                Text("\(storage.items.count)")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.accentBlue)
                    )
                    .offset(x: 18, y: -14)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 40, height: 40)
    }

    private func airDropRingColor(for index: Int) -> Color {
        if isAirDropDropTargeted {
            return AppTheme.Colors.accentBlue.opacity(1.0 - Double(index) * 0.2)
        } else if isAirDropHovering {
            return AppTheme.Colors.accentBlue.opacity(0.9 - Double(index) * 0.2)
        } else {
            return AppTheme.Colors.accentBlue.opacity(0.7 - Double(index) * 0.15)
        }
    }

    private var airDropEnhancedBackground: some View {
        ZStack {
            // Base gradient
            if isAirDropDropTargeted {
                RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                AppTheme.Colors.accentBlue.opacity(0.3),
                                AppTheme.Colors.accentBlue.opacity(0.15)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            } else {
                RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                    .fill(
                        AppTheme.Colors.airDropGradient
                            .opacity(isAirDropHovering ? 1.0 : 0.8)
                    )
            }

            // Animated border
            RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                .stroke(
                    isAirDropDropTargeted ?
                    AppTheme.Colors.accentBlue.opacity(0.8) :
                    AppTheme.Colors.accentBlue.opacity(isAirDropHovering ? 0.4 : 0.2),
                    lineWidth: isAirDropDropTargeted ? 2 : 1
                )

            // Shimmer effect when drop targeted
            if isAirDropDropTargeted {
                RoundedRectangle(cornerRadius: AppConstants.Layout.padding, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0),
                                Color.white.opacity(0.1),
                                Color.white.opacity(0)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .opacity(airDropPulse ? 1 : 0)
                    .animation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true), value: airDropPulse)
            }
        }
    }

    // MARK: - AirDrop Actions

    private func handleAirDropDrop(providers: [NSItemProvider]) {
        var fileURLs: [URL] = []
        let group = DispatchGroup()

        for provider in providers {
            if provider.hasItemConformingToTypeIdentifier(UTType.fileURL.identifier) {
                group.enter()
                _ = provider.loadObject(ofClass: URL.self) { url, error in
                    if let url = url, url.isFileURL {
                        DispatchQueue.main.async {
                            fileURLs.append(url)
                        }
                    }
                    group.leave()
                }
            }
        }

        group.notify(queue: .main) {
            if !fileURLs.isEmpty {
                // Haptic feedback
                HapticManager.shared.playFeedback(.medium)

                // Start sharing animation
                airDropState.startSharing(files: fileURLs)

                // Perform AirDrop share
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    self.performAirDropShare(files: fileURLs)
                }
            }
        }
    }

    private func performAirDropShare(files: [URL]) {
        if let airDropService = NSSharingService(named: .sendViaAirDrop) {
            if airDropService.canPerform(withItems: files) {
                airDropService.delegate = AirDropServiceDelegate.shared
                airDropService.perform(withItems: files)

                // Complete animation after a delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    airDropState.completeSharing()
                }
            } else {
                airDropState.cancelSharing()
                openAirDrop()
            }
        } else {
            airDropState.cancelSharing()
            openAirDrop()
        }
    }

    private func openAirDrop() {
        let airDropURL = URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app")
        NSWorkspace.shared.open(airDropURL)
    }

    /// Share all tray items via AirDrop
    private func shareAllViaAirDrop() {
        let fileURLs = storage.items.compactMap { $0.url.isFileURL ? $0.url : nil }
        guard !fileURLs.isEmpty else {
            openAirDrop()
            return
        }

        HapticManager.shared.playFeedback(.medium)
        airDropState.startSharing(files: fileURLs)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            performAirDropShare(files: fileURLs)
        }
    }
}

// MARK: - AirDrop Service Delegate
class AirDropServiceDelegate: NSObject, NSSharingServiceDelegate {
    static let shared = AirDropServiceDelegate()

    func sharingService(_ sharingService: NSSharingService, didShareItems items: [Any]) {
        DispatchQueue.main.async {
            AirDropState.shared.completeSharing()
            HapticManager.shared.playFeedback(.light)
        }
    }

    func sharingService(_ sharingService: NSSharingService, didFailToShareItems items: [Any], error: Error) {
        DispatchQueue.main.async {
            AirDropState.shared.cancelSharing()
        }
    }
}

// MARK: - Tray File Chip
/// A compact file chip displaying file icon and name with hover actions
/// Supports drag-out functionality for Dropover-style behavior

struct TrayFileChip: View {

    // MARK: - Properties
    let item: TrayItem
    let onTap: () -> Void
    let onDelete: () -> Void

    @State private var fileIcon: NSImage?
    @State private var isHovering = false
    @State private var isDragging = false

    // MARK: - Body
    var body: some View {
        Button(action: onTap) {
            ZStack(alignment: .topTrailing) {
                chipContent

                if isHovering && !isDragging {
                    actionButtons
                }
            }
            .hoverScale(isHovering && !isDragging, scale: 1.05)
        }
        .buttonStyle(.plain)
        .opacity(isDragging ? 0.5 : 1.0)
        .onDrag {
            isDragging = true
            // Return the file URL for dragging to other apps
            let provider = NSItemProvider(object: item.url as NSURL)
            return provider
        }
        .onHover { hovering in
            withAnimation(AppTheme.Animations.hover) {
                isHovering = hovering
                if !hovering {
                    isDragging = false
                }
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

            Text(item.url.deletingPathExtension().lastPathComponent)
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
            if item.url.isFileURL {
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
            } else {
                Image(systemName: "link")
                    .font(.system(size: 16))
                    .foregroundColor(AppTheme.Colors.accentBlue)
            }
        }
    }

    private var actionButtons: some View {
        HStack(spacing: 2) {
            // AirDrop button
            Button(action: shareViaAirDrop) {
                Image(systemName: "airplayaudio")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundStyle(.white, AppTheme.Colors.accentBlue)
                    .frame(width: 16, height: 16)
                    .background(
                        Circle()
                            .fill(AppTheme.Colors.accentBlue)
                    )
            }
            .buttonStyle(.plain)

            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 16, height: 16)
                    .background(
                        Circle()
                            .fill(Color.red.opacity(0.9))
                    )
            }
            .buttonStyle(.plain)
        }
        .offset(x: 8, y: -8)
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Helpers

    private func loadFileIcon() {
        if item.url.isFileURL {
            fileIcon = NSWorkspace.shared.icon(forFile: item.url.path)
        }
    }

    private func shareViaAirDrop() {
        guard item.url.isFileURL else { return }

        // Use NSSharingService to share via AirDrop
        if let airDropService = NSSharingService(named: .sendViaAirDrop) {
            if airDropService.canPerform(withItems: [item.url]) {
                airDropService.perform(withItems: [item.url])
            } else {
                // Fallback: Open Finder's AirDrop window
                openAirDropWindow()
            }
        } else {
            // Fallback: Open Finder's AirDrop window
            openAirDropWindow()
        }
    }

    private func openAirDropWindow() {
        let airDropURL = URL(fileURLWithPath: "/System/Library/CoreServices/Finder.app/Contents/Applications/AirDrop.app")
        NSWorkspace.shared.open(airDropURL)
    }
}

// MARK: - Preview
#Preview {
    TrayView()
        .frame(width: 500, height: 100)
        .background(Color.black)
}