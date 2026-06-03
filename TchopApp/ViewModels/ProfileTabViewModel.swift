import Foundation
import Observation
import AppErrors

/// Presentation owner for the profile tab root screen.
///
/// This view model keeps profile-specific UI state and owns the optimistic preference-update
/// flow so the SwiftUI view stays declarative and does not perform persistence/error work itself.
@MainActor
@Observable
final class ProfileTabViewModel {
    /// Mutable presentation state for the profile tab.
    struct State {
        var accountSummary: AccountProfileSummary
        var isNavigationRestoreEnabled: Bool
        var errorMessage: String?
    }

    private(set) var state: State

    /// Presentation summary for the currently signed-in user.
    var accountSummary: AccountProfileSummary { state.accountSummary }

    /// UI-facing restore-navigation preference state.
    var isNavigationRestoreEnabled: Bool { state.isNavigationRestoreEnabled }

    /// Presentation-ready error message for profile preference failures.
    var errorMessage: String? { state.errorMessage }

    private let errorManager: any AppErrorManaging
    private let onNavigationRestoreChange: (Bool) throws -> Void

    /// Creates a new profile-tab view model for the supplied signed-in user.
    init(
        currentUser: AppUser,
        errorManager: any AppErrorManaging,
        onNavigationRestoreChange: @escaping (Bool) throws -> Void
    ) {
        self.state = State(
            accountSummary: AccountProfileSummary(user: currentUser),
            isNavigationRestoreEnabled: currentUser.isNavigationStateRestoreEnabled,
            errorMessage: nil
        )
        self.errorManager = errorManager
        self.onNavigationRestoreChange = onNavigationRestoreChange
    }

    /// Synchronizes presentation state when the signed-in user snapshot changes upstream.
    func syncCurrentUser(_ currentUser: AppUser) {
        state.accountSummary = AccountProfileSummary(user: currentUser)
        state.isNavigationRestoreEnabled = currentUser.isNavigationStateRestoreEnabled
    }

    /// Applies the restore-navigation preference with optimistic UI and rollback on failure.
    func setNavigationRestoreEnabled(_ isEnabled: Bool) {
        let previousValue = state.isNavigationRestoreEnabled
        state.isNavigationRestoreEnabled = isEnabled

        do {
            try onNavigationRestoreChange(isEnabled)
            state.errorMessage = nil
        } catch {
            state.isNavigationRestoreEnabled = previousValue
            presentNavigationRestoreFailure(error)
        }
    }

    /// Normalizes profile-preference persistence failures through the shared app error pipeline.
    private func presentNavigationRestoreFailure(_ error: Error) {
        Task { @MainActor [weak self, errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "updateNavigationRestorePreference",
                    feature: "profile"
                )
            )
            self?.state.errorMessage = presentation.userMessage
        }
    }
}
