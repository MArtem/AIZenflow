import Foundation

public enum AppQueuedTaskState: String, Codable, Equatable, Sendable {
    case queued
    case reserved
    case succeeded
    case failed
    case cancelled
}

public struct AppTaskEnqueueRequest: Sendable, CustomStringConvertible {
    public let id: AppTaskID
    public let kind: AppTaskKind
    public let payload: AppTaskPayload
    public let priority: AppTaskPriority
    public let schedule: AppTaskSchedule
    public let retryPolicy: AppTaskRetryPolicy

    public init(
        id: AppTaskID,
        kind: AppTaskKind,
        payload: AppTaskPayload,
        priority: AppTaskPriority = .normal,
        schedule: AppTaskSchedule = .immediate,
        retryPolicy: AppTaskRetryPolicy = .standard
    ) throws {
        self.id = id
        self.kind = kind
        self.payload = payload
        self.priority = priority
        self.schedule = schedule
        self.retryPolicy = try retryPolicy.validated()
    }

    public var description: String {
        "AppTaskEnqueueRequest(id: redacted, kind: redacted, payloadBytes: \(payload.byteCount), priority: \(priority.value))"
    }
}

public struct AppQueuedTask: Codable, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let id: AppTaskID
    public let kind: AppTaskKind
    public let payload: AppTaskPayload
    public let priority: AppTaskPriority
    public let schedule: AppTaskSchedule
    public let retryPolicy: AppTaskRetryPolicy
    public let createdAt: Date
    public let updatedAt: Date
    public let attemptCount: Int
    public let state: AppQueuedTaskState

    public init(
        id: AppTaskID,
        kind: AppTaskKind,
        payload: AppTaskPayload,
        priority: AppTaskPriority,
        schedule: AppTaskSchedule,
        retryPolicy: AppTaskRetryPolicy,
        createdAt: Date,
        updatedAt: Date,
        attemptCount: Int,
        state: AppQueuedTaskState
    ) throws {
        guard attemptCount >= 0 else {
            throw AppTaskQueueFailure.invalidSchedule
        }
        self.id = id
        self.kind = kind
        self.payload = payload
        self.priority = priority
        self.schedule = schedule
        self.retryPolicy = try retryPolicy.validated()
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.attemptCount = attemptCount
        self.state = state
    }

    public static func make(from request: AppTaskEnqueueRequest, createdAt: Date) throws -> AppQueuedTask {
        try AppQueuedTask(
            id: request.id,
            kind: request.kind,
            payload: request.payload,
            priority: request.priority,
            schedule: request.schedule,
            retryPolicy: request.retryPolicy,
            createdAt: createdAt,
            updatedAt: createdAt,
            attemptCount: 0,
            state: .queued
        )
    }

    public func reserving(at date: Date) throws -> AppQueuedTask {
        guard state == .queued, schedule.isDue(at: date) else {
            throw AppTaskQueueFailure.taskCannotBeReserved
        }
        return try AppQueuedTask(
            id: id,
            kind: kind,
            payload: payload,
            priority: priority,
            schedule: schedule,
            retryPolicy: retryPolicy,
            createdAt: createdAt,
            updatedAt: date,
            attemptCount: attemptCount + 1,
            state: .reserved
        )
    }

    public func succeeding(at date: Date) throws -> AppQueuedTask {
        guard state == .reserved else {
            throw AppTaskQueueFailure.taskCannotBeCompleted
        }
        return try with(state: .succeeded, schedule: schedule, updatedAt: date)
    }

    public func failing(at date: Date) throws -> AppQueuedTask {
        guard state == .reserved else {
            throw AppTaskQueueFailure.taskCannotBeCompleted
        }
        return try with(state: .failed, schedule: schedule, updatedAt: date)
    }

    public func cancelling(at date: Date) throws -> AppQueuedTask {
        guard state == .queued || state == .reserved else {
            throw AppTaskQueueFailure.taskCannotBeCompleted
        }
        return try with(state: .cancelled, schedule: schedule, updatedAt: date)
    }

    public func schedulingRetry(notBefore: Date, updatedAt date: Date) throws -> AppQueuedTask {
        guard state == .reserved, retryPolicy.canRetry(afterAttemptCount: attemptCount) else {
            throw AppTaskQueueFailure.taskCannotBeRetried
        }
        return try with(state: .queued, schedule: AppTaskSchedule(notBefore: notBefore), updatedAt: date)
    }

    private func with(state: AppQueuedTaskState, schedule: AppTaskSchedule, updatedAt date: Date) throws -> AppQueuedTask {
        try AppQueuedTask(
            id: id,
            kind: kind,
            payload: payload,
            priority: priority,
            schedule: schedule,
            retryPolicy: retryPolicy,
            createdAt: createdAt,
            updatedAt: date,
            attemptCount: attemptCount,
            state: state
        )
    }

    public var description: String {
        "AppQueuedTask(id: redacted, kind: redacted, state: \(state), attemptCount: \(attemptCount), payloadBytes: \(payload.byteCount))"
    }

    public var debugDescription: String { description }
}
