import Foundation

public struct DownloadDestination: Equatable, Sendable, CustomStringConvertible {
    public let directory: DownloadDirectory
    public let fileName: SafeDownloadFileName
    public let replacementPolicy: DownloadReplacementPolicy

    public init(
        directory: DownloadDirectory,
        fileName: SafeDownloadFileName,
        replacementPolicy: DownloadReplacementPolicy = .replaceExisting
    ) {
        self.directory = directory
        self.fileName = fileName
        self.replacementPolicy = replacementPolicy
    }

    public var fileURL: URL {
        directory.url.appendingPathComponent(fileName.value, isDirectory: false)
    }

    public var description: String {
        "DownloadDestination(role: \(directory.role), fileName: redacted, policy: \(replacementPolicy))"
    }
}

public enum DownloadReplacementPolicy: String, Equatable, Sendable, Codable, CustomStringConvertible {
    case replaceExisting
    case failIfExists
    case makeUniqueName

    public var description: String { rawValue }
}
