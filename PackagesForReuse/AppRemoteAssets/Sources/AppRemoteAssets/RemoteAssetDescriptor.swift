import Foundation

public struct RemoteAssetDescriptor: Hashable, Codable, Sendable, CustomStringConvertible {
    public let id: RemoteAssetID
    public let version: RemoteAssetVersion
    public let location: RemoteAssetLocation
    public let kind: RemoteAssetKind
    public let mediaType: RemoteAssetMediaType
    public let expectedByteCount: Int64?
    public let checksum: RemoteAssetChecksum?
    public let cachePolicy: RemoteAssetCachePolicy

    public init(
        id: RemoteAssetID,
        version: RemoteAssetVersion,
        location: RemoteAssetLocation,
        kind: RemoteAssetKind = .data,
        mediaType: RemoteAssetMediaType = .binary,
        expectedByteCount: Int64? = nil,
        checksum: RemoteAssetChecksum? = nil,
        cachePolicy: RemoteAssetCachePolicy = .revalidateOnLaunch
    ) throws {
        if let expectedByteCount, expectedByteCount <= 0 {
            throw RemoteAssetFailure(code: .invalidByteCount)
        }
        self.id = id
        self.version = version
        self.location = location
        self.kind = kind
        self.mediaType = mediaType
        self.expectedByteCount = expectedByteCount
        self.checksum = checksum
        self.cachePolicy = cachePolicy
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case version
        case location
        case kind
        case mediaType
        case expectedByteCount
        case checksum
        case cachePolicy
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            id: container.decode(RemoteAssetID.self, forKey: .id),
            version: container.decode(RemoteAssetVersion.self, forKey: .version),
            location: container.decode(RemoteAssetLocation.self, forKey: .location),
            kind: container.decodeIfPresent(RemoteAssetKind.self, forKey: .kind) ?? .data,
            mediaType: container.decodeIfPresent(RemoteAssetMediaType.self, forKey: .mediaType) ?? .binary,
            expectedByteCount: container.decodeIfPresent(Int64.self, forKey: .expectedByteCount),
            checksum: container.decodeIfPresent(RemoteAssetChecksum.self, forKey: .checksum),
            cachePolicy: container.decodeIfPresent(RemoteAssetCachePolicy.self, forKey: .cachePolicy) ?? .revalidateOnLaunch
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(version, forKey: .version)
        try container.encode(location, forKey: .location)
        try container.encode(kind, forKey: .kind)
        try container.encode(mediaType, forKey: .mediaType)
        try container.encodeIfPresent(expectedByteCount, forKey: .expectedByteCount)
        try container.encodeIfPresent(checksum, forKey: .checksum)
        try container.encode(cachePolicy, forKey: .cachePolicy)
    }

    public var description: String {
        "RemoteAssetDescriptor(id: redacted, version: redacted, kind: \(kind.rawValue), location: \(location.redactedURLString))"
    }
}
