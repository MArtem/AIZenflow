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
