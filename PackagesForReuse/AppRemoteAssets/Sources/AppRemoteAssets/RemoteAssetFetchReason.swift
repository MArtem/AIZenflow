import Foundation

public enum RemoteAssetFetchReason: String, Codable, Sendable, Equatable, CustomStringConvertible {
    case missingLocalRecord
    case versionChanged
    case revalidationRequested
    case refreshWindowExpired
    case noStorePolicy

    public var description: String {
        "RemoteAssetFetchReason(\(rawValue))"
    }
}
