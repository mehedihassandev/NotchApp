import Foundation
import Combine
import AppKit

// MARK: - MRMediaRemote Private Framework Bridge
// These are private APIs that allow us to get now playing info from any app (Spotify, YouTube Music, etc.)

// Function type definitions for MRMediaRemote
typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (DispatchQueue, @escaping ([String: Any]?) -> Void) -> Void
typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (DispatchQueue, @escaping (Bool) -> Void) -> Void
typealias MRMediaRemoteSendCommandFunction = @convention(c) (UInt32, UnsafeMutableRawPointer?) -> Bool
typealias MRMediaRemoteGetNowPlayingClientFunction = @convention(c) (DispatchQueue, @escaping (AnyObject?) -> Void) -> Void

// MRMediaRemote commands
private let kMRPlay: UInt32 = 0
private let kMRPause: UInt32 = 1
private let kMRTogglePlayPause: UInt32 = 2
private let kMRStop: UInt32 = 3
private let kMRNextTrack: UInt32 = 4
private let kMRPreviousTrack: UInt32 = 5

/// Manager class to fetch and monitor currently playing media from any app
class MediaPlayerManager: ObservableObject {
    @Published var currentMedia: MediaInfo = .placeholder
    @Published var nowPlayingAppName: String = ""

    private var timer: Timer?
    private var mediaRemoteBundle: CFBundle?

    // MRMediaRemote function pointers
    private var MRMediaRemoteGetNowPlayingInfo: MRMediaRemoteGetNowPlayingInfoFunction?
    private var MRMediaRemoteGetNowPlayingApplicationIsPlaying: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction?
    private var MRMediaRemoteSendCommand: MRMediaRemoteSendCommandFunction?
    private var MRMediaRemoteGetNowPlayingClient: MRMediaRemoteGetNowPlayingClientFunction?

    init() {
        loadMediaRemoteFramework()
        setupMediaMonitoring()
    }

    private func loadMediaRemoteFramework() {
        // Load the private MediaRemote framework
        let bundlePath = "/System/Library/PrivateFrameworks/MediaRemote.framework"

        guard let bundleURL = CFURLCreateWithFileSystemPath(
            kCFAllocatorDefault,
            bundlePath as CFString,
            .cfurlposixPathStyle,
            true
        ) else {
            print("❌ Failed to create bundle URL")
            return
        }

        guard let bundle = CFBundleCreate(kCFAllocatorDefault, bundleURL) else {
            print("❌ Failed to load MediaRemote framework")
            return
        }

        mediaRemoteBundle = bundle
        print("✅ MediaRemote framework loaded successfully")

        // Get function pointers
        if let getNowPlayingInfoPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingInfo" as CFString) {
            MRMediaRemoteGetNowPlayingInfo = unsafeBitCast(getNowPlayingInfoPointer, to: MRMediaRemoteGetNowPlayingInfoFunction.self)
            print("✅ MRMediaRemoteGetNowPlayingInfo loaded")
        } else {
            print("❌ Failed to load MRMediaRemoteGetNowPlayingInfo")
        }

        if let getIsPlayingPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingApplicationIsPlaying" as CFString) {
            MRMediaRemoteGetNowPlayingApplicationIsPlaying = unsafeBitCast(getIsPlayingPointer, to: MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction.self)
            print("✅ MRMediaRemoteGetNowPlayingApplicationIsPlaying loaded")
        } else {
            print("❌ Failed to load MRMediaRemoteGetNowPlayingApplicationIsPlaying")
        }

        if let sendCommandPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteSendCommand" as CFString) {
            MRMediaRemoteSendCommand = unsafeBitCast(sendCommandPointer, to: MRMediaRemoteSendCommandFunction.self)
            print("✅ MRMediaRemoteSendCommand loaded")
        } else {
            print("❌ Failed to load MRMediaRemoteSendCommand")
        }

        if let getClientPointer = CFBundleGetFunctionPointerForName(bundle, "MRMediaRemoteGetNowPlayingClient" as CFString) {
            MRMediaRemoteGetNowPlayingClient = unsafeBitCast(getClientPointer, to: MRMediaRemoteGetNowPlayingClientFunction.self)
            print("✅ MRMediaRemoteGetNowPlayingClient loaded")
        } else {
            print("❌ Failed to load MRMediaRemoteGetNowPlayingClient")
        }
    }

    private func setupMediaMonitoring() {
        // Start monitoring for media changes
        startMonitoring()

        // Register for distributed notifications (works for most media apps)
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

        // Initial fetch
        updateMediaInfo()
    }

    private func startMonitoring() {
        // Poll for media info frequently (0.5 seconds) for better Chrome/web detection
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            self?.updateMediaInfo()
        }
        timer?.tolerance = 0.1
    }

    @objc private func handleMediaChange(_ notification: Notification) {
        updateMediaInfo()
    }

    private func updateMediaInfo() {
        // Try MRMediaRemote first (works for all apps including YouTube Music, Spotify, etc.)
        fetchUsingMediaRemote()
    }

    private func fetchUsingMediaRemote() {
        guard let getNowPlayingInfo = MRMediaRemoteGetNowPlayingInfo,
              let getIsPlaying = MRMediaRemoteGetNowPlayingApplicationIsPlaying else {
            print("⚠️ MediaRemote functions not available")
            // If MediaRemote framework is not available, show placeholder
            DispatchQueue.main.async { [weak self] in
                self?.currentMedia = .placeholder
            }
            return
        }

        // Get playing state first
        getIsPlaying(DispatchQueue.main) { [weak self] isPlaying in
            guard let self = self else { return }
            print("🎵 Is playing: \(isPlaying)")

            // Get now playing info
            getNowPlayingInfo(DispatchQueue.main) { [weak self] info in
                guard let self = self else { return }

                if let infoKeys = info?.keys {
                    print("📊 Raw info keys: \(Array(infoKeys))")
                }
                if let infoDict = info {
                    print("📊 Raw info: \(infoDict)")
                }

                if let info = info, !info.isEmpty {
                    // Try multiple key formats for different apps
                    let title = info["kMRMediaRemoteNowPlayingInfoTitle"] as? String
                        ?? info["title"] as? String
                        ?? "Unknown"

                    let artist = info["kMRMediaRemoteNowPlayingInfoArtist"] as? String
                        ?? info["artist"] as? String
                        ?? "Unknown Artist"

                    let album = info["kMRMediaRemoteNowPlayingInfoAlbum"] as? String
                        ?? info["album"] as? String

                    let duration = info["kMRMediaRemoteNowPlayingInfoDuration"] as? Double
                        ?? info["duration"] as? Double
                        ?? 0

                    let elapsed = info["kMRMediaRemoteNowPlayingInfoElapsedTime"] as? Double
                        ?? info["elapsedTime"] as? Double
                        ?? 0

                    // Get artwork
                    var artwork: NSImage?
                    if let artworkData = info["kMRMediaRemoteNowPlayingInfoArtworkData"] as? Data {
                        artwork = NSImage(data: artworkData)
                    } else if let artworkData = info["artworkData"] as? Data {
                        artwork = NSImage(data: artworkData)
                    }

                    // Get app name - try multiple keys for different apps
                    if let appBundleId = info["kMRMediaRemoteNowPlayingInfoClientPropertiesDeviceIdentifier"] as? String {
                        self.nowPlayingAppName = appBundleId
                    } else if let bundleId = info["kMRMediaRemoteNowPlayingApplicationBundleIdentifier"] as? String {
                        self.nowPlayingAppName = bundleId
                    }

                    // Only update if we have meaningful title (not "Unknown")
                    if title != "Unknown" {
                        print("✅ Found media: \(title) by \(artist)")
                        DispatchQueue.main.async {
                            self.currentMedia = MediaInfo(
                                title: title,
                                artist: artist,
                                album: album,
                                artwork: artwork,
                                isPlaying: isPlaying,
                                duration: duration,
                                currentTime: elapsed
                            )
                        }
                    } else {
                        // No valid media info, show placeholder
                        print("⚠️ No valid title found in media info")
                        DispatchQueue.main.async {
                            self.currentMedia = .placeholder
                        }
                    }
                } else {
                    // No media playing, show placeholder
                    print("⚠️ Media info is empty or nil")
                    DispatchQueue.main.async {
                        self.currentMedia = .placeholder
                    }
                }
            }
        }
    }

    func togglePlayPause() {
        // Use MRMediaRemote (works for any app - Spotify, YouTube Music, Apple Music, etc.)
        if let sendCommand = MRMediaRemoteSendCommand {
            _ = sendCommand(kMRTogglePlayPause, nil)

            // Update state after a short delay
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateMediaInfo()
            }
        }
    }

    func nextTrack() {
        if let sendCommand = MRMediaRemoteSendCommand {
            _ = sendCommand(kMRNextTrack, nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateMediaInfo()
            }
        }
    }

    func previousTrack() {
        if let sendCommand = MRMediaRemoteSendCommand {
            _ = sendCommand(kMRPreviousTrack, nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.updateMediaInfo()
            }
        }
    }

    deinit {
        timer?.invalidate()
        DistributedNotificationCenter.default().removeObserver(self)
    }
}
