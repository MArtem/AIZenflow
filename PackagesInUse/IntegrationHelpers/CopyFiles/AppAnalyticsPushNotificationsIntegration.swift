import AppAnalytics
import AppPushNotifications

/// Optional integration helper for projects that use both `AppAnalytics` and `AppPushNotifications`.
///
/// Privacy:
/// Notification titles and raw routes are intentionally not recorded.
/// The mapper records `has_title` and a coarse first-segment route category instead.
public enum PushNotificationAnalyticsEventMapper {
    public static func map(_ event: PushNotificationEvent) -> AnalyticsEvent {
        switch event {
        case let .authorizationStatusUpdated(status):
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "authorization_status_updated",
                attributes: ["status": .string(status.rawValue)]
            )
        case let .remoteRegistrationUpdated(isRegistered):
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "remote_registration_updated",
                attributes: ["is_registered": .bool(isRegistered)]
            )
        case let .deviceTokenUpdated(token):
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "device_token_updated",
                attributes: ["token_length": .int(token.count)]
            )
        case let .registrationFailed(reason):
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "registration_failed",
                attributes: ["reason_code": .string(sanitizedCode(reason))]
            )
        case let .remoteNotificationHandled(source, route, title):
            var attributes: [String: AnalyticsValue] = [
                "source": .string(source.rawValue),
                "has_title": .bool(title != nil)
            ]
            if let route {
                attributes["route_code"] = .string(routeCode(route))
            }
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "remote_notification_handled",
                attributes: attributes
            )
        case .stateCleared:
            return AnalyticsEvent(
                domain: .pushNotifications,
                name: "state_cleared",
                attributes: [:]
            )
        }
    }

    private static func sanitizedCode(_ value: String) -> String {
        let normalized = value
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "_"
            }
        let collapsed = String(normalized).split(separator: "_").joined(separator: "_")
        return collapsed.isEmpty ? "unknown" : collapsed
    }

    private static func routeCode(_ value: String) -> String {
        let firstPathComponent = value
            .split { character in
                character == "/" || character == "?" || character == "#" || character == "&" || character == "="
            }
            .first
            .map(String.init) ?? ""
        let sanitized = sanitizedCode(firstPathComponent)
        return sanitized == "unknown" || isDynamicRouteComponent(sanitized) ? "route" : sanitized
    }

    private static func isDynamicRouteComponent(_ value: String) -> Bool {
        value.allSatisfy(\.isNumber) || value.count > 48
    }
}

/// Push lifecycle collector that forwards events into the shared analytics layer.
public struct PushNotificationAnalyticsCollector: PushNotificationEventCollecting {
    private let collector: any AnalyticsCollecting

    public init(collector: any AnalyticsCollecting) {
        self.collector = collector
    }

    public func record(_ event: PushNotificationEvent) async {
        await collector.record(PushNotificationAnalyticsEventMapper.map(event))
    }
}
