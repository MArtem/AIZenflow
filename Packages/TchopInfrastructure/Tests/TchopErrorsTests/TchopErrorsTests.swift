import Testing
import TchopErrors
import TchopNetworking

/// Verifies default API-error normalization into app-facing error semantics.
struct TchopErrorsTests {
    @Test
    func mapsUnauthorizedToSessionRecoveryError() {
        let mapper = APIErrorAppErrorMapper()
        let mapped = mapper.map(.invalidStatusCode(401))

        #expect(mapped.category == .authentication)
        #expect(mapped.isSessionRecoveryRequired)
        #expect(!mapped.isRetryable)
        #expect(mapped.suggestion == .reauthenticate)
    }

    @Test
    func mapsOfflineErrorToRetryableNetworkError() {
        let mapper = APIErrorAppErrorMapper()
        let mapped = mapper.map(.noConnection)

        #expect(mapped.category == .network)
        #expect(mapped.isRetryable)
        #expect(mapped.suggestion == .checkConnection)
    }

    @Test
    func defaultCatalogProvidesStableFallbackMessage() {
        let catalog = DefaultAppErrorMessageCatalog()
        let message = catalog.userMessage(
            for: AppError(
                category: .unknown,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.unknown",
                debugDescription: "unknown"
            )
        )

        #expect(message == "Something went wrong. Please try again.")
    }
}
