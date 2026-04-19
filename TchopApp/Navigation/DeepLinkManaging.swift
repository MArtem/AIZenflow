import Foundation
import TchopNavigation

/// Contract that routes incoming URLs/user activities into app navigation.
@MainActor
protocol DeepLinkManaging {
    /// Handles a deep or universal link URL and updates coordinator navigation.
    @discardableResult
    /// Handles this operation.
    func handle(url: URL, coordinator: AppCoordinator) -> Bool

    /// Handles universal-link user activity and updates coordinator navigation.
    @discardableResult
    /// Handles this operation.
    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool
}
