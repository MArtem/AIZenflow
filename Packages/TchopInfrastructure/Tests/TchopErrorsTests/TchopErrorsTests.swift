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

    @Test
    func errorManagerReturnsPresentationAndReportsPayload() async {
        let reporter = MemoryAppErrorReporter()
        let manager = AppErrorManager(reporter: reporter)

        let presentation = await manager.presentableError(
            from: APIError.noConnection,
            context: AppErrorContext(
                operation: "refreshFeed",
                feature: "news"
            )
        )

        #expect(presentation.error.category == .network)
        #expect(presentation.userMessage == "No internet connection. Try again when you are back online.")

        let payloads = await reporter.payloads
        #expect(payloads.count == 1)
        #expect(payloads.first?.feature == "news")
        #expect(payloads.first?.operation == "refreshFeed")
    }
}
