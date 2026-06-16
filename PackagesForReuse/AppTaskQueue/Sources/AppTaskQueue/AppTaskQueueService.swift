import Foundation

public struct AppTaskQueueSnapshot: Sendable, Equatable, CustomStringConvertible {
    public let queuedCount: Int
    public let reservedCount: Int
    public let succeededCount: Int
    public let failedCount: Int
    public let cancelledCount: Int

    public init(tasks: [AppQueuedTask]) {
        self.queuedCount = tasks.filter { $0.state == .queued }.count
        self.reservedCount = tasks.filter { $0.state == .reserved }.count
        self.succeededCount = tasks.filter { $0.state == .succeeded }.count
        self.failedCount = tasks.filter { $0.state == .failed }.count
        self.cancelledCount = tasks.filter { $0.state == .cancelled }.count
    }

    public var description: String {
        "AppTaskQueueSnapshot(queued: \(queuedCount), reserved: \(reservedCount), succeeded: \(succeededCount), failed: \(failedCount), cancelled: \(cancelledCount))"
    }
}

public actor AppTaskQueueService {
    private let store: any AppTaskQueueStore
    private let clock: any AppTaskQueueClock

    public init(
        store: any AppTaskQueueStore,
        clock: any AppTaskQueueClock = SystemAppTaskQueueClock()
    ) {
        self.store = store
        self.clock = clock
    }

    public func enqueue(_ request: AppTaskEnqueueRequest) async throws -> AppQueuedTask {
        let date = clock.now()
        let task = try AppQueuedTask.make(from: request, createdAt: date)
        try await store.insert(task)
        return task
    }

    public func reserveNext() async throws -> AppQueuedTask? {
        let date = clock.now()
        let tasks = try await store.snapshot()
        guard let candidate = Self.nextReservableTask(from: tasks, at: date) else {
            return nil
        }
        let reserved = try candidate.reserving(at: date)
        try await store.update(reserved)
        return reserved
    }

    public func complete(id: AppTaskID) async throws -> AppQueuedTask {
        let date = clock.now()
        let task = try await requiredTask(id: id)
        let completed = try task.succeeding(at: date)
        try await store.update(completed)
        return completed
    }

    public func fail(id: AppTaskID) async throws -> AppQueuedTask {
        let date = clock.now()
        let task = try await requiredTask(id: id)
        let failed = try task.failing(at: date)
        try await store.update(failed)
        return failed
    }

    public func retry(id: AppTaskID) async throws -> AppQueuedTask {
        let date = clock.now()
        let task = try await requiredTask(id: id)
        let delay = task.retryPolicy.delay(afterAttemptCount: task.attemptCount)
        let retryDate = date.addingTimeInterval(delay)
        let retried = try task.schedulingRetry(notBefore: retryDate, updatedAt: date)
        try await store.update(retried)
        return retried
    }

    public func cancel(id: AppTaskID) async throws -> AppQueuedTask {
        let date = clock.now()
        let task = try await requiredTask(id: id)
        let cancelled = try task.cancelling(at: date)
        try await store.update(cancelled)
        return cancelled
    }

    public func remove(id: AppTaskID) async throws {
        try await store.remove(id: id)
    }

    public func task(id: AppTaskID) async throws -> AppQueuedTask? {
        try await store.load(id: id)
    }

    public func tasks() async throws -> [AppQueuedTask] {
        try await store.snapshot().sorted { lhs, rhs in
            if lhs.createdAt == rhs.createdAt {
                return lhs.priority > rhs.priority
            }
            return lhs.createdAt < rhs.createdAt
        }
    }

    public func snapshot() async throws -> AppTaskQueueSnapshot {
        let currentTasks = try await store.snapshot()
        return AppTaskQueueSnapshot(tasks: currentTasks)
    }

    private func requiredTask(id: AppTaskID) async throws -> AppQueuedTask {
        guard let task = try await store.load(id: id) else {
            throw AppTaskQueueFailure.missingTask
        }
        return task
    }

    private static func nextReservableTask(from tasks: [AppQueuedTask], at date: Date) -> AppQueuedTask? {
        tasks
            .filter { $0.state == .queued && $0.schedule.isDue(at: date) }
            .sorted { lhs, rhs in
                if lhs.priority == rhs.priority {
                    return lhs.createdAt < rhs.createdAt
                }
                return lhs.priority > rhs.priority
            }
            .first
    }
}
