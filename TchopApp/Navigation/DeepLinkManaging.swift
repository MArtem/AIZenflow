import Foundation

/// Typed events emitted by navigation restore/deep-link flows.
@MainActor
enum NavigationEvent: Equatable {
    case deepLinkHandled(url: String, destination: String, policy: NavigationTransitionPolicy)
    case deepLinkRejected(url: String, reason: String)
    case deepLinkFallback(url: String, reason: String)
    case snapshotRestoreStarted(userID: String, sourceVersion: Int)
    case snapshotRestoreCompleted(userID: String, appliedVersion: Int, wasSanitized: Bool, wasMigrated: Bool)
    case snapshotRestoreSkipped(userID: String, reason: String)
    case snapshotRestoreFailed(userID: String, reason: String)
}

/// Contract used to report navigation events for diagnostics and observability.
@MainActor
protocol NavigationEventReporting: AnyObject {
    func report(_ event: NavigationEvent)
}

/// Default no-op navigation event reporter.
@MainActor
final class NavigationNoopEventReporter: NavigationEventReporting {
    func report(_ event: NavigationEvent) {}
}

/// In-memory navigation reporter primarily used by tests.
@MainActor
final class NavigationMemoryEventReporter: NavigationEventReporting {
    private(set) var events: [NavigationEvent] = []

    func report(_ event: NavigationEvent) {
        events.append(event)
    }
}

/// Contract that routes incoming URLs/user activities into app navigation.
@MainActor
protocol DeepLinkManaging {
    /// Handles a deep or universal link URL and updates coordinator navigation.
    @discardableResult
    func handle(url: URL, coordinator: AppCoordinator) -> Bool

    /// Handles universal-link user activity and updates coordinator navigation.
    @discardableResult
    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool
}
