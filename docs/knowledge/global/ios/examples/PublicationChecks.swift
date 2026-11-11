// Append to the Swift block in SWIFT_CONCURRENCY_DEEP_REFERENCE.md's
// Illustrative Owner Example. This fixture verifies that model, not an app or SDK.
import Foundation

private enum ProbeError: Error { case injected; case failed(String) }
private func require(_ value: Bool, _ message: String) throws {
    if !value { throw ProbeError.failed(message) }
}
private actor ControlledProducer {
    nonisolated let starts: AsyncStream<Int>
    private let events: AsyncStream<Int>.Continuation
    private var pending: [Int: CheckedContinuation<String, any Error>] = [:]
    init() { (starts, events) = AsyncStream<Int>.makeStream() }
    func request(_ id: Int) async throws -> String {
        try await withCheckedThrowingContinuation { completion in
            pending[id] = completion
            events.yield(id)
        }
    }
    func complete(_ id: Int, fail: Bool = false) throws {
        guard let completion = pending.removeValue(forKey: id) else {
            throw ProbeError.failed("missing request")
        }
        if fail { completion.resume(throwing: ProbeError.injected) }
        else { completion.resume(returning: "value-\(id)") }
    }
}
@main private struct PublicationChecks {
    @MainActor static func main() async {
        do {
            try await lateCompletion(failure: false)
            try await lateCompletion(failure: true)
            try await cancelThenComplete()
            try await oldCleanupWhileNewPending()
            try await genuineFailure()
            try await rejectOverlap()
            print("PASS publication: 6 controlled scenarios")
        } catch {
            print("FAIL publication: \(error)")
            exit(1)
        }
    }
    @MainActor static func lateCompletion(failure: Bool) async throws {
        let producer = ControlledProducer(); var starts = producer.starts.makeAsyncIterator()
        let owner = PublicationOwner()
        let old = owner.start { try await producer.request(1) }
        try require(await starts.next() == 1, "old start")
        let middle = owner.start { try await producer.request(2) }
        try require(await starts.next() == 2, "middle start")
        // Same consumer intent as first A; the invocation itself is distinct.
        let current = owner.start { try await producer.request(3) }
        try require(await starts.next() == 3, "current start")
        try await producer.complete(3); await current.value
        try await producer.complete(2); await middle.value
        try await producer.complete(1, fail: failure); await old.value
        try require(owner.state == .loaded("value-3"), "obsolete publication")
    }
    @MainActor static func cancelThenComplete() async throws {
        let producer = ControlledProducer(); var starts = producer.starts.makeAsyncIterator()
        let owner = PublicationOwner(); let old = owner.start { try await producer.request(1) }
        try require(await starts.next() == 1, "cancel start")
        owner.cancel(); try await producer.complete(1); await old.value
        try require(owner.state == .cancelled, "late completion after cancel")
    }
    @MainActor static func oldCleanupWhileNewPending() async throws {
        let producer = ControlledProducer(); var starts = producer.starts.makeAsyncIterator()
        let owner = PublicationOwner(); let old = owner.start { try await producer.request(1) }
        try require(await starts.next() == 1, "cleanup old start")
        let current = owner.start { try await producer.request(2) }
        try require(await starts.next() == 2, "cleanup current start")
        try await producer.complete(1); await old.value
        let handleSurvived = owner.hasActiveOperation
        owner.cancel(); try await producer.complete(2); await current.value
        try require(handleSurvived, "old cleanup removed replacement handle")
        try require(owner.state == .cancelled, "replacement no longer cancellable")
    }
    @MainActor static func genuineFailure() async throws {
        let producer = ControlledProducer(); var starts = producer.starts.makeAsyncIterator()
        let owner = PublicationOwner(); let current = owner.start { try await producer.request(1) }
        try require(await starts.next() == 1, "failure start")
        try await producer.complete(1, fail: true); await current.value
        try require(owner.state == .failed, "genuine failure hidden")
    }
    @MainActor static func rejectOverlap() async throws {
        let producer = ControlledProducer(); var starts = producer.starts.makeAsyncIterator()
        let owner = PublicationOwner(); let current = owner.start { try await producer.request(1) }
        try require(await starts.next() == 1, "exclusive start")
        let rejected = owner.startIfIdle { throw ProbeError.failed("rejected work ran") }
        try await producer.complete(1); await current.value
        try require(rejected == nil, "overlap accepted")
        try require(owner.state == .loaded("value-1"), "exclusive result lost")
    }
}
