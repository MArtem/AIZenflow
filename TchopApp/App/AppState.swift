import Foundation

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

    /// Creates the app state and attempts to restore the previous user session.
    init(
        coordinator: AppCoordinator,
        appShellViewModel: AppShellViewModel,
        sessionService: any UserSessionManaging,
        userRepository: any UserRepository,
        navigationStateManager: any NavigationStateManaging
    ) {
        self.coordinator = coordinator
        self.appShellViewModel = appShellViewModel
        self.sessionService = sessionService
        self.userRepository = userRepository
        self.navigationStateManager = navigationStateManager
        restoreSession()
    }

    /// Signs in with the provided username and updates the source of truth user state.
    func signIn(username: String) throws {
        let signedInUser = try sessionService.signIn(username: username)
        currentUser = signedInUser
        restoreNavigationIfNeeded(for: signedInUser)
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
        }
    }

    /// Signs out the current user and resets navigation back to the default app state.
    func signOut() {
        sessionService.signOut()
        currentUser = nil
        coordinator.selectTab(.news)
        coordinator.resetAllNavigation()
        appShellViewModel.closeMenu()
    }

    /// Restores the previously persisted user session if one exists.
    private func restoreSession() {
        do {
            let restoredUser = try sessionService.restoreSession()
            currentUser = restoredUser
            if let restoredUser {
                restoreNavigationIfNeeded(for: restoredUser)
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
            return
        }

        guard let snapshot = navigationStateManager.restoreSnapshot(for: user.id) else {
            return
        }

        coordinator.selectTab(snapshot.selectedTab)
        coordinator.newsRouter.replacePath(with: snapshot.newsPath)
        coordinator.mixesRouter.replacePath(with: snapshot.mixesPath)
        coordinator.pinnedRouter.replacePath(with: snapshot.pinnedPath)
        coordinator.chatRouter.replacePath(with: snapshot.chatPath)
        coordinator.profileRouter.replacePath(with: snapshot.profilePath)
    }
}
