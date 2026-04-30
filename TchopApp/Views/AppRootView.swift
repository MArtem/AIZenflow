import SwiftUI
import TchopAppleAuthentication
import TchopErrors

/// Root switch between authentication flow and authenticated shell.
struct AppRootView: View {
    @ObservedObject var appState: AppState
    /// Login UI contract selected by the active app environment.
    let loginScreenMode: LoginScreenMode
    let appleAuthenticationManager: any AppleAuthenticationManaging
    let errorManager: any AppErrorManaging
    let onOpenURL: (URL) -> Void
    let onContinueUserActivity: (NSUserActivity) -> Void

    /// Creates a new AppRootView instance.
    init(
        appState: AppState,
        loginScreenMode: LoginScreenMode,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging,
        onOpenURL: @escaping (URL) -> Void = { _ in },
        onContinueUserActivity: @escaping (NSUserActivity) -> Void = { _ in }
    ) {
        self.appState = appState
        self.loginScreenMode = loginScreenMode
        self.appleAuthenticationManager = appleAuthenticationManager
        self.errorManager = errorManager
        self.onOpenURL = onOpenURL
        self.onContinueUserActivity = onContinueUserActivity
    }

    var body: some View {
        Group {
            switch appState.sessionState {
            case .restoring:
                rootLoadingView
                    .accessibilityIdentifier("app.restoring")
            case .signedOut:
                LoginScreenView(
                    mode: loginScreenMode,
                    onCredentialLogin: appState.signIn(email:password:),
                    onRegister: appState.register(email:password:),
                    onAppleLogin: appState.signInWithApple(identity:),
                    appleAuthenticationManager: appleAuthenticationManager,
                    errorManager: errorManager
                )
                .accessibilityIdentifier("login.screen")
            case let .authenticated(currentUser):
                AppShellView(
                    viewModel: appState.appShellViewModel,
                    coordinator: appState.coordinator,
                    errorManager: errorManager,
                    currentUser: currentUser,
                    onNavigationRestoreChange: appState.setNavigationRestoreEnabled,
                    onLogout: appState.signOut
                )
                .accessibilityIdentifier("shell.screen")
            }
        }
        .onOpenURL(perform: onOpenURL)
        .onContinueUserActivity(NSUserActivityTypeBrowsingWeb, perform: onContinueUserActivity)
    }

    /// Lightweight restoring state shown while the app resolves any persisted authenticated session.
    private var rootLoadingView: some View {
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
enum ViewPreviewSupport {
    static let sampleUser = AppUser(
        id: "preview-user-001",
        username: "Alex Morgan",
        createdAt: Date(),
        isNavigationStateRestoreEnabled: true
    )

    static let sampleChannelInfo = ChannelHeaderInfo(
        title: "Tchop",
        subtitle: "Editorial"
    )

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

    static var sampleFeaturedArticle: FeaturedArticleCardModel {
        for card in NewsFeedFixtures.fallbackContent.cards {
            if case let .featuredArticle(article) = card {
                return article
            }
        }

        fatalError("Missing featured article preview fixture.")
    }

    static var sampleDiscussion: DiscussionCardModel {
        for card in NewsFeedFixtures.fallbackContent.cards {
            if case let .discussion(discussion) = card {
                return discussion
            }
        }

        fatalError("Missing discussion preview fixture.")
    }

    static func makeLocalContainer() -> AppDIContainer {
        AppDIContainer(
            databaseConfiguration: .inMemory,
            apiEnvironment: .localStub,
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
        makeLocalContainer().makeAppState()
    }

    static func makeNewsFeedViewModel() -> NewsFeedViewModel {
        makeLocalContainer().makeAppShellViewModel().newsFeedViewModel
    }

    static func makeShellViewModel() -> AppShellViewModel {
        makeLocalContainer().makeAppShellViewModel()
    }
}

#Preview("App Root - Signed Out") {
    let container = ViewPreviewSupport.makeLocalContainer()
    let appState = container.makeAppState()
    appState.setPreviewSessionState(.signedOut)

    return AppRootView(
        appState: appState,
        loginScreenMode: container.loginScreenMode,
        appleAuthenticationManager: container.appleAuthenticationManager,
        errorManager: container.errorManager
    )
}

#Preview("App Root - Restoring") {
    let container = ViewPreviewSupport.makeLocalContainer()
    let appState = container.makeAppState()
    appState.setPreviewSessionState(.restoring)

    return AppRootView(
        appState: appState,
        loginScreenMode: container.loginScreenMode,
        appleAuthenticationManager: container.appleAuthenticationManager,
        errorManager: container.errorManager
    )
}
#endif
