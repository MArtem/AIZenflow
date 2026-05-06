import Observation
import SwiftUI
import TchopNavigation

/// Root profile-tab screen bound to its dedicated navigation router.
struct ProfileTabRootView: View {
    let viewModel: ProfileTabViewModel
    @Bindable var router: TabRouter<ProfileRoute>
    let onLogout: () -> Void

    var body: some View {
        NavigationStack(path: pathBinding) {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.lg) {
                    ProfileHeaderSection(
                        username: viewModel.accountSummary.displayName,
                        userInitials: viewModel.accountSummary.initials,
                        providerTitle: viewModel.accountSummary.providerTitle
                    )
                    ProfileAccountCard(
                        providerTitle: viewModel.accountSummary.providerTitle,
                        providerDescription: viewModel.accountSummary.providerDescription,
                        accountIDHint: viewModel.accountSummary.accountIDHint
                    )
                    ProfilePreferencesCard(
                        isNavigationRestoreEnabled: Binding(
                            get: { viewModel.isNavigationRestoreEnabled },
                            set: { viewModel.setNavigationRestoreEnabled($0) }
                        )
                    )
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.destructive.opacity(0.85))
                    }
                    ProfileLogoutButton(onLogout: onLogout)
                }
                .padding(.horizontal, AppSpacing.cardPadding)
                .padding(.top, AppSpacing.profileTopInset)
                .padding(.bottom, AppSpacing.shellBottomInset)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            .background(Color.clear)
            .accessibilityIdentifier("profile.root")
        }
    }

    /// Bridges the profile tab router into `NavigationStack` without letting the view own route state.
    private var pathBinding: Binding<[ProfileRoute]> {
        $router.path
    }
}

/// Top identity summary shown above the account and preferences cards.
private struct ProfileHeaderSection: View {
    let username: String
    let userInitials: String
    let providerTitle: String

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            Circle()
                .fill(AppTheme.surfacePrimary)
                .frame(width: 96, height: 96)
                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 4)
                .overlay(
                    Text(userInitials)
                        .font(AppTypography.featureDisplay)
                        .foregroundStyle(AppTheme.accent)
                )

            VStack(spacing: AppSpacing.xs) {
                Text(username)
                    .font(AppTypography.profileDisplay)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(providerTitle)
                    .font(AppTypography.detailSemibold)
                    .foregroundStyle(AppTheme.accent)
                    .padding(.horizontal, AppSpacing.sm)
                    .padding(.vertical, 6)
                    .background(AppTheme.surfacePrimary)
                    .clipShape(Capsule())
            }
            .frame(maxWidth: .infinity)
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .combine)
    }
}

#if DEBUG
#Preview("Profile Tab Root") {
    ProfileTabRootView(
        viewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        router: TabRouter<ProfileRoute>(),
        onLogout: {}
    )
}
#endif

/// Read-only account metadata card for the current signed-in profile.
private struct ProfileAccountCard: View {
    let providerTitle: String
    let providerDescription: String
    let accountIDHint: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileCardTitle(
                title: AppLocalization.text("profile.accountTitle")
            )

            ProfileDetailRow(
                title: AppLocalization.text("profile.providerLabel"),
                value: providerTitle
            )

            ProfileDetailRow(
                title: AppLocalization.text("profile.accountIDLabel"),
                value: accountIDHint
            )

            Text(providerDescription)
                .font(AppTypography.detail)
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(AppSpacing.cardPadding)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

/// Hosts user preferences that are stored with the signed-in account record.
private struct ProfilePreferencesCard: View {
    @Binding var isNavigationRestoreEnabled: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            ProfileCardTitle(
                title: AppLocalization.text("profile.preferencesTitle")
            )

            Toggle(isOn: $isNavigationRestoreEnabled) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(AppLocalization.text("profile.restoreNavigationTitle"))
                    .font(AppTypography.actionTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                    Text(AppLocalization.text("profile.restoreNavigationDescription"))
                    .font(AppTypography.detail)
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .tint(AppTheme.accent)
            .accessibilityHint(AppLocalization.text("accessibility.profile.restoreNavigationHint"))
        }
        .padding(AppSpacing.cardPadding)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }
}

/// Session-ending action kept visually separate from informational profile content.
private struct ProfileLogoutButton: View {
    let onLogout: () -> Void

    var body: some View {
        Button(action: onLogout) {
            Text(AppLocalization.text("profile.logout"))
                .font(AppTypography.actionTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(AppTheme.accent)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.prominentButton, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(AppLocalization.text("accessibility.profile.logoutHint"))
    }
}

/// Shared card-section title styling for the profile tab.
private struct ProfileCardTitle: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppTypography.cardTitleBold)
            .foregroundStyle(AppTheme.textPrimary)
    }
}

/// Small label/value row reused inside profile detail cards.
private struct ProfileDetailRow: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xxs) {
            Text(title)
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textTertiary)

            Text(value)
                .font(AppTypography.body)
                .foregroundStyle(AppTheme.textPrimary)
                .textSelection(.enabled)
        }
    }
}
