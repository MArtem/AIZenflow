import TchopAnalyticsCore
import TchopPushNotifications

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
