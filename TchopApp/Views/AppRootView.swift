import SwiftUI
import TchopAppleAuthentication
import TchopErrors

/// Root switch between authentication flow and authenticated shell.
struct AppRootView: View {
    @ObservedObject var appState: AppState
    let appleAuthenticationManager: any AppleAuthenticationManaging
    let errorManager: any AppErrorManaging
    let onOpenURL: (URL) -> Void
    let onContinueUserActivity: (NSUserActivity) -> Void

    /// Creates a new AppRootView instance.
    init(
        appState: AppState,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging,
        onOpenURL: @escaping (URL) -> Void = { _ in },
        onContinueUserActivity: @escaping (NSUserActivity) -> Void = { _ in }
    ) {
        self.appState = appState
        self.appleAuthenticationManager = appleAuthenticationManager
        self.errorManager = errorManager
        self.onOpenURL = onOpenURL
        self.onContinueUserActivity = onContinueUserActivity
    }

    var body: some View {
        Group {
            if appState.currentUser == nil {
                LoginScreenView(
                    onLogin: appState.signIn(username:),
                    onAppleLogin: appState.signInWithApple(identity:),
                    appleAuthenticationManager: appleAuthenticationManager,
                    errorManager: errorManager
                )
                    .accessibilityIdentifier("login.screen")
            } else {
                AppShellView(
                    viewModel: appState.appShellViewModel,
                    coordinator: appState.coordinator,
                    errorManager: errorManager,
                    currentUser: appState.currentUser,
                    onNavigationRestoreChange: appState.setNavigationRestoreEnabled,
                    onLogout: appState.signOut
                )
                .accessibilityIdentifier("shell.screen")
            }
        }
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: onContinueUserActivity)
    }
}
