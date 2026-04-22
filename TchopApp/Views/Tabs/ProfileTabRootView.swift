import SwiftUI
import TchopNavigation

/// Root profile-tab screen bound to its dedicated navigation router.
struct ProfileTabRootView: View {
    let currentUser: AppUser
    @ObservedObject var router: TabRouter<ProfileRoute>
    let onNavigationRestoreChange: (Bool) throws -> Void
    let onLogout: () -> Void
    @State private var isNavigationRestoreEnabled: Bool
    @State private var errorMessage: String?

    init(
        currentUser: AppUser,
        router: TabRouter<ProfileRoute>,
        onNavigationRestoreChange: @escaping (Bool) throws -> Void,
        onLogout: @escaping () -> Void
    ) {
        self.currentUser = currentUser
        self.router = router
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

    private var pathBinding: Binding<[ProfileRoute]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

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
                    errorMessage = AppLocalization.text(
                        "profile.restoreNavigationError",
                        fallback: "Unable to update the restore preference right now."
                    )
                }
            }
        )
    }

}

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

private struct ProfileCardTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.system(size: 18, weight: .bold))
            .foregroundStyle(AppTheme.textPrimary)
    }
}

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
