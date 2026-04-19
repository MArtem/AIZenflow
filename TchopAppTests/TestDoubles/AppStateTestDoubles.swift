import Foundation
import TchopNavigation
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
    func signIn(username: String) throws -> AppUser {
        try signInResult.get()
    }

    /// Returns the configured restore result.
    func restoreSession() throws -> AppUser? {
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
