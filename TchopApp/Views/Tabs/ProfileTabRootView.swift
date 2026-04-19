import SwiftUI
import TchopNavigation

/// Root profile-tab screen bound to its dedicated navigation router.
struct ProfileTabRootView: View {
    let currentUser: AppUser
    @ObservedObject var router: TabRouter<ProfileRoute>
    let onLogout: () -> Void

    var body: some View {
        NavigationStack(path: pathBinding) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

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
                    Text(currentUser.username)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(
                        AppLocalization.text(
                            "profile.signedInHint",
                            fallback: "Signed in locally with SwiftData-backed user persistence."
                        )
                    )
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textTertiary)
                        .multilineTextAlignment(.center)
                }

                Button(action: openProfileDetails) {
                    Text(AppLocalization.text("profile.openDetails", fallback: "Open profile details"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(AppTheme.accent)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onLogout) {
                    Text(AppLocalization.text("profile.logout", fallback: "Log out"))
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(AppTheme.surfacePrimary)
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, 32)
            .padding(.bottom, 120)
            .background(Color.clear)
            .navigationDestination(for: ProfileRoute.self) { route in
                StubTabDetailView(
                    title: route.title,
                    description: route.description
                )
            }
        }
    }

    private var pathBinding: Binding<[ProfileRoute]> {
        Binding(
            get: { router.path },
            set: { router.replacePath(with: $0) }
        )
    }

    private var userInitials: String {
        let parts = currentUser.username.split(separator: " ")
        let letters = parts.prefix(2).compactMap { $0.first }
        let value = String(letters)
        return value.isEmpty ? "U" : value.uppercased()
    }

    private func openProfileDetails() {
        router.push(
            ProfileRoute(
                title: AppLocalization.text("profile.detailsTitle", fallback: "Profile Details"),
                description: AppLocalization.text(
                    "profile.detailsDescription",
                    fallback: "This profile screen belongs to the profile router. Logging out resets app state and returns to the login screen."
                )
            )
        )
    }
}
