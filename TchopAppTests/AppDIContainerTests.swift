import XCTest
@testable import TchopApp

/// Verifies the composition root exposes the expected public runtime surface.
@MainActor
final class AppDIContainerTests: XCTestCase {
    /// Verifies the default container keeps the local stub login mode.
    func testDefaultContainerUsesDefaultAppAuthLoginMode() {
        let container = AppDIContainer(databaseConfiguration: .inMemory)

        XCTAssertEqual(container.loginScreenMode, .defaultAppAuth)
    }

    /// Verifies the external ReqRes auth environment switches the login screen mode.
    func testReqResEnvironmentUsesExternalAuthLoginMode() {
        let container = AppDIContainer(
            databaseConfiguration: .inMemory,
            apiEnvironment: .developmentExternalAuth(reqResAPIKey: "test-key", enablesNetworkLogging: false)
        )

        XCTAssertEqual(container.loginScreenMode, .reqResDemoExternalAuth)
    }

    /// Verifies the composition root can assemble the authenticated shell graph.
    func testContainerBuildsShellAndAppState() {
        let container = AppDIContainer(databaseConfiguration: .inMemory)

        let shellViewModel = container.makeAppShellViewModel()
        let appState = container.makeAppState()

        XCTAssertFalse(shellViewModel.channelsStore.selectionSnapshot.availableChannels.isEmpty)
        XCTAssertNotNil(appState.appShellViewModel)
    }
}
