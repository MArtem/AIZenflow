import XCTest
@testable import TchopNetworking

/// Validates networking client behavior, retry logic, and offline queue durability.
final class TchopNetworkingTests: XCTestCase {
    /// Verifies mock manager returns stubbed value.
    func testMockManagerReturnsStubbedValue() async throws {
        let manager = MockAPIManager()
        let request = APIRequest<String>(
            path: "feed",
            stubResponse: { "ok" }
        )

        let response = try await manager.perform(request)

        XCTAssertEqual(response, "ok")
    }

    /// Verifies cancellation token cancels request.
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

    /// Verifies caller-owned Swift task cancellation remains the primary cancellation mechanism.
    func testTaskCancellationCancelsRequest() async {
        let manager = APIManager(configuration: .stub)
        let request = APIRequest<String>(
            path: "feed",
            stubResponse: {
                try await Task.sleep(nanoseconds: 1_000_000_000)
                return "ok"
            }
        )

        let task = Task {
            try await manager.perform(request)
        }
        task.cancel()

        do {
            _ = try await task.value
            XCTFail("Expected request cancellation")
        } catch let error as APIError {
            XCTAssertEqual(error, .requestCancelled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Verifies authentication interceptor injects headers.
    func testAuthenticationInterceptorInjectsHeaders() async throws {
        let interceptor = APIAuthenticationInterceptor(
            provider: TestAuthenticationProvider(headers: ["Authorization": "Bearer token"])
        )
        let request = URLRequest(url: URL(string: "https://example.com")!)

        let preparedRequest = try await interceptor.prepare(request)

        XCTAssertEqual(preparedRequest.value(forHTTPHeaderField: "Authorization"), "Bearer token")
    }

    /// Verifies offline queue drains only when connected.
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

    /// Verifies mock manager download writes stubbed data.
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

    /// Verifies upload respects cancelled token before starting.
    func testUploadRespectsCancelledTokenBeforeStarting() async {
        let manager = MockAPIManager()
        let token = APICancellationToken()
        await token.cancel()
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try? Data("payload".utf8).write(to: fileURL, options: .atomic)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        let request = APIRequest<String>(
            path: "upload",
            stubResponse: { "ok" }
        )

        do {
            _ = try await manager.upload(
                request,
                from: fileURL,
                progressHandler: nil,
                cancellationToken: token
            )
            XCTFail("Expected upload cancellation")
        } catch let error as APIError {
            XCTAssertEqual(error, .requestCancelled)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Verifies download respects cancelled token before writing file.
    func testDownloadRespectsCancelledTokenBeforeWritingFile() async {
        let manager = MockAPIManager()
        let token = APICancellationToken()
        await token.cancel()
        let destinationURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: destinationURL) }

        let request = APIRequest<Data>(
            path: "download-cancelled",
            stubResponse: { Data("payload".utf8) }
        )

        do {
            _ = try await manager.download(
                request,
                destinationURL: destinationURL,
                progressHandler: nil,
                cancellationToken: token
            )
            XCTFail("Expected download cancellation")
        } catch let error as APIError {
            XCTAssertEqual(error, .requestCancelled)
            XCTAssertFalse(FileManager.default.fileExists(atPath: destinationURL.path))
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Verifies authorization refresh interceptor refreshes and retries request.
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

        /// Test-only response DTO used to validate decoding for this networking scenario.
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

    /// Verifies concurrent 401 responses share one authorization refresh operation.
    func testAuthorizationRefreshInterceptorCoalescesConcurrentRefreshes() async throws {
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
            refreshedHeaders: ["Authorization": "Bearer new-token"],
            refreshDelayNanoseconds: 50_000_000
        )
        let coordinator = APIAuthorizationRefreshCoordinator()
        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [
                APIAuthenticationInterceptor(provider: authProvider),
                APIAuthorizationRefreshInterceptor(provider: authProvider, coordinator: coordinator)
            ]
        )

        /// Test-only response DTO used to validate decoding for this networking scenario.
        struct ResponseModel: Decodable, Sendable, Equatable {
            let value: String
        }

        async let first = manager.perform(APIRequest<ResponseModel>.json(path: "resource/1"))
        async let second = manager.perform(APIRequest<ResponseModel>.json(path: "resource/2"))
        async let third = manager.perform(APIRequest<ResponseModel>.json(path: "resource/3"))

        let responses = try await [first, second, third]

        XCTAssertEqual(responses, Array(repeating: ResponseModel(value: "ok"), count: 3))
        let refreshCount = await authProvider.refreshCount
        XCTAssertEqual(refreshCount, 1)
    }

    /// Verifies request allows custom valid status codes.
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

    /// Verifies live HTTP failures retain bounded body and header context for endpoint-specific mapping.
    func testAPIManagerCapturesHTTPFailureContext() async {
        URLProtocolStub.reset()
        let body = Data(#"{"code":"validation_failed"}"#.utf8)
        URLProtocolStub.requestHandler = { request in
            (
                HTTPURLResponse(
                    url: request.url!,
                    statusCode: 422,
                    httpVersion: nil,
                    headerFields: ["Retry-After": "30"]
                )!,
                body
            )
        }

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolStub.self]
        let session = URLSession(configuration: sessionConfiguration)
        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session
        )

        do {
            _ = try await manager.perform(APIRequest<APIEmptyResponse>.json(path: "resource"))
            XCTFail("Expected HTTP failure")
        } catch let failure as APIHTTPFailure {
            XCTAssertEqual(failure.statusCode, 422)
            XCTAssertEqual(failure.bodyText, #"{"code":"validation_failed"}"#)
            XCTAssertEqual(failure.headers["Retry-After"], "30")
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    /// Verifies captured HTTP failure bodies are bounded before they become long-lived error values.
    func testHTTPFailureBodyCaptureIsBounded() {
        let failure = APIHTTPFailure(
            statusCode: 500,
            body: Data(repeating: 1, count: 10),
            headers: [:],
            maximumCapturedBodyBytes: 4
        )

        XCTAssertEqual(failure.bodyText, String(repeating: "\u{1}", count: 4))
    }

    /// Verifies apimanager uses custom error mapper for non apierrors.
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

    /// Verifies apimanager uses retry context surface.
    func testAPIManagerUsesRetryContextSurface() async throws {
        URLProtocolStub.reset()
        let responseCounter = LockedCounter()
        URLProtocolStub.requestHandler = { request in
            let index = responseCounter.increment()
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

        /// Test-only response DTO used to validate decoding for this networking scenario.
        struct ResponseModel: Decodable, Sendable, Equatable {
            let value: String
        }

        let response = try await manager.perform(
            APIRequest<ResponseModel>.json(path: "resource")
        )

        XCTAssertEqual(response, ResponseModel(value: "ok"))
        let contexts = await contextRecorder.contexts
        XCTAssertEqual(contexts.count, 1)
        XCTAssertEqual(contexts.first?.error.statusCode, 500)
        XCTAssertEqual(contexts.first?.attempt, 0)
    }

    /// Verifies apimanager emits retry scheduled for invalid status code branch.
    func testAPIManagerEmitsRetryScheduledForInvalidStatusCodeBranch() async throws {
        URLProtocolStub.reset()
        let responseCounter = LockedCounter()
        URLProtocolStub.requestHandler = { request in
            if responseCounter.increment() == 1 {
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
        let sleeper = RetrySleepRecorder()

        let manager = APIManager(
            configuration: APIConfiguration(baseURL: URL(string: "https://example.com")!),
            session: session,
            interceptors: [
                APIMetricsInterceptor(collector: collector),
                RetryOnFirst500Interceptor(delayNanoseconds: 123)
            ],
            retrySleeper: { delayNanoseconds in
                await sleeper.record(delayNanoseconds)
            }
        )

        /// Test-only response DTO used to validate decoding for this networking scenario.
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
                    return error.statusCode == 500 && attempt == 0
                }
                return false
            }
        )
        let sleepDelays = await sleeper.delays
        XCTAssertEqual(sleepDelays, [123])
    }

    /// Verifies persisted offline queue stores and reloads entries.
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

    /// Verifies persisted offline queue drains only when connected.
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

    /// Verifies persisted offline queue moves failed entries to dead letters.
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

    /// Verifies persisted offline queue does not drop entries enqueued during drain.
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

    /// Verifies persisted offline queue reloads dead letters.
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

    /// Verifies persisted offline queue drain report and snapshot expose diagnostics.
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

    /// Verifies metrics interceptor captures lifecycle events.
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

    /// Verifies logging interceptor redacts sensitive headers and query values.
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

    /// Verifies file offline queue store recovers from corrupted payload when policy is recover to empty.
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

    /// Verifies file offline queue store recover to empty does not mask non decoding read errors.
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

    /// Verifies persisted offline queue can export and import diagnostics payload.
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

    /// Handles authorization headers.
    func authorizationHeaders() async throws -> [String: String] {
        headers
    }
}

private actor InvocationRecorder {
    private(set) var invocationCount = 0
    private(set) var payloads: [String] = []

    /// Handles record invocation.
    func recordInvocation() {
        invocationCount += 1
    }

    /// Handles record payload.
    func recordPayload(_ payload: String) {
        invocationCount += 1
        payloads.append(payload)
    }
}

private actor TestMetricsCollector: APIMetricsCollecting {
    private(set) var events: [APIMetricsEvent] = []

    /// Handles record.
    func record(_ event: APIMetricsEvent) async {
        events.append(event)
    }
}

private struct StaticErrorMapper: APIErrorMapping {
    let error: APIError

    /// Maps this operation.
    func map(_ error: Error) -> APIError {
        self.error
    }
}

private actor RetryContextRecorder {
    private(set) var contexts: [APIRetryContext] = []

    /// Handles record.
    func record(_ context: APIRetryContext) {
        contexts.append(context)
    }
}

private actor RetrySleepRecorder {
    private(set) var delays: [UInt64] = []

    /// Handles record.
    func record(_ delay: UInt64) {
        delays.append(delay)
    }
}

private actor LogRecorder {
    private var values: [String] = []

    /// Handles append.
    func append(_ value: String) {
        values.append(value)
    }

    /// Handles joined.
    func joined() -> String {
        values.joined(separator: "\n")
    }
}

private struct ContextDrivenRetryInterceptor: APIRequestIntercepting {
    let recorder: RetryContextRecorder

    /// Handles retry directive.
    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective {
        await recorder.record(context)
        if context.attempt == 0, context.error.statusCode == 500 {
            return .retry(afterNanoseconds: 0)
        }
        return .doNotRetry
    }

    /// Handles retry directive.
    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        .doNotRetry
    }
}

private struct RetryOnFirst500Interceptor: APIRequestIntercepting {
    let delayNanoseconds: UInt64

    /// Creates a RetryOnFirst500Interceptor instance.
    init(delayNanoseconds: UInt64 = 0) {
        self.delayNanoseconds = delayNanoseconds
    }

    /// Handles retry directive.
    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective {
        if context.attempt == 0, context.error.statusCode == 500 {
            return .retry(afterNanoseconds: delayNanoseconds)
        }
        return .doNotRetry
    }
}

private actor DrainExecutionControl {
    private var hasStarted = false
    private var startedContinuation: CheckedContinuation<Void, Never>?
    private var resumeContinuation: CheckedContinuation<Void, Never>?

    /// Waits until until started.
    func waitUntilStarted() async {
        if hasStarted {
            return
        }
        await withCheckedContinuation { continuation in
            startedContinuation = continuation
        }
    }

    /// Handles signal started and wait for resume.
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

    /// Handles resume.
    func resume() {
        resumeContinuation?.resume()
        resumeContinuation = nil
    }
}

/// Removes offline queue artifacts.
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
    private let refreshDelayNanoseconds: UInt64
    private var refreshCountStorage = 0

    /// Creates a new RefreshingTestAuthenticationProvider instance.
    init(
        initialHeaders: [String: String],
        refreshedHeaders: [String: String],
        refreshDelayNanoseconds: UInt64 = 0
    ) {
        self.headers = initialHeaders
        self.refreshedHeaders = refreshedHeaders
        self.refreshDelayNanoseconds = refreshDelayNanoseconds
    }

    var refreshCount: Int {
        refreshCountStorage
    }

    /// Handles authorization headers.
    func authorizationHeaders() async throws -> [String: String] {
        headers
    }

    /// Handles refresh authorization headers.
    func refreshAuthorizationHeaders() async throws -> [String: String] {
        refreshCountStorage += 1
        if refreshDelayNanoseconds > 0 {
            try await Task.sleep(nanoseconds: refreshDelayNanoseconds)
        }
        headers = refreshedHeaders
        return headers
    }
}

private final class LockedCounter: @unchecked Sendable {
    private let lock = NSLock()
    private var value = 0

    func increment() -> Int {
        lock.withLock {
            value += 1
            return value
        }
    }
}

private final class URLProtocolStubState: @unchecked Sendable {
    private let lock = NSLock()
    private var lockedRequestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))?
    private var lockedObservedRequests: [URLRequest] = []

    var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))? {
        get {
            lock.withLock { lockedRequestHandler }
        }
        set {
            lock.withLock { lockedRequestHandler = newValue }
        }
    }

    var observedRequests: [URLRequest] {
        lock.withLock { lockedObservedRequests }
    }

    func recordObservedRequest(_ request: URLRequest) {
        lock.withLock { lockedObservedRequests.append(request) }
    }

    func reset() {
        lock.withLock {
            lockedRequestHandler = nil
            lockedObservedRequests = []
        }
    }
}

private final class URLProtocolStub: URLProtocol {
    private static let state = URLProtocolStubState()

    static var requestHandler: (@Sendable (URLRequest) throws -> (HTTPURLResponse, Data))? {
        get { state.requestHandler }
        set { state.requestHandler = newValue }
    }

    static var observedRequests: [URLRequest] {
        state.observedRequests
    }

    static func reset() {
        state.reset()
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    private static func recordObservedRequest(_ request: URLRequest) {
        state.recordObservedRequest(request)
    }

    /// Handles start loading.
    override func startLoading() {
        guard let handler = URLProtocolStub.requestHandler else {
            client?.urlProtocol(self, didFailWithError: APIError.transportFailure("Missing request handler"))
            return
        }

        do {
            URLProtocolStub.recordObservedRequest(request)
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    /// Handles stop loading.
    override func stopLoading() {}
}
