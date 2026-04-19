import XCTest
@testable import TchopApp

/// Validates login form state and submission behavior.
@MainActor
final class LoginViewModelTests: XCTestCase {
    /// Verifies submit with empty username shows validation error.
    func testSubmitWithEmptyUsernameShowsValidationError() {
        let viewModel = LoginViewModel { _ in }
        viewModel.username = "   "

        viewModel.submit()

        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.emptyUsername", fallback: "Enter a username.")
        )
    }

    /// Verifies submit trims whitespace before login.
    func testSubmitTrimsWhitespaceBeforeLogin() {
        var capturedUsername: String?
        let viewModel = LoginViewModel { username in
            capturedUsername = username
        }
        viewModel.username = "  alice  "

        viewModel.submit()

        XCTAssertEqual(capturedUsername, "alice")
        XCTAssertNil(viewModel.errorMessage)
    }

    /// Verifies submit shows generic error when login fails.
    func testSubmitShowsGenericErrorWhenLoginFails() {
        let viewModel = LoginViewModel { _ in
            throw TestLoginError.failed
        }
        viewModel.username = "alice"

        viewModel.submit()

        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.generic", fallback: "Unable to sign in right now.")
        )
    }
}

private enum TestLoginError: Error {
    case failed
}
