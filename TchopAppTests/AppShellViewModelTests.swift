import XCTest
import TchopUIConfiguration
@testable import TchopApp

@MainActor
final class AppShellViewModelTests: XCTestCase {
    func testShellViewModelAppliesCachedUIConfigurationBeforeRefreshCompletes() async {
        let uiConfigurationManager = TestUIConfigurationManager(
            currentSnapshot: UIConfigurationSnapshot(
                shell: ShellUIConfiguration(showsFloatingActionButton: false)
            ),
            refreshResult: .failure(TestUIConfigurationError.refreshFailed),
            refreshDelayNanoseconds: 200_000_000
        )

        let viewModel = AppShellViewModel(
            contentRepository: TestAppContentRepository(),
            uiConfigurationManager: uiConfigurationManager,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
        )

        await waitUntil(viewModel.showsFloatingActionButton == false)

        XCTAssertFalse(viewModel.showsFloatingActionButton)
    }

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

        let viewModel = AppShellViewModel(
            contentRepository: TestAppContentRepository(),
            uiConfigurationManager: uiConfigurationManager,
            widgetContentSyncManager: NoopWidgetContentSyncManager()
        )

        await waitUntil(viewModel.showsFloatingActionButton == true)

        XCTAssertTrue(viewModel.showsFloatingActionButton)
    }

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
}

private enum TestUIConfigurationError: Error {
    case refreshFailed
}

private actor TestUIConfigurationManager: UIConfigurationManaging {
    private let currentSnapshotValue: UIConfigurationSnapshot
    private let refreshResult: Result<UIConfigurationSnapshot, Error>
    private let refreshDelayNanoseconds: UInt64

    init(
        currentSnapshot: UIConfigurationSnapshot,
        refreshResult: Result<UIConfigurationSnapshot, Error>,
        refreshDelayNanoseconds: UInt64
    ) {
        self.currentSnapshotValue = currentSnapshot
        self.refreshResult = refreshResult
        self.refreshDelayNanoseconds = refreshDelayNanoseconds
    }

    func currentConfiguration() async -> UIConfigurationSnapshot {
        currentSnapshotValue
    }

    func refreshConfiguration() async throws -> UIConfigurationSnapshot {
        if refreshDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshDelayNanoseconds)
        }

        return try refreshResult.get()
    }
}
