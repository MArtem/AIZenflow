import Foundation

public enum AppLifecyclePhase: String, Codable, Equatable, Sendable {
    case unknown
    case inactive
    case active
    case background
    case terminated

    public var isForeground: Bool {
        switch self {
        case .active, .inactive:
            return true
        case .unknown, .background, .terminated:
            return false
        }
    }
}

public enum AppLifecycleEventKind: String, Codable, Equatable, Sendable {
    case launchStarted
    case launchCompleted
    case willEnterForeground
    case didBecomeActive
    case willResignActive
    case didEnterBackground
    case willTerminate
    case memoryWarning
    case significantTimeChange
    case protectedDataBecameAvailable
    case protectedDataWillBecomeUnavailable
    case custom
}

public enum AppLifecycleAttributePrivacy: String, Codable, Equatable, Sendable {
    case `public`
    case `private`
    case sensitive
}

public enum AppLifecycleAttributeValue: Codable, Equatable, Sendable, CustomStringConvertible {
    case string(String)
    case integer(Int)
    case double(Double)
    case bool(Bool)
    case date(Date)

    public var description: String {
        switch self {
        case .string:
            return "<redacted-string>"
        case let .integer(value):
            return String(value)
        case let .double(value):
            return String(value)
        case let .bool(value):
            return String(value)
        case .date:
            return "<date>"
        }
    }
}

public struct AppLifecycleAttribute: Codable, Equatable, Sendable {
    public let value: AppLifecycleAttributeValue
    public let privacy: AppLifecycleAttributePrivacy

    public init(
        value: AppLifecycleAttributeValue,
        privacy: AppLifecycleAttributePrivacy = .public
    ) {
        self.value = value
        self.privacy = privacy
    }

    public static func publicString(_ value: String) -> AppLifecycleAttribute {
        AppLifecycleAttribute(value: .string(value), privacy: .public)
    }

    public static func privateString(_ value: String) -> AppLifecycleAttribute {
        AppLifecycleAttribute(value: .string(value), privacy: .private)
    }

    public static func sensitiveString(_ value: String) -> AppLifecycleAttribute {
        AppLifecycleAttribute(value: .string(value), privacy: .sensitive)
    }
}

public struct AppLifecycleEvent: Codable, Equatable, Sendable, Identifiable {
    public let id: UUID
    public let kind: AppLifecycleEventKind
    public let phase: AppLifecyclePhase
    public let occurredAt: Date
    public let attributes: [String: AppLifecycleAttribute]

    public init(
        id: UUID = UUID(),
        kind: AppLifecycleEventKind,
        phase: AppLifecyclePhase,
        occurredAt: Date,
        attributes: [String: AppLifecycleAttribute] = [:]
    ) {
        self.id = id
        self.kind = kind
        self.phase = phase
        self.occurredAt = occurredAt
        self.attributes = attributes
    }
}

public struct AppLifecycleBuildIdentity: Codable, Equatable, Sendable {
    public let version: String
    public let build: String?

    public init(version: String, build: String? = nil) {
        self.version = version
        self.build = build
    }
}

public enum AppLaunchClassification: Codable, Equatable, Sendable {
    case firstLaunch
    case sameBuildRelaunch
    case updated(previous: AppLifecycleBuildIdentity)
    case changed(previous: AppLifecycleBuildIdentity)
    case unknown
}

public struct AppLifecycleSnapshot: Codable, Equatable, Sendable {
    public let phase: AppLifecyclePhase
    public let launchID: UUID
    public let launchStartedAt: Date
    public let lastEvent: AppLifecycleEvent?
    public let launchClassification: AppLaunchClassification
    public let foregroundEntryCount: Int
    public let backgroundEntryCount: Int

    public init(
        phase: AppLifecyclePhase,
        launchID: UUID,
        launchStartedAt: Date,
        lastEvent: AppLifecycleEvent? = nil,
        launchClassification: AppLaunchClassification = .unknown,
        foregroundEntryCount: Int = 0,
        backgroundEntryCount: Int = 0
    ) {
        self.phase = phase
        self.launchID = launchID
        self.launchStartedAt = launchStartedAt
        self.lastEvent = lastEvent
        self.launchClassification = launchClassification
        self.foregroundEntryCount = foregroundEntryCount
        self.backgroundEntryCount = backgroundEntryCount
    }
}

public struct AppLifecycleDiagnostics: Codable, Equatable, Sendable {
    public let phase: AppLifecyclePhase
    public let launchClassification: AppLaunchClassification
    public let foregroundEntryCount: Int
    public let backgroundEntryCount: Int
    public let hasLastEvent: Bool

    public init(snapshot: AppLifecycleSnapshot) {
        phase = snapshot.phase
        launchClassification = snapshot.launchClassification
        foregroundEntryCount = snapshot.foregroundEntryCount
        backgroundEntryCount = snapshot.backgroundEntryCount
        hasLastEvent = snapshot.lastEvent != nil
    }
}

public struct AppLifecyclePersistedState: Codable, Equatable, Sendable {
    public let launchCount: Int
    public let lastKnownBuildIdentity: AppLifecycleBuildIdentity?
    public let lastLaunchAt: Date?
    public let lastForegroundAt: Date?
    public let lastBackgroundAt: Date?

    public init(
        launchCount: Int = 0,
        lastKnownBuildIdentity: AppLifecycleBuildIdentity? = nil,
        lastLaunchAt: Date? = nil,
        lastForegroundAt: Date? = nil,
        lastBackgroundAt: Date? = nil
    ) {
        self.launchCount = launchCount
        self.lastKnownBuildIdentity = lastKnownBuildIdentity
        self.lastLaunchAt = lastLaunchAt
        self.lastForegroundAt = lastForegroundAt
        self.lastBackgroundAt = lastBackgroundAt
    }
}

public protocol AppLifecycleStateStoring: Sendable {
    func loadState() async throws -> AppLifecyclePersistedState?
    func saveState(_ state: AppLifecyclePersistedState) async throws
    func removeState() async throws
}

public actor InMemoryAppLifecycleStateStore: AppLifecycleStateStoring {
    private var state: AppLifecyclePersistedState?

    public init(initialState: AppLifecyclePersistedState? = nil) {
        self.state = initialState
    }

    public func loadState() async throws -> AppLifecyclePersistedState? {
        state
    }

    public func saveState(_ state: AppLifecyclePersistedState) async throws {
        self.state = state
    }

    public func removeState() async throws {
        state = nil
    }
}

public protocol AppLifecycleClock: Sendable {
    func now() -> Date
}

public struct SystemAppLifecycleClock: AppLifecycleClock {
    public init() {}

    public func now() -> Date {
        Date()
    }
}

public struct StaticAppLifecycleClock: AppLifecycleClock {
    public let date: Date

    public init(date: Date) {
        self.date = date
    }

    public func now() -> Date {
        date
    }
}

public protocol AppLifecycleManaging: Sendable {
    func snapshot() async -> AppLifecycleSnapshot
    func diagnostics() async -> AppLifecycleDiagnostics
    func eventStream() async -> AsyncStream<AppLifecycleEvent>
    func startLaunch(buildIdentity: AppLifecycleBuildIdentity?) async throws -> AppLifecycleSnapshot
    func record(_ kind: AppLifecycleEventKind, attributes: [String: AppLifecycleAttribute]) async throws -> AppLifecycleSnapshot
    func setPhase(_ phase: AppLifecyclePhase, reason: AppLifecycleEventKind) async throws -> AppLifecycleSnapshot
    func resetPersistedState() async throws
}

public actor DefaultAppLifecycleManager: AppLifecycleManaging {
    private let stateStore: any AppLifecycleStateStoring
    private let clock: any AppLifecycleClock
    private var currentSnapshot: AppLifecycleSnapshot
    private var continuations: [UUID: AsyncStream<AppLifecycleEvent>.Continuation]

    public init(
        stateStore: any AppLifecycleStateStoring = InMemoryAppLifecycleStateStore(),
        clock: any AppLifecycleClock = SystemAppLifecycleClock(),
        initialPhase: AppLifecyclePhase = .unknown
    ) {
        self.stateStore = stateStore
        self.clock = clock
        currentSnapshot = AppLifecycleSnapshot(
            phase: initialPhase,
            launchID: UUID(),
            launchStartedAt: clock.now()
        )
        continuations = [:]
    }

    public func snapshot() async -> AppLifecycleSnapshot {
        currentSnapshot
    }

    public func diagnostics() async -> AppLifecycleDiagnostics {
        AppLifecycleDiagnostics(snapshot: currentSnapshot)
    }

    public func eventStream() async -> AsyncStream<AppLifecycleEvent> {
        let id = UUID()
        let pair = AsyncStream.makeStream(of: AppLifecycleEvent.self)
        continuations[id] = pair.continuation
        pair.continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id) }
        }
        return pair.stream
    }

    public func startLaunch(buildIdentity: AppLifecycleBuildIdentity? = nil) async throws -> AppLifecycleSnapshot {
        let persisted = try await stateStore.loadState()
        let now = clock.now()
        let classification = Self.classifyLaunch(
            current: buildIdentity,
            previous: persisted?.lastKnownBuildIdentity,
            previousLaunchCount: persisted?.launchCount ?? 0
        )

        let updatedPersistedState = AppLifecyclePersistedState(
            launchCount: (persisted?.launchCount ?? 0) + 1,
            lastKnownBuildIdentity: buildIdentity ?? persisted?.lastKnownBuildIdentity,
            lastLaunchAt: now,
            lastForegroundAt: persisted?.lastForegroundAt,
            lastBackgroundAt: persisted?.lastBackgroundAt
        )
        try await stateStore.saveState(updatedPersistedState)

        let event = AppLifecycleEvent(kind: .launchStarted, phase: currentSnapshot.phase, occurredAt: now)
        currentSnapshot = AppLifecycleSnapshot(
            phase: currentSnapshot.phase,
            launchID: currentSnapshot.launchID,
            launchStartedAt: now,
            lastEvent: event,
            launchClassification: classification,
            foregroundEntryCount: currentSnapshot.foregroundEntryCount,
            backgroundEntryCount: currentSnapshot.backgroundEntryCount
        )
        publish(event)
        return currentSnapshot
    }

    public func record(
        _ kind: AppLifecycleEventKind,
        attributes: [String: AppLifecycleAttribute] = [:]
    ) async throws -> AppLifecycleSnapshot {
        try await apply(kind: kind, phase: phase(for: kind, current: currentSnapshot.phase), attributes: attributes)
    }

    public func setPhase(
        _ phase: AppLifecyclePhase,
        reason: AppLifecycleEventKind = .custom
    ) async throws -> AppLifecycleSnapshot {
        try await apply(kind: reason, phase: phase, attributes: [:])
    }

    public func resetPersistedState() async throws {
        try await stateStore.removeState()
    }

    private func removeContinuation(_ id: UUID) {
        continuations.removeValue(forKey: id)
    }

    private func apply(
        kind: AppLifecycleEventKind,
        phase: AppLifecyclePhase,
        attributes: [String: AppLifecycleAttribute]
    ) async throws -> AppLifecycleSnapshot {
        let now = clock.now()
        let event = AppLifecycleEvent(
            kind: kind,
            phase: phase,
            occurredAt: now,
            attributes: AppLifecycleRedactor.redactedAttributes(attributes)
        )

        let foregroundCount = currentSnapshot.foregroundEntryCount + (phase == .active && currentSnapshot.phase != .active ? 1 : 0)
        let backgroundCount = currentSnapshot.backgroundEntryCount + (phase == .background && currentSnapshot.phase != .background ? 1 : 0)

        let persisted = try await stateStore.loadState()
        let updatedPersistedState = AppLifecyclePersistedState(
            launchCount: persisted?.launchCount ?? 0,
            lastKnownBuildIdentity: persisted?.lastKnownBuildIdentity,
            lastLaunchAt: persisted?.lastLaunchAt,
            lastForegroundAt: phase.isForeground ? now : persisted?.lastForegroundAt,
            lastBackgroundAt: phase == .background ? now : persisted?.lastBackgroundAt
        )
        try await stateStore.saveState(updatedPersistedState)

        currentSnapshot = AppLifecycleSnapshot(
            phase: phase,
            launchID: currentSnapshot.launchID,
            launchStartedAt: currentSnapshot.launchStartedAt,
            lastEvent: event,
            launchClassification: currentSnapshot.launchClassification,
            foregroundEntryCount: foregroundCount,
            backgroundEntryCount: backgroundCount
        )
        publish(event)
        return currentSnapshot
    }

    private func publish(_ event: AppLifecycleEvent) {
        for continuation in continuations.values {
            continuation.yield(event)
        }
    }

    private nonisolated static func classifyLaunch(
        current: AppLifecycleBuildIdentity?,
        previous: AppLifecycleBuildIdentity?,
        previousLaunchCount: Int
    ) -> AppLaunchClassification {
        guard previousLaunchCount > 0 else {
            return .firstLaunch
        }
        guard let current else {
            return .unknown
        }
        guard let previous else {
            return .unknown
        }
        if current == previous {
            return .sameBuildRelaunch
        }
        if current.version != previous.version || current.build != previous.build {
            return .updated(previous: previous)
        }
        return .changed(previous: previous)
    }

    private nonisolated func phase(for kind: AppLifecycleEventKind, current: AppLifecyclePhase) -> AppLifecyclePhase {
        switch kind {
        case .willEnterForeground:
            return .inactive
        case .didBecomeActive:
            return .active
        case .willResignActive:
            return .inactive
        case .didEnterBackground:
            return .background
        case .willTerminate:
            return .terminated
        case .launchStarted, .launchCompleted, .memoryWarning, .significantTimeChange, .protectedDataBecameAvailable, .protectedDataWillBecomeUnavailable, .custom:
            return current
        }
    }
}

public enum AppLifecycleRedactor {
    private static let sensitiveKeyFragments = [
        "token", "secret", "password", "credential", "authorization", "cookie", "email", "phone", "user", "account"
    ]

    public static func redactedAttributes(_ attributes: [String: AppLifecycleAttribute]) -> [String: AppLifecycleAttribute] {
        attributes.mapValues { attribute in
            switch attribute.privacy {
            case .public:
                return attribute
            case .private:
                return AppLifecycleAttribute(value: .string("<private>"), privacy: .private)
            case .sensitive:
                return AppLifecycleAttribute(value: .string("<sensitive>"), privacy: .sensitive)
            }
        }
        .mapKeys { key in
            key
        }
        .mapValuesWithKeys { key, attribute in
            let lowercased = key.lowercased()
            if sensitiveKeyFragments.contains(where: { lowercased.contains($0) }) {
                return AppLifecycleAttribute(value: .string("<sensitive>"), privacy: .sensitive)
            }
            return attribute
        }
    }
}

private extension Dictionary {
    func mapKeys<NewKey: Hashable>(_ transform: (Key) -> NewKey) -> [NewKey: Value] {
        Dictionary<NewKey, Value>(uniqueKeysWithValues: map { (transform($0.key), $0.value) })
    }

    func mapValuesWithKeys<NewValue>(_ transform: (Key, Value) -> NewValue) -> [Key: NewValue] {
        Dictionary<Key, NewValue>(uniqueKeysWithValues: map { ($0.key, transform($0.key, $0.value)) })
    }
}
