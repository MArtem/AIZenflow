import Foundation

/// Optional integration helper for projects that use both `AppAnalytics` and `AppNavigation`.
///
/// Privacy:
/// Deep-link URLs are recorded without query strings or fragments.
@MainActor
public enum NavigationAnalyticsEventMapper {
    public static func map(_ event: NavigationEvent) -> AnalyticsEvent {
        switch event {
        case let .deepLinkHandled(url, destination, policy):
            return AnalyticsEvent(
                domain: .navigation,
                name: "deep_link_handled",
                attributes: [
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "destination": .string(destination),
                    "policy": .string(policy.rawValue)
                ]
            )
        case let .deepLinkRejected(url, reason):
            return AnalyticsEvent(
                domain: .navigation,
                name: "deep_link_rejected",
                attributes: [
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "reason_code": .string(TelemetrySanitizer.sanitizedCode(reason))
                ]
            )
        case let .deepLinkFallback(url, reason):
            return AnalyticsEvent(
                domain: .navigation,
                name: "deep_link_fallback",
                attributes: [
                    "url": .string(TelemetrySanitizer.redactedURL(url)),
                    "reason_code": .string(TelemetrySanitizer.sanitizedCode(reason))
                ]
            )
        case let .snapshotRestoreStarted(userID, sourceVersion):
            return AnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_started",
                attributes: [
                    "user_id_hash": .string(TelemetrySanitizer.stableNonCryptographicHash(userID)),
                    "source_version": .int(sourceVersion)
                ]
            )
        case let .snapshotRestoreCompleted(userID, appliedVersion, wasSanitized, wasMigrated):
            return AnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_completed",
                attributes: [
                    "user_id_hash": .string(TelemetrySanitizer.stableNonCryptographicHash(userID)),
                    "applied_version": .int(appliedVersion),
                    "was_sanitized": .bool(wasSanitized),
                    "was_migrated": .bool(wasMigrated)
                ]
            )
        case let .snapshotRestoreSkipped(userID, reason):
            return AnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_skipped",
                attributes: [
                    "user_id_hash": .string(TelemetrySanitizer.stableNonCryptographicHash(userID)),
                    "reason_code": .string(TelemetrySanitizer.sanitizedCode(reason))
                ]
            )
        case let .snapshotRestoreFailed(userID, reason):
            return AnalyticsEvent(
                domain: .navigation,
                name: "snapshot_restore_failed",
                attributes: [
                    "user_id_hash": .string(TelemetrySanitizer.stableNonCryptographicHash(userID)),
                    "reason_code": .string(TelemetrySanitizer.sanitizedCode(reason))
                ]
            )
        }
    }
}

/// Navigation reporter that forwards diagnostics into the shared analytics collector.
@MainActor
public final class NavigationAnalyticsEventReporter: NavigationEventReporting {
    private let collector: any AnalyticsCollecting

    public init(collector: any AnalyticsCollecting) {
        self.collector = collector
    }

    public func report(_ event: NavigationEvent) {
        let analyticsEvent = NavigationAnalyticsEventMapper.map(event)
        Task {
            await collector.record(analyticsEvent)
        }
    }
}

private enum TelemetrySanitizer {
    static func redactedURL(_ value: String) -> String {
        guard var components = URLComponents(string: value) else {
            return "invalid_url"
        }
        components.query = nil
        components.fragment = nil
        return components.string ?? "invalid_url"
    }

    static func sanitizedCode(_ value: String) -> String {
        let normalized = value
            .lowercased()
            .map { character in
                character.isLetter || character.isNumber ? character : "_"
            }
        let collapsed = String(normalized).split(separator: "_").joined(separator: "_")
        return collapsed.isEmpty ? "unknown" : collapsed
    }

    static func stableNonCryptographicHash(_ value: String) -> String {
        var hash: UInt64 = 1469598103934665603
        for byte in value.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        return String(hash, radix: 16)
    }
}
