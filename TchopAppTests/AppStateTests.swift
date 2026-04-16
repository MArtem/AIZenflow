import XCTest
@testable import TchopApp

@MainActor
final class AppStateTests: XCTestCase {
    func testSignInUpdatesCurrentUser() throws {
        let expectedUser = AppUser(id: "user-1", username: "alice", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .success(expectedUser),
            restoreResult: .success(nil)
        )
        let coordinator = AppCoordinator()
        let shellViewModel = AppShellViewModel(contentRepository: TestAppContentRepository())
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: shellViewModel,
            sessionService: sessionService,
            userRepository: TestUserRepository(user: expectedUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager()
        )

        try state.signIn(username: "alice")

        XCTAssertEqual(state.currentUser, expectedUser)
    }

    func testInitRestoresPersistedSession() {
        let restoredUser = AppUser(id: "user-2", username: "restored", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .failure(TestSessionError.signInUnavailable),
            restoreResult: .success(restoredUser)
        )
        let state = AppState(
            coordinator: AppCoordinator(),
            appShellViewModel: AppShellViewModel(contentRepository: TestAppContentRepository()),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager()
        )

        XCTAssertEqual(state.currentUser, restoredUser)
    }

    func testSignOutClearsUserAndResetsShellState() {
        let restoredUser = AppUser(id: "user-3", username: "signed-in", createdAt: Date())
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator()
        coordinator.selectTab(.profile)
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "news-detail",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )

        let shellViewModel = AppShellViewModel(contentRepository: TestAppContentRepository(), isMenuOpen: true)
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: shellViewModel,
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: TestNavigationStateManager(),
            deepLinkManager: TestDeepLinkManager()
        )

        state.signOut()

        XCTAssertNil(state.currentUser)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertFalse(shellViewModel.isMenuOpen)
        XCTAssertEqual(sessionService.signOutCallCount, 1)
    }

    func testInitRestoresNavigationSnapshotWhenFlagEnabled() {
        let restoredUser = AppUser(
            id: "user-snapshot-enabled",
            username: "snapshot-on",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .chat,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [ChatRoute(title: "Room", description: "From snapshot")],
            profilePath: []
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator()

        _ = AppState(
            coordinator: coordinator,
            appShellViewModel: AppShellViewModel(contentRepository: TestAppContentRepository()),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager()
        )

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    func testInitDoesNotRestoreSnapshotWhenFlagDisabled() {
        let restoredUser = AppUser(
            id: "user-snapshot-disabled",
            username: "snapshot-off",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: false
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Saved", description: "Saved")]
        )
        let stateManager = TestNavigationStateManager(seed: [restoredUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(restoredUser),
            restoreResult: .success(restoredUser)
        )
        let coordinator = AppCoordinator(selectedTab: .mixes)

        _ = AppState(
            coordinator: coordinator,
            appShellViewModel: AppShellViewModel(contentRepository: TestAppContentRepository()),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: restoredUser),
            navigationStateManager: stateManager,
            deepLinkManager: TestDeepLinkManager()
        )

        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }

    func testSignInPrioritizesPendingDeepLinkOverSnapshotRestore() throws {
        let signedInUser = AppUser(
            id: "user-priority",
            username: "priority-user",
            createdAt: Date(),
            isNavigationStateRestoreEnabled: true
        )
        let snapshot = NavigationSnapshot(
            selectedTab: .profile,
            newsPath: [],
            mixesPath: [],
            pinnedPath: [],
            chatPath: [],
            profilePath: [ProfileRoute(title: "Snapshot", description: "Should be skipped")]
        )
        let stateManager = TestNavigationStateManager(seed: [signedInUser.id: snapshot])
        let sessionService = TestUserSessionService(
            signInResult: .success(signedInUser),
            restoreResult: .success(nil)
        )
        let coordinator = AppCoordinator()
        let state = AppState(
            coordinator: coordinator,
            appShellViewModel: AppShellViewModel(contentRepository: TestAppContentRepository()),
            sessionService: sessionService,
            userRepository: TestUserRepository(user: signedInUser),
            navigationStateManager: stateManager,
            deepLinkManager: DeepLinkManager()
        )

        XCTAssertTrue(state.handleIncomingURL(URL(string: "tchop://chat?title=Support&description=Urgent")!))

        try state.signIn(username: signedInUser.username)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.chatRouter.path.first?.title, "Support")
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
    }
}

@MainActor
private final class TestUserSessionService: UserSessionManaging {
    private let signInResult: Result<AppUser, Error>
    private let restoreResult: Result<AppUser?, Error>

    private(set) var signOutCallCount = 0

    init(
        signInResult: Result<AppUser, Error>,
        restoreResult: Result<AppUser?, Error>
    ) {
        self.signInResult = signInResult
        self.restoreResult = restoreResult
    }

    func signIn(username: String) throws -> AppUser {
        try signInResult.get()
    }

    func restoreSession() throws -> AppUser? {
        try restoreResult.get()
    }

    func signOut() {
        signOutCallCount += 1
    }
}

private enum TestSessionError: Error {
    case signInUnavailable
}

@MainActor
private final class TestUserRepository: UserRepository {
    private let user: AppUser

    init(user: AppUser) {
        self.user = user
    }

    func findUser(username: String) throws -> AppUser? {
        user.username == username ? user : nil
    }

    func findOrCreateUser(username: String) throws -> AppUser {
        user
    }

    func updateNavigationStateRestoreEnabled(
        userID: String,
        isEnabled: Bool
    ) throws -> AppUser {
        AppUser(
            id: user.id,
            username: user.username,
            createdAt: user.createdAt,
            isNavigationStateRestoreEnabled: isEnabled
        )
    }
}

@MainActor
private final class TestNavigationStateManager: NavigationStateManaging {
    private var snapshots: [String: NavigationSnapshot] = [:]
    private(set) var clearCallCount = 0

    init(seed: [String: NavigationSnapshot] = [:]) {
        self.snapshots = seed
    }

    func saveSnapshot(_ snapshot: NavigationSnapshot, for userID: String) {
        snapshots[userID] = snapshot
    }

    func restoreSnapshot(for userID: String) -> NavigationSnapshot? {
        snapshots[userID]
    }

    func clearSnapshot(for userID: String) {
        clearCallCount += 1
        snapshots[userID] = nil
    }
}

@MainActor
private final class TestDeepLinkManager: DeepLinkManaging {
    func handle(url: URL, coordinator: AppCoordinator) -> Bool {
        false
    }

    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool {
        false
    }
}

@MainActor
final class TabRouterTests: XCTestCase {
    func testPushAppendRouteToPath() {
        let router = TabRouter<NewsRoute>()

        router.push(
            NewsRoute(
                destinationID: "article-1",
                title: "Article",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )

        XCTAssertEqual(router.path.count, 1)
    }

    func testPopRemovesLastRouteOnly() {
        let router = TabRouter<NewsRoute>()
        let firstRoute = NewsRoute(
            destinationID: "article-1",
            title: "First",
            subtitle: "Subtitle",
            bodyText: "Body"
        )
        let secondRoute = NewsRoute(
            destinationID: "article-2",
            title: "Second",
            subtitle: "Subtitle",
            bodyText: "Body"
        )

        router.replacePath(with: [firstRoute, secondRoute])
        router.pop()

        XCTAssertEqual(router.path, [firstRoute])
    }

    func testPopToRootClearsEntirePath() {
        let router = TabRouter<MixesRoute>()
        router.replacePath(
            with: [
                MixesRoute(title: "One", description: "First"),
                MixesRoute(title: "Two", description: "Second")
            ]
        )

        router.popToRoot()

        XCTAssertTrue(router.path.isEmpty)
    }
}

@MainActor
final class AppCoordinatorTests: XCTestCase {
    func testSelectTabDoesNotResetOtherTabPaths() {
        let coordinator = AppCoordinator()
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "article-1",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )
        coordinator.chatRouter.push(
            ChatRoute(title: "Chat", description: "Room")
        )

        coordinator.selectTab(.chat)

        XCTAssertEqual(coordinator.selectedTab, .chat)
        XCTAssertEqual(coordinator.newsRouter.path.count, 1)
        XCTAssertEqual(coordinator.chatRouter.path.count, 1)
    }

    func testResetAllNavigationClearsEveryTabPath() {
        let coordinator = AppCoordinator(selectedTab: .profile)
        coordinator.newsRouter.push(
            NewsRoute(
                destinationID: "article-1",
                title: "News",
                subtitle: "Subtitle",
                bodyText: "Body"
            )
        )
        coordinator.mixesRouter.push(MixesRoute(title: "Mix", description: "Mix"))
        coordinator.pinnedRouter.push(PinnedRoute(title: "Pinned", description: "Pinned"))
        coordinator.chatRouter.push(ChatRoute(title: "Chat", description: "Chat"))
        coordinator.profileRouter.push(ProfileRoute(title: "Profile", description: "Profile"))

        coordinator.resetAllNavigation()

        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertTrue(coordinator.mixesRouter.path.isEmpty)
        XCTAssertTrue(coordinator.pinnedRouter.path.isEmpty)
        XCTAssertTrue(coordinator.chatRouter.path.isEmpty)
        XCTAssertTrue(coordinator.profileRouter.path.isEmpty)
        XCTAssertEqual(coordinator.selectedTab, .profile)
    }
}

@MainActor
final class DeepLinkManagerTests: XCTestCase {
    func testCustomSchemeDiscussionLinkRoutesToNewsDiscussion() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "tchop://news/discussion?title=Debate&subtitle=12+joined&body=Body")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertEqual(coordinator.newsRouter.path.first?.destinationID, "discussion-details")
        XCTAssertEqual(coordinator.newsRouter.path.first?.title, "Debate")
    }

    func testUniversalLinkRoutesToProfileDetail() {
        let coordinator = AppCoordinator()
        let manager = DeepLinkManager()

        let handled = manager.handle(
            url: URL(string: "https://example.com/profile?title=Settings&description=Manage+profile")!,
            coordinator: coordinator
        )

        XCTAssertTrue(handled)
        XCTAssertEqual(coordinator.selectedTab, .profile)
        XCTAssertEqual(coordinator.profileRouter.path.first?.title, "Settings")
    }
}
