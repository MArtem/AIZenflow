import Foundation

public enum AppTaskExecutionDecision: Equatable, Sendable, CustomStringConvertible {
    case succeeded
    case retry
    case failed

    public var description: String {
        switch self {
        case .succeeded:
            "AppTaskExecutionDecision.succeeded"
        case .retry:
            "AppTaskExecutionDecision.retry"
        case .failed:
            "AppTaskExecutionDecision.failed"
        }
    }
}

public struct AppTaskExecutionContext: Equatable, Sendable, CustomStringConvertible {
    public let attemptCount: Int
    public let maximumAttempts: Int
    public let payloadByteCount: Int

    public init(attemptCount: Int, maximumAttempts: Int, payloadByteCount: Int) {
        self.attemptCount = attemptCount
        self.maximumAttempts = maximumAttempts
        self.payloadByteCount = payloadByteCount
    }

    public var description: String {
        "AppTaskExecutionContext(attemptCount: \(attemptCount), maximumAttempts: \(maximumAttempts), payloadByteCount: \(payloadByteCount))"
    }
}

public protocol AppTaskExecutor: Sendable {
    func execute(_ task: AppQueuedTask, context: AppTaskExecutionContext) async -> AppTaskExecutionDecision
}

public enum AppTaskRunOutcome: Equatable, Sendable, CustomStringConvertible {
    case noTask
    case succeeded
    case scheduledRetry
    case failed

    public var description: String {
        switch self {
        case .noTask:
            "AppTaskRunOutcome.noTask"
        case .succeeded:
            "AppTaskRunOutcome.succeeded"
        case .scheduledRetry:
            "AppTaskRunOutcome.scheduledRetry"
        case .failed:
            "AppTaskRunOutcome.failed"
        }
    }
}

public struct AppTaskRunReport: Equatable, Sendable, CustomStringConvertible {
    public let outcome: AppTaskRunOutcome
    public let taskWasReserved: Bool

    public init(outcome: AppTaskRunOutcome, taskWasReserved: Bool) {
        self.outcome = outcome
        self.taskWasReserved = taskWasReserved
    }

    public var description: String {
        "AppTaskRunReport(outcome: \(outcome), taskWasReserved: \(taskWasReserved))"
    }
}

public actor AppTaskQueueRunner {
    private let queue: AppTaskQueueService
    private let executor: any AppTaskExecutor

    public init(queue: AppTaskQueueService, executor: any AppTaskExecutor) {
        self.queue = queue
        self.executor = executor
    }

    public func runOne() async throws -> AppTaskRunReport {
        guard let task = try await queue.reserveNext() else {
            return AppTaskRunReport(outcome: .noTask, taskWasReserved: false)
        }

        let context = AppTaskExecutionContext(
            attemptCount: task.attemptCount,
            maximumAttempts: task.retryPolicy.maximumAttempts,
            payloadByteCount: task.payload.byteCount
        )
        let decision = await executor.execute(task, context: context)

        switch decision {
        case .succeeded:
            _ = try await queue.complete(id: task.id)
            return AppTaskRunReport(outcome: .succeeded, taskWasReserved: true)
        case .retry:
            if task.retryPolicy.canRetry(afterAttemptCount: task.attemptCount) {
                _ = try await queue.retry(id: task.id)
                return AppTaskRunReport(outcome: .scheduledRetry, taskWasReserved: true)
            } else {
                _ = try await queue.fail(id: task.id)
                return AppTaskRunReport(outcome: .failed, taskWasReserved: true)
            }
        case .failed:
            _ = try await queue.fail(id: task.id)
            return AppTaskRunReport(outcome: .failed, taskWasReserved: true)
        }
    }
}
