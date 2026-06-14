import Foundation

public enum RemoteAssetCachePolicy: Hashable, Codable, Sendable, CustomStringConvertible {
    case immutable
    case revalidateOnLaunch
    case refreshAfter(seconds: TimeInterval)
    case noStore

    public static func refreshingAfter(_ seconds: TimeInterval) throws -> Self {
        guard seconds.isFinite, seconds > 0 else {
            throw RemoteAssetFailure(code: .invalidCachePolicy)
        }
        return .refreshAfter(seconds: seconds)
    }

    public var description: String {
        switch self {
        case .immutable:
            "RemoteAssetCachePolicy(immutable)"
        case .revalidateOnLaunch:
            "RemoteAssetCachePolicy(revalidateOnLaunch)"
        case .refreshAfter(let seconds):
            "RemoteAssetCachePolicy(refreshAfter: \(Int(seconds))s)"
        case .noStore:
            "RemoteAssetCachePolicy(noStore)"
        }
    }
}
