import Foundation

public protocol PermissionManaging: Sendable {
    func state(for kind: PermissionKind) async -> PermissionState
    func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome
}

public extension PermissionManaging {
    func snapshot(for kind: PermissionKind) async -> PermissionSnapshot {
        let state = await state(for: kind)
        return PermissionSnapshot(kind: kind, state: state)
    }

    func snapshots(for kinds: [PermissionKind]) async -> [PermissionSnapshot] {
        var result: [PermissionSnapshot] = []
        result.reserveCapacity(kinds.count)
        for kind in kinds {
            result.append(await snapshot(for: kind))
        }
        return result
    }

    func diagnosticSnapshots(for kinds: [PermissionKind]) async -> [PermissionDiagnosticSnapshot] {
        await snapshots(for: kinds).map(PermissionDiagnosticSnapshot.init(snapshot:))
    }
}

public protocol PermissionProviding: Sendable {
    var supportedKinds: Set<PermissionKind> { get }
    func state(for kind: PermissionKind) async -> PermissionState
    func request(_ kind: PermissionKind) async throws -> PermissionRequestOutcome
}
