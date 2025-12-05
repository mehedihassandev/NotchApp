import Foundation
import os.log

// MARK: - App Logger
/// Centralized logging utility for the app
/// Uses os.log for efficient system logging

final class AppLogger {

    // MARK: - Subsystems
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.notchapp"

    // MARK: - Categories
    enum Category: String {
        case general = "General"
        case media = "Media"
        case ui = "UI"
        case window = "Window"
        case persistence = "Persistence"
    }

    // MARK: - Log Levels
    enum Level {
        case debug
        case info
        case warning
        case error

        var osLogType: OSLogType {
            switch self {
            case .debug: return .debug
            case .info: return .info
            case .warning: return .default
            case .error: return .error
            }
        }

        var emoji: String {
            switch self {
            case .debug: return "🔍"
            case .info: return "ℹ️"
            case .warning: return "⚠️"
            case .error: return "❌"
            }
        }
    }

    // MARK: - Singleton
    static let shared = AppLogger()

    private init() {}

    // MARK: - Logging Methods

    /// Logs a message with the specified level and category
    func log(
        _ message: String,
        level: Level = .info,
        category: Category = .general,
        file: String = #file,
        function: String = #function,
        line: Int = #line
    ) {
        let logger = Logger(subsystem: AppLogger.subsystem, category: category.rawValue)
        let fileName = (file as NSString).lastPathComponent

        #if DEBUG
        let fullMessage = "\(level.emoji) [\(fileName):\(line)] \(function) - \(message)"
        print(fullMessage)
        #endif

        logger.log(level: level.osLogType, "\(message)")
    }

    // MARK: - Convenience Methods

    func debug(_ message: String, category: Category = .general) {
        log(message, level: .debug, category: category)
    }

    func info(_ message: String, category: Category = .general) {
        log(message, level: .info, category: category)
    }

    func warning(_ message: String, category: Category = .general) {
        log(message, level: .warning, category: category)
    }

    func error(_ message: String, category: Category = .general) {
        log(message, level: .error, category: category)
    }
}

// MARK: - Global Convenience Functions

/// Debug log
func logDebug(_ message: String, category: AppLogger.Category = .general) {
    AppLogger.shared.debug(message, category: category)
}

/// Info log
func logInfo(_ message: String, category: AppLogger.Category = .general) {
    AppLogger.shared.info(message, category: category)
}

/// Warning log
func logWarning(_ message: String, category: AppLogger.Category = .general) {
    AppLogger.shared.warning(message, category: category)
}

/// Error log
func logError(_ message: String, category: AppLogger.Category = .general) {
    AppLogger.shared.error(message, category: category)
}
