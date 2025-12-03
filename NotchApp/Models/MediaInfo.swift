import Foundation
import AppKit

/// Model representing currently playing media information
struct MediaInfo: Identifiable {
    let id = UUID()
    var title: String
    var artist: String
    var album: String?
    var artwork: NSImage?
    var isPlaying: Bool
    var duration: TimeInterval
    var currentTime: TimeInterval

    var progress: Double {
        guard duration > 0 else { return 0 }
        return currentTime / duration
    }

    var formattedCurrentTime: String {
        formatTime(currentTime)
    }

    var formattedDuration: String {
        formatTime(duration)
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

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
