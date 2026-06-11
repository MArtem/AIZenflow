import AuthenticationServices
import Testing
import AppAppleAuthentication

/// Verifies Apple authentication normalization that does not require live Apple services.
struct AppAppleAuthenticationTests {
    @Test
    func identityPreferredUsernameUsesDisplayNameBeforeEmailPrefix() {
        let displayNameIdentity = AppleAuthenticationIdentity(
            userID: "apple-user",
            displayName: "Artem User",
            email: "artem@example.com"
        )
        let emailOnlyIdentity = AppleAuthenticationIdentity(
            userID: "apple-user",
            email: "fallback@example.com"
        )
        let emptyIdentity = AppleAuthenticationIdentity(userID: "apple-user")

        #expect(displayNameIdentity.preferredUsername == "Artem User")
        #expect(emailOnlyIdentity.preferredUsername == "fallback")
        #expect(emptyIdentity.preferredUsername == nil)
    }

    @Test
    func cancellationDetectionOnlyAcceptsAppleCanceledErrors() {
        let manager = AppleAuthenticationManager()
        let cancelledError = ASAuthorizationError(.canceled)
        let failedError = ASAuthorizationError(.failed)
        struct NonAppleError: Error {}

        #expect(manager.isCancellationError(cancelledError))
        #expect(!manager.isCancellationError(failedError))
        #expect(!manager.isCancellationError(NonAppleError()))
    }
}
