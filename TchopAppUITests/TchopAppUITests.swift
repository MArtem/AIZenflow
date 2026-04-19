import XCTest

/// Smoke UI coverage for the app root, shell, and news feed entry states.
final class TchopAppUITests: XCTestCase {
    /// Verifies unauthenticated launch shows the login screen.
    func testSignedOutLaunchShowsLoginScreen() {
        let application = makeApplication(authenticated: false)

        application.launch()

        XCTAssertTrue(application.otherElements["login.screen"].waitForExistence(timeout: 3))
        XCTAssertTrue(application.textFields["login.usernameField"].exists)
        XCTAssertTrue(application.buttons["login.continueButton"].exists)
    }

    /// Verifies authenticated launch shows the root shell container.
    func testAuthenticatedLaunchShowsShellScreen() {
        let application = makeApplication(authenticated: true)

        application.launch()

        XCTAssertTrue(application.otherElements["shell.screen"].waitForExistence(timeout: 3))
        XCTAssertTrue(application.otherElements["shell.content"].exists)
    }

    /// Verifies authenticated launch lands on the news feed baseline.
    func testAuthenticatedLaunchShowsNewsFeed() {
        let application = makeApplication(authenticated: true)

        application.launch()

        XCTAssertTrue(application.otherElements["news.feed"].waitForExistence(timeout: 3))
    }

    /// Creates a configured application instance for UI smoke coverage.
    private func makeApplication(authenticated: Bool) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchEnvironment["TCHOP_UI_TEST_MODE"] = "1"
        application.launchEnvironment["TCHOP_UI_TEST_USERNAME"] = "ui-smoke"

        if authenticated {
            application.launchEnvironment["TCHOP_UI_TEST_AUTHENTICATED"] = "1"
        }

        return application
    }
}
