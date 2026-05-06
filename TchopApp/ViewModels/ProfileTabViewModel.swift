import Foundation
import Observation
import TchopErrors

/// Presentation owner for the profile tab root screen.
///
/// This view model keeps profile-specific UI state and owns the optimistic preference-update
/// flow so the SwiftUI view stays declarative and does not perform persistence/error work itself.
@MainActor
@Observable
final class ProfileTabViewModel {
    /// Presentation summary for the currently signed-in user.
    private(set) var accountSummary: AccountProfileSummary

    /// UI-facing restore-navigation preference state.
    private(set) var isNavigationRestoreEnabled: Bool

    /// Presentation-ready error message for profile preference failures.
    private(set) var errorMessage: String?

    private let errorManager: any AppErrorManaging
    private let onNavigationRestoreChange: (Bool) throws -> Void

    /// Creates a new profile-tab view model for the supplied signed-in user.
    init(
        currentUser: AppUser,
        errorManager: any AppErrorManaging,
        onNavigationRestoreChange: @escaping (Bool) throws -> Void
    ) {
        self.accountSummary = AccountProfileSummary(user: currentUser)
        self.isNavigationRestoreEnabled = currentUser.isNavigationStateRestoreEnabled
        self.errorManager = errorManager
        self.onNavigationRestoreChange = onNavigationRestoreChange
    }

    /// Synchronizes presentation state when the signed-in user snapshot changes upstream.
    func syncCurrentUser(_ currentUser: AppUser) {
        accountSummary = AccountProfileSummary(user: currentUser)
        isNavigationRestoreEnabled = currentUser.isNavigationStateRestoreEnabled
    }

    /// Applies the restore-navigation preference with optimistic UI and rollback on failure.
    func setNavigationRestoreEnabled(_ isEnabled: Bool) {
        let previousValue = isNavigationRestoreEnabled
        isNavigationRestoreEnabled = isEnabled

        do {
            try onNavigationRestoreChange(isEnabled)
            errorMessage = nil
        } catch {
            isNavigationRestoreEnabled = previousValue
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
            self?.errorMessage = presentation.userMessage
        }
    }
}
