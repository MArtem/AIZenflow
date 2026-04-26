import AuthenticationServices
import Foundation
import TchopAppleAuthentication
import TchopErrors

/// View model backing the local-username and Apple sign-in screen.
@MainActor
final class LoginViewModel: ObservableObject {
    /// User-entered username value.
    @Published var username = ""

    /// Prevents duplicate submissions while an async sign-in attempt is in flight.
    @Published private(set) var isSubmitting = false

    /// Presentation-ready validation or sign-in error.
    @Published private(set) var errorMessage: String?

    private let onLogin: (String) async throws -> Void
    private let onAppleLogin: (AppleAuthenticationIdentity) async throws -> Void
    private let appleAuthenticationManager: any AppleAuthenticationManaging
    private let errorManager: any AppErrorManaging

    /// Creates a login view model.
    ///
    /// The view model stays intentionally thin: authentication normalization lives in the
    /// Apple-auth package and session ownership lives in AppState.
    init(
        onLogin: @escaping (String) async throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging
    ) {
        self.onLogin = onLogin
        self.onAppleLogin = onAppleLogin
        self.appleAuthenticationManager = appleAuthenticationManager
        self.errorManager = errorManager
    }

    /// Validates the input and attempts to sign in.
    func submit() {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            errorMessage = AppLocalization.text("login.error.emptyUsername", fallback: "Enter a username.")
            return
        }

        guard !isSubmitting else {
            return
        }

        runSignInTask(
            operation: { try await onLogin(normalizedUsername) },
            failureContext: AppErrorContext(
                operation: "usernameLogin",
                feature: "login"
            )
        )
    }

    /// Handles the Sign in with Apple completion result and converts it into the app session payload.
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            handleSuccessfulAppleAuthorization(authorization)
        case let .failure(error):
            handleAppleAuthorizationFailure(error)
        }
    }

    /// Extracts the credential payload and starts the Apple-backed sign-in flow.
    private func handleSuccessfulAppleAuthorization(_ authorization: ASAuthorization) {
        do {
            let identity = try appleAuthenticationManager.identity(from: authorization)
            guard !isSubmitting else {
                return
            }
            runSignInTask(
                operation: { try await onAppleLogin(identity) },
                failureContext: AppErrorContext(
                    operation: "appleLogin",
                    feature: "login"
                )
            )
        } catch AppleAuthenticationError.invalidCredential {
            errorMessage = AppLocalization.text(
                "login.apple.error.invalidCredential",
                fallback: "Unable to read the Apple sign-in credential."
            )
        } catch {
            presentLoginError(
                error,
                context: AppErrorContext(
                    operation: "appleLogin",
                    feature: "login"
                )
            )
        }
    }

    /// Handles Apple authorization failures while keeping user-cancelled flows silent.
    private func handleAppleAuthorizationFailure(_ error: Error) {
        if appleAuthenticationManager.isCancellationError(error) {
            errorMessage = nil
            return
        }

        presentLoginError(
            error,
            context: AppErrorContext(
                operation: "appleAuthorization",
                feature: "login"
            )
        )
    }

    /// Maps and reports login-flow failures through the shared app error manager.
    private func presentLoginError(
        _ error: Error,
        context: AppErrorContext
    ) {
        Task { @MainActor [weak self, errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: context
            )
            self?.errorMessage = presentation.userMessage
        }
    }

    /// Runs a single sign-in operation while keeping the screen responsive and duplicate-safe.
    private func runSignInTask(
        operation: @escaping () async throws -> Void,
        failureContext: AppErrorContext
    ) {
        isSubmitting = true
        errorMessage = nil

        Task { @MainActor [weak self] in
            defer {
                self?.isSubmitting = false
            }

            do {
                try await operation()
                self?.errorMessage = nil
            } catch {
                self?.presentLoginError(error, context: failureContext)
            }
        }
    }
}
