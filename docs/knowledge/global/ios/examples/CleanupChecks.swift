import Foundation
actor CleanupLedger {
    var values: [Bool] = []
    func record(_ cancelled: Bool) { values.append(cancelled) }
    func snapshot() -> [Bool] { values }
}
@main struct CleanupChecks {
    static func operation(_ ledger: CleanupLedger, cancel: Bool) async throws {
        defer {
            await withTaskCancellationShield {
                await ledger.record(Task.isCancelled)
            }
        }
        if cancel { withUnsafeCurrentTask { $0?.cancel() } }
        try Task.checkCancellation()
    }
    static func main() async {
        let normalLedger = CleanupLedger()
        do { try await operation(normalLedger, cancel: false) } catch { exit(2) }
        let cancelledLedger = CleanupLedger()
        let cancelled = Task {
            do { try await operation(cancelledLedger, cancel: true); return false }
            catch is CancellationError { return Task.isCancelled }
            catch { return false }
        }
        let normal = await normalLedger.snapshot()
        let stillCancelled = await cancelled.value
        let clean = await cancelledLedger.snapshot()
        guard normal == [false], clean == [false], stillCancelled else { exit(1) }
        print("PASS cleanup: awaited teardown on success/cancellation; cancellation remains outside shield")
    }
}
