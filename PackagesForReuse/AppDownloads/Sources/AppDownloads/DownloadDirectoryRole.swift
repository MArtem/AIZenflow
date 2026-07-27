import Foundation

public enum DownloadDirectoryRole: Equatable, Sendable, Codable, CustomStringConvertible {
    case caches
    case documents
    case applicationSupport
    case custom(label: String)
    case sharedContainer(identifier: String)

    public var description: String {
        switch self {
        case .caches:
            "DownloadDirectoryRole.caches"
        case .documents:
            "DownloadDirectoryRole.documents"
        case .applicationSupport:
            "DownloadDirectoryRole.applicationSupport"
        case .custom:
            "DownloadDirectoryRole.custom(redacted)"
        case .sharedContainer:
            "DownloadDirectoryRole.sharedContainer(redacted)"
        }
    }
}

public struct DownloadDirectory: Equatable, Sendable, CustomStringConvertible {
    public let role: DownloadDirectoryRole
    public let url: URL

    public init(role: DownloadDirectoryRole, url: URL) throws {
        guard url.isFileURL else {
            throw DownloadFailure(.invalidDestination, operation: .validation)
        }
        self.role = role
        self.url = url
    }

    public var description: String {
        "DownloadDirectory(role: \(role), path: redacted)"
    }
}

public enum DownloadDirectoryResolver {
    public static func standard(_ role: DownloadDirectoryRole) throws -> DownloadDirectory {
        let manager = FileManager.default
        switch role {
        case .caches:
            guard let url = manager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
                throw DownloadFailure(.invalidDestination, operation: .validation)
            }
            return try DownloadDirectory(role: role, url: url)
        case .documents:
            guard let url = manager.urls(for: .documentDirectory, in: .userDomainMask).first else {
                throw DownloadFailure(.invalidDestination, operation: .validation)
            }
            return try DownloadDirectory(role: role, url: url)
        case .applicationSupport:
            guard let url = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                throw DownloadFailure(.invalidDestination, operation: .validation)
            }
            return try DownloadDirectory(role: role, url: url)
        case .custom, .sharedContainer:
            throw DownloadFailure(.invalidDestination, operation: .validation)
        }
    }

    #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS)
    public static func sharedContainer(identifier: String) throws -> DownloadDirectory {
        guard identifier.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw DownloadFailure(.invalidDestination, operation: .validation)
        }
        guard let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: identifier) else {
            throw DownloadFailure(.invalidDestination, operation: .validation)
        }
        return try DownloadDirectory(role: .sharedContainer(identifier: identifier), url: url)
    }
    #endif
}
