import Foundation

/// Persistence contract for per-user navigation snapshots.
@MainActor
protocol NavigationStateManaging {
    /// Saves navigation state snapshot for the provided user identifier.
    func saveSnapshot(_ snapshot: NavigationSnapshot, for userID: String)

    /// Restores previously saved navigation snapshot for the provided user identifier.
    func restoreSnapshot(for userID: String) -> NavigationSnapshot?

    /// Removes previously saved navigation snapshot for the provided user identifier.
    func clearSnapshot(for userID: String)
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
