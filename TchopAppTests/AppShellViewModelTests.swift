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
        timeoutNanoseconds: UInt64 = 1_000_000_000
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
            currentSnapshot: UIConfigurationSnapshot(),
            refreshResult: .success(UIConfigurationSnapshot()),
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
