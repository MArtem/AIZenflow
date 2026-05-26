import AuthenticationServices
import XCTest
import TchopAppleAuthentication
import TchopErrors
@testable import TchopApp

/// Validates login form state and submission behavior for the credential-first login screen.
@MainActor
final class LoginViewModelTests: XCTestCase {
    func testSubmitWithEmptyEmailShowsValidationError() {
        let viewModel = makeViewModel()
        viewModel.email = "   "
        viewModel.password = "Password1"

        viewModel.submit()

        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text(
                "login.error.invalidCredentials",
                fallback: "Check the highlighted fields and try again."
            )
        )
    }

    func testSubmitTrimsWhitespaceBeforeLogin() {
        let expectation = expectation(description: "credential login called")
        var capturedEmail: String?
        var capturedPassword: String?

        let viewModel = makeViewModel { email, password in
            capturedEmail = email
            capturedPassword = password
            expectation.fulfill()
        }
        viewModel.email = "  alice@example.com  "
        viewModel.password = "Password1"

        viewModel.submit()

        wait(for: [expectation], timeout: 1)
        XCTAssertEqual(capturedEmail, "alice@example.com")
        XCTAssertEqual(capturedPassword, "Password1")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testSubmitShowsGenericErrorWhenLoginFails() async {
        let viewModel = makeViewModel { _, _ in
            throw TestLoginError.failed
        }
        viewModel.email = "alice@example.com"
        viewModel.password = "Password1"

        viewModel.submit()

        await waitForErrorMessage(in: viewModel)
        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.generic", fallback: "Unable to sign in right now.")
        )
    }

    private func makeViewModel(
        onCredentialLogin: @escaping (String, String) async throws -> Void = { _, _ in }
    ) -> LoginViewModel {
        LoginViewModel(
            mode: .defaultAppAuth,
            onCredentialLogin: onCredentialLogin,
            onRegister: { _, _ in },
            onAppleLogin: { _ in },
            appleAuthenticationManager: TestAppleAuthenticationManager(),
            errorManager: AppErrorManager(
                mapper: AppRuntimeErrorMapper(),
                messageCatalog: AppRuntimeErrorMessageCatalog()
            ),
            submissionThrottleInterval: 0
        )
    }

    private func waitForErrorMessage(in viewModel: LoginViewModel) async {
        for _ in 0..<50 {
            if viewModel.errorMessage != nil {
                return
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

}

private enum TestLoginError: Error {
    case failed
}

private struct TestAppleAuthenticationManager: AppleAuthenticationManaging {
    func identity(from authorization: ASAuthorization) throws -> AppleAuthenticationIdentity {
        AppleAuthenticationIdentity(userID: "test-user")
    }

    func isCancellationError(_ error: Error) -> Bool {
        false
    }

    func credentialState(for userID: String) async throws -> AppleAuthenticationCredentialState {
        .authorized
    }
}
