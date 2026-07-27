import Foundation

public enum RemoteAssetFetchAction: Equatable, Sendable, CustomStringConvertible {
    case keep(RemoteAssetDescriptor)
    case fetch(RemoteAssetDescriptor, reason: RemoteAssetFetchReason)
    case removeLocal(RemoteAssetID)

    public var description: String {
        switch self {
        case .keep(let asset):
            "RemoteAssetFetchAction(keep, id: redacted, kind: \(asset.kind.rawValue))"
        case .fetch(let asset, let reason):
            "RemoteAssetFetchAction(fetch, id: redacted, kind: \(asset.kind.rawValue), reason: \(reason.rawValue))"
        case .removeLocal:
            "RemoteAssetFetchAction(removeLocal, id: redacted)"
        }
    }
}
