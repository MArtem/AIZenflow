import Foundation

public protocol AppTaskQueueStore: Sendable {
    func insert(_ task: AppQueuedTask) async throws
    func update(_ task: AppQueuedTask) async throws
    func load(id: AppTaskID) async throws -> AppQueuedTask?
    func remove(id: AppTaskID) async throws
    func snapshot() async throws -> [AppQueuedTask]
}

public actor InMemoryAppTaskQueueStore: AppTaskQueueStore {
    private var tasks: [AppTaskID: AppQueuedTask]

    public init(tasks: [AppQueuedTask] = []) throws {
        var indexed: [AppTaskID: AppQueuedTask] = [:]
        for task in tasks {
            guard indexed[task.id] == nil else {
                throw AppTaskQueueFailure.duplicateTask
            }
            indexed[task.id] = task
        }
        self.tasks = indexed
    }

    public func insert(_ task: AppQueuedTask) async throws {
        guard tasks[task.id] == nil else {
            throw AppTaskQueueFailure.duplicateTask
        }
        tasks[task.id] = task
    }

    public func update(_ task: AppQueuedTask) async throws {
        guard tasks[task.id] != nil else {
            throw AppTaskQueueFailure.missingTask
        }
        tasks[task.id] = task
    }

    public func load(id: AppTaskID) async throws -> AppQueuedTask? {
        tasks[id]
    }

    public func remove(id: AppTaskID) async throws {
        guard tasks.removeValue(forKey: id) != nil else {
            throw AppTaskQueueFailure.missingTask
        }
    }

    public func snapshot() async throws -> [AppQueuedTask] {
        Array(tasks.values)
    }
}
