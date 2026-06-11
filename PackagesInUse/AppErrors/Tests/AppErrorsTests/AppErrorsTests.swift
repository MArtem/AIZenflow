import Testing
@testable import AppErrors

struct AppErrorsTests {
    @Test
    func unknownMapperProducesRetryableUnknownError() {
        let mapper = UnknownAppErrorMapper()
        let mapped = mapper.map(SampleError.failure, context: .init(operation: "load", feature: "demo"))

        #expect(mapped.category == .unknown)
        #expect(mapped.severity == .error)
        #expect(mapped.suggestion == .retry)
        #expect(mapped.isRetryable)
        #expect(mapped.context?.operation == "load")
    }

    @Test
    func managerReportsAndLocalizesMappedError() async {
        let reporter = MemoryAppErrorReporter()
        let manager = AppErrorManager(reporter: reporter)

        let presentation = await manager.presentableError(
            from: SampleError.failure,
            context: .init(operation: "refresh", feature: "feed")
        )

        #expect(presentation.error.category == .unknown)
        #expect(presentation.userMessage == "Something went wrong. Please try again.")

        let payloads = await reporter.payloads
        #expect(payloads.count == 1)
        #expect(payloads.first?.operation == "refresh")
    }

    @Test
    func presentationUsesInjectedMessageCatalog() async {
        let manager = AppErrorManager(messageCatalog: StaticCatalog())

        let presentation = await manager.presentableError(from: SampleError.failure, context: nil)

        #expect(presentation.userMessage == "Custom message")
    }
}

private enum SampleError: Error {
    case failure
}

private struct StaticCatalog: AppErrorMessageCatalog {
    func userMessage(for error: AppError) -> String {
        "Custom message"
    }
}
