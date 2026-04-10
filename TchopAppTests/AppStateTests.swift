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
            sessionService: sessionService
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
            sessionService: sessionService
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
            sessionService: sessionService
        )

        state.signOut()

        XCTAssertNil(state.currentUser)
        XCTAssertEqual(coordinator.selectedTab, .news)
        XCTAssertTrue(coordinator.newsRouter.path.isEmpty)
        XCTAssertFalse(shellViewModel.isMenuOpen)
        XCTAssertEqual(sessionService.signOutCallCount, 1)
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
