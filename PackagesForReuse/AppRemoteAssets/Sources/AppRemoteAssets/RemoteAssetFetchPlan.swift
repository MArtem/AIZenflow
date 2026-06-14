import Foundation

public struct RemoteAssetFetchPlan: Sendable, CustomStringConvertible {
    public let actions: [RemoteAssetFetchAction]

    public init(actions: [RemoteAssetFetchAction]) {
        self.actions = actions
    }

    public var fetchActions: [RemoteAssetFetchAction] {
        actions.filter {
            if case .fetch = $0 { return true }
            return false
        }
    }

    public var keepActions: [RemoteAssetFetchAction] {
        actions.filter {
            if case .keep = $0 { return true }
            return false
        }
    }

    public var removeActions: [RemoteAssetFetchAction] {
        actions.filter {
            if case .removeLocal = $0 { return true }
            return false
        }
    }

    public var description: String {
        "RemoteAssetFetchPlan(actionCount: \(actions.count), fetchCount: \(fetchActions.count), keepCount: \(keepActions.count), removeCount: \(removeActions.count))"
    }
}
