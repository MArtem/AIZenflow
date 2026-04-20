import XCTest

/// Smoke UI coverage for the app root, shell, and news feed entry states.
final class TchopAppUITests: XCTestCase {
    private let launchTimeout: TimeInterval = 15

    /// Verifies unauthenticated launch shows the login screen.
    func testSignedOutLaunchShowsLoginScreen() {
        let application = makeApplication(authenticated: false)

        application.launch()

        XCTAssertTrue(element("login.screen", in: application).waitForExistence(timeout: launchTimeout))
    }

    /// Verifies authenticated launch shows the root shell container.
    func testAuthenticatedLaunchShowsShellScreen() {
        let application = makeApplication(authenticated: true)

        application.launch()

        XCTAssertTrue(element("shell.screen", in: application).waitForExistence(timeout: launchTimeout))
    }

    /// Verifies authenticated launch lands on the news feed baseline.
    func testAuthenticatedLaunchShowsNewsFeed() {
        let application = makeApplication(authenticated: true)

        application.launch()

        XCTAssertTrue(element("news.feed", in: application).waitForExistence(timeout: launchTimeout))
    }

    /// Verifies launch-time deep links can bring an authenticated session directly to the profile tab.
    func testAuthenticatedLaunchWithInitialProfileDeepLinkShowsProfileRoot() {
        let application = makeApplication(
            authenticated: true,
            initialURL: "tchop://profile"
        )

        application.launch()

        XCTAssertTrue(element("profile.root", in: application).waitForExistence(timeout: launchTimeout))
        XCTAssertTrue(element("ui-smoke", in: application).waitForExistence(timeout: launchTimeout))
    }

    /// Creates a configured application instance for UI smoke coverage.
    private func makeApplication(
        authenticated: Bool,
        initialURL: String? = nil
    ) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchEnvironment["TCHOP_UI_TEST_MODE"] = "1"
        application.launchEnvironment["TCHOP_UI_TEST_USERNAME"] = "ui-smoke"

        if authenticated {
            application.launchEnvironment["TCHOP_UI_TEST_AUTHENTICATED"] = "1"
        }

        if let initialURL {
            application.launchEnvironment["TCHOP_UI_TEST_INITIAL_URL"] = initialURL
        }

        return application
    }

    /// Resolves a UI element by accessibility identifier without assuming its element type.
    private func element(_ identifier: String, in application: XCUIApplication) -> XCUIElement {
        application.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
