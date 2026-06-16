import Foundation

public protocol StateMachineStore: Sendable {
    func loadSnapshot(for machineID: StateMachineID) async throws -> StateMachineSnapshot?
    func saveSnapshot(_ snapshot: StateMachineSnapshot) async throws
    func resetSnapshot(for machineID: StateMachineID) async throws
}

public actor InMemoryStateMachineStore: StateMachineStore {
    private var snapshots: [StateMachineID: StateMachineSnapshot]

    public init(seed: [StateMachineSnapshot] = []) {
        var values: [StateMachineID: StateMachineSnapshot] = [:]
        for snapshot in seed {
            values[snapshot.machineID] = snapshot
        }
        self.snapshots = values
    }

    public func loadSnapshot(for machineID: StateMachineID) async throws -> StateMachineSnapshot? {
        snapshots[machineID]
    }

    public func saveSnapshot(_ snapshot: StateMachineSnapshot) async throws {
        snapshots[snapshot.machineID] = snapshot
    }

    public func resetSnapshot(for machineID: StateMachineID) async throws {
        snapshots.removeValue(forKey: machineID)
    }
}
