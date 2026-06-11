import Foundation

actor ConnectivityContinuationStore {
    private var continuations: [UUID: AsyncStream<ConnectivitySnapshot>.Continuation] = [:]

    func makeStream(currentSnapshot: ConnectivitySnapshot) -> AsyncStream<ConnectivitySnapshot> {
        let id = UUID()
        return AsyncStream(bufferingPolicy: .bufferingNewest(1)) { continuation in
            continuation.yield(currentSnapshot)
            continuations[id] = continuation
            continuation.onTermination = { [weak self] _ in
                Task { await self?.removeContinuation(id: id) }
            }
        }
    }

    func yield(_ snapshot: ConnectivitySnapshot) {
        for continuation in continuations.values {
            continuation.yield(snapshot)
        }
    }

    func finish() {
        for continuation in continuations.values {
            continuation.finish()
        }
        continuations.removeAll()
    }

    private func removeContinuation(id: UUID) {
        continuations[id] = nil
    }
}
