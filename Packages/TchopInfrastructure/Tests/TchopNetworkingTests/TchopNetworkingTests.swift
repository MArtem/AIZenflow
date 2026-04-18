import XCTest
@testable import TchopNetworking

final class TchopNetworkingTests: XCTestCase {
    func testMockManagerReturnsStubbedValue() async throws {
        let manager = MockAPIManager()
        let request = APIRequest<String>(
            path: "feed",
            stubResponse: { "ok" }
        )

        let response = try await manager.perform(request)

        XCTAssertEqual(response, "ok")
    }

    func testCancellationTokenCancelsRequest() async {
        let manager = APIManager(configuration: .stub)
        let token = APICancellationToken()
        await token.cancel()

        let request = APIRequest<String>(
            path: "feed",
            stubResponse: {
                try await Task.sleep(nanoseconds: 50_000_000)
                return "ok"
            }
        )

        do {
            _ = try await manager.perform(request, cancellationToken: token)
            XCTFail("Expected request cancellation")
        } catch let error as APIError {
            XCTAssertEqual(error, .requestCancelled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAuthenticationInterceptorInjectsHeaders() async throws {
        let interceptor = APIAuthenticationInterceptor(
            provider: TestAuthenticationProvider(headers: ["Authorization": "Bearer token"])
        )
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let preparedRequest = try await interceptor.prepare(request)

        XCTAssertEqual(preparedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    func testOfflineQueueDrainsOnlyWhenConnected() async {
        let queue = APIOfflineRequestQueue()
        let recorder = InvocationRecorder()

        await queue.enqueue {
            await recorder.recordInvocation()
        }

        await queue.drainIfConnected(using: StaticConnectivityProvider(connected: false))
        let afterDisconnectedDrain = await recorder.invocationCount
        XCTAssertEqual(afterDisconnectedDrain, 0)

        await queue.drainIfConnected(using: StaticConnectivityProvider(connected: true))
        let afterConnectedDrain = await recorder.invocationCount
        let remainingOperations = await queue.pendingRequestCount

        XCTAssertEqual(afterConnectedDrain, 1)
        XCTAssertEqual(remainingOperations, 0)
    }

    func testMockManagerDownloadWritesStubbedData() async throws {
        let manager = MockAPIManager()
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        let request = APIRequest<Data>(
            path: "download",
            stubResponse: { Data("payload".utf8) }
        )

        let fileURL = try await manager.download(
            request,
            destinationURL: destinationURL,
            progressHandler: nil
        )

        let data = try Data(contentsOf: fileURL)
        XCTAssertEqual(String(decoding: data, as: UTF8.self), "payload")
    }

    func testAuthorizationRefreshInterceptorRefreshesAndRetriesRequest() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.requestHandler = { request in
            let token = request.value(forHTTPHeaderField: "Authorization")
            if token == "Bearer old-token" {
                return (
                    HTTPURLResponse(url: request.url!, statusCode: 401, httpVersion: nil, headerFields: nil)!,
                    Data()
                )
            }

            return (
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                Data(#"{"value":"ok"}"#.utf8)
            )
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: sessionConfiguration)

        let authProvider = RefreshingTestAuthenticationProvider(
            initialHeaders: ["Authorization": "Bearer old-token"],
            refreshedHeaders: ["Authorization": "Bearer new-token"]
        )
        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [
                APIAuthenticationInterceptor(provider: authProvider),
                APIAuthorizationRefreshInterceptor(provider: authProvider)
            ]
        )

        struct ResponseModel: Decodable, Sendable, Equatable {
            let value: String
        }

        let response = try await manager.perform(
            APIRequest<ResponseModel>.json(
                path: "resource",
                jsonDecoder: JSONDecoder()
            )
        )

        XCTAssertEqual(response, ResponseModel(value: "ok"))
        let requests = URLProtocolStub.observedRequests
        XCTAssertEqual(requests.count, 2)
        XCTAssertEqual(requests.first?.value(forHTTPHeaderField: "Authorization"), "Bearer old-token")
        XCTAssertEqual(requests.last?.value(forHTTPHeaderField: "Authorization"), "Bearer new-token")
    }

    func testRequestAllowsCustomValidStatusCodes() async throws {
        URLProtocolStub.reset()
        URLProtocolStub.requestHandler = { request in
            (
                HTTPURLResponse(url: request.url!, statusCode: 404, httpVersion: nil, headerFields: nil)!,
                Data()
            )
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: sessionConfiguration)

        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session
        )

        let response = try await manager.perform(
            APIRequest<APIEmptyResponse>(
                path: "no-content",
                responseParser: { _, _ in APIEmptyResponse() },
                validStatusCodes: 400 ..< 500
            )
        )

        XCTAssertEqual(response, APIEmptyResponse())
    }

    func testAPIManagerUsesCustomErrorMapperForNonAPIErrors() async {
        struct SyntheticError: Error {}

        let manager = APIManager(
            configuration: .stub,
            errorMapper: StaticErrorMapper(error: .transportFailure("mapped-error"))
        )
        let request = APIRequest<String>(
            path: "mapper",
            stubResponse: { throw SyntheticError() }
        )

        do {
            _ = try await manager.perform(request)
            XCTFail("Expected mapped API error")
        } catch let error as APIError {
            XCTAssertEqual(error, .transportFailure("mapped-error"))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testAPIManagerUsesRetryContextSurface() async throws {
        URLProtocolStub.reset()
        var responseCounter = 0
        URLProtocolStub.requestHandler = { request in
            responseCounter += 1
            let index = responseCounter
            if index == 1 {
                return (
                    HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data()
                )
            }

            return (
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                Data(#"{"value":"ok"}"#.utf8)
            )
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: sessionConfiguration)

        let contextRecorder = RetryContextRecorder()
        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [
                ContextDrivenRetryInterceptor(
                    recorder: contextRecorder
                )
            ]
        )

        struct ResponseModel: Decodable, Sendable, Equatable {
            let value: String
        }

        let response = try await manager.perform(
            APIRequest<ResponseModel>.json(path: "resource")
        )

        XCTAssertEqual(response, ResponseModel(value: "ok"))
        let contexts = await contextRecorder.contexts
        XCTAssertEqual(contexts.count, 1)
        XCTAssertEqual(contexts.first?.error, .invalidStatusCode(500))
        XCTAssertEqual(contexts.first?.attempt, 0)
    }

    func testAPIManagerEmitsRetryScheduledForInvalidStatusCodeBranch() async throws {
        URLProtocolStub.reset()
        var responseCounter = 0
        URLProtocolStub.requestHandler = { request in
            responseCounter += 1
            if responseCounter == 1 {
                return (
                    HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!,
                    Data()
                )
            }

            return (
                HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!,
                Data(#"{"value":"ok"}"#.utf8)
            )
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: sessionConfiguration)
        let collector = TestMetricsCollector()

        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [
                APIMetricsInterceptor(collector: collector),
                RetryOnFirst500Interceptor()
            ]
        )

        struct ResponseModel: Decodable, Sendable, Equatable {
            let value: String
        }

        let response = try await manager.perform(
            APIRequest<ResponseModel>.json(path: "resource")
        )
        XCTAssertEqual(response, ResponseModel(value: "ok"))

        let events = await collector.events
        XCTAssertTrue(
            events.contains { event in
                if case let .retryScheduled(error, attempt, _, _) = event {
                    return error == .invalidStatusCode(500) && attempt == 0
                }
                return false
            }
        )
    }

    func testPersistedOfflineQueueStoresAndReloadsEntries() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL)
        )
        try await queue.enqueue(payload: "first")
        try await queue.enqueue(payload: "second")

        let reloadedQueue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL)
        )
        let pendingCount = await reloadedQueue.pendingCount

        XCTAssertEqual(pendingCount, 2)
    }

    func testPersistedOfflineQueueDrainsOnlyWhenConnected() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL)
        )
        let recorder = InvocationRecorder()

        try await queue.enqueue(payload: "payload")

        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: false),
            execute: { _ in
                await recorder.recordInvocation()
            }
        )
        let disconnectedInvocationCount = await recorder.invocationCount
        let disconnectedPendingCount = await queue.pendingCount
        XCTAssertEqual(disconnectedInvocationCount, 0)
        XCTAssertEqual(disconnectedPendingCount, 1)

        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { _ in
                await recorder.recordInvocation()
            }
        )

        let connectedInvocationCount = await recorder.invocationCount
        let connectedPendingCount = await queue.pendingCount
        XCTAssertEqual(connectedInvocationCount, 1)
        XCTAssertEqual(connectedPendingCount, 0)
    }

    func testPersistedOfflineQueueMovesFailedEntriesToDeadLetters() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL),
            configuration: APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.Configuration(maxAttempts: 2)
        )

        try await queue.enqueue(payload: "will-fail")

        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { _ in throw APIError.transportFailure("failure") }
        )
        let firstDrainPendingCount = await queue.pendingCount
        let firstDrainDeadLetterCount = await queue.deadLetters.count
        XCTAssertEqual(firstDrainPendingCount, 1)
        XCTAssertEqual(firstDrainDeadLetterCount, 0)

        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { _ in throw APIError.transportFailure("failure") }
        )

        let finalPendingCount = await queue.pendingCount
        let finalDeadLetters = await queue.deadLetters
        XCTAssertEqual(finalPendingCount, 0)
        XCTAssertEqual(finalDeadLetters.count, 1)
        XCTAssertEqual(finalDeadLetters.first?.attempts, 2)
    }

    func testPersistedOfflineQueueDoesNotDropEntriesEnqueuedDuringDrain() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL)
        )
        let control = DrainExecutionControl()
        let recorder = InvocationRecorder()

        try await queue.enqueue(payload: "first")

        let drainTask = Task {
            try await queue.drainIfConnected(
                using: StaticConnectivityProvider(connected: true),
                execute: { payload in
                    await recorder.recordPayload(payload)
                    await control.signalStartedAndWaitForResume()
                }
            )
        }

        await control.waitUntilStarted()
        try await queue.enqueue(payload: "second")
        await control.resume()
        try await drainTask.value

        let pendingAfterDrain = await queue.pendingCount
        let executedPayloads = await recorder.payloads
        XCTAssertEqual(pendingAfterDrain, 1)
        XCTAssertEqual(executedPayloads, ["first"])

        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { payload in
                await recorder.recordPayload(payload)
            }
        )

        let finalPendingCount = await queue.pendingCount
        let finalExecutedPayloads = await recorder.payloads
        XCTAssertEqual(finalPendingCount, 0)
        XCTAssertEqual(finalExecutedPayloads, ["first", "second"])
    }

    func testPersistedOfflineQueueReloadsDeadLetters() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL),
            configuration: APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.Configuration(maxAttempts: 1)
        )

        try await queue.enqueue(payload: "dead-letter")
        try await queue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { _ in throw APIError.transportFailure("failure") }
        )

        let reloadedQueue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL),
            configuration: APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.Configuration(maxAttempts: 1)
        )

        let reloadedPendingCount = await reloadedQueue.pendingCount
        let reloadedDeadLetters = await reloadedQueue.deadLetters
        XCTAssertEqual(reloadedPendingCount, 0)
        XCTAssertEqual(reloadedDeadLetters.count, 1)
        XCTAssertEqual(reloadedDeadLetters.first?.payload, "dead-letter")
    }

    func testPersistedOfflineQueueDrainReportAndSnapshotExposeDiagnostics() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: fileURL),
            configuration: APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.Configuration(maxAttempts: 2)
        )

        try await queue.enqueue(payload: "ok", createdAt: Date(timeIntervalSince1970: 10))
        try await queue.enqueue(payload: "fail", createdAt: Date(timeIntervalSince1970: 20))

        let firstReport = try await queue.drainWithReportIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { payload in
                if payload == "fail" {
                    throw APIError.transportFailure("failure")
                }
            }
        )

        XCTAssertEqual(
            firstReport,
            APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.DrainReport(
                skippedDueToNoConnectivity: false,
                attempted: 2,
                succeeded: 1,
                failed: 1,
                retried: 1,
                movedToDeadLetters: 0
            )
        )

        let snapshotAfterFirstDrain = await queue.makeSnapshot()
        XCTAssertEqual(snapshotAfterFirstDrain.pendingCount, 1)
        XCTAssertEqual(snapshotAfterFirstDrain.deadLetterCount, 0)
        XCTAssertNotNil(snapshotAfterFirstDrain.oldestPendingCreatedAt)

        let secondReport = try await queue.drainWithReportIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { _ in
                throw APIError.transportFailure("failure")
            }
        )
        XCTAssertEqual(secondReport.movedToDeadLetters, 1)

        let finalSnapshot = await queue.makeSnapshot()
        XCTAssertEqual(finalSnapshot.pendingCount, 0)
        XCTAssertEqual(finalSnapshot.deadLetterCount, 1)
        XCTAssertNotNil(finalSnapshot.oldestDeadLetterCreatedAt)
    }

    func testMetricsInterceptorCapturesLifecycleEvents() async throws {
        let collector = TestMetricsCollector()
        let interceptor = APIMetricsInterceptor(collector: collector)
        let request = URLRequest(url: URL(string: "https://example.com/resource")!)

        _ = try await interceptor.prepare(request)
        await interceptor.didReceive(
            result: .success(
                (
                    Data("ok".utf8),
                    HTTPURLResponse(
                        url: request.url!,
                        statusCode: 200,
                        httpVersion: nil,
                        headerFields: nil
                    )!
                )
            ),
            request: request
        )
        await interceptor.didReceive(
            result: .failure(.timeout),
            request: request
        )
        await interceptor.didScheduleRetry(
            for: .timeout,
            attempt: 1,
            delayNanoseconds: 250_000_000,
            request: request
        )

        let events = await collector.events
        XCTAssertEqual(events.count, 4)
        XCTAssertEqual(
            events[0],
            .requestPrepared(
                method: "GET",
                url: "https://example.com/resource"
            )
        )
        XCTAssertEqual(
            events[1],
            .requestSucceeded(
                statusCode: 200,
                bytes: 2,
                url: "https://example.com/resource"
            )
        )
        XCTAssertEqual(
            events[2],
            .requestFailed(
                error: .timeout,
                url: "https://example.com/resource"
            )
        )
        XCTAssertEqual(
            events[3],
            .retryScheduled(
                error: .timeout,
                attempt: 1,
                delayNanoseconds: 250_000_000,
                url: "https://example.com/resource"
            )
        )
    }

    func testLoggingInterceptorRedactsSensitiveHeadersAndQueryValues() async throws {
        let logs = LogRecorder()
        let interceptor = APILoggingInterceptor(
            level: .requestAndResponse,
            logger: { message in
                Task { await logs.append(message) }
            }
        )

        var request = URLRequest(
            url: URL(string: "https://example.com/feed?token=super-secret&query=swift")!
        )
        request.setValue("Bearer secret-token", forHTTPHeaderField: "Authorization")
        request.setValue("trace-123", forHTTPHeaderField: "X-Trace-Id")

        _ = try await interceptor.prepare(request)
        await interceptor.didReceive(
            result: .failure(.timeout),
            request: request
        )

        // Allow detached log tasks to flush into the recorder actor.
        try await Task.sleep(nanoseconds: 10_000_000)

        let joined = await logs.joined()
        XCTAssertFalse(joined.contains("super-secret"))
        XCTAssertFalse(joined.contains("secret-token"))
        XCTAssertTrue(joined.contains("token=%3Credacted%3E"))
        XCTAssertTrue(joined.contains("Authorization=<redacted>"))
        XCTAssertTrue(joined.contains("X-Trace-Id=trace-123"))
    }

    func testFileOfflineQueueStoreRecoversFromCorruptedPayloadWhenPolicyIsRecoverToEmpty() async throws {
        let fileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: fileURL) }

        try Data("not-json".utf8).write(to: fileURL, options: .atomic)

        let queue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(
                fileURL: fileURL,
                corruptionPolicy: .recoverToEmpty
            )
        )

        let pendingCount = await queue.pendingCount
        let snapshot = await queue.makeSnapshot()
        XCTAssertEqual(pendingCount, 0)
        XCTAssertEqual(snapshot.pendingCount, 0)
    }

    func testFileOfflineQueueStoreRecoverToEmptyDoesNotMaskNonDecodingReadErrors() throws {
        let directoryURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-dir-\(UUID().uuidString)")
        defer { try? FileManager.default.removeItem(at: directoryURL) }
        try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true)

        let store = FileAPIOfflineQueueStore<String>(
            fileURL: directoryURL,
            corruptionPolicy: .recoverToEmpty
        )

        XCTAssertThrowsError(try store.loadEntries())
    }

    func testPersistedOfflineQueueCanExportAndImportDiagnosticsPayload() async throws {
        let sourceFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: sourceFileURL) }

        let sourceQueue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: sourceFileURL),
            configuration: APIPersistedOfflineQueue<FileAPIOfflineQueueStore<String>>.Configuration(maxAttempts: 1)
        )
        try await sourceQueue.enqueue(payload: "pending")
        try await sourceQueue.enqueue(payload: "dead-candidate")
        try await sourceQueue.drainIfConnected(
            using: StaticConnectivityProvider(connected: true),
            execute: { payload in
                if payload == "dead-candidate" {
                    throw APIError.transportFailure("fail")
                }
            }
        )

        let payload = await sourceQueue.exportDiagnosticsPayload()

        let targetFileURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("offline-queue-\(UUID().uuidString).json")
        defer { removeOfflineQueueArtifacts(at: targetFileURL) }
        let targetQueue = try APIPersistedOfflineQueue(
            store: FileAPIOfflineQueueStore<String>(fileURL: targetFileURL)
        )

        try await targetQueue.importDiagnosticsPayload(payload, strategy: .replace)

        let targetPending = await targetQueue.pendingCount
        let targetDeadLetters = await targetQueue.deadLetters
        XCTAssertEqual(targetPending, payload.pendingEntries.count)
        XCTAssertEqual(targetDeadLetters.count, payload.deadLetterEntries.count)
    }
}

private struct TestAuthenticationProvider: APIAuthenticationProviding {
    let headers: [String: String]

    func authorizationHeaders() async throws -> [String: String] {
        headers
    }
}

private actor InvocationRecorder {
    private(set) var invocationCount = 0
    private(set) var payloads: [String] = []

    func recordInvocation() {
        invocationCount += 1
    }

    func recordPayload(_ payload: String) {
        invocationCount += 1
        payloads.append(payload)
    }
}

private actor TestMetricsCollector: APIMetricsCollecting {
    private(set) var events: [APIMetricsEvent] = []

    func record(_ event: APIMetricsEvent) async {
        events.append(event)
    }
}

private struct StaticErrorMapper: APIErrorMapping {
    let error: APIError

    func map(_ error: Error) -> APIError {
        self.error
    }
}

private actor RetryContextRecorder {
    private(set) var contexts: [APIRetryContext] = []

    func record(_ context: APIRetryContext) {
        contexts.append(context)
    }
}

private actor LogRecorder {
    private var values: [String] = []

    func append(_ value: String) {
        values.append(value)
    }

    func joined() -> String {
        values.joined(separator: "\n")
    }
}

private struct ContextDrivenRetryInterceptor: APIRequestIntercepting {
    let recorder: RetryContextRecorder

    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective {
        await recorder.record(context)
        if context.attempt == 0, case .invalidStatusCode(500) = context.error {
            return .retry(afterNanoseconds: 0)
        }
        return .doNotRetry
    }

    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        .doNotRetry
    }
}

private struct RetryOnFirst500Interceptor: APIRequestIntercepting {
    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective {
        if context.attempt == 0, context.error == .invalidStatusCode(500) {
            return .retry(afterNanoseconds: 0)
        }
        return .doNotRetry
    }
}

private actor DrainExecutionControl {
    private var hasStarted = false
    private var startedContinuation: CheckedContinuation<Void, Never>?
    private var resumeContinuation: CheckedContinuation<Void, Never>?

    func waitUntilStarted() async {
        if hasStarted {
            return
        }
        await withCheckedContinuation { continuation in
            startedContinuation = continuation
        }
    }

    func signalStartedAndWaitForResume() async {
        if !hasStarted {
            hasStarted = true
            startedContinuation?.resume()
            startedContinuation = nil
        }

        await withCheckedContinuation { continuation in
            resumeContinuation = continuation
        }
    }

    func resume() {
        resumeContinuation?.resume()
        resumeContinuation = nil
    }
}

private func removeOfflineQueueArtifacts(at fileURL: URL) {
    try? FileManager.default.removeItem(at: fileURL)
    let deadLetterURL = fileURL.deletingPathExtension()
        .appendingPathExtension("deadletters")
        .appendingPathExtension(fileURL.pathExtension.isEmpty ? "json" : fileURL.pathExtension)
    try? FileManager.default.removeItem(at: deadLetterURL)
}

private actor RefreshingTestAuthenticationProvider: APIAuthenticationRefreshing {
    private var headers: [String: String]
    private let refreshedHeaders: [String: String]

    init(initialHeaders: [String: String], refreshedHeaders: [String: String]) {
        self.headers = initialHeaders
        self.refreshedHeaders = refreshedHeaders
    }

    func authorizationHeaders() async throws -> [String: String] {
        headers
    }

    func refreshAuthorizationHeaders() async throws -> [String: String] {
        headers = refreshedHeaders
        return headers
    }
}

private final class URLProtocolStub: URLProtocol {
    static var requestHandler: ((URLRequest) throws -> (HTTPURLResponse, Data))?
    static var observedRequests: [URLRequest] = []

    static func reset() {
        requestHandler = nil
        observedRequests = []
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        guard let handler = URLProtocolStub.requestHandler else {
            client?.urlProtocol(self, didFailWithError: APIError.transportFailure("Missing request handler"))
            return
        }

        do {
            URLProtocolStub.observedRequests.append(request)
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}
