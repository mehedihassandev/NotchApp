import AVFoundation
import Combine
import PDFKit
import QuickLookThumbnailing
import SwiftUI
import UniformTypeIdentifiers

// MARK: - Tray Item Model
/// Represents an item stored in the Dropover-style tray
struct TrayItem: Identifiable, Equatable, Codable {
    let id: UUID
    let url: URL
    let dateAdded: Date

    init(url: URL) {
        id = UUID()
        self.url = url
        dateAdded = Date()
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

        // Send notification
        NotificationManager.shared.notifyAirDropStarted(fileCount: files.count)

        // Animate progress
        withAnimation(.easeInOut(duration: 0.3)) {
            shareProgress = 0.3
        }
    }

    func completeSharing() {
        withAnimation(.easeOut(duration: 0.2)) {
            shareProgress = 1.0
        }

        // Send success notification
        NotificationManager.shared.notifyAirDropCompleted(fileCount: droppedFiles.count)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeOut(duration: 0.3)) {
                self.isSharing = false
                self.droppedFiles = []
                self.shareProgress = 0
            }
        }
    }

    func cancelSharing() {
        // Send failure notification
        NotificationManager.shared.notifyAirDropFailed()

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

        // Send notification
        let fileName = url.lastPathComponent
        NotificationManager.shared.notifyItemAddedToTray(fileName: fileName)
    }

    func removeItem(_ item: TrayItem) {
        let fileName = item.url.lastPathComponent
        items.removeAll { $0.id == item.id }
        saveItems()

        // Send notification
        NotificationManager.shared.notifyItemRemovedFromTray(fileName: fileName)
    }

    func removeItem(at url: URL) {
        items.removeAll { $0.url == url }
        saveItems()
    }

    func clearAll() {
        let itemCount = items.count
        items.removeAll()
        saveItems()

        // Send notification
        if itemCount > 0 {
            NotificationManager.shared.notifyTrayCleared(itemCount: itemCount)
        }
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
        HStack(spacing: 24) {
            filesTraySection
            airDropSection
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(Color.black.opacity(0.45))
                .shadow(color: Color.black.opacity(0.18), radius: 18, x: 0, y: 8)
        )
        .frame(minHeight: 180)
        .onAppear {
            setupKeyboardShortcutObservers()
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self)
        }
    }

    // MARK: - Keyboard Shortcuts

    private func setupKeyboardShortcutObservers() {
        NotificationCenter.default.addObserver(
            forName: .clearTray,
            object: nil,
            queue: .main
        ) { [self] _ in
            handleClearTrayShortcut()
        }
    }

    private func handleClearTrayShortcut() {
        guard !storage.items.isEmpty else { return }

        // Show confirmation or just clear
        storage.clearAll()
        HapticManager.shared.success()
        logInfo("Tray cleared via keyboard shortcut", category: .general)
    }
}

// MARK: - Files Tray Section
extension TrayView {

    private var filesTraySection: some View {
        HStack(spacing: 0) {
            if storage.items.isEmpty {
                emptyTrayState
            } else {
                filesScrollView
            }
            // Removed Spacer to reduce left area
        }
        .padding(.horizontal, storage.items.isEmpty ? 8 : 0)
        .padding(.vertical, storage.items.isEmpty ? 32 : 18)
        .frame(maxWidth: .infinity)
        .frame(height: 140)
        .background(dropZoneBackground)
        .hoverScale(isDropTargeted || notchState.isDraggingFile, scale: 1.01)
        .onDrop(of: [.fileURL, .url, .text], isTargeted: $isDropTargeted) { providers in
            handleDrop(providers: providers)
            DispatchQueue.main.async {
                notchState.fileDragExited()
            }
            return true
        }
        .onHover { hovering in
            if hovering {
                NSApp.activate(ignoringOtherApps: true)
            }
        }
    }

    private var emptyTrayState: some View {
        VStack(spacing: 14) {
            Image(systemName: notchState.isDraggingFile ? "tray.and.arrow.down.fill" : "tray.fill")
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(notchState.isDraggingFile ? AppTheme.Colors.accentBlue : AppTheme.Colors.textQuaternary)
                .symbolEffect(.bounce, options: .repeating, value: notchState.isDraggingFile)
                .shadow(color: Color.black.opacity(0.18), radius: 8, x: 0, y: 2)

            Text(notchState.isDraggingFile ? "Drop Files Here" : "Files Tray")
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .foregroundColor(notchState.isDraggingFile ? AppTheme.Colors.textSecondary : AppTheme.Colors.textTertiary)
                .padding(.top, 2)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(AppTheme.Animations.spring, value: notchState.isDraggingFile)
    }

    private var filesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
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
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
        }
        .clipped()
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
            .frame(width: 140, height: 140) // Match Files Tray height
            .background(airDropEnhancedBackground)
            .scaleEffect(isAirDropDropTargeted ? 1.05 : (isAirDropHovering ? 1.02 : 1.0))
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isAirDropDropTargeted)
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isAirDropHovering)
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            isAirDropHovering = hovering
            if hovering {
                NSApp.activate(ignoringOtherApps: true)
            }
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
    @State private var fileThumbnail: NSImage?
    @State private var fileType: FilePreviewType = .unknown
    @State private var isDragging = false

    // MARK: - Body
    var body: some View {
        ZStack {
            Button(action: onTap) {
                chipContent
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(.plain)
            .opacity(isDragging ? 0.5 : 1.0)
            .frame(width: 80, height: 110) // Increased height
            .clipped()
            .onDrag {
                isDragging = true
                let provider = NSItemProvider(object: item.url as NSURL)
                DispatchQueue.main.async {
                    startDragSessionObserver()
                }
                return provider
            }
            .contextMenu {
                Button(action: onTap) {
                    Label("Open", systemImage: "arrow.up.forward.app")
                }
                Button(action: shareViaAirDrop) {
                    Label("Share via AirDrop", systemImage: "airplayaudio")
                }
                Divider()
                Button(action: onDelete) {
                    Label("Delete", systemImage: "trash")
                }
            }
            .onAppear {
                loadFileData()
            }

            // Close button outside top-right
            if !isDragging {
                VStack {
                    HStack {
                        Spacer()
                        actionButtons
                    }
                    Spacer()
                }
                .frame(width: 90, height: 115) // Increased height for close button area
            }
        }
        .frame(width: 90, height: 115) // Increased height for ZStack
    }

    // MARK: - Drag Session Observer
    private func startDragSessionObserver() {
        // After a short delay, check if the item is still present in the tray
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            // If the item is no longer in the tray, do nothing
            // If the item is still in the tray, remove it (assume drag out)
            if let storage = TrayStorageManager.shared as? TrayStorageManager {
                if storage.items.contains(where: { $0.id == item.id }) {
                    onDelete()
                }
            }
        }
    }

    // MARK: - Subviews

    private var chipContent: some View {
        VStack(spacing: 8) { // Slightly more spacing for taller chip
            fileIconView

            Text(item.url.deletingPathExtension().lastPathComponent)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.white.opacity(0.95))
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 60, minHeight: 20) // Ensure text area is a bit taller
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 10) // More vertical padding for height
    }

    private var fileIconView: some View {
        Group {
            if let thumbnail = fileThumbnail {
                // Show actual thumbnail preview
                Image(nsImage: thumbnail)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40, height: 40)
                    .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 7, style: .continuous)
                            .stroke(Color.white.opacity(0.4), lineWidth: 1.5)
                    )
            } else if item.url.isFileURL {
                // Show file type specific icon with color
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(fileType.backgroundColor)
                        .frame(width: 40, height: 40)

                    Image(systemName: fileType.iconName)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                }
            } else {
                // Web URL icon
                ZStack {
                    RoundedRectangle(cornerRadius: 7, style: .continuous)
                        .fill(AppTheme.Colors.accentBlue.opacity(0.8))
                        .frame(width: 40, height: 40)

                    Image(systemName: "link")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
        }
    }

    private var actionButtons: some View {
        Button(action: onDelete) {
            Image(systemName: "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(Color.black.opacity(0.8))
                .frame(width: 14, height: 14) // Smaller close button
                .background(
                    Circle()
                        .fill(Color.white.opacity(0.95))
                        .shadow(color: Color.black.opacity(0.18), radius: 1, x: 0, y: 1)
                )
        }
        .buttonStyle(.plain)
        .padding(.top, -2)
        .padding(.trailing, -2) // Less negative padding for smaller button
        .transition(.scale.combined(with: .opacity))
    }

    // MARK: - Helpers

    private func loadFileData() {
        guard item.url.isFileURL else { return }

        // Determine file type
        fileType = FilePreviewType.detect(from: item.url)

        // Load system icon as fallback
        fileIcon = NSWorkspace.shared.icon(forFile: item.url.path)

        // Generate thumbnail based on file type
        generateThumbnail(for: item.url)
    }

    private func generateThumbnail(for url: URL) {
        // Try different thumbnail generation methods based on file type
        switch fileType {
        case .image:
            generateImageThumbnail(for: url)
        case .video:
            generateVideoThumbnail(for: url)
        case .pdf:
            generatePDFThumbnail(for: url)
        default:
            // Use QuickLook for other file types
            generateQuickLookThumbnail(for: url)
        }
    }

    private func generateImageThumbnail(for url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let image = NSImage(contentsOf: url) {
                let thumbnail = self.resizeImage(image, toSize: CGSize(width: 200, height: 200))
                DispatchQueue.main.async {
                    self.fileThumbnail = thumbnail
                }
            } else {
                // Fallback to QuickLook
                self.generateQuickLookThumbnail(for: url)
            }
        }
    }

    private func generateVideoThumbnail(for url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            let asset = AVAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.maximumSize = CGSize(width: 200, height: 200)

            let time = CMTime(seconds: 1.0, preferredTimescale: 600)

            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                let thumbnail = NSImage(cgImage: cgImage, size: CGSize(width: 200, height: 200))
                DispatchQueue.main.async {
                    self.fileThumbnail = thumbnail
                }
            } catch {
                print("Error generating video thumbnail: \(error.localizedDescription)")
                // Fallback to QuickLook
                self.generateQuickLookThumbnail(for: url)
            }
        }
    }

    private func generatePDFThumbnail(for url: URL) {
        DispatchQueue.global(qos: .userInitiated).async {
            if let pdfDocument = PDFDocument(url: url),
               let firstPage = pdfDocument.page(at: 0) {
                let pageRect = firstPage.bounds(for: .mediaBox)
                let thumbnail = NSImage(size: CGSize(width: 200, height: 200))

                thumbnail.lockFocus()
                if let context = NSGraphicsContext.current?.cgContext {
                    context.setFillColor(NSColor.white.cgColor)
                    context.fill(CGRect(origin: .zero, size: thumbnail.size))

                    context.saveGState()
                    let scale = min(200.0 / pageRect.width, 200.0 / pageRect.height)
                    context.scaleBy(x: scale, y: scale)
                    firstPage.draw(with: .mediaBox, to: context)
                    context.restoreGState()
                }
                thumbnail.unlockFocus()

                DispatchQueue.main.async {
                    self.fileThumbnail = thumbnail
                }
            } else {
                // Fallback to QuickLook
                self.generateQuickLookThumbnail(for: url)
            }
        }
    }

    private func generateQuickLookThumbnail(for url: URL) {
        let size = CGSize(width: 200, height: 200)
        let request = QLThumbnailGenerator.Request(
            fileAt: url,
            size: size,
            scale: NSScreen.main?.backingScaleFactor ?? 1.0,
            representationTypes: .all
        )

        QLThumbnailGenerator.shared.generateBestRepresentation(for: request) { thumbnail, error in
            if let thumbnail = thumbnail {
                DispatchQueue.main.async {
                    self.fileThumbnail = thumbnail.nsImage
                }
            } else if let error = error {
                print("Error generating QuickLook thumbnail: \(error.localizedDescription)")
            }
        }
    }

    private func resizeImage(_ image: NSImage, toSize size: CGSize) -> NSImage {
        let thumbnail = NSImage(size: size)
        thumbnail.lockFocus()
        image.draw(in: CGRect(origin: .zero, size: size),
                   from: CGRect(origin: .zero, size: image.size),
                   operation: .copy,
                   fraction: 1.0)
        thumbnail.unlockFocus()
        return thumbnail
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

// MARK: - File Preview Type
/// Enumeration of different file types for preview generation

enum FilePreviewType {
    case image
    case video
    case pdf
    case zip
    case audio
    case document
    case code
    case unknown

    static func detect(from url: URL) -> FilePreviewType {
        let fileExtension = url.pathExtension.lowercased()

        // Image formats
        if ["jpg", "jpeg", "png", "gif", "bmp", "tiff", "tif", "heic", "heif", "webp", "svg"].contains(fileExtension) {
            return .image
        }

        // Video formats
        if ["mp4", "mov", "avi", "mkv", "m4v", "mpg", "mpeg", "wmv", "flv", "webm"].contains(fileExtension) {
            return .video
        }

        // PDF
        if fileExtension == "pdf" {
            return .pdf
        }

        // Archive formats
        if ["zip", "rar", "7z", "tar", "gz", "bz2", "xz", "dmg", "pkg"].contains(fileExtension) {
            return .zip
        }

        // Audio formats
        if ["mp3", "wav", "aac", "m4a", "flac", "ogg", "wma", "aiff", "alac"].contains(fileExtension) {
            return .audio
        }

        // Document formats
        if ["doc", "docx", "xls", "xlsx", "ppt", "pptx", "pages", "numbers", "key", "txt", "rtf"].contains(fileExtension) {
            return .document
        }

        // Code formats
        if ["swift", "py", "js", "ts", "java", "cpp", "c", "h", "m", "html", "css", "json", "xml", "yml", "yaml"].contains(fileExtension) {
            return .code
        }

        return .unknown
    }

    var iconName: String {
        switch self {
        case .image:
            return "photo.fill"
        case .video:
            return "video.fill"
        case .pdf:
            return "doc.text.fill"
        case .zip:
            return "doc.zipper"
        case .audio:
            return "music.note"
        case .document:
            return "doc.fill"
        case .code:
            return "chevron.left.forwardslash.chevron.right"
        case .unknown:
            return "doc.fill"
        }
    }

    var backgroundColor: Color {
        switch self {
        case .image:
            return Color.green.opacity(0.8)
        case .video:
            return Color.purple.opacity(0.8)
        case .pdf:
            return Color.red.opacity(0.8)
        case .zip:
            return Color.orange.opacity(0.8)
        case .audio:
            return Color.pink.opacity(0.8)
        case .document:
            return Color.blue.opacity(0.8)
        case .code:
            return Color.indigo.opacity(0.8)
        case .unknown:
            return Color.gray.opacity(0.8)
        }
    }
}

// MARK: - Preview
#Preview {
    TrayView()
        .frame(width: 500, height: 160)
        .background(Color.black)
}
