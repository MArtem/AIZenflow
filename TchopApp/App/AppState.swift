import Combine
import Foundation
import TchopAppleAuthentication
import UIKit
import TchopNavigation

/// Root app-level state object.
///
/// This type owns authenticated user state and coordinates transitions between
/// login and the main shell.
@MainActor
final class AppState: ObservableObject {
    /// Currently signed-in user, if any.
    @Published private(set) var currentUser: AppUser?

    /// Shared coordinator for tab selection and per-tab navigation state.
    let coordinator: AppCoordinator

    /// Shared shell view model used by the authenticated app.
    let appShellViewModel: AppShellViewModel
    private let sessionService: any UserSessionManaging
    private let userRepository: any UserRepository
    private let navigationStateManager: any NavigationStateManaging
    private let deepLinkManager: any DeepLinkManaging
    private let navigationEventReporter: any NavigationEventReporting
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let pushNotificationBridge: any AppPushNotificationBridging
    private var navigationBindings: Set<AnyCancellable> = []
    /// Guards snapshot persistence while an old snapshot is being restored into the coordinator.
    private var isApplyingNavigationSnapshot = false
    /// Deep links received before authentication are buffered and replayed after sign-in.
    private var pendingDeepLinkInput: PendingDeepLinkInput?

    /// Creates the app state and attempts to restore the previous user session.
    init(
        coordinator: AppCoordinator,
        appShellViewModel: AppShellViewModel,
        sessionService: any UserSessionManaging,
        userRepository: any UserRepository,
        navigationStateManager: any NavigationStateManaging,
        deepLinkManager: any DeepLinkManaging,
        navigationEventReporter: any NavigationEventReporting,
        widgetContentSyncManager: any WidgetContentSyncing,
        pushNotificationBridge: any AppPushNotificationBridging
    ) {
        self.coordinator = coordinator
        self.appShellViewModel = appShellViewModel
        self.sessionService = sessionService
        self.userRepository = userRepository
        self.navigationStateManager = navigationStateManager
        self.deepLinkManager = deepLinkManager
        self.navigationEventReporter = navigationEventReporter
        self.widgetContentSyncManager = widgetContentSyncManager
        self.pushNotificationBridge = pushNotificationBridge
        setupNavigationPersistenceBindings()
        Task { @MainActor [weak self] in
            await self?.restoreSession()
        }
    }

    /// Signs in with the provided username and updates the source of truth user state.
    func signIn(username: String) throws {
        let signedInUser = try sessionService.signIn(username: username)
        activateAuthenticatedUser(signedInUser)
    }

    /// Signs in with a normalized Apple identity profile and updates the source of truth user state.
    func signInWithApple(identity: AppleAuthenticationIdentity) throws {
        let signedInUser = try sessionService.signInWithApple(identity: identity)
        activateAuthenticatedUser(signedInUser)
    }

    /// Updates restore preference for the active profile and applies the chosen policy immediately.
    func setNavigationRestoreEnabled(_ isEnabled: Bool) throws {
        guard let currentUser else {
            return
        }

        let updatedUser = try userRepository.updateNavigationStateRestoreEnabled(
            userID: currentUser.id,
            isEnabled: isEnabled
        )
        self.currentUser = updatedUser

        if isEnabled {
            restoreNavigationIfNeeded(for: updatedUser)
        } else {
            resetNavigationToDefaultState()
            navigationStateManager.clearSnapshot(for: updatedUser.id)
        }
    }

    /// Routes an incoming deep-link URL when the app has an authenticated user.
    @discardableResult
    func handleIncomingURL(_ url: URL) -> Bool {
        handleDeepLinkInput(.url(url))
    }

    /// Routes an incoming universal-link activity when the app has an authenticated user.
    @discardableResult
    func handleIncomingUserActivity(_ userActivity: NSUserActivity) -> Bool {
        handleDeepLinkInput(.userActivity(userActivity))
    }

    /// Signs out the current user and resets navigation back to the default app state.
    func signOut() {
        sessionService.signOut()
        currentUser = nil
        pendingDeepLinkInput = nil
        resetNavigationToDefaultState()
        appShellViewModel.closeMenu()
        widgetContentSyncManager.clearFeed()
    }

    /// Requests push notification authorization and APNs registration on demand.
    func requestPushNotificationAuthorization() {
        Task { @MainActor [pushNotificationBridge] in
            await pushNotificationBridge.requestAuthorizationAndRegister(
                application: UIApplication.shared
            )
        }
    }

    /// Restores the previously persisted user session if one exists.
    private func restoreSession() async {
        do {
            let restoredUser = try await sessionService.restoreAuthenticatedSession()
            if let restoredUser {
                activateAuthenticatedUser(restoredUser)
            } else {
                currentUser = nil
            }
        } catch {
            assertionFailure("Failed to restore user session: \(error)")
            currentUser = nil
        }
    }

    /// Restores navigation if needed.
    ///
    /// Restore is user-scoped and opt-in, so this path always checks the active profile before
    /// touching the coordinator.
    private func restoreNavigationIfNeeded(for user: AppUser) {
        guard let snapshot = resolveRestorableSnapshot(for: user) else {
            return
        }

        navigationEventReporter.report(
            .snapshotRestoreStarted(
                userID: user.id,
                sourceVersion: snapshot.version
            )
        )
        applyRestoredSnapshot(snapshot, for: user)
    }

    /// Resolves the snapshot that may be restored for the current user.
    private func resolveRestorableSnapshot(for user: AppUser) -> NavigationSnapshot? {
        guard user.isNavigationStateRestoreEnabled else {
            resetNavigationToDefaultState()
            reportSnapshotRestoreSkipped(for: user.id, reason: "restore-disabled")
            return nil
        }

        guard
            let snapshot = navigationStateManager.restoreSnapshot(
                for: user.id,
                as: NavigationSnapshot.self
            )
        else {
            reportSnapshotRestoreSkipped(for: user.id, reason: "snapshot-missing")
            return nil
        }

        guard snapshot.version <= NavigationSnapshot.supportedVersion else {
            resetNavigationToDefaultState()
            navigationStateManager.clearSnapshot(for: user.id)
            reportSnapshotRestoreFailed(
                for: user.id,
                reason: "unsupported-future-version-\(snapshot.version)"
            )
            return nil
        }

        return snapshot
    }

    /// Applies a resolved snapshot and records whether migration or sanitization changed it.
    private func applyRestoredSnapshot(_ snapshot: NavigationSnapshot, for user: AppUser) {
        let migratedSnapshot = snapshot.migratedToSupportedVersion()
        let sanitizedSnapshot = migratedSnapshot.sanitized()
        let wasMigrated = migratedSnapshot.version != snapshot.version
        let wasSanitized = sanitizedSnapshot != migratedSnapshot

        applyNavigationSnapshot(sanitizedSnapshot)

        if wasMigrated || wasSanitized {
            navigationStateManager.saveSnapshot(sanitizedSnapshot, for: user.id)
        }

        navigationEventReporter.report(
            .snapshotRestoreCompleted(
                userID: user.id,
                appliedVersion: sanitizedSnapshot.version,
                wasSanitized: wasSanitized,
                wasMigrated: wasMigrated
            )
        )
    }

    /// Reports that snapshot restore was skipped before applying any persisted state.
    private func reportSnapshotRestoreSkipped(for userID: String, reason: String) {
        navigationEventReporter.report(
            .snapshotRestoreSkipped(
                userID: userID,
                reason: reason
            )
        )
    }

    /// Reports that snapshot restore failed after a persisted snapshot was inspected.
    private func reportSnapshotRestoreFailed(for userID: String, reason: String) {
        navigationEventReporter.report(
            .snapshotRestoreFailed(
                userID: userID,
                reason: reason
            )
        )
    }

    /// Applies post authentication navigation.
    ///
    /// Pending deep links win over snapshot restore so external routing never gets silently
    /// overwritten by an older persisted tab state.
    private func applyPostAuthenticationNavigation(for user: AppUser) {
        if applyPendingDeepLinkIfNeeded() {
            return
        }

        restoreNavigationIfNeeded(for: user)
    }

    /// Stores the active user and applies the standard authenticated runtime bootstrap flow.
    private func activateAuthenticatedUser(_ user: AppUser) {
        currentUser = user
        applyPostAuthenticationNavigation(for: user)
    }

    /// Applies pending deep link if needed.
    private func applyPendingDeepLinkIfNeeded() -> Bool {
        guard let pendingDeepLinkInput else {
            return false
        }

        self.pendingDeepLinkInput = nil
        return resolveDeepLinkInput(pendingDeepLinkInput)
    }

    /// Subscribes to coordinator navigation changes and persists snapshots when allowed.
    private func setupNavigationPersistenceBindings() {
        coordinator.navigationChanges
            .sink { [weak self] _ in
                self?.persistNavigationSnapshotIfNeeded()
            }
            .store(in: &navigationBindings)
    }

    /// Persists the current navigation snapshot when the active user opted into restore.
    private func persistNavigationSnapshotIfNeeded() {
        guard !isApplyingNavigationSnapshot else {
            return
        }

        guard let currentUser, currentUser.isNavigationStateRestoreEnabled else {
            return
        }

        navigationStateManager.saveSnapshot(
            coordinator.makeSnapshot(),
            for: currentUser.id
        )
    }

    /// Queues unauthenticated deep links and resolves them immediately once a user session exists.
    @discardableResult
    private func handleDeepLinkInput(_ input: PendingDeepLinkInput) -> Bool {
        guard currentUser != nil else {
            pendingDeepLinkInput = input
            return true
        }

        return resolveDeepLinkInput(input)
    }

    /// Resolves a concrete deep-link input through the deep-link manager.
    private func resolveDeepLinkInput(_ input: PendingDeepLinkInput) -> Bool {
        switch input {
        case let .url(url):
            return deepLinkManager.handle(url: url, coordinator: coordinator)
        case let .userActivity(userActivity):
            return deepLinkManager.handle(userActivity: userActivity, coordinator: coordinator)
        }
    }

    /// Resets the app navigation back to the default signed-out root state.
    private func resetNavigationToDefaultState() {
        coordinator.selectTab(.news)
        coordinator.resetAllNavigation()
    }

    /// Applies a restored navigation snapshot while suppressing persistence feedback loops.
    private func applyNavigationSnapshot(_ snapshot: NavigationSnapshot) {
        isApplyingNavigationSnapshot = true
        defer { isApplyingNavigationSnapshot = false }
        coordinator.applySnapshot(snapshot)
    }
}

private enum PendingDeepLinkInput {
    case url(URL)
    case userActivity(NSUserActivity)
}
