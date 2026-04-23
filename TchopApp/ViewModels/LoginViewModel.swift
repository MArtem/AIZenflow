import AuthenticationServices
import Foundation
import TchopAppleAuthentication

/// View model backing the local-username and Apple sign-in screen.
@MainActor
final class LoginViewModel: ObservableObject {
    /// User-entered username value.
    @Published var username = ""

    /// Presentation-ready validation or sign-in error.
    @Published private(set) var errorMessage: String?

    private let onLogin: (String) throws -> Void
    private let onAppleLogin: (AppleAuthenticationIdentity) throws -> Void
    private let appleAuthenticationManager: any AppleAuthenticationManaging

    /// Creates a login view model.
    ///
    /// The view model stays intentionally thin: authentication normalization lives in the
    /// Apple-auth package and session ownership lives in AppState.
    init(
        onLogin: @escaping (String) throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging
    ) {
        self.onLogin = onLogin
        self.onAppleLogin = onAppleLogin
        self.appleAuthenticationManager = appleAuthenticationManager
    }

    /// Validates the input and attempts to sign in.
    func submit() {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            errorMessage = AppLocalization.text("login.error.emptyUsername", fallback: "Enter a username.")
            return
        }

        do {
            try onLogin(normalizedUsername)
            errorMessage = nil
        } catch {
            errorMessage = AppLocalization.text("login.error.generic", fallback: "Unable to sign in right now.")
        }
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
            try onAppleLogin(appleAuthenticationManager.identity(from: authorization))
            errorMessage = nil
        } catch AppleAuthenticationError.invalidCredential {
            errorMessage = AppLocalization.text(
                "login.apple.error.invalidCredential",
                fallback: "Unable to read the Apple sign-in credential."
            )
        } catch {
            errorMessage = AppLocalization.text(
                "login.apple.error.generic",
                fallback: "Unable to sign in with Apple right now."
            )
        }
    }

    /// Handles Apple authorization failures while keeping user-cancelled flows silent.
    private func handleAppleAuthorizationFailure(_ error: Error) {
        if appleAuthenticationManager.isCancellationError(error) {
            errorMessage = nil
            return
        }

        errorMessage = AppLocalization.text(
            "login.apple.error.generic",
            fallback: "Unable to sign in with Apple right now."
        )
    }
}
