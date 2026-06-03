import SwiftUI
import AppAppleAuthentication
import AppErrors

/// Root switch between authentication flow and authenticated shell.
struct AppRootView: View {
    let appState: AppState
    let loginViewModel: LoginViewModel
    let onOpenURL: (URL) -> Void
    let onContinueUserActivity: (NSUserActivity) -> Void

    /// Creates a new AppRootView instance.
    init(
        appState: AppState,
        loginViewModel: LoginViewModel,
        onOpenURL: @escaping (URL) -> Void = { _ in },
        onContinueUserActivity: @escaping (NSUserActivity) -> Void = { _ in }
    ) {
        self.appState = appState
        self.loginViewModel = loginViewModel
        self.onOpenURL = onOpenURL
        self.onContinueUserActivity = onContinueUserActivity
    }

    var body: some View {
        Group {
            sessionContent
        }
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: onContinueUserActivity)
    }

    @ViewBuilder
    private var sessionContent: some View {
        switch appState.sessionState {
        case .restoring:
            AppRootLoadingView()
                .accessibilityIdentifier("app.restoring")
        case .signedOut:
            LoginScreenView(
                viewModel: loginViewModel
            )
            .accessibilityIdentifier("login.screen")
        case let .authenticated(currentUser):
            AppShellView(
                viewModel: appState.appShellViewModel,
                coordinator: appState.coordinator,
                currentUser: currentUser,
                profileTabViewModel: appState.profileTabViewModel,
                onLogout: appState.signOut
            )
            .accessibilityIdentifier("shell.screen")
        }
    }

}

/// Lightweight restoring state shown while the app resolves any persisted authenticated session.
private struct AppRootLoadingView: View {
    var body: some View {
        VStack(spacing: 14) {
            ProgressView()
                .controlSize(.large)

            Text(AppLocalization.text("app.session.restoring.title"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text(AppLocalization.text("app.session.restoring.subtitle"))
                .font(AppTypography.detail)
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal, 32)
        .background(AppTheme.canvasBackground.ignoresSafeArea())
    }
}

#if DEBUG
@MainActor
/// Debug-only sample data used by SwiftUI previews.
enum ViewPreviewSupport {
    static let sampleUser = AppUser(
        id: "preview-user-001",
        username: "Alex Morgan",
        createdAt: Date(),
        isNavigationStateRestoreEnabled: true
    )

    static let sampleChannelInfo = ChannelHeaderInfo(
        title: AppChannel.defaultChannel.title,
        subtitle: AppChannel.defaultChannel.subtitle
    )

    static let sampleChannels: [AppChannel] = [
        .product,
        .community,
        .leadership
    ]

    static let sampleNewsRoute = NewsRoute(
        destinationID: "preview-news",
        title: "Preview Article",
        subtitle: "Our Blog",
        bodyText: "Preview body content for a destination screen.",
        accentLabel: "See translation"
    )

    static let sampleMixesRoute = MixesRoute(
        title: "Daily Briefing",
        description: "Preview destination for the mixes tab."
    )

    static let sampleAccountSummary = AccountProfileSummary(user: sampleUser)

    static func makePreviewContainer() -> AppDIContainer {
        AppDIContainer(
            databaseConfiguration: .inMemory,
            apiEnvironment: .developmentStub,
            isUITesting: true
        )
    }

    static func makeErrorManager() -> any AppErrorManaging {
        AppErrorManager(
            mapper: AppRuntimeErrorMapper(),
            messageCatalog: AppRuntimeErrorMessageCatalog()
        )
    }

    static func makeAppleAuthenticationManager() -> any AppleAuthenticationManaging {
        AppleAuthenticationManager()
    }

    static func makeCoordinator(selectedTab: AppTab = .news) -> AppCoordinator {
        AppCoordinator(selectedTab: selectedTab)
    }

    static func makeAppState() -> AppState {
        makePreviewContainer().makeAppState()
    }

    static func makeNewsFeedViewModel() -> NewsFeedViewModel {
        makePreviewContainer().makeAppShellViewModel().newsFeedViewModel
    }

    static func makeShellViewModel() -> AppShellViewModel {
        makePreviewContainer().makeAppShellViewModel()
    }

    static func makeLoginViewModel(mode: LoginScreenMode = .defaultAppAuth) -> LoginViewModel {
        LoginViewModel(
            mode: mode,
            onCredentialLogin: { _, _ in },
            onRegister: { _, _ in },
            onAppleLogin: { _ in },
            appleAuthenticationManager: makeAppleAuthenticationManager(),
            errorManager: makeErrorManager()
        )
    }

    static func makeProfileTabViewModel(currentUser: AppUser) -> ProfileTabViewModel {
        ProfileTabViewModel(
            currentUser: currentUser,
            errorManager: makeErrorManager(),
            onNavigationRestoreChange: { _ in }
        )
    }
}

#Preview("App Root - Signed Out") {
    let container = ViewPreviewSupport.makePreviewContainer()
    let appState = container.makeAppState()
    appState.setPreviewSessionState(.signedOut)

    return AppRootView(
        appState: appState,
        loginViewModel: ViewPreviewSupport.makeLoginViewModel(mode: container.loginScreenMode)
    )
}

#Preview("App Root - Restoring") {
    let container = ViewPreviewSupport.makePreviewContainer()
    let appState = container.makeAppState()
    appState.setPreviewSessionState(.restoring)

    return AppRootView(
        appState: appState,
        loginViewModel: ViewPreviewSupport.makeLoginViewModel(mode: container.loginScreenMode)
    )
}
#endif
