import Foundation
import TchopNavigation
import TchopNetworking
import TchopPushNotifications

/// Stable top-level domains used by the shared analytics layer.
public enum ProductAnalyticsDomain: String, Codable, Equatable, Sendable {
    case navigation
    case networking
    case pushNotifications
}

/// Product-level analytics event shared across infrastructure modules.
public struct ProductAnalyticsEvent: Codable, Equatable, Sendable {
    public let domain: ProductAnalyticsDomain
    public let name: String
    public let attributes: [String: String]
    public let recordedAt: Date

    /// Creates a new product analytics event.
    public init(
        domain: ProductAnalyticsDomain,
        name: String,
        attributes: [String: String],
        recordedAt: Date = Date()
    ) {
        self.domain = domain
        self.name = name
        self.attributes = attributes
        self.recordedAt = recordedAt
    }
}

/// Sink contract used by analytics adapters across infrastructure modules.
public protocol ProductAnalyticsCollecting: Sendable {
    /// Records a product analytics event.
    func record(_ event: ProductAnalyticsEvent) async
}

/// In-memory collector useful for tests, debug overlays, and local inspection.
public actor ProductAnalyticsMemoryCollector: ProductAnalyticsCollecting {
    private var eventsStorage: [ProductAnalyticsEvent] = []

    /// Creates an empty analytics collector.
    public init() {}

    /// Recorded events in insertion order.
    public var events: [ProductAnalyticsEvent] {
        eventsStorage
    }

    /// Clears all recorded analytics events.
    public func reset() {
        eventsStorage.removeAll()
    }

    /// Records a product analytics event.
    public func record(_ event: ProductAnalyticsEvent) async {
        eventsStorage.append(event)
    }
}

/// Default no-op collector used when analytics is intentionally disabled.
public struct ProductAnalyticsNoopCollector: ProductAnalyticsCollecting {
    /// Creates a new no-op analytics collector.
    public init() {}

    /// Ignores the incoming analytics event.
    public func record(_ event: ProductAnalyticsEvent) async {}
}

/// Maps navigation diagnostics into shared product analytics events.
@MainActor
public enum NavigationAnalyticsEventMapper {
    /// Maps a navigation event into the shared analytics format.
    public static func map(_ event: NavigationEvent) -> ProductAnalyticsEvent {
        switch event {
        case let .deepLinkHandled(url, destination, policy):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "deep_link_handled",
                attributes: [
                    "url": url,
                    "destination": destination,
                    "policy": policy.rawValue
                ]
            )
        case let .deepLinkRejected(url, reason):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "deep_link_rejected",
                attributes: [
                    "url": url,
                    "reason": reason
                ]
            )
        case let .deepLinkFallback(url, reason):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "deep_link_fallback",
                attributes: [
                    "url": url,
                    "reason": reason
                ]
            )
        case let .snapshotRestoreStarted(userID, sourceVersion):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_started",
                attributes: [
                    "user_id": userID,
                    "source_version": String(sourceVersion)
                ]
            )
        case let .snapshotRestoreCompleted(userID, appliedVersion, wasSanitized, wasMigrated):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_completed",
                attributes: [
                    "user_id": userID,
                    "applied_version": String(appliedVersion),
                    "was_sanitized": String(wasSanitized),
                    "was_migrated": String(wasMigrated)
                ]
            )
        case let .snapshotRestoreSkipped(userID, reason):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_skipped",
                attributes: [
                    "user_id": userID,
                    "reason": reason
                ]
            )
        case let .snapshotRestoreFailed(userID, reason):
            return ProductAnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_failed",
                attributes: [
                    "user_id": userID,
                    "reason": reason
                ]
            )
        }
    }
}

/// Navigation reporter that forwards diagnostics into the shared analytics collector.
@MainActor
public final class NavigationAnalyticsEventReporter: NavigationEventReporting {
    private let collector: any ProductAnalyticsCollecting

    /// Creates a new analytics-backed navigation reporter.
    public init(collector: any ProductAnalyticsCollecting) {
        self.collector = collector
    }

    /// Reports a navigation event through the shared analytics layer.
    public func report(_ event: NavigationEvent) {
        let analyticsEvent = NavigationAnalyticsEventMapper.map(event)
        Task {
            await collector.record(analyticsEvent)
        }
    }
}

/// Maps networking metrics into shared product analytics events.
public enum APIMetricsAnalyticsEventMapper {
    /// Maps a networking metrics event into the shared analytics format.
    public static func map(_ event: APIMetricsEvent) -> ProductAnalyticsEvent {
        switch event {
        case let .requestPrepared(method, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_prepared",
                attributes: [
                    "method": method,
                    "url": url
                ]
            )
        case let .requestSucceeded(statusCode, bytes, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_succeeded",
                attributes: [
                    "status_code": String(statusCode),
                    "bytes": String(bytes),
                    "url": url
                ]
            )
        case let .requestFailed(error, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "request_failed",
                attributes: [
                    "error": String(describing: error),
                    "url": url
                ]
            )
        case let .retryScheduled(error, attempt, delayNanoseconds, url):
            return ProductAnalyticsEvent(
                domain: .networking,
                name: "retry_scheduled",
                attributes: [
                    "error": String(describing: error),
                    "attempt": String(attempt),
                    "delay_nanoseconds": String(delayNanoseconds),
                    "url": url
                ]
            )
        }
    }
}

/// Networking metrics collector that forwards events into the shared analytics layer.
public struct APIAnalyticsMetricsCollector: APIMetricsCollecting {
    private let collector: any ProductAnalyticsCollecting

    /// Creates a new analytics-backed networking collector.
    public init(collector: any ProductAnalyticsCollecting) {
        self.collector = collector
    }

    /// Records a networking metrics event through the shared analytics layer.
    public func record(_ event: APIMetricsEvent) async {
        await collector.record(APIMetricsAnalyticsEventMapper.map(event))
    }
}

/// Maps push lifecycle events into shared product analytics events.
public enum PushNotificationAnalyticsEventMapper {
    /// Maps a push event into the shared analytics format.
    public static func map(_ event: PushNotificationEvent) -> ProductAnalyticsEvent {
        switch event {
        case let .authorizationStatusUpdated(status):
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "authorization_status_updated",
                attributes: [
                    "status": status.rawValue
                ]
            )
        case let .remoteRegistrationUpdated(isRegistered):
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "remote_registration_updated",
                attributes: [
                    "is_registered": String(isRegistered)
                ]
            )
        case let .deviceTokenUpdated(token):
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "device_token_updated",
                attributes: [
                    "token_length": String(token.count)
                ]
            )
        case let .registrationFailed(reason):
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "registration_failed",
                attributes: [
                    "reason": reason
                ]
            )
        case let .remoteNotificationHandled(source, route, title):
            var attributes: [String: String] = [
                "source": source.rawValue
            ]
            if let route {
                attributes["route"] = route
            }
            if let title {
                attributes["title"] = title
            }
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "remote_notification_handled",
                attributes: attributes
            )
        case .stateCleared:
            return ProductAnalyticsEvent(
                domain: .pushNotifications,
                name: "state_cleared",
                attributes: [:]
            )
        }
    }
}

/// Push lifecycle collector that forwards events into the shared analytics layer.
public struct PushNotificationAnalyticsCollector: PushNotificationEventCollecting {
    private let collector: any ProductAnalyticsCollecting

    /// Creates a new analytics-backed push collector.
    public init(collector: any ProductAnalyticsCollecting) {
        self.collector = collector
    }

    /// Records a push lifecycle event through the shared analytics layer.
    public func record(_ event: PushNotificationEvent) async {
        await collector.record(PushNotificationAnalyticsEventMapper.map(event))
    }
}
