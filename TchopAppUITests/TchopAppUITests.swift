import XCTest

/// Smoke UI coverage for the app root, shell, and news feed entry states.
final class TchopAppUITests: XCTestCase {
    private let launchTimeout: TimeInterval = 15
    private let reqResEmail = "eve.holt@reqres.in"
    private let reqResPassword = "pistol"

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

    /// Verifies the ReqRes-backed registration flow can be exercised end-to-end from the login UI.
    func testReqResRegistrationFlowShowsShellScreen() {
        let application = makeApplication(
            authenticated: false,
            environment: [
                "TCHOP_API_ENV": "reqres_demo_auth",
                "TCHOP_NETWORK_LOGGING": "1"
            ]
        )

        application.launch()

        XCTAssertTrue(element("login.screen", in: application).waitForExistence(timeout: launchTimeout))

        let emailField = element("login.emailField", in: application)
        XCTAssertTrue(emailField.waitForExistence(timeout: launchTimeout))
        emailField.tap()
        emailField.typeText(reqResEmail)

        let passwordVisibilityButton = element("login.passwordVisibilityButton", in: application)
        XCTAssertTrue(passwordVisibilityButton.waitForExistence(timeout: launchTimeout))
        passwordVisibilityButton.tap()
        XCTAssertEqual(passwordVisibilityButton.label, "Hide password")

        let passwordField = application.textFields.matching(identifier: "login.passwordField").firstMatch
        XCTAssertTrue(passwordField.waitForExistence(timeout: launchTimeout))
        passwordField.tap()
        passwordField.typeText(reqResPassword)
        XCTAssertEqual(passwordField.value as? String, reqResPassword)

        let registerButton = element("login.reqresRegisterButton", in: application)
        XCTAssertTrue(registerButton.waitForExistence(timeout: launchTimeout))
        registerButton.tap()

        XCTAssertTrue(element("shell.screen", in: application).waitForExistence(timeout: 20))
    }

    /// Creates a configured application instance for UI smoke coverage.
    private func makeApplication(
        authenticated: Bool,
        initialURL: String? = nil,
        environment: [String: String] = [:]
    ) -> XCUIApplication {
        let application = XCUIApplication()
        application.launchEnvironment["TCHOP_UI_TEST_MODE"] = "1"
        application.launchEnvironment["TCHOP_UI_TEST_USERNAME"] = "ui-smoke"
        environment.forEach { key, value in
            application.launchEnvironment[key] = value
        }

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
