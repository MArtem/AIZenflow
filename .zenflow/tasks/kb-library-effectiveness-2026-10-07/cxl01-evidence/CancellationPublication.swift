import Foundation

enum ProbeError: Error, Sendable { case genuineFailure }
enum ScreenState: Equatable { case idle, loading, loaded(String), failed, cancelled }

actor DurableLedger {
    private(set) var commits = 0
    func commit() { commits += 1 }
}

// Intentionally ignores task cancellation. Completion order is owned by the harness.
actor ControlledProducer {
    private var pending: [String: CheckedContinuation<String, any Error>] = [:]
    private var ready: [String: CheckedContinuation<Void, Never>] = [:]
    func value(_ key: String, ledger: DurableLedger? = nil) async throws -> String {
        if let ledger { await ledger.commit() }
        return try await withCheckedThrowingContinuation { continuation in
            precondition(pending[key] == nil)
            pending[key] = continuation
            ready.removeValue(forKey: key)?.resume()
        }
    }
    func waitUntilReady(_ key: String) async {
        if pending[key] != nil { return }
        await withCheckedContinuation { continuation in
            precondition(ready[key] == nil)
            ready[key] = continuation
        }
    }
    func complete(_ key: String, _ result: Result<String, ProbeError>) {
        guard let continuation = pending.removeValue(forKey: key) else { preconditionFailure("No pending request") }
        switch result {
        case .success(let value): continuation.resume(returning: value)
        case .failure(let error): continuation.resume(throwing: error)
        }
    }
}

// CXL01_EXAMPLE_BEGIN
@MainActor
final class PublicationOwner {
    // Identity denotes one invocation, not its query text. No wrapping counter.
    private final class Operation {}
    private var current: Operation?
    private var task: Task<Void, Never>?
    private(set) var state: ScreenState = .idle
    var hasActiveOperation: Bool { current != nil && task != nil }

    @discardableResult
    func start(_ work: @escaping @Sendable () async throws -> String) -> Task<Void, Never> {
        task?.cancel()
        let operation = Operation()
        current = operation
        state = .loading
        let handle = Task { @MainActor in
            defer {
                // Old completion must never remove a replacement's task handle.
                if current === operation { current = nil; task = nil }
            }
            do {
                let value = try await work()
                guard current === operation, !Task.isCancelled else { return }
                state = .loaded(value)
            } catch is CancellationError {
                guard current === operation else { return }
                state = .cancelled
            } catch {
                guard current === operation, !Task.isCancelled else { return }
                state = .failed
            }
        }
        task = handle
        return handle
    }

    func cancel() {
        // Contract of this example: explicit cancellation publishes .cancelled.
        current = nil
        task?.cancel()
        task = nil
        state = .cancelled
    }

    func startIfIdle(_ work: @escaping @Sendable () async throws -> String) -> Task<Void, Never>? {
        guard current == nil else { return nil }
        return start(work)
    }
}
// CXL01_EXAMPLE_END

@main
struct Checks {
    @MainActor
    static func main() async {
        var failures = 0
        func check(_ number: Int, _ label: String, _ passed: Bool) {
            print("\(passed ? "PASS" : "FAIL") \(number): \(label)")
            if !passed { failures += 1 }
        }
        // 1: cancellation-ignoring old success after replacement success.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A") }; await p.waitUntilReady("A")
            let b = owner.start { try await p.value("B") }; await p.waitUntilReady("B")
            await p.complete("B", .success("B")); await b.value
            await p.complete("A", .success("A")); await a.value
            check(1, "stale success rejected", owner.state == .loaded("B"))
        }
        // 2: cancellation can surface as a generic failure, not CancellationError.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A") }; await p.waitUntilReady("A")
            let b = owner.start { try await p.value("B") }; await p.waitUntilReady("B")
            await p.complete("B", .success("B")); await b.value
            await p.complete("A", .failure(.genuineFailure)); await a.value
            check(2, "stale generic error rejected", owner.state == .loaded("B"))
        }
        // 3: cancelling the owner invalidates publication even if producer returns.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A") }; await p.waitUntilReady("A")
            owner.cancel(); await p.complete("A", .success("late")); await a.value
            check(3, "explicit cancellation remains terminal", owner.state == .cancelled && !owner.hasActiveOperation)
        }
        // 4: equal query values do not identify equal invocations.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a1 = owner.start { try await p.value("A-first") }; await p.waitUntilReady("A-first")
            let b = owner.start { try await p.value("B") }; await p.waitUntilReady("B")
            let a2 = owner.start { try await p.value("A-second") }; await p.waitUntilReady("A-second")
            await p.complete("A-second", .success("A-new")); await a2.value
            await p.complete("B", .success("B")); await b.value
            await p.complete("A-first", .success("A-old")); await a1.value
            check(4, "A-B-A invocation identity", owner.state == .loaded("A-new"))
        }
        // 5: current real errors must remain observable.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A") }; await p.waitUntilReady("A")
            await p.complete("A", .failure(.genuineFailure)); await a.value
            check(5, "current genuine error visible", owner.state == .failed && !owner.hasActiveOperation)
        }
        // 6: a rejection policy can exclude replacement; do not invent a stale-write finding.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.startIfIdle { try await p.value("A") }!; await p.waitUntilReady("A")
            let rejected = owner.startIfIdle { "should never run" }
            await p.complete("A", .success("A")); await a.value
            check(6, "overlap rejected by serialized intake", rejected == nil && owner.state == .loaded("A"))
        }
        // 7: invalidating presentation does not roll back a durable write.
        do {
            let p = ControlledProducer(); let ledger = DurableLedger(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A", ledger: ledger) }; await p.waitUntilReady("A")
            owner.cancel(); await p.complete("A", .success("committed")); await a.value
            let commits = await ledger.commits
            check(7, "committed side effect survives cancellation", commits == 1 && owner.state == .cancelled)
        }
        // 8: old defer must leave the replacement handle available for cancellation.
        do {
            let p = ControlledProducer(); let owner = PublicationOwner()
            let a = owner.start { try await p.value("A") }; await p.waitUntilReady("A")
            let b = owner.start { try await p.value("B") }; await p.waitUntilReady("B")
            await p.complete("A", .success("A")); await a.value
            let replacementRetained = owner.hasActiveOperation && owner.state == .loading
            owner.cancel(); await p.complete("B", .success("B")); await b.value
            check(8, "old cleanup preserves replacement handle", replacementRetained && owner.state == .cancelled)
        }
        if failures != 0 { fatalError("\(failures) contract checks failed") }
        print("CXL-01: 8/8 PASS; controlled local model only")
    }
}
