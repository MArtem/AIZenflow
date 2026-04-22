import SwiftUI
import TchopAppleAuthentication

/// Root switch between authentication flow and authenticated shell.
struct AppRootView: View {
    @ObservedObject var appState: AppState
    let appleAuthenticationManager: any AppleAuthenticationManaging
    let onOpenURL: (URL) -> Void
    let onContinueUserActivity: (NSUserActivity) -> Void

    /// Creates a new AppRootView instance.
    init(
        appState: AppState,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        onOpenURL: @escaping (URL) -> Void = { _ in },
        onContinueUserActivity: @escaping (NSUserActivity) -> Void = { _ in }
    ) {
        self.appState = appState
        self.appleAuthenticationManager = appleAuthenticationManager
        self.onOpenURL = onOpenURL
        self.onContinueUserActivity = onContinueUserActivity
    }

    var body: some View {
        Group {
            if appState.currentUser == nil {
                LoginScreenView(
                    onLogin: appState.signIn,
                    onAppleLogin: appState.signInWithApple(identity:),
                    appleAuthenticationManager: appleAuthenticationManager
                )
                    .accessibilityIdentifier("login.screen")
            } else {
                AppShellView(
                    viewModel: appState.appShellViewModel,
                    coordinator: appState.coordinator,
                    currentUser: appState.currentUser,
                    onLogout: appState.signOut
                )
                .accessibilityIdentifier("shell.screen")
            }
        }
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: onContinueUserActivity)
    }
}
