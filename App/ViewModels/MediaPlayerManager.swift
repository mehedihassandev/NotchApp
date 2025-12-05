import Foundation
import Combine
import AppKit

// MARK: - Media Player Manager
/// Manager class to fetch and monitor currently playing media from any app
/// Uses the private MediaRemote framework for system-wide media control

final class MediaPlayerManager: ObservableObject {

    // MARK: - Published Properties
    @Published private(set) var currentMedia: MediaInfo = .placeholder
    @Published private(set) var nowPlayingAppName: String = ""

    // MARK: - Private Properties
    private var timer: Timer?
    private var mediaRemoteBundle: CFBundle?
    private var cancellables = Set<AnyCancellable>()

    // MRMediaRemote function pointers
    private var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    private var MRMediaRemoteGetNowPlayingApplicationIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction?
    private var MRMediaRemoteSendCommand: MRMediaRemoteSendCommandFunction?
    private var MRMediaRemoteGetNowPlayingClient: MRMediaRemoteGetNowPlayingClientFunction?

    // MARK: - Initialization
    init() {
        loadMediaRemoteFramework()
        setupMediaMonitoring()
    }

    deinit {
        stopMonitoring()
    }

    // MARK: - Public Methods

    func togglePlayPause() {
        sendCommand(.togglePlayPause)
    }

    func nextTrack() {
        sendCommand(.nextTrack)
    }

    func previousTrack() {
        sendCommand(.previousTrack)
    }

    func refresh() {
        updateMediaInfo()
    }

    // MARK: - Private Methods - Framework Loading

    private func loadMediaRemoteFramework() {
        let bundlePath = "/System/Library/PrivateFrameworks/MediaRemote.framework"

        guard let bundleURL = CFURLCreateWithFileSystemPath(
            kCFAllocatorDefault,
            bundlePath as CFString,
            .cfurlposixPathStyle,
            true
        ) else {
            logError("Failed to create MediaRemote bundle URL", category: .media)
            return
        }

        guard let bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL) else {
            logError("Failed to load MediaRemote framework", category: .media)
            return
        }

        mediaRemoteBundle = bundle
        logInfo("MediaRemote framework loaded successfully", category: .media)

        loadFunctionPointers(from: bundle)
    }

    private func loadFunctionPointers(from bundle: CFBundle) {
        // Load MRMediaRemoteGetNowPlayingInfo
        if let pointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
            MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(pointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
            logDebug("MRMediaRemoteGetNowPlayingInfo loaded", category: .media)
        }

        // Load MRMediaRemoteGetNowPlayingApplicationIsPlaying
        if let pointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) {
            MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(pointer, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
            logDebug("MRMediaRemoteGetNowPlayingApplicationIsPlaying loaded", category: .media)
        }

        // Load MRMediaRemoteSendCommand
        if let pointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) {
            MRMediaRemoteSendCommand = unsafeBitCast(pointer, to: MRMediaRemoteSendCommandFunction.self)
            logDebug("MRMediaRemoteSendCommand loaded", category: .media)
        }

        // Load MRMediaRemoteGetNowPlayingClient
        if let pointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingClient" as CFString) {
            MRMediaRemoteGetNowPlayingClient = unsafeBitCast(pointer, to: MRMediaRemoteGetNowPlayingClientFunction.self)
            logDebug("MRMediaRemoteGetNowPlayingClient loaded", category: .media)
        }
    }

    // MARK: - Private Methods - Monitoring

    private func setupMediaMonitoring() {
        startPolling()
        registerNotifications()
        updateMediaInfo()
    }

    private func startPolling() {
        timer = Timer.scheduledTimer(
            withTimeInterval: AppConstants.MediaPlayer.pollingInterval,
            repeats: true
        ) { [weak self] _ in
            self?.updateMediaInfo()
        }
        timer?.tolerance = AppConstants.MediaPlayer.pollingTolerance
    }

    private func stopMonitoring() {
        timer?.invalidate()
        timer = nil
        DistributedNotificationCenter.default().removeObserver(self)
    }

    private func registerNotifications() {
        let notificationNames = [
            "com.apple.Music.playerInfo",
            "com.spotify.client.PlaybackStateChanged",
            "com.google.Chrome.playerInfo",
            "kMRMediaRemoteNowPlayingInfoDidChangeNotification",
            "kMRMediaRemoteNowPlayingApplicationDidChangeNotification",
            "kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification",
            "kMRNowPlayingPlaybackQueueChangedNotification",
            "kMRPlaybackQueueContentItemsChangedNotification",
            "AVSystemController_SystemVolumeDidChangeNotification"
        ]

        for name in notificationNames {
            DistributedNotificationCenter.default().addObserver(
                self,
                selector: #selector(handleMediaChange),
                name: NSNotification.Name(name),
                object: nil
            )
        }
    }

    @objc private func handleMediaChange(_ notification: Notification) {
        updateMediaInfo()
    }

    // MARK: - Private Methods - Media Info

    private func updateMediaInfo() {
        guard let getNowPlayingInfo = MRMediaRemoteGetNowPlayingInfo,
              let getIsPlaying = MRMediaRemoteGetNowPlayingApplicationIsPlaying else {
            logWarning("MediaRemote functions not available", category: .media)
            DispatchQueue.main.async { [weak self] in
                self?.currentMedia = .placeholder
            }
            return
        }

        // Get playing state first
        getIsPlaying(DispatchQueue.main) { [weak self] isPlaying in
            guard let self = self else { return }

            // Get now playing info
            getNowPlayingInfo(DispatchQueue.main) { [weak self] info in
                guard let self = self else { return }
                self.processMediaInfo(info, isPlaying: isPlaying)
            }
        }
    }

    private func processMediaInfo(_ info: [String: Any]?, isPlaying: Bool) {
        guard let info = info, !info.isEmpty else {
            logDebug("Media info is empty or nil", category: .media)
            DispatchQueue.main.async { [weak self] in
                self?.currentMedia = .placeholder
            }
            return
        }

        let title = extractString(from: info, keys: [MediaInfoKey.title, MediaInfoKey.titleAlt]) ?? "Unknown"
        let artist = extractString(from: info, keys: [MediaInfoKey.artist, MediaInfoKey.artistAlt]) ?? "Unknown Artist"
        let album = extractString(from: info, keys: [MediaInfoKey.album, MediaInfoKey.albumAlt])
        let duration = extractDouble(from: info, keys: [MediaInfoKey.duration, MediaInfoKey.durationAlt])
        let elapsed = extractDouble(from: info, keys: [MediaInfoKey.elapsedTime, MediaInfoKey.elapsedTimeAlt])
        let artwork = extractArtwork(from: info)

        // Update app name
        if let bundleId = extractString(from: info, keys: [MediaInfoKey.bundleIdentifier, MediaInfoKey.clientDeviceIdentifier]) {
            nowPlayingAppName = bundleId
        }

        // Only update if we have meaningful title
        guard title != "Unknown" else {
            logDebug("No valid title found in media info", category: .media)
            DispatchQueue.main.async { [weak self] in
                self?.currentMedia = .placeholder
            }
            return
        }

        logDebug("Found media: \(title) by \(artist)", category: .media)

        DispatchQueue.main.async { [weak self] in
            self?.currentMedia = MediaInfo(
                title: title,
                artist: artist,
                album: album,
                artwork: artwork,
                isPlaying: isPlaying,
                duration: duration,
                currentTime: elapsed
            )
        }
    }

    // MARK: - Private Methods - Command Sending

    private func sendCommand(_ command: MediaRemoteCommand) {
        guard let sendCommand = MRMediaRemoteSendCommand else {
            logWarning("MRMediaRemoteSendCommand not available", category: .media)
            return
        }

        _ = sendCommand(command.rawValue, nil)

        // Update state after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + AppConstants.MediaPlayer.commandDelay) { [weak self] in
            self?.updateMediaInfo()
        }
    }

    // MARK: - Private Methods - Value Extraction

    private func extractString(from info: [String: Any], keys: [String]) -> String? {
        for key in keys {
            if let value = info[key] as? String {
                return value
            }
        }
        return nil
    }

    private func extractDouble(from info: [String: Any], keys: [String]) -> Double {
        for key in keys {
            if let value = info[key] as? Double {
                return value
            }
        }
        return 0
    }

    private func extractArtwork(from info: [String: Any]) -> NSImage? {
        let artworkKeys = [MediaInfoKey.artworkData, MediaInfoKey.artworkDataAlt]

        for key in artworkKeys {
            if let artworkData = info[key] as? Data {
                return NSImage(data: artworkData)
            }
        }
        return nil
    }
}
