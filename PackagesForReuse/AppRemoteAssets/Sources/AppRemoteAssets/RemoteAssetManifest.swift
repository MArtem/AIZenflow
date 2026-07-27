import Foundation

public struct RemoteAssetManifest: Codable, Sendable, CustomStringConvertible {
    public let schemaVersion: RemoteAssetVersion
    public let generatedAt: Date?
    public let assets: [RemoteAssetDescriptor]

    public init(
        schemaVersion: RemoteAssetVersion,
        generatedAt: Date? = nil,
        assets: [RemoteAssetDescriptor]
    ) throws {
        var seen: Set<RemoteAssetID> = []
        for asset in assets {
            guard seen.insert(asset.id).inserted else {
                throw RemoteAssetFailure(code: .duplicateAssetIdentifier)
            }
        }
        self.schemaVersion = schemaVersion
        self.generatedAt = generatedAt
        self.assets = assets
    }

    private enum CodingKeys: String, CodingKey {
        case schemaVersion
        case generatedAt
        case assets
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        try self.init(
            schemaVersion: container.decode(RemoteAssetVersion.self, forKey: .schemaVersion),
            generatedAt: container.decodeIfPresent(Date.self, forKey: .generatedAt),
            assets: container.decode([RemoteAssetDescriptor].self, forKey: .assets)
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(schemaVersion, forKey: .schemaVersion)
        try container.encodeIfPresent(generatedAt, forKey: .generatedAt)
        try container.encode(assets, forKey: .assets)
    }

    public func asset(withID id: RemoteAssetID) -> RemoteAssetDescriptor? {
        assets.first { $0.id == id }
    }

    public var description: String {
        "RemoteAssetManifest(schemaVersion: redacted, assetCount: \(assets.count))"
    }
}
