import Foundation

public struct RemoteAssetFetchPlanner: Sendable {
    public let removesLocalRecordsMissingFromManifest: Bool

    public init(removesLocalRecordsMissingFromManifest: Bool = false) {
        self.removesLocalRecordsMissingFromManifest = removesLocalRecordsMissingFromManifest
    }

    public func makePlan(
        manifest: RemoteAssetManifest,
        localRecords: [RemoteAssetLocalRecord],
        now: Date = Date()
    ) -> RemoteAssetFetchPlan {
        var recordsByID: [RemoteAssetID: RemoteAssetLocalRecord] = [:]
        for record in localRecords {
            recordsByID[record.id] = record
        }
        let manifestIDs = Set(manifest.assets.map(\.id))
        var actions: [RemoteAssetFetchAction] = []

        for asset in manifest.assets {
            guard let record = recordsByID[asset.id] else {
                actions.append(.fetch(asset, reason: .missingLocalRecord))
                continue
            }
            if record.version != asset.version {
                actions.append(.fetch(asset, reason: .versionChanged))
                continue
            }
            switch asset.cachePolicy {
            case .immutable:
                actions.append(.keep(asset))
            case .revalidateOnLaunch:
                actions.append(.fetch(asset, reason: .revalidationRequested))
            case .refreshAfter(let seconds):
                let reference = record.validatedAt ?? record.storedAt
                if now.timeIntervalSince(reference) >= seconds {
                    actions.append(.fetch(asset, reason: .refreshWindowExpired))
                } else {
                    actions.append(.keep(asset))
                }
            case .noStore:
                actions.append(.fetch(asset, reason: .noStorePolicy))
            }
        }

        if removesLocalRecordsMissingFromManifest {
            for record in localRecords where !manifestIDs.contains(record.id) {
                actions.append(.removeLocal(record.id))
            }
        }

        return RemoteAssetFetchPlan(actions: actions)
    }
}
