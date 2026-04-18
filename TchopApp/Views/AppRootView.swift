import SwiftUI

/// Root switch between authentication flow and authenticated shell.
struct AppRootView: View {
    @ObservedObject var appState: AppState
    let onOpenURL: (URL) -> Void
    let onContinueUserActivity: (NSUserActivity) -> Void

    init(
        appState: AppState,
        onOpenURL: @escaping (URL) -> Void = { _ in },
        onContinueUserActivity: @escaping (NSUserActivity) -> Void = { _ in }
    ) {
        self.appState = appState
        self.onOpenURL = onOpenURL
        self.onContinueUserActivity = onContinueUserActivity
    }

    var body: some View {
        Group {
            if appState.currentUser == nil {
                LoginScreenView(onLogin: appState.signIn)
            } else {
                AppShellView(
                    viewModel: appState.appShellViewModel,
                    coordinator: appState.coordinator,
                    currentUser: appState.currentUser,
                    onLogout: appState.signOut
                )
            }
        }
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: onContinueUserActivity)
    }
}
