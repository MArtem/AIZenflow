import AuthenticationServices
import XCTest
import TchopAppleAuthentication
import TchopErrors
@testable import TchopApp

/// Validates login form state and submission behavior for the credential-first login screen.
@MainActor
final class LoginViewModelTests: XCTestCase {
    func testPasswordVisibilityToggleUpdatesState() {
        let viewModel = makeViewModel()

        viewModel.togglePasswordVisibility()

        XCTAssertTrue(viewModel.isPasswordVisible)

        viewModel.togglePasswordVisibility()

        XCTAssertFalse(viewModel.isPasswordVisible)
    }

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

    func testSubmitWithWeakDefaultPasswordBlocksCredentialLogin() async {
        var didCallCredentialLogin = false
        let viewModel = makeViewModel { _, _ in
            didCallCredentialLogin = true
        }
        viewModel.email = "alice@example.com"
        viewModel.password = "short"

        viewModel.submit()

        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertFalse(didCallCredentialLogin)
        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text(
                "login.error.invalidCredentials",
                fallback: "Check the highlighted fields and try again."
            )
        )
    }

    func testSubmitTrimsWhitespaceBeforeLogin() async {
        var capturedEmail: String?
        var capturedPassword: String?

        let viewModel = makeViewModel { email, password in
            capturedEmail = email
            capturedPassword = password
        }
        viewModel.email = "  alice@example.com  "
        viewModel.password = "Password1"

        viewModel.submit()

        await waitForCredentialCapture { capturedEmail != nil }
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

    func testReqResRegistrationUsesRegisterCallbackWithTrimmedCredentials() async {
        var capturedCredentialLogin: (email: String, password: String)?
        var capturedRegistration: (email: String, password: String)?
        let viewModel = makeViewModel(
            mode: .reqResDemoExternalAuth,
            onCredentialLogin: { email, password in
                capturedCredentialLogin = (email, password)
            },
            onRegister: { email, password in
                capturedRegistration = (email, password)
            }
        )
        viewModel.email = "  eve.holt@reqres.in  "
        viewModel.password = "  pistol  "

        viewModel.submitRegistration()

        await waitForCredentialCapture { capturedRegistration != nil }
        XCTAssertNil(capturedCredentialLogin)
        XCTAssertEqual(capturedRegistration?.email, "eve.holt@reqres.in")
        XCTAssertEqual(capturedRegistration?.password, "pistol")
        XCTAssertNil(viewModel.errorMessage)
    }

    func testDefaultModeIgnoresRegistrationSubmission() async {
        var didRegister = false
        let viewModel = makeViewModel(
            mode: .defaultAppAuth,
            onRegister: { _, _ in
                didRegister = true
            }
        )
        viewModel.email = "alice@example.com"
        viewModel.password = "Password1"

        viewModel.submitRegistration()

        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertFalse(didRegister)
    }

    func testSubmissionThrottleBlocksImmediateSecondSubmit() async {
        var credentialLoginCallCount = 0
        let viewModel = makeViewModel(
            onCredentialLogin: { _, _ in
                credentialLoginCallCount += 1
            },
            submissionThrottleInterval: 60
        )
        viewModel.email = "alice@example.com"
        viewModel.password = "Password1"

        viewModel.submit()
        await waitForCredentialCapture { credentialLoginCallCount == 1 }
        viewModel.submit()

        XCTAssertEqual(credentialLoginCallCount, 1)
        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.throttled", fallback: "Please wait before trying again.")
        )
    }

    func testAppleAuthorizationCancellationKeepsErrorMessageEmpty() async {
        let viewModel = makeViewModel(
            appleAuthenticationManager: TestAppleAuthenticationManager(treatErrorsAsCancellation: true)
        )

        viewModel.handleAppleSignInCompletion(.failure(TestLoginError.failed))

        try? await Task.sleep(for: .milliseconds(50))
        XCTAssertNil(viewModel.errorMessage)
    }

    func testAppleAuthorizationFailureUsesLoginErrorMapping() async {
        let viewModel = makeViewModel()

        viewModel.handleAppleSignInCompletion(.failure(TestLoginError.failed))

        await waitForErrorMessage(in: viewModel)
        XCTAssertEqual(
            viewModel.errorMessage,
            AppLocalization.text("login.error.generic", fallback: "Unable to sign in right now.")
        )
    }

    private func makeViewModel(
        mode: LoginScreenMode = .defaultAppAuth,
        onCredentialLogin: @escaping (String, String) async throws -> Void = { _, _ in },
        onRegister: @escaping (String, String) async throws -> Void = { _, _ in },
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void = { _ in },
        appleAuthenticationManager: any AppleAuthenticationManaging = TestAppleAuthenticationManager(),
        submissionThrottleInterval: TimeInterval = 0
    ) -> LoginViewModel {
        LoginViewModel(
            mode: mode,
            onCredentialLogin: onCredentialLogin,
            onRegister: onRegister,
            onAppleLogin: onAppleLogin,
            appleAuthenticationManager: appleAuthenticationManager,
            errorManager: TestLoginErrorManager(),
            submissionThrottleInterval: submissionThrottleInterval
        )
    }


    private func waitForCredentialCapture(_ isCaptured: @MainActor () -> Bool) async {
        for _ in 0..<500 {
            if isCaptured() {
                return
            }
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    private func waitForErrorMessage(in viewModel: LoginViewModel) async {
        for _ in 0..<500 {
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

private struct TestLoginErrorManager: AppErrorManaging {
    func presentableError(
        from error: Error,
        context: AppErrorContext?
    ) async -> AppErrorPresentation {
        AppErrorPresentation(
            error: AppError(
                category: .unknown,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.unknown",
                debugDescription: String(describing: error),
                context: context
            ),
            userMessage: AppLocalization.text(
                "login.error.generic",
                fallback: "Unable to sign in right now."
            )
        )
    }
}

private struct TestAppleAuthenticationManager: AppleAuthenticationManaging {
    let treatErrorsAsCancellation: Bool

    init(treatErrorsAsCancellation: Bool = false) {
        self.treatErrorsAsCancellation = treatErrorsAsCancellation
    }

    func identity(from authorization: ASAuthorization) throws -> AppleAuthenticationIdentity {
        AppleAuthenticationIdentity(userID: "test-user")
    }

    func isCancellationError(_ error: Error) -> Bool {
        treatErrorsAsCancellation
    }

    func credentialState(for userID: String) async throws -> AppleAuthenticationCredentialState {
        .authorized
    }
}
