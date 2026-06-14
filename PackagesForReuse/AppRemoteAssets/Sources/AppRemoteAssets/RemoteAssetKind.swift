import Foundation

public enum RemoteAssetKind: String, Codable, Sendable, CaseIterable, CustomStringConvertible {
    case image
    case data
    case json
    case archive
    case configuration
    case other

    public var description: String {
        "RemoteAssetKind(\(rawValue))"
    }
}
