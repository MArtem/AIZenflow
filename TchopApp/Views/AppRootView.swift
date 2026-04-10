import SwiftUI

struct AppRootView: View {
    @ObservedObject var appState: AppState

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
    }
}
