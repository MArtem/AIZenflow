import SwiftUI
import TchopErrors
import TchopNavigation

/// Root profile-tab screen bound to its dedicated navigation router.
struct ProfileTabRootView: View {
    let currentUser: AppUser
    @ObservedObject var router: TabRouter<ProfileRoute>
    let errorManager: any AppErrorManaging
    /// Persists the "restore previous navigation" preference for the currently signed-in user.
    let onNavigationRestoreChange: (Bool) throws -> Void
    let onLogout: () -> Void
    @State private var isNavigationRestoreEnabled: Bool
    @State private var errorMessage: String?

    init(
        currentUser: AppUser,
        router: TabRouter<ProfileRoute>,
        errorManager: any AppErrorManaging,
        onNavigationRestoreChange: @escaping (Bool) throws -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.currentUser = currentUser
        self.router = router
        self.errorManager = errorManager
        self.onNavigationRestoreChange = onNavigationRestoreChange
        self.onLogout = onLogout
        _isNavigationRestoreEnabled = State(initialValue: currentUser.isNavigationStateRestoreEnabled)
    }

    var body: some View {
        let accountSummary = AccountProfileSummary(user: currentUser)

        NavigationStack(path: pathBinding) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    ProfileHeaderSection(
                        username: accountSummary.displayName,
                        userInitials: accountSummary.initials,
                        providerTitle: accountSummary.providerTitle
                    )
                    ProfileAccountCard(
                        providerTitle: accountSummary.providerTitle,
                        providerDescription: accountSummary.providerDescription,
                        accountIDHint: accountSummary.accountIDHint
                    )
                    ProfilePreferencesCard(
                        isNavigationRestoreEnabled: navigationRestoreBinding
                    )
                    if let errorMessage {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(Color.red.opacity(0.85))
                    }
                    ProfileLogoutButton(onLogout: onLogout)
                }
                .padding(.horizontal, 20)
                .padding(.top, 28)
                .padding(.bottom, 120)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.clear)
            .accessibilityIdentifier("profile.root")
            .onChange(of: currentUser.isNavigationStateRestoreEnabled) { newValue in
                isNavigationRestoreEnabled = newValue
            }
        }
    }

    /// Bridges the profile tab router into `NavigationStack` without letting the view own route state.
    private var pathBinding: Binding<[ProfileRoute]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    /// Applies the toggle optimistically, then restores the previous UI value if persistence fails.
    private var navigationRestoreBinding: Binding<Bool> {
        Binding(
            get: { isNavigationRestoreEnabled },
            set: { newValue in
                let previousValue = isNavigationRestoreEnabled
                isNavigationRestoreEnabled = newValue

                do {
                    try onNavigationRestoreChange(newValue)
                    errorMessage = nil
                } catch {
                    isNavigationRestoreEnabled = previousValue
                    presentNavigationRestoreFailure(error)
                }
            }
        )
    }

    /// Normalizes profile-preference persistence failures through the shared app error pipeline.
    private func presentNavigationRestoreFailure(_ error: Error) {
        Task { @MainActor [errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "updateNavigationRestorePreference",
                    feature: "profile"
                )
            )
            errorMessage = presentation.userMessage
        }
    }

}

/// Top identity summary shown above the account and preferences cards.
private struct ProfileHeaderSection: View {
    let username: String
    let userInitials: String
    let providerTitle: String

    var body: some View {
        VStack(spacing: 16) {
            Circle()
                .fill(AppTheme.surfacePrimary)
                .frame(width: 96, height: 96)
                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 4)
                .overlay(
                    Text(userInitials)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.accent)
                )

            VStack(spacing: 8) {
                Text(username)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(providerTitle)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(AppTheme.surfacePrimary)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
    }
}

/// Read-only account metadata card for the current signed-in profile.
private struct ProfileAccountCard: View {
    let providerTitle: String
    let providerDescription: String
    let accountIDHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileCardTitle(
                title: AppLocalization.text("profile.accountTitle", fallback: "Account")
            )

            ProfileDetailRow(
                title: AppLocalization.text("profile.providerLabel", fallback: "Sign-in method"),
                value: providerTitle
            )

            ProfileDetailRow(
                title: AppLocalization.text("profile.accountIDLabel", fallback: "Account ID"),
                value: accountIDHint
            )

            Text(providerDescription)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// Hosts user preferences that are stored with the signed-in account record.
private struct ProfilePreferencesCard: View {
    @Binding var isNavigationRestoreEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileCardTitle(
                title: AppLocalization.text("profile.preferencesTitle", fallback: "Preferences")
            )

            Toggle(isOn: $isNavigationRestoreEnabled) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(
                        AppLocalization.text(
                            "profile.restoreNavigationTitle",
                            fallback: "Restore previous navigation state"
                        )
                    )
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                    Text(
                        AppLocalization.text(
                            "profile.restoreNavigationDescription",
                            fallback: "Reopen the last visited tab and nested destination after signing in."
                        )
                    )
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(AppTheme.accent)
        }
        .padding(20)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}

/// Session-ending action kept visually separate from informational profile content.
private struct ProfileLogoutButton: View {
    let onLogout: () -> Void

    var body: some View {
        Button(action: onLogout) {
            Text(AppLocalization.text("profile.logout", fallback: "Log out"))
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(AppTheme.accent)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

/// Shared card-section title styling for the profile tab.
private struct ProfileCardTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(AppTheme.textPrimary)
    }
}

/// Small label/value row reused inside profile detail cards.
private struct ProfileDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)

            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(AppTheme.textPrimary)
                .textSelection(.enabled)
        }
    }
}
