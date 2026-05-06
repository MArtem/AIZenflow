import Foundation

public actor SyncScheduler {
    private let engine: SyncEngine
    private let debounceNanoseconds: UInt64
    private var scheduledTask: Task<Void, Never>?

    public init(engine: SyncEngine, debounceSeconds: Double = 2.0) {
        self.engine = engine
        self.debounceNanoseconds = UInt64(debounceSeconds * 1_000_000_000)
    }

    public func requestSync(reason: SyncReason) {
        scheduledTask?.cancel()

        scheduledTask = Task { [engine, debounceNanoseconds] in
            do {
                try await Task.sleep(nanoseconds: debounceNanoseconds)
                await engine.sync(reason: reason)
            } catch {
                // Cancelled debounce is expected when a newer sync request arrives.
            }
        }
    }

    public func syncNow(reason: SyncReason) {
        scheduledTask?.cancel()
        scheduledTask = Task { [engine] in
            await engine.sync(reason: reason)
        }
    }

    public func cancelScheduledSync() {
        scheduledTask?.cancel()
        scheduledTask = nil
    }
}
