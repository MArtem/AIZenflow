import XCTest
@testable import TchopApp

/// Validates login form state and submission behavior.
@MainActor
final class LoginViewModelTests: XCTestCase {
    func testSubmitWithEmptyUsernameShowsValidationError() {
        let viewModel = LoginViewModel { _ in }
        viewModel.username = "   "

        viewModel.submit()

        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.emptyUsername", fallback: "Enter a username.")
        )
    }

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
