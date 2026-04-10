import SwiftUI

struct ProfileTabRootView: View {
    let currentUser: AppUser
    @ObservedObject var router: TabRouter<ProfileRoute>
    let onLogout: () -> Void

    var body: some View {
        NavigationStack(path: pathBinding) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                Circle()
                    .fill(Color.white)
                    .frame(width: 96, height: 96)
                    .shadow(color: .black.opacity(0.05), radius: 10, y: 4)
                    .overlay(
                        Text(userInitials)
                            .font(.system(size: 30, weight: .bold))
                            .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))
                    )

                VStack(spacing: 8) {
                    Text(currentUser.username)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color(red: 0.24, green: 0.25, blue: 0.36))

                    Text("Signed in locally with SwiftData-backed user persistence.")
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(.gray)
                        .multilineTextAlignment(.center)
                }

                Button(action: openProfileDetails) {
                    Text("Open profile details")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color(red: 0.95, green: 0.50, blue: 0.37))
                        .clipShape(Capsule())
                }
                .buttonStyle(.plain)

                Button(action: onLogout) {
                    Text("Log out")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(Color(red: 0.95, green: 0.50, blue: 0.37))
                        .padding(.horizontal, 18)
                        .padding(.vertical, 12)
                        .background(Color.white)
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
                title: "Profile Details",
                description: "This profile screen belongs to the profile router. Logging out resets app state and returns to the login screen."
            )
        )
    }
}
