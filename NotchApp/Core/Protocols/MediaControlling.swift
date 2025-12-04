import Foundation
import AppKit

// MARK: - Media Controlling Protocol
/// Protocol for media playback control
/// This abstraction allows for easy testing and alternative implementations

protocol MediaControlling: AnyObject {
    /// Current media information
    var currentMedia: MediaInfo { get }

    /// Name of the currently playing app
    var nowPlayingAppName: String { get }

    /// Toggle play/pause state
    func togglePlayPause()

    /// Skip to next track
    func nextTrack()

    /// Skip to previous track
    func previousTrack()

    /// Force refresh media information
    func refresh()
}

// MARK: - Media Remote Commands
/// Commands supported by the MediaRemote framework
enum MediaRemoteCommand: UInt32 {
    case play = 0
    case pause = 1
    case togglePlayPause = 2
    case stop = 3
    case nextTrack = 4
    case previousTrack = 5
}

// MARK: - Media Remote Function Types
/// Type definitions for MRMediaRemote private framework functions
typealias MRMediaRemoteGetNowPlayingInfoFunction = @convention(c) (
    DispatchQueue,
    @escaping ([String: Any]?) -> Void
) -> Void

typealias MRMediaRemoteGetNowPlayingApplicationIsPlayingFunction = @convention(c) (
    DispatchQueue,
    @escaping (Bool) -> Void
) -> Void

typealias MRMediaRemoteSendCommandFunction = @convention(c) (
    UInt32,
    UnsafeMutableRawPointer?
) -> Bool

typealias MRMediaRemoteGetNowPlayingClientFunction = @convention(c) (
    DispatchQueue,
    @escaping (AnyObject?) -> Void
) -> Void

// MARK: - Media Info Keys
/// Known keys for the MediaRemote now playing info dictionary
enum MediaInfoKey {
    static let title = "kMRMediaRemoteNowPlayingInfoTitle"
    static let artist = "kMRMediaRemoteNowPlayingInfoArtist"
    static let album = "kMRMediaRemoteNowPlayingInfoAlbum"
    static let duration = "kMRMediaRemoteNowPlayingInfoDuration"
    static let elapsedTime = "kMRMediaRemoteNowPlayingInfoElapsedTime"
    static let artworkData = "kMRMediaRemoteNowPlayingInfoArtworkData"
    static let bundleIdentifier = "kMRMediaRemoteNowPlayingApplicationBundleIdentifier"
    static let clientDeviceIdentifier = "kMRMediaRemoteNowPlayingInfoClientPropertiesDeviceIdentifier"

    // Alternative keys used by some apps
    static let titleAlt = "title"
    static let artistAlt = "artist"
    static let albumAlt = "album"
    static let durationAlt = "duration"
    static let elapsedTimeAlt = "elapsedTime"
    static let artworkDataAlt = "artworkData"
}
