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

    /// Creates the app state and attempts to restore the previous user session.
    init(
        coordinator: AppCoordinator,
        appShellViewModel: AppShellViewModel,
        sessionService: any UserSessionManaging
    ) {
        self.coordinator = coordinator
        self.appShellViewModel = appShellViewModel
        self.sessionService = sessionService
        restoreSession()
    }

    /// Signs in with the provided username and updates the source of truth user state.
    func signIn(username: String) throws {
        currentUser = try sessionService.signIn(username: username)
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
            currentUser = try sessionService.restoreSession()
        } catch {
            assertionFailure("Failed to restore user session: \(error)")
            currentUser = nil
        }
    }
}
