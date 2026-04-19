import Foundation

/// Stable authorization states used by the reusable APNs manager.
public enum PushNotificationAuthorizationStatus: String, Codable, Equatable, Sendable {
    case notDetermined
    case denied
    case authorized
    case provisional
    case ephemeral
}

/// Lifecycle source that produced the current push payload.
public enum PushNotificationEventSource: String, Codable, Equatable, Sendable {
    case foreground
    case opened
    case backgroundFetch
}

/// Normalized APNs device token stored by the manager.
public struct APNsDeviceToken: Codable, Equatable, Sendable {
    public let value: String

    /// Creates a new APNsDeviceToken instance.
    public init(value: String) {
        self.value = value
    }

    /// Creates a new APNsDeviceToken instance.
    public init(data: Data) {
        self.value = data.map { String(format: "%02x", $0) }.joined()
    }
}

/// Parsed payload shape used by the app layer before a real backend contract exists.
public struct PushNotificationPayload: Codable, Equatable, Sendable {
    public let source: PushNotificationEventSource
    public let title: String?
    public let body: String?
    public let badge: Int?
    public let sound: String?
    public let customData: [String: String]

    /// Creates a new PushNotificationPayload instance.
    public init(
        source: PushNotificationEventSource,
        title: String?,
        body: String?,
        badge: Int?,
        sound: String?,
        customData: [String: String]
    ) {
        self.source = source
        self.title = title
        self.body = body
        self.badge = badge
        self.sound = sound
        self.customData = customData
    }
}

/// Persisted manager snapshot covering authorization, token, and the latest payloads.
public struct PushNotificationState: Codable, Equatable, Sendable {
    public let authorizationStatus: PushNotificationAuthorizationStatus
    public let isRegisteredForRemoteNotifications: Bool
    public let deviceToken: APNsDeviceToken?
    public let lastRegistrationErrorDescription: String?
    public let lastReceivedPayload: PushNotificationPayload?
    public let lastOpenedPayload: PushNotificationPayload?

    /// Creates a new PushNotificationState instance.
    public init(
        authorizationStatus: PushNotificationAuthorizationStatus = .notDetermined,
        isRegisteredForRemoteNotifications: Bool = false,
        deviceToken: APNsDeviceToken? = nil,
        lastRegistrationErrorDescription: String? = nil,
        lastReceivedPayload: PushNotificationPayload? = nil,
        lastOpenedPayload: PushNotificationPayload? = nil
    ) {
        self.authorizationStatus = authorizationStatus
        self.isRegisteredForRemoteNotifications = isRegisteredForRemoteNotifications
        self.deviceToken = deviceToken
        self.lastRegistrationErrorDescription = lastRegistrationErrorDescription
        self.lastReceivedPayload = lastReceivedPayload
        self.lastOpenedPayload = lastOpenedPayload
    }
}

/// Store abstraction that keeps the reusable push state independent from the host app.
public protocol PushNotificationStateStoring: Sendable {
    /// Saves this operation.
    func save(_ state: PushNotificationState) throws
    /// Loads this operation.
    func load() throws -> PushNotificationState?
    /// Clears this operation.
    func clear() throws
}

/// Payload parser abstraction for host apps that may need a custom APNs contract later.
public protocol PushNotificationPayloadParsing: Sendable {
    /// Parses this operation.
    func parse(
        userInfo: [AnyHashable: Any],
        source: PushNotificationEventSource
    ) -> PushNotificationPayload
}

/// Public manager contract consumed by the app composition layer.
public protocol PushNotificationManaging: Sendable {
    /// Returns state.
    func currentState() async -> PushNotificationState
    /// Updates authorization status.
    func updateAuthorizationStatus(_ status: PushNotificationAuthorizationStatus) async throws -> PushNotificationState
    /// Updates remote registration.
    func updateRemoteRegistration(isRegistered: Bool) async throws -> PushNotificationState
    /// Handles device token.
    func handleDeviceToken(_ deviceToken: Data) async throws -> PushNotificationState
    /// Handles registration failure.
    func handleRegistrationFailure(_ errorDescription: String) async throws -> PushNotificationState
    /// Handles remote notification.
    func handleRemoteNotification(_ payload: PushNotificationPayload) async throws -> PushNotificationPayload
    /// Clears state.
    func clearState() async throws
}

/// Typed lifecycle events emitted by the reusable push manager.
public enum PushNotificationEvent: Sendable, Equatable {
    case authorizationStatusUpdated(PushNotificationAuthorizationStatus)
    case remoteRegistrationUpdated(isRegistered: Bool)
    case deviceTokenUpdated(String)
    case registrationFailed(reason: String)
    case remoteNotificationHandled(
        source: PushNotificationEventSource,
        route: String?,
        title: String?
    )
    case stateCleared
}

/// Sink contract for push lifecycle events.
public protocol PushNotificationEventCollecting: Sendable {
    /// Records a push event.
    func record(_ event: PushNotificationEvent) async
}

/// In-memory collector for push lifecycle events.
public actor PushNotificationMemoryEventCollector: PushNotificationEventCollecting {
    private var eventsStorage: [PushNotificationEvent] = []

    /// Creates an empty push event collector.
    public init() {}

    /// Recorded push events in insertion order.
    public var events: [PushNotificationEvent] {
        eventsStorage
    }

    /// Clears all recorded push events.
    public func reset() {
        eventsStorage.removeAll()
    }

    /// Records a push lifecycle event.
    public func record(_ event: PushNotificationEvent) async {
        eventsStorage.append(event)
    }
}

/// Default no-op collector used when push analytics is not wired.
public struct PushNotificationNoopEventCollector: PushNotificationEventCollecting {
    /// Creates a new no-op push event collector.
    public init() {}

    /// Ignores the incoming push event.
    public func record(_ event: PushNotificationEvent) async {}
}

/// Errors produced by the default state store.
public enum PushNotificationStateStoreError: Error {
    case unavailableUserDefaults(suiteName: String)
}

/// UserDefaults-backed push state storage used by the app by default.
public final class UserDefaultsPushNotificationStateStore: @unchecked Sendable, PushNotificationStateStoring {
    private let userDefaults: UserDefaults
    private let storageKey: String

    /// Creates a new UserDefaultsPushNotificationStateStore instance.
    public init(
        userDefaults: UserDefaults,
        storageKey: String = "push-notifications.state"
    ) {
        self.userDefaults = userDefaults
        self.storageKey = storageKey
    }

    /// Creates a new UserDefaultsPushNotificationStateStore instance.
    public convenience init(
        suiteName: String,
        storageKey: String = "push-notifications.state"
    ) throws {
        guard let userDefaults = UserDefaults(suiteName: suiteName) else {
            throw PushNotificationStateStoreError.unavailableUserDefaults(suiteName: suiteName)
        }

        self.init(userDefaults: userDefaults, storageKey: storageKey)
    }

    /// Saves this operation.
    public func save(_ state: PushNotificationState) throws {
        let data = try JSONEncoder().encode(state)
        userDefaults.set(data, forKey: storageKey)
    }

    /// Loads this operation.
    public func load() throws -> PushNotificationState? {
        guard let data = userDefaults.data(forKey: storageKey) else {
            return nil
        }

        return try JSONDecoder().decode(PushNotificationState.self, from: data)
    }

    /// Clears this operation.
    public func clear() throws {
        userDefaults.removeObject(forKey: storageKey)
    }
}

/// Default parser that normalizes APNs payloads into a reusable model.
public struct DefaultPushNotificationPayloadParser: PushNotificationPayloadParsing {
    /// Creates a new DefaultPushNotificationPayloadParser instance.
    public init() {}

    /// Parses this operation.
    public func parse(
        userInfo: [AnyHashable: Any],
        source: PushNotificationEventSource
    ) -> PushNotificationPayload {
        let aps = userInfo["aps"] as? [String: Any]
        let alert = aps?["alert"]

        let title: String?
        let body: String?

        if let alert = alert as? String {
            title = nil
            body = alert
        } else if let alert = alert as? [String: Any] {
            title = alert["title"] as? String
            body = alert["body"] as? String
        } else {
            title = nil
            body = nil
        }

        let badge = Self.intValue(from: aps?["badge"])
        let sound = Self.stringValue(from: aps?["sound"])

        var customData: [String: String] = [:]
        for (key, value) in userInfo {
            guard let key = key as? String, key != "aps" else {
                continue
            }

            if let stringValue = Self.stringValue(from: value) {
                customData[key] = stringValue
            }
        }

        return PushNotificationPayload(
            source: source,
            title: title,
            body: body,
            badge: badge,
            sound: sound,
            customData: customData
        )
    }

    private static func intValue(from value: Any?) -> Int? {
        if let intValue = value as? Int {
            return intValue
        }

        if let stringValue = value as? String {
            return Int(stringValue)
        }

        return nil
    }

    private static func stringValue(from value: Any?) -> String? {
        switch value {
        case let stringValue as String:
            return stringValue
        case let number as NSNumber:
            return number.stringValue
        case let dictionary as [String: Any]:
            guard
                let name = dictionary["name"] as? String,
                !name.isEmpty
            else {
                return nil
            }
            return name
        default:
            return nil
        }
    }
}

/// Reusable actor that stores push-registration state and the latest APNs payloads.
public actor PushNotificationManager: PushNotificationManaging {
    private let store: any PushNotificationStateStoring
    private let eventCollector: any PushNotificationEventCollecting
    private var state: PushNotificationState

    /// Creates a new PushNotificationManager instance.
    public init(
        store: any PushNotificationStateStoring,
        eventCollector: any PushNotificationEventCollecting = PushNotificationNoopEventCollector()
    ) {
        self.store = store
        self.eventCollector = eventCollector
        self.state = (try? store.load()) ?? PushNotificationState()
    }

    /// Returns state.
    public func currentState() async -> PushNotificationState {
        state
    }

    /// Updates authorization status.
    public func updateAuthorizationStatus(_ status: PushNotificationAuthorizationStatus) async throws -> PushNotificationState {
        state = PushNotificationState(
            authorizationStatus: status,
            isRegisteredForRemoteNotifications: state.isRegisteredForRemoteNotifications,
            deviceToken: state.deviceToken,
            lastRegistrationErrorDescription: state.lastRegistrationErrorDescription,
            lastReceivedPayload: state.lastReceivedPayload,
            lastOpenedPayload: state.lastOpenedPayload
        )
        try persistState()
        await eventCollector.record(.authorizationStatusUpdated(status))
        return state
    }

    /// Updates remote registration.
    public func updateRemoteRegistration(isRegistered: Bool) async throws -> PushNotificationState {
        state = PushNotificationState(
            authorizationStatus: state.authorizationStatus,
            isRegisteredForRemoteNotifications: isRegistered,
            deviceToken: state.deviceToken,
            lastRegistrationErrorDescription: state.lastRegistrationErrorDescription,
            lastReceivedPayload: state.lastReceivedPayload,
            lastOpenedPayload: state.lastOpenedPayload
        )
        try persistState()
        await eventCollector.record(.remoteRegistrationUpdated(isRegistered: isRegistered))
        return state
    }

    /// Handles device token.
    public func handleDeviceToken(_ deviceToken: Data) async throws -> PushNotificationState {
        let normalizedToken = APNsDeviceToken(data: deviceToken)
        state = PushNotificationState(
            authorizationStatus: state.authorizationStatus,
            isRegisteredForRemoteNotifications: true,
            deviceToken: normalizedToken,
            lastRegistrationErrorDescription: nil,
            lastReceivedPayload: state.lastReceivedPayload,
            lastOpenedPayload: state.lastOpenedPayload
        )
        try persistState()
        await eventCollector.record(.deviceTokenUpdated(normalizedToken.value))
        return state
    }

    /// Handles registration failure.
    public func handleRegistrationFailure(_ errorDescription: String) async throws -> PushNotificationState {
        state = PushNotificationState(
            authorizationStatus: state.authorizationStatus,
            isRegisteredForRemoteNotifications: false,
            deviceToken: state.deviceToken,
            lastRegistrationErrorDescription: errorDescription,
            lastReceivedPayload: state.lastReceivedPayload,
            lastOpenedPayload: state.lastOpenedPayload
        )
        try persistState()
        await eventCollector.record(.registrationFailed(reason: errorDescription))
        return state
    }

    /// Handles remote notification.
    public func handleRemoteNotification(_ payload: PushNotificationPayload) async throws -> PushNotificationPayload {
        state = PushNotificationState(
            authorizationStatus: state.authorizationStatus,
            isRegisteredForRemoteNotifications: state.isRegisteredForRemoteNotifications,
            deviceToken: state.deviceToken,
            lastRegistrationErrorDescription: state.lastRegistrationErrorDescription,
            lastReceivedPayload: payload.source == .opened ? state.lastReceivedPayload : payload,
            lastOpenedPayload: payload.source == .opened ? payload : state.lastOpenedPayload
        )
        try persistState()
        await eventCollector.record(
            .remoteNotificationHandled(
                source: payload.source,
                route: payload.customData["route"],
                title: payload.title
            )
        )
        return payload
    }

    /// Clears state.
    public func clearState() async throws {
        state = PushNotificationState()
        try store.clear()
        await eventCollector.record(.stateCleared)
    }

    /// Handles persist state.
    private func persistState() throws {
        try store.save(state)
    }
}
