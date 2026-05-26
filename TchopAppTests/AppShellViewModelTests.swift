import XCTest
import TchopErrors
import TchopUIConfiguration
@testable import TchopApp

@MainActor
/// Verifies shell state, bottom chrome, and UI configuration behavior.
final class AppShellViewModelTests: XCTestCase {
    /// Verifies shell view model applies cached uiconfiguration before refresh completes.
    func testShellViewModelAppliesCachedUIConfigurationBeforeRefreshCompletes() async {
        let uiConfigurationManager = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(
                shell: ShellUIConfiguration(showsFloatingActionButton: false)
            ),
            refreshResult: .failure(TestUIConfigurationError.refreshFailed),
            refreshDelayNanoseconds: 200_000_000
        )

        let viewModel = makeShellViewModel(uiConfigurationManager: uiConfigurationManager)

        await waitUntil(viewModel.showsFloatingActionButton == false)

        XCTAssertFalse(viewModel.showsFloatingActionButton)
    }

    /// Verifies shell view model applies refreshed uiconfiguration when fetch succeeds.
    func testShellViewModelAppliesRefreshedUIConfigurationWhenFetchSucceeds() async {
        let uiConfigurationManager = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(
                shell: ShellUIConfiguration(showsFloatingActionButton: false)
            ),
            refreshResult: .success(
                UIConfigurationSnapshot(
                    shell: ShellUIConfiguration(showsFloatingActionButton: true)
                )
            ),
            refreshDelayNanoseconds: 0
        )

        let viewModel = makeShellViewModel(uiConfigurationManager: uiConfigurationManager)

        await waitUntil(viewModel.showsFloatingActionButton == true)

        XCTAssertTrue(viewModel.showsFloatingActionButton)
    }

    /// Verifies shell only changes the near-top flag when the feed reports a real threshold transition.
    func testSetNewsFeedNearTopUpdatesShellState() {
        let viewModel = makeShellViewModel()

        viewModel.setNewsFeedNearTop(false)
        XCTAssertFalse(viewModel.isNewsFeedNearTop)

        viewModel.setNewsFeedNearTop(true)
        XCTAssertTrue(viewModel.isNewsFeedNearTop)
    }

    /// Waits until until.
    private func waitUntil(
        _ condition: @autoclosure () -> Bool,
        timeoutNanoseconds: UInt64 = 3_000_000_000
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTFail("Timed out waiting for condition")
    }

    /// Creates a shell view model with local feed runtime dependencies.
    private func makeShellViewModel(
        uiConfigurationManager: any UIConfigurationManaging = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(shell: ShellUIConfiguration(showsFloatingActionButton: true)),
            refreshResult: .success(UIConfigurationSnapshot(shell: ShellUIConfiguration(showsFloatingActionButton: true))),
            refreshDelayNanoseconds: 0
        )
    ) -> AppShellViewModel {
        let channelsStore = makeTestChannelsStore()
        let feedCardStore = makeTestFeedCardStore()
        let newsFeedViewModel = NewsFeedViewModel(
            channelsStore: channelsStore,
            widgetContentSyncManager: NoopWidgetContentSyncManager(),
            errorManager: AppErrorManager(),
            feedCardStore: feedCardStore
        )

        return AppShellViewModel(
            channelsStore: channelsStore,
            feedCardStore: feedCardStore,
            newsFeedViewModel: newsFeedViewModel,
            errorManager: AppErrorManager(),
            uiConfigurationManager: uiConfigurationManager
        )
    }
}

/// Verifies profile-tab preference state and optimistic rollback behavior.
@MainActor
final class ProfileTabViewModelTests: XCTestCase {
    /// Verifies profile view model syncs updated user snapshots into presentation state.
    func testSyncCurrentUserUpdatesAccountSummaryAndPreference() {
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(id: "user-1", username: "alice", createdAt: Date(timeIntervalSince1970: 1)),
            errorManager: AppErrorManager(),
            onNavigationRestoreChange: { _ in }
        )

        viewModel.syncCurrentUser(
            AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            )
        )

        XCTAssertEqual(viewModel.accountSummary.displayName, "alice")
        XCTAssertFalse(viewModel.isNavigationRestoreEnabled)
    }

    /// Verifies preference update success keeps optimistic state and clears stale errors.
    func testSetNavigationRestoreEnabledPersistsOptimisticStateOnSuccess() {
        var receivedValue: Bool?
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            ),
            errorManager: AppErrorManager(),
            onNavigationRestoreChange: { receivedValue = $0 }
        )

        viewModel.setNavigationRestoreEnabled(true)

        XCTAssertEqual(receivedValue, true)
        XCTAssertTrue(viewModel.isNavigationRestoreEnabled)
        XCTAssertNil(viewModel.errorMessage)
    }

    /// Verifies failed preference persistence rolls back optimistic state and presents an error.
    func testSetNavigationRestoreEnabledRollsBackOnFailure() async {
        let viewModel = ProfileTabViewModel(
            currentUser: AppUser(
                id: "user-1",
                username: "alice",
                createdAt: Date(timeIntervalSince1970: 1),
                isNavigationStateRestoreEnabled: false
            ),
            errorManager: ProfileTestErrorManager(),
            onNavigationRestoreChange: { _ in throw ProfileTestError.persistenceFailed }
        )

        viewModel.setNavigationRestoreEnabled(true)
        await waitUntil(viewModel.errorMessage != nil)

        XCTAssertFalse(viewModel.isNavigationRestoreEnabled)
        XCTAssertNotNil(viewModel.errorMessage)
    }

    /// Waits until an async UI-state side effect is visible.
    private func waitUntil(
        _ condition: @autoclosure () -> Bool,
        timeoutNanoseconds: UInt64 = 3_000_000_000
    ) async {
        let deadline = DispatchTime.now().uptimeNanoseconds + timeoutNanoseconds

        while DispatchTime.now().uptimeNanoseconds < deadline {
            if condition() {
                return
            }

            try? await Task.sleep(nanoseconds: 20_000_000)
        }

        XCTFail("Timed out waiting for condition")
    }
}

private enum ProfileTestError: Error {
    case persistenceFailed
}

private struct ProfileTestErrorManager: AppErrorManaging {
    func presentableError(
        from error: Error,
        context: AppErrorContext?
    ) async -> AppErrorPresentation {
        AppErrorPresentation(
            error: AppError(
                category: .persistence,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "profile.test.error",
                debugDescription: String(describing: error),
                context: context
            ),
            userMessage: "Profile preference update failed"
        )
    }
}
