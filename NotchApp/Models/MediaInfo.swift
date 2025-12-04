import Foundation
import AppKit

// MARK: - Media Info
/// Model representing currently playing media information

struct MediaInfo: Identifiable, Equatable {

    // MARK: - Properties
    let id: UUID
    var title: String
    var artist: String
    var album: String?
    var artwork: NSImage?
    var isPlaying: Bool
    var duration: TimeInterval
    var currentTime: TimeInterval

    // MARK: - Initialization
    init(
        id: UUID = UUID(),
        title: String,
        artist: String,
        album: String? = nil,
        artwork: NSImage? = nil,
        isPlaying: Bool = false,
        duration: TimeInterval = 0,
        currentTime: TimeInterval = 0
    ) {
        self.id = id
        self.title = title
        self.artist = artist
        self.album = album
        self.artwork = artwork
        self.isPlaying = isPlaying
        self.duration = duration
        self.currentTime = currentTime
    }

    // MARK: - Computed Properties

    /// Playback progress as a value between 0 and 1
    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    /// Formatted current time string (e.g., "2:34")
    var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    /// Formatted duration string (e.g., "4:56")
    var formattedDuration: String {
        formatTime(duration)
    }

    /// Whether this represents actual media or a placeholder
    var isPlaceholder: Bool {
        title == "No Media Playing"
    }

    /// Whether media info has meaningful content
    var hasContent: Bool {
        !isPlaceholder && title != "Unknown"
    }

    // MARK: - Helpers

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // MARK: - Equatable

    static func == (lhs: MediaInfo, rhs: MediaInfo) -> Bool {
        lhs.title == rhs.title &&
        lhs.artist == rhs.artist &&
        lhs.isPlaying == rhs.isPlaying &&
        lhs.duration == rhs.duration
    }

    // MARK: - Static Properties

    /// Placeholder instance when no media is playing
    static var placeholder: MediaInfo {
        MediaInfo(
            title: "No Media Playing",
            artist: "---",
            album: nil,
            artwork: nil,
            isPlaying: false,
            duration: 0,
            currentTime: 0
        )
    }
}

// MARK: - Media Source
/// Represents the source application of the media

enum MediaSource: String {
    case appleMusic = "com.apple.Music"
    case spotify = "com.spotify.client"
    case chrome = "com.google.Chrome"
    case safari = "com.apple.Safari"
    case unknown = "unknown"

    var displayName: String {
        switch self {
        case .appleMusic: return "Apple Music"
        case .spotify: return "Spotify"
        case .chrome: return "Chrome"
        case .safari: return "Safari"
        case .unknown: return "Unknown"
        }
    }

    var icon: String {
        switch self {
        case .appleMusic: return "music.note"
        case .spotify: return "music.note.list"
        case .chrome, .safari: return "globe"
        case .unknown: return "music.note"
        }
    }

    init(bundleIdentifier: String?) {
        guard let id = bundleIdentifier else {
            self = .unknown
            return
        }

        self = MediaSource(rawValue: id) ?? .unknown
    }
}
