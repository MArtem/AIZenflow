import AuthenticationServices
import Foundation
import TchopAppleAuthentication
import TchopErrors

/// Login screen behavior selected by the active app environment.
enum LoginScreenMode {
    case localUsername
    case reqResDemoExternalAuth
}

/// View model backing both local username auth and the development-only external ReqRes auth flow.
@MainActor
final class LoginViewModel: ObservableObject {
    /// Active login presentation mode selected by the app environment.
    let mode: LoginScreenMode

    /// User-entered username for the local stub flow.
    @Published var username = ""
    /// User-entered email for external credential auth.
    @Published var email = ""
    /// User-entered password for external credential auth.
    @Published var password = ""

    /// Prevents duplicate submissions while an async sign-in attempt is in flight.
    @Published private(set) var isSubmitting = false

    /// Presentation-ready validation or sign-in error.
    @Published private(set) var errorMessage: String?

    private let onCredentialLogin: (String, String) async throws -> Void
    private let onRegister: (String, String) async throws -> Void
    private let onLogin: (String) async throws -> Void
    private let onAppleLogin: (AppleAuthenticationIdentity) async throws -> Void
    private let appleAuthenticationManager: any AppleAuthenticationManaging
    private let errorManager: any AppErrorManaging

    /// Creates a login view model.
    ///
    /// The view model stays intentionally thin:
    /// - environment-specific rendering decisions stay in `mode`
    /// - session ownership stays in `AppState`
    /// - vendor-specific auth transport stays below the view model in `UserSessionService`
    init(
        mode: LoginScreenMode,
        onCredentialLogin: @escaping (String, String) async throws -> Void,
        onRegister: @escaping (String, String) async throws -> Void,
        onLogin: @escaping (String) async throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging
    ) {
        self.mode = mode
        self.onCredentialLogin = onCredentialLogin
        self.onRegister = onRegister
        self.onLogin = onLogin
        self.onAppleLogin = onAppleLogin
        self.appleAuthenticationManager = appleAuthenticationManager
        self.errorManager = errorManager
    }

    /// Validates the input and attempts to sign in.
    func submit() {
        guard mode == .localUsername else {
            return
        }

        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            errorMessage = AppLocalization.text("login.error.emptyUsername", fallback: "Enter a username.")
            return
        }

        guard !isSubmitting else {
            return
        }

        runSignInTask(
            operation: { [self] in
                try await self.onLogin(normalizedUsername)
            },
            failureContext: AppErrorContext(
                operation: "usernameLogin",
                feature: "login"
            )
        )
    }

    /// Validates the external-auth credentials and attempts to sign in.
    func submitCredentialLogin() {
        guard mode == .reqResDemoExternalAuth else {
            return
        }

        let credentials = validatedCredentials()
        guard let credentials else {
            return
        }

        guard !isSubmitting else {
            return
        }

        runSignInTask(
            operation: { [self] in
                try await self.onCredentialLogin(credentials.email, credentials.password)
            },
            failureContext: AppErrorContext(
                operation: "credentialLogin",
                feature: "login"
            )
        )
    }

    /// Validates the external-auth credentials and attempts to register.
    func submitRegistration() {
        guard mode == .reqResDemoExternalAuth else {
            return
        }

        let credentials = validatedCredentials()
        guard let credentials else {
            return
        }

        guard !isSubmitting else {
            return
        }

        runSignInTask(
            operation: { [self] in
                try await self.onRegister(credentials.email, credentials.password)
            },
            failureContext: AppErrorContext(
                operation: "credentialRegistration",
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

    /// Validates the external auth form with the minimum constraints required by ReqRes demo auth.
    private func validatedCredentials() -> (email: String, password: String)? {
        let normalizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedEmail.isEmpty else {
            errorMessage = AppLocalization.text("login.error.emptyEmail", fallback: "Enter an email.")
            return nil
        }

        guard normalizedEmail.contains("@"), normalizedEmail.contains(".") else {
            errorMessage = AppLocalization.text("login.error.invalidEmail", fallback: "Enter a valid email.")
            return nil
        }

        guard !normalizedPassword.isEmpty else {
            errorMessage = AppLocalization.text("login.error.emptyPassword", fallback: "Enter a password.")
            return nil
        }

        return (normalizedEmail, normalizedPassword)
    }

    /// Extracts the credential payload and starts the Apple-backed sign-in flow.
    private func handleSuccessfulAppleAuthorization(_ authorization: ASAuthorization) {
        do {
            let identity = try appleAuthenticationManager.identity(from: authorization)
            guard !isSubmitting else {
                return
            }
            runSignInTask(
                operation: { [self] in
                    try await self.onAppleLogin(identity)
                },
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
