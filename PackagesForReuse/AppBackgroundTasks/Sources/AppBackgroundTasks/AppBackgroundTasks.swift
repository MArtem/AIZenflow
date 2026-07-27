import Foundation

#if canImport(BackgroundTasks) && !os(macOS) && !os(watchOS)
import BackgroundTasks
#endif

public struct BackgroundTaskIdentifier: RawRepresentable, Hashable, Codable, Sendable, CustomStringConvertible, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    public init(validating rawValue: String) throws {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw BackgroundTaskError.invalidIdentifier
        }
        self.rawValue = trimmed
    }

    public var description: String {
        "BackgroundTaskIdentifier(<redacted>)"
    }
}

public enum BackgroundTaskKind: Equatable, Hashable, Codable, Sendable {
    case appRefresh
    case processing
    case urlSession
    case custom(String)

    public var diagnosticCode: String {
        switch self {
        case .appRefresh:
            "app_refresh"
        case .processing:
            "processing"
        case .urlSession:
            "url_session"
        case .custom:
            "custom"
        }
    }
}

public enum BackgroundTaskPriority: String, Codable, Sendable, CaseIterable {
    case low
    case normal
    case high
}

public struct BackgroundTaskRequest: Equatable, Codable, Sendable {
    public let identifier: BackgroundTaskIdentifier
    public let kind: BackgroundTaskKind
    public let earliestBeginDate: Date?
    public let requiresNetworkConnectivity: Bool
    public let requiresExternalPower: Bool
    public let priority: BackgroundTaskPriority

    public init(
        identifier: BackgroundTaskIdentifier,
        kind: BackgroundTaskKind,
        earliestBeginDate: Date? = nil,
        requiresNetworkConnectivity: Bool = false,
        requiresExternalPower: Bool = false,
        priority: BackgroundTaskPriority = .normal
    ) {
        self.identifier = identifier
        self.kind = kind
        self.earliestBeginDate = earliestBeginDate
        self.requiresNetworkConnectivity = requiresNetworkConnectivity
        self.requiresExternalPower = requiresExternalPower
        self.priority = priority
    }
}

public struct BackgroundTaskRegistration: Equatable, Codable, Sendable {
    public let identifier: BackgroundTaskIdentifier
    public let kind: BackgroundTaskKind
    public let allowsManualExecution: Bool

    public init(
        identifier: BackgroundTaskIdentifier,
        kind: BackgroundTaskKind,
        allowsManualExecution: Bool = true
    ) {
        self.identifier = identifier
        self.kind = kind
        self.allowsManualExecution = allowsManualExecution
    }
}

public enum BackgroundTaskResult: Equatable, Codable, Sendable {
    case success
    case noData
    case failed(BackgroundTaskFailure)
    case cancelled
    case expired

    public var isSuccessfulForSystemScheduler: Bool {
        switch self {
        case .success, .noData:
            true
        case .failed, .cancelled, .expired:
            false
        }
    }

    public var diagnosticCode: String {
        switch self {
        case .success:
            "success"
        case .noData:
            "no_data"
        case .failed(let failure):
            failure.code.rawValue
        case .cancelled:
            "cancelled"
        case .expired:
            "expired"
        }
    }
}

public struct BackgroundTaskFailureCode: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let allowedCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789._-")
        let sanitizedScalars = trimmed.unicodeScalars.prefix(64).map { scalar in
            allowedCharacters.contains(scalar) ? Character(scalar) : "_"
        }
        let sanitized = String(sanitizedScalars)
            .trimmingCharacters(in: CharacterSet(charactersIn: "._-"))
        self.rawValue = sanitized.isEmpty ? "failed" : sanitized
    }

    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }
}

public struct BackgroundTaskFailure: Equatable, Codable, Sendable {
    public let code: BackgroundTaskFailureCode
    public let isRetryable: Bool

    public init(code: BackgroundTaskFailureCode = "failed", isRetryable: Bool = false) {
        self.code = code
        self.isRetryable = isRetryable
    }
}

public struct BackgroundTaskExecutionContext: Equatable, Sendable {
    public let identifier: BackgroundTaskIdentifier
    public let kind: BackgroundTaskKind
    public let request: BackgroundTaskRequest?
    public let startedAt: Date
    public let attempt: Int

    public init(
        identifier: BackgroundTaskIdentifier,
        kind: BackgroundTaskKind,
        request: BackgroundTaskRequest? = nil,
        startedAt: Date = Date(),
        attempt: Int = 1
    ) {
        self.identifier = identifier
        self.kind = kind
        self.request = request
        self.startedAt = startedAt
        self.attempt = max(1, attempt)
    }
}

public enum BackgroundTaskEventKind: String, Codable, Sendable, CaseIterable {
    case registered
    case unregistered
    case scheduled
    case cancelled
    case started
    case completed
    case rejected
}

public struct BackgroundTaskEvent: Equatable, Codable, Sendable {
    public let kind: BackgroundTaskEventKind
    public let identifier: BackgroundTaskIdentifier
    public let taskKind: BackgroundTaskKind
    public let result: BackgroundTaskResult?
    public let occurredAt: Date

    public init(
        kind: BackgroundTaskEventKind,
        identifier: BackgroundTaskIdentifier,
        taskKind: BackgroundTaskKind,
        result: BackgroundTaskResult? = nil,
        occurredAt: Date = Date()
    ) {
        self.kind = kind
        self.identifier = identifier
        self.taskKind = taskKind
        self.result = result
        self.occurredAt = occurredAt
    }
}

public struct BackgroundTaskDiagnosticSnapshot: Equatable, Codable, Sendable {
    public let registeredCount: Int
    public let pendingCount: Int
    public let eventCount: Int
    public let registeredKinds: [String]
    public let pendingKinds: [String]

    public init(
        registeredCount: Int,
        pendingCount: Int,
        eventCount: Int,
        registeredKinds: [String],
        pendingKinds: [String]
    ) {
        self.registeredCount = registeredCount
        self.pendingCount = pendingCount
        self.eventCount = eventCount
        self.registeredKinds = registeredKinds.sorted()
        self.pendingKinds = pendingKinds.sorted()
    }
}

public enum BackgroundTaskError: Error, Equatable, Sendable, CustomStringConvertible {
    case invalidIdentifier
    case alreadyRegistered
    case notRegistered
    case unsupportedTaskKind
    case nativeSubmissionUnavailable
    case schedulingRejected(BackgroundTaskFailureCode)
    case executionUnavailable

    public var description: String {
        switch self {
        case .invalidIdentifier:
            "invalid_identifier"
        case .alreadyRegistered:
            "already_registered"
        case .notRegistered:
            "not_registered"
        case .unsupportedTaskKind:
            "unsupported_task_kind"
        case .nativeSubmissionUnavailable:
            "native_submission_unavailable"
        case .schedulingRejected(let code):
            "scheduling_rejected(\(code.rawValue))"
        case .executionUnavailable:
            "execution_unavailable"
        }
    }
}

public protocol BackgroundTaskClock: Sendable {
    func now() -> Date
}

public struct SystemBackgroundTaskClock: BackgroundTaskClock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}

public struct StaticBackgroundTaskClock: BackgroundTaskClock {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }

    public func now() -> Date {
        date
    }
}

public protocol BackgroundTaskHandling: Sendable {
    func handleBackgroundTask(_ context: BackgroundTaskExecutionContext) async -> BackgroundTaskResult
}

public struct AnyBackgroundTaskHandler: BackgroundTaskHandling {
    private let operation: @Sendable (BackgroundTaskExecutionContext) async -> BackgroundTaskResult

    public init(_ operation: @escaping @Sendable (BackgroundTaskExecutionContext) async -> BackgroundTaskResult) {
        self.operation = operation
    }

    public func handleBackgroundTask(_ context: BackgroundTaskExecutionContext) async -> BackgroundTaskResult {
        await operation(context)
    }
}

public protocol BackgroundTaskScheduling: Sendable {
    func register(_ registration: BackgroundTaskRegistration) async throws
    func unregister(identifier: BackgroundTaskIdentifier) async
    func schedule(_ request: BackgroundTaskRequest) async throws
    func cancel(identifier: BackgroundTaskIdentifier) async
    func cancelAll() async
    func pendingRequests() async -> [BackgroundTaskRequest]
    func registrations() async -> [BackgroundTaskRegistration]
    func events() async -> [BackgroundTaskEvent]
    func diagnostics() async -> BackgroundTaskDiagnosticSnapshot
}

public actor ManualBackgroundTaskScheduler: BackgroundTaskScheduling {
    private var registrationByIdentifier: [BackgroundTaskIdentifier: BackgroundTaskRegistration]
    private var requestByIdentifier: [BackgroundTaskIdentifier: BackgroundTaskRequest]
    private var eventLog: [BackgroundTaskEvent]
    private let clock: any BackgroundTaskClock

    public init(clock: any BackgroundTaskClock = SystemBackgroundTaskClock()) {
        self.registrationByIdentifier = [:]
        self.requestByIdentifier = [:]
        self.eventLog = []
        self.clock = clock
    }

    public func register(_ registration: BackgroundTaskRegistration) async throws {
        guard registrationByIdentifier[registration.identifier] == nil else {
            throw BackgroundTaskError.alreadyRegistered
        }
        registrationByIdentifier[registration.identifier] = registration
        eventLog.append(
            BackgroundTaskEvent(
                kind: .registered,
                identifier: registration.identifier,
                taskKind: registration.kind,
                occurredAt: clock.now()
            )
        )
    }

    public func unregister(identifier: BackgroundTaskIdentifier) async {
        guard let registration = registrationByIdentifier.removeValue(forKey: identifier) else {
            return
        }
        requestByIdentifier.removeValue(forKey: identifier)
        eventLog.append(
            BackgroundTaskEvent(
                kind: .unregistered,
                identifier: identifier,
                taskKind: registration.kind,
                occurredAt: clock.now()
            )
        )
    }

    public func schedule(_ request: BackgroundTaskRequest) async throws {
        guard let registration = registrationByIdentifier[request.identifier] else {
            eventLog.append(
                BackgroundTaskEvent(
                    kind: .rejected,
                    identifier: request.identifier,
                    taskKind: request.kind,
                    result: .failed(BackgroundTaskFailure(code: "not_registered", isRetryable: false)),
                    occurredAt: clock.now()
                )
            )
            throw BackgroundTaskError.notRegistered
        }
        guard registration.kind == request.kind else {
            eventLog.append(
                BackgroundTaskEvent(
                    kind: .rejected,
                    identifier: request.identifier,
                    taskKind: request.kind,
                    result: .failed(BackgroundTaskFailure(code: "kind_mismatch", isRetryable: false)),
                    occurredAt: clock.now()
                )
            )
            throw BackgroundTaskError.schedulingRejected("kind_mismatch")
        }
        requestByIdentifier[request.identifier] = request
        eventLog.append(
            BackgroundTaskEvent(
                kind: .scheduled,
                identifier: request.identifier,
                taskKind: request.kind,
                occurredAt: clock.now()
            )
        )
    }

    public func cancel(identifier: BackgroundTaskIdentifier) async {
        guard let request = requestByIdentifier.removeValue(forKey: identifier) else {
            return
        }
        eventLog.append(
            BackgroundTaskEvent(
                kind: .cancelled,
                identifier: identifier,
                taskKind: request.kind,
                result: .cancelled,
                occurredAt: clock.now()
            )
        )
    }

    public func cancelAll() async {
        let requests = Array(requestByIdentifier.values)
        requestByIdentifier.removeAll()
        for request in requests {
            eventLog.append(
                BackgroundTaskEvent(
                    kind: .cancelled,
                    identifier: request.identifier,
                    taskKind: request.kind,
                    result: .cancelled,
                    occurredAt: clock.now()
                )
            )
        }
    }

    public func pendingRequests() async -> [BackgroundTaskRequest] {
        requestByIdentifier.values.sorted { $0.identifier.rawValue < $1.identifier.rawValue }
    }

    public func registrations() async -> [BackgroundTaskRegistration] {
        registrationByIdentifier.values.sorted { $0.identifier.rawValue < $1.identifier.rawValue }
    }

    public func events() async -> [BackgroundTaskEvent] {
        eventLog
    }

    public func diagnostics() async -> BackgroundTaskDiagnosticSnapshot {
        BackgroundTaskDiagnosticSnapshot(
            registeredCount: registrationByIdentifier.count,
            pendingCount: requestByIdentifier.count,
            eventCount: eventLog.count,
            registeredKinds: registrationByIdentifier.values.map { $0.kind.diagnosticCode },
            pendingKinds: requestByIdentifier.values.map { $0.kind.diagnosticCode }
        )
    }

    public func removePendingRequest(identifier: BackgroundTaskIdentifier) async -> BackgroundTaskRequest? {
        requestByIdentifier.removeValue(forKey: identifier)
    }

    public func recordStart(identifier: BackgroundTaskIdentifier, kind: BackgroundTaskKind) async {
        eventLog.append(
            BackgroundTaskEvent(kind: .started, identifier: identifier, taskKind: kind, occurredAt: clock.now())
        )
    }

    public func recordCompletion(identifier: BackgroundTaskIdentifier, kind: BackgroundTaskKind, result: BackgroundTaskResult) async {
        eventLog.append(
            BackgroundTaskEvent(kind: .completed, identifier: identifier, taskKind: kind, result: result, occurredAt: clock.now())
        )
    }
}

public actor DefaultBackgroundTaskManager {
    private let scheduler: ManualBackgroundTaskScheduler
    private let clock: any BackgroundTaskClock
    private var handlers: [BackgroundTaskIdentifier: AnyBackgroundTaskHandler]
    private var attempts: [BackgroundTaskIdentifier: Int]

    public init(
        scheduler: ManualBackgroundTaskScheduler = ManualBackgroundTaskScheduler(),
        clock: any BackgroundTaskClock = SystemBackgroundTaskClock()
    ) {
        self.scheduler = scheduler
        self.clock = clock
        self.handlers = [:]
        self.attempts = [:]
    }

    public func register(
        _ registration: BackgroundTaskRegistration,
        handler: AnyBackgroundTaskHandler
    ) async throws {
        try await scheduler.register(registration)
        handlers[registration.identifier] = handler
    }

    public func unregister(identifier: BackgroundTaskIdentifier) async {
        handlers.removeValue(forKey: identifier)
        attempts.removeValue(forKey: identifier)
        await scheduler.unregister(identifier: identifier)
    }

    public func schedule(_ request: BackgroundTaskRequest) async throws {
        try await scheduler.schedule(request)
    }

    public func cancel(identifier: BackgroundTaskIdentifier) async {
        await scheduler.cancel(identifier: identifier)
    }

    public func pendingRequests() async -> [BackgroundTaskRequest] {
        await scheduler.pendingRequests()
    }

    public func runPending(identifier: BackgroundTaskIdentifier) async throws -> BackgroundTaskResult {
        guard let handler = handlers[identifier] else {
            throw BackgroundTaskError.executionUnavailable
        }
        guard let request = await scheduler.removePendingRequest(identifier: identifier) else {
            throw BackgroundTaskError.executionUnavailable
        }
        let nextAttempt = (attempts[identifier] ?? 0) + 1
        attempts[identifier] = nextAttempt
        await scheduler.recordStart(identifier: identifier, kind: request.kind)
        let context = BackgroundTaskExecutionContext(
            identifier: identifier,
            kind: request.kind,
            request: request,
            startedAt: clock.now(),
            attempt: nextAttempt
        )
        let result = await handler.handleBackgroundTask(context)
        await scheduler.recordCompletion(identifier: identifier, kind: request.kind, result: result)
        return result
    }

    public func events() async -> [BackgroundTaskEvent] {
        await scheduler.events()
    }

    public func diagnostics() async -> BackgroundTaskDiagnosticSnapshot {
        await scheduler.diagnostics()
    }
}

#if canImport(BackgroundTasks) && !os(macOS) && !os(watchOS)
@available(iOS 13.0, tvOS 13.0, *)
public enum BGTaskRequestFactory {
    public static func makeRequest(from request: BackgroundTaskRequest) throws -> BGTaskRequest {
        switch request.kind {
        case .appRefresh:
            let nativeRequest = BGAppRefreshTaskRequest(identifier: request.identifier.rawValue)
            nativeRequest.earliestBeginDate = request.earliestBeginDate
            return nativeRequest
        case .processing:
            let nativeRequest = BGProcessingTaskRequest(identifier: request.identifier.rawValue)
            nativeRequest.earliestBeginDate = request.earliestBeginDate
            nativeRequest.requiresNetworkConnectivity = request.requiresNetworkConnectivity
            nativeRequest.requiresExternalPower = request.requiresExternalPower
            return nativeRequest
        case .urlSession, .custom:
            throw BackgroundTaskError.unsupportedTaskKind
        }
    }
}
#endif
