import TchopAnalyticsCore
import TchopNavigation

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
