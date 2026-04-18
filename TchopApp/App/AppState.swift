import Combine
import Foundation
import TchopDatabase

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
    private var navigationBindings: Set<AnyCancellable> = []
    private var isApplyingNavigationSnapshot = false
    private var pendingDeepLinkInput: PendingDeepLinkInput?

    /// Creates the app state and attempts to restore the previous user session.
    init(
        coordinator: AppCoordinator,
        appShellViewModel: AppShellViewModel,
        sessionService: any UserSessionManaging,
        userRepository: any UserRepository,
        navigationStateManager: any NavigationStateManaging,
        deepLinkManager: any DeepLinkManaging,
        navigationEventReporter: (any NavigationEventReporting)? = nil,
        widgetContentSyncManager: any WidgetContentSyncing
    ) {
        self.coordinator = coordinator
        self.appShellViewModel = appShellViewModel
        self.sessionService = sessionService
        self.userRepository = userRepository
        self.navigationStateManager = navigationStateManager
        self.deepLinkManager = deepLinkManager
        self.navigationEventReporter = navigationEventReporter ?? NavigationNoopEventReporter()
        self.widgetContentSyncManager = widgetContentSyncManager
        setupNavigationPersistenceBindings()
        restoreSession()
    }

    /// Signs in with the provided username and updates the source of truth user state.
    func signIn(username: String) throws {
        let signedInUser = try sessionService.signIn(username: username)
        currentUser = signedInUser
        applyPostAuthenticationNavigation(for: signedInUser)
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
            coordinator.selectTab(.news)
            coordinator.resetAllNavigation()
            navigationStateManager.clearSnapshot(for: updatedUser.id)
        }
    }

    /// Routes an incoming deep-link URL when the app has an authenticated user.
    @discardableResult
    func handleIncomingURL(_ url: URL) -> Bool {
        guard currentUser != nil else {
            pendingDeepLinkInput = .url(url)
            return true
        }

        return deepLinkManager.handle(url: url, coordinator: coordinator)
    }

    /// Routes an incoming universal-link activity when the app has an authenticated user.
    @discardableResult
    func handleIncomingUserActivity(_ userActivity: NSUserActivity) -> Bool {
        guard currentUser != nil else {
            pendingDeepLinkInput = .userActivity(userActivity)
            return true
        }

        return deepLinkManager.handle(userActivity: userActivity, coordinator: coordinator)
    }

    /// Signs out the current user and resets navigation back to the default app state.
    func signOut() {
        sessionService.signOut()
        currentUser = nil
        pendingDeepLinkInput = nil
        coordinator.selectTab(.news)
        coordinator.resetAllNavigation()
        appShellViewModel.closeMenu()
        widgetContentSyncManager.clearFeed()
    }

    /// Restores the previously persisted user session if one exists.
    private func restoreSession() {
        do {
            let restoredUser = try sessionService.restoreSession()
            currentUser = restoredUser
            if let restoredUser {
                applyPostAuthenticationNavigation(for: restoredUser)
            }
        } catch {
            assertionFailure("Failed to restore user session: \(error)")
            currentUser = nil
        }
    }

    private func restoreNavigationIfNeeded(for user: AppUser) {
        guard user.isNavigationStateRestoreEnabled else {
            coordinator.selectTab(.news)
            coordinator.resetAllNavigation()
            navigationEventReporter.report(
                .snapshotRestoreSkipped(
                    userID: user.id,
                    reason: "restore-disabled"
                )
            )
            return
        }

        guard
            let snapshot = navigationStateManager.restoreSnapshot(
                for: user.id,
                as: NavigationSnapshot.self
            )
        else {
            navigationEventReporter.report(
                .snapshotRestoreSkipped(
                    userID: user.id,
                    reason: "snapshot-missing"
                )
            )
            return
        }

        navigationEventReporter.report(
            .snapshotRestoreStarted(
                userID: user.id,
                sourceVersion: snapshot.version
            )
        )

        guard snapshot.version <= NavigationSnapshot.supportedVersion else {
            coordinator.selectTab(.news)
            coordinator.resetAllNavigation()
            navigationStateManager.clearSnapshot(for: user.id)
            navigationEventReporter.report(
                .snapshotRestoreFailed(
                    userID: user.id,
                    reason: "unsupported-future-version-\(snapshot.version)"
                )
            )
            return
        }

        let migratedSnapshot = snapshot.migratedToSupportedVersion()
        let sanitizedSnapshot = migratedSnapshot.sanitized()
        let wasMigrated = migratedSnapshot.version != snapshot.version
        let wasSanitized = sanitizedSnapshot != migratedSnapshot

        isApplyingNavigationSnapshot = true
        coordinator.applySnapshot(sanitizedSnapshot)
        isApplyingNavigationSnapshot = false

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

    private func applyPostAuthenticationNavigation(for user: AppUser) {
        if applyPendingDeepLinkIfNeeded() {
            return
        }

        restoreNavigationIfNeeded(for: user)
    }

    private func applyPendingDeepLinkIfNeeded() -> Bool {
        guard let pendingDeepLinkInput else {
            return false
        }

        let wasHandled: Bool
        switch pendingDeepLinkInput {
        case let .url(url):
            wasHandled = deepLinkManager.handle(url: url, coordinator: coordinator)
        case let .userActivity(userActivity):
            wasHandled = deepLinkManager.handle(userActivity: userActivity, coordinator: coordinator)
        }

        self.pendingDeepLinkInput = nil
        return wasHandled
    }

    private func setupNavigationPersistenceBindings() {
        Publishers.MergeMany(
            coordinator.$selectedTab.map { _ in () }.eraseToAnyPublisher(),
            coordinator.newsRouter.$path.map { _ in () }.eraseToAnyPublisher(),
            coordinator.mixesRouter.$path.map { _ in () }.eraseToAnyPublisher(),
            coordinator.pinnedRouter.$path.map { _ in () }.eraseToAnyPublisher(),
            coordinator.chatRouter.$path.map { _ in () }.eraseToAnyPublisher(),
            coordinator.profileRouter.$path.map { _ in () }.eraseToAnyPublisher()
        )
        .sink { [weak self] _ in
            self?.persistNavigationSnapshotIfNeeded()
        }
        .store(in: &navigationBindings)
    }

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
}

private enum PendingDeepLinkInput {
    case url(URL)
    case userActivity(NSUserActivity)
}
