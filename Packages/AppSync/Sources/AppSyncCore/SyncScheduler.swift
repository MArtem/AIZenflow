import Foundation

/// Debounced sync trigger that coalesces repeated sync requests before invoking `SyncEngine`.
///
/// Concurrency:
/// Actor isolation owns the scheduled task and cancels stale debounce work when a newer request arrives.
public actor SyncScheduler {
    private let engine: SyncEngine
    private let debounceNanoseconds: UInt64
    private var scheduledTask: Task<Void, Never>?

    public init(engine: SyncEngine, debounceSeconds: Double = 2.0) {
        self.engine = engine
        self.debounceNanoseconds = UInt64(debounceSeconds * 1_000_000_000)
    }

        /// Requests a debounced sync run, replacing any pending debounce task.
    ///
    /// External usage:
    /// Call from local mutation/network-restored events where multiple rapid changes should coalesce.
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

        /// Starts an immediate sync run and cancels any pending debounced request.
public func syncNow(reason: SyncReason) {
        scheduledTask?.cancel()
        scheduledTask = Task { [engine] in
            await engine.sync(reason: reason)
        }
    }

        /// Cancels pending scheduled sync work without cancelling an already running engine sync.
public func cancelScheduledSync() {
        scheduledTask?.cancel()
        scheduledTask = nil
    }
}
