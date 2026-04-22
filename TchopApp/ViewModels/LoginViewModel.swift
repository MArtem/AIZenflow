import AuthenticationServices
import Foundation

/// View model backing the simple username-only login screen.
@MainActor
final class LoginViewModel: ObservableObject {
    /// User-entered username value.
    @Published var username = ""

    /// Presentation-ready validation or sign-in error.
    @Published private(set) var errorMessage: String?

    private let onLogin: (String) throws -> Void
    private let onAppleLogin: (AppleSignInSessionProfile) throws -> Void

    /// Creates a login view model.
    init(
        onLogin: @escaping (String) throws -> Void,
        onAppleLogin: @escaping (AppleSignInSessionProfile) throws -> Void
    ) {
        self.onLogin = onLogin
        self.onAppleLogin = onAppleLogin
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
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            errorMessage = AppLocalization.text(
                "login.apple.error.invalidCredential",
                fallback: "Unable to read the Apple sign-in credential."
            )
            return
        }

        do {
            try onAppleLogin(
                AppleSignInSessionProfile(
                    userID: credential.user,
                    displayName: makeDisplayName(from: credential.fullName),
                    email: credential.email
                )
            )
            errorMessage = nil
        } catch {
            errorMessage = AppLocalization.text(
                "login.apple.error.generic",
                fallback: "Unable to sign in with Apple right now."
            )
        }
    }

    /// Handles Apple authorization failures while keeping user-cancelled flows silent.
    private func handleAppleAuthorizationFailure(_ error: Error) {
        if let authorizationError = error as? ASAuthorizationError, authorizationError.code == .canceled {
            errorMessage = nil
            return
        }

        errorMessage = AppLocalization.text(
            "login.apple.error.generic",
            fallback: "Unable to sign in with Apple right now."
        )
    }

    /// Resolves a human-readable display name from Apple credential name components.
    private func makeDisplayName(from components: PersonNameComponents?) -> String? {
        guard let components else {
            return nil
        }

        let formattedName = PersonNameComponentsFormatter().string(from: components)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return formattedName.isEmpty ? nil : formattedName
    }
}
