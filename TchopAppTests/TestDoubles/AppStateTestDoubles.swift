import Foundation
import UIKit
import TchopAppleAuthentication
import TchopNavigation
import TchopPushNotifications
@testable import TchopApp

/// Test-only session error cases used by app-state scenarios.
enum TestSessionError: Error {
    case signInUnavailable
}

/// Lightweight session service double for app-state tests.
@MainActor
final class TestUserSessionService: UserSessionManaging {
    private let signInResult: Result<AppUser, Error>
    private let restoreResult: Result<AppUser?, Error>

    private(set) var signOutCallCount = 0

    /// Creates a new TestUserSessionService instance.
    init(
        signInResult: Result<AppUser, Error>,
        restoreResult: Result<AppUser?, Error>
    ) {
        self.signInResult = signInResult
        self.restoreResult = restoreResult
    }

    /// Returns the configured sign-in result.
    func signIn(username: String) async throws -> AppUser {
        try signInResult.get()
    }

    func signIn(email: String, password: String) async throws -> AppUser {
        try signInResult.get()
    }

    func register(email: String, password: String) async throws -> AppUser {
        try signInResult.get()
    }

    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AppUser {
        try signInResult.get()
    }

    /// Returns the configured restore result.
    func restoreSession() throws -> AppUser? {
        try restoreResult.get()
    }

    func restoreAuthenticatedSession() async throws -> AppUser? {
        try restoreResult.get()
    }

    /// Tracks sign-out calls for assertions.
    func signOut() {
        signOutCallCount += 1
    }
}

/// Lightweight user repository double for app-state tests.
@MainActor
final class TestUserRepository: UserRepository {
    private let user: AppUser

    /// Creates a new TestUserRepository instance.
    init(user: AppUser) {
        self.user = user
    }

    func findUser(id: String) throws -> AppUser? {
        user.id == id ? user : nil
    }

    /// Returns the seeded user when the username matches exactly.
    func findUser(username: String) throws -> AppUser? {
        user.username == username ? user : nil
    }

    /// Returns the seeded user without creating additional records.
    func findOrCreateUser(username: String) throws -> AppUser {
        user
    }

    /// Returns a copy of the seeded user with the updated restore flag.
    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        AppUser(
            id: user.id,
            username: user.username,
            createdAt: user.createdAt,
            isNavigationStateRestoreEnabled: isEnabled
        )
    }

    func findOrCreateAppleUser(
        appleUserID: String,
        preferredUsername: String?
    ) throws -> AppUser {
        user
    }
}

/// In-memory navigation-state double for restore and persistence assertions.
@MainActor
final class TestNavigationStateManager: NavigationStateManaging {
    private var snapshots: [String: NavigationSnapshot] = [:]
    private(set) var clearCallCount = 0

    /// Creates a new TestNavigationStateManager instance.
    init(seed: [String: NavigationSnapshot] = [:]) {
        self.snapshots = seed
    }

    /// Stores the typed navigation snapshot for the given user.
    func saveSnapshot<Snapshot: Codable>(_ snapshot: Snapshot, for userID: String) {
        guard let typedSnapshot = snapshot as? NavigationSnapshot else {
            return
        }

        snapshots[userID] = typedSnapshot
    }

    /// Restores the previously stored navigation snapshot when present.
    func restoreSnapshot<Snapshot: Codable>(for userID: String, as snapshotType: Snapshot.Type) -> Snapshot? {
        guard let snapshot = snapshots[userID] else {
            return nil
        }

        return snapshot as? Snapshot
    }

    /// Removes the stored navigation snapshot for the given user.
    func clearSnapshot(for userID: String) {
        clearCallCount += 1
        snapshots[userID] = nil
    }

    /// Returns the concrete navigation snapshot for direct test assertions.
    func snapshot(for userID: String) -> NavigationSnapshot? {
        snapshots[userID]
    }
}

/// No-op deep-link double used when a test does not need link handling.
@MainActor
final class TestDeepLinkManager: DeepLinkManaging {
    /// Always declines URL handling.
    func handle(url: URL, coordinator: AppCoordinator) -> Bool {
        false
    }

    /// Always declines user-activity handling.
    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool {
        false
    }
}

/// Recording widget sync double used for logout side-effect assertions.
@MainActor
final class RecordingWidgetContentSyncManager: WidgetContentSyncing {
    private(set) var syncCallCount = 0
    private(set) var clearCallCount = 0

    /// Creates a new RecordingWidgetContentSyncManager instance.
    init() {}

    /// Tracks feed synchronization calls.
    func syncFeed(content: NewsFeedContent) {
        syncCallCount += 1
    }

    /// Tracks widget snapshot clearing calls.
    func clearFeed() {
        clearCallCount += 1
    }
}

/// Recording push bridge double used for app-state delegation assertions.
@MainActor
final class RecordingPushNotificationBridge: AppPushNotificationBridging {
    private(set) var startCallCount = 0
    private(set) var requestAuthorizationAndRegisterCallCount = 0
    private(set) var didRegisterCallCount = 0
    private(set) var didFailToRegisterCallCount = 0
    private(set) var handledRemoteNotificationCount = 0

    /// Creates a new RecordingPushNotificationBridge instance.
    init() {}

    /// Tracks application startup wiring calls.
    func start(application: UIApplication) {
        startCallCount += 1
    }

    /// Tracks explicit authorization requests from app state.
    func requestAuthorizationAndRegister(application: UIApplication) async {
        requestAuthorizationAndRegisterCallCount += 1
    }

    /// Tracks successful device token forwarding.
    func didRegisterForRemoteNotifications(deviceToken: Data) async {
        didRegisterCallCount += 1
    }

    /// Tracks APNs registration failure forwarding.
    func didFailToRegisterForRemoteNotifications(error: Error) async {
        didFailToRegisterCallCount += 1
    }

    /// Tracks remote notification forwarding.
    func handleRemoteNotification(_ payload: PushNotificationPayload) async {
        handledRemoteNotificationCount += 1
    }
}
