import Foundation
import Testing
import AppErrors
import AppNetworking

/// Verifies default API-error normalization into app-facing error semantics.
struct AppErrorsTests {
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
    func mapsCancelledRequestToNonBlockingClientInfo() {
        let mapper = APIErrorAppErrorMapper()
        let mapped = mapper.map(.requestCancelled)

        #expect(mapped.category == .client)
        #expect(mapped.severity == .info)
        #expect(!mapped.isRetryable)
        #expect(mapped.suggestion == .none)
        #expect(mapped.messageKey == "error.request.cancelled")
    }

    @Test
    func mapsServerStatusCodeToRetryableServerError() {
        let mapper = APIErrorAppErrorMapper()
        let mapped = mapper.map(.invalidStatusCode(503))

        #expect(mapped.category == .server)
        #expect(mapped.severity == .error)
        #expect(mapped.isRetryable)
        #expect(mapped.suggestion == .retry)
        #expect(mapped.messageKey == "error.server.unavailable")
    }

    @Test
    func mapsRichHTTPFailureWithoutExposingCapturedPayload() {
        let mapper = APIErrorAppErrorMapper()
        let mapped = mapper.map(
            APIHTTPFailure(
                statusCode: 503,
                body: Data("secret-body".utf8),
                headers: ["Set-Cookie": "secret-cookie"]
            )
        )

        #expect(mapped.category == .server)
        #expect(mapped.isRetryable)
        #expect(!mapped.debugDescription.contains("secret-body"))
        #expect(!mapped.debugDescription.contains("secret-cookie"))
    }

    @Test
    func defaultMapperRecognizesRichHTTPFailureWithoutExposingCapturedPayload() {
        let mapper = DefaultAppErrorMapper()
        let mapped = mapper.map(
            APIHTTPFailure(
                statusCode: 422,
                body: Data("secret-body".utf8),
                headers: ["Set-Cookie": "secret-cookie"]
            )
        )

        #expect(mapped.category == .client)
        #expect(!mapped.debugDescription.contains("secret-body"))
        #expect(!mapped.debugDescription.contains("secret-cookie"))
    }

    @Test
    func defaultMapperPreservesContextForUnknownErrors() {
        struct UnknownError: Error, CustomStringConvertible {
            let description = "unknown failure"
        }

        let mapper = DefaultAppErrorMapper()
        let context = AppErrorContext(
            operation: "save",
            feature: "composer",
            metadata: ["cardType": "photo"]
        )

        let mapped = mapper.map(UnknownError(), context: context)

        #expect(mapped.category == .unknown)
        #expect(mapped.isRetryable)
        #expect(mapped.context == context)
        #expect(mapped.debugDescription.contains("unknown failure"))
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
