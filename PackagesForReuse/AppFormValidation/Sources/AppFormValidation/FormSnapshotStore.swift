import Foundation

public protocol FormSnapshotStore: Sendable {
    func load(formID: FormID) async throws -> FormSnapshot?
    func save(_ snapshot: FormSnapshot) async throws
    func remove(formID: FormID) async throws
}

public actor InMemoryFormSnapshotStore: FormSnapshotStore {
    private var snapshots: [FormID: FormSnapshot]

    public init(snapshots: [FormSnapshot] = []) {
        var keyed: [FormID: FormSnapshot] = [:]
        for snapshot in snapshots {
            keyed[snapshot.formID] = snapshot
        }
        self.snapshots = keyed
    }

    public func load(formID: FormID) async throws -> FormSnapshot? {
        snapshots[formID]
    }

    public func save(_ snapshot: FormSnapshot) async throws {
        snapshots[snapshot.formID] = snapshot
    }

    public func remove(formID: FormID) async throws {
        snapshots.removeValue(forKey: formID)
    }
}
