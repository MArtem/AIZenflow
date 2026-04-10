import Foundation

/// View model backing the simple username-only login screen.
@MainActor
final class LoginViewModel: ObservableObject {
    /// User-entered username value.
    @Published var username = ""

    /// Presentation-ready validation or sign-in error.
    @Published private(set) var errorMessage: String?

    private let onLogin: (String) throws -> Void

    /// Creates a login view model.
    init(onLogin: @escaping (String) throws -> Void) {
        self.onLogin = onLogin
    }

    /// Validates the input and attempts to sign in.
    func submit() {
        let normalizedUsername = username.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedUsername.isEmpty else {
            errorMessage = "Enter a username."
            return
        }

        do {
            try onLogin(normalizedUsername)
            errorMessage = nil
        } catch {
            errorMessage = "Unable to sign in right now."
        }
    }
}
