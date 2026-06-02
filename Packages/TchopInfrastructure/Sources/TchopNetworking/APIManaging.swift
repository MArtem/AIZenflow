import Foundation

/// Performs a retry delay requested by the interceptor pipeline.
public typealias APIRetrySleeper = @Sendable (_ delayNanoseconds: UInt64) async throws -> Void

public protocol APIManaging: Actor {
    /// Replaces the active runtime configuration.
    func updateConfiguration(_ configuration: APIConfiguration)

    /// Replaces the active interceptor pipeline.
    func updateInterceptors(_ interceptors: [any APIRequestIntercepting])

    /// Executes a request without an explicit cancellation token.
    func perform<Response>(_ request: APIRequest<Response>) async throws -> Response where Response: Sendable

    /// Executes a request while observing a cancellation token.
    func perform<Response>(
        _ request: APIRequest<Response>,
        cancellationToken: APICancellationToken?
    ) async throws -> Response where Response: Sendable

    /// Uploads the file at the supplied URL and returns the typed response.
    func upload<Response>(
        _ request: APIRequest<Response>,
        from fileURL: URL,
        progressHandler: APIProgressHandler?
    ) async throws -> Response where Response: Sendable

    /// Uploads the file at the supplied URL while observing a cancellation token.
    func upload<Response>(
        _ request: APIRequest<Response>,
        from fileURL: URL,
        progressHandler: APIProgressHandler?,
        cancellationToken: APICancellationToken?
    ) async throws -> Response where Response: Sendable

    /// Downloads a resource to disk and returns the final file location.
    func download(
        _ request: APIRequest<Data>,
        destinationURL: URL?,
        progressHandler: APIProgressHandler?
    ) async throws -> URL

    /// Downloads a resource to disk while observing a cancellation token.
    func download(
        _ request: APIRequest<Data>,
        destinationURL: URL?,
        progressHandler: APIProgressHandler?,
        cancellationToken: APICancellationToken?
    ) async throws -> URL

    /// Cancels a running request with the matching identifier.
    func cancelRequest(id: UUID)

    /// Cancels every in-flight request.
    func cancelAllRequests()
}

private protocol CancellableTask {
    /// Cancels this operation.
    func cancel()
}

private final class TaskBox<Response: Sendable>: CancellableTask {
    let task: Task<Response, Error>

    /// Creates a new TaskBox instance.
    init(task: Task<Response, Error>) {
        self.task = task
    }

    /// Cancels this operation.
    func cancel() {
        task.cancel()
    }
}

/// Default URLSession-based API client.
public actor APIManager: APIManaging {
    private var configuration: APIConfiguration
    private let session: URLSession
    private var interceptors: [any APIRequestIntercepting]
    private var runningTasks: [UUID: CancellableTask]
    private let errorMapper: any APIErrorMapping
    private let retrySleeper: APIRetrySleeper

    /// Creates a new API client.
    public init(
        configuration: APIConfiguration,
        session: URLSession = .shared,
        interceptors: [any APIRequestIntercepting] = [],
        errorMapper: any APIErrorMapping = APIDefaultErrorMapper(),
        retrySleeper: @escaping APIRetrySleeper = { delayNanoseconds in
            try await Task.sleep(nanoseconds: delayNanoseconds)
        }
    ) {
        self.configuration = configuration
        self.session = session
        self.interceptors = interceptors
        self.runningTasks = [:]
        self.errorMapper = errorMapper
        self.retrySleeper = retrySleeper
    }

    /// Updates configuration.
    public func updateConfiguration(_ configuration: APIConfiguration) {
        self.configuration = configuration
    }

    /// Updates interceptors.
    public func updateInterceptors(_ interceptors: [any APIRequestIntercepting]) {
        self.interceptors = interceptors
    }

    /// Handles perform.
    public func perform<Response>(_ request: APIRequest<Response>) async throws -> Response where Response: Sendable {
        try await perform(request, cancellationToken: nil)
    }

    /// Handles perform.
    public func perform<Response>(
        _ request: APIRequest<Response>,
        cancellationToken: APICancellationToken?
    ) async throws -> Response where Response: Sendable {
        let task = execute(request, cancellationToken: cancellationToken)

        defer {
            runningTasks[request.id] = nil
        }

        do {
            return try await task.value
        } catch let error as APIError {
            throw error
        } catch {
            throw errorMapper.map(error)
        }
    }

    /// Handles upload.
    public func upload<Response>(
        _ request: APIRequest<Response>,
        from fileURL: URL,
        progressHandler: APIProgressHandler?
    ) async throws -> Response where Response: Sendable {
        try await upload(
            request,
            from: fileURL,
            progressHandler: progressHandler,
            cancellationToken: nil
        )
    }

    /// Handles upload.
    public func upload<Response>(
        _ request: APIRequest<Response>,
        from fileURL: URL,
        progressHandler: APIProgressHandler?,
        cancellationToken: APICancellationToken?
    ) async throws -> Response where Response: Sendable {
        if let stubResponse = request.stubResponse {
            try await cancellationToken?.throwIfCancelled()
            await progressHandler?(.started)

            do {
                let (_, response) = try await Self.executeStubResponse(
                    for: request,
                    configuration: configuration,
                    interceptors: interceptors,
                    errorMapper: errorMapper,
                    operation: stubResponse
                )
                try await cancellationToken?.throwIfCancelled()
                await progressHandler?(.finished)

                return response
            } catch {
                throw error
            }
        }

        let urlRequest = try await Self.prepareRequest(
            for: request,
            configuration: configuration,
            interceptors: interceptors
        )

        try await cancellationToken?.throwIfCancelled()
        await progressHandler?(.started)

        do {
            let (data, response) = try await session.upload(for: urlRequest, fromFile: fileURL)
            try await cancellationToken?.throwIfCancelled()
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard isStatusCodeValid(httpResponse.statusCode, for: request) else {
                let error = APIError.invalidStatusCode(httpResponse.statusCode)
                await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)
                throw error
            }

            await progressHandler?(.progressed(1))
            await progressHandler?(.finished)

            await Self.notifyInterceptors(
                of: .success((data, httpResponse)),
                for: urlRequest,
                interceptors: interceptors
            )

            guard let responseParser = request.responseParser else {
                throw APIError.invalidResponse
            }

            return try responseParser(data, httpResponse)
        } catch let error as APIError {
            throw error
        } catch {
            throw errorMapper.map(error)
        }
    }

    /// Handles download.
    public func download(
        _ request: APIRequest<Data>,
        destinationURL: URL?,
        progressHandler: APIProgressHandler?
    ) async throws -> URL {
        try await download(
            request,
            destinationURL: destinationURL,
            progressHandler: progressHandler,
            cancellationToken: nil
        )
    }

    /// Handles download.
    public func download(
        _ request: APIRequest<Data>,
        destinationURL: URL?,
        progressHandler: APIProgressHandler?,
        cancellationToken: APICancellationToken?
    ) async throws -> URL {
        if let stubResponse = request.stubResponse {
            try await cancellationToken?.throwIfCancelled()
            await progressHandler?(.started)

            do {
                let (_, data) = try await Self.executeStubResponse(
                    for: request,
                    configuration: configuration,
                    interceptors: interceptors,
                    errorMapper: errorMapper,
                    operation: stubResponse
                )
                try await cancellationToken?.throwIfCancelled()
                let outputURL = destinationURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("\(request.id.uuidString).tmp")
                try data.write(to: outputURL, options: .atomic)
                await progressHandler?(.progressed(1))
                await progressHandler?(.finished)

                return outputURL
            } catch {
                throw error
            }
        }

        let urlRequest = try await Self.prepareRequest(
            for: request,
            configuration: configuration,
            interceptors: interceptors
        )

        try await cancellationToken?.throwIfCancelled()
        await progressHandler?(.started)

        do {
            let (temporaryURL, response) = try await session.download(for: urlRequest)
            try await cancellationToken?.throwIfCancelled()
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            guard isStatusCodeValid(httpResponse.statusCode, for: request) else {
                let error = APIError.invalidStatusCode(httpResponse.statusCode)
                await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)
                throw error
            }

            let outputURL = destinationURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("\(request.id.uuidString).download")

            if FileManager.default.fileExists(atPath: outputURL.path) {
                try FileManager.default.removeItem(at: outputURL)
            }

            try FileManager.default.moveItem(at: temporaryURL, to: outputURL)

            await progressHandler?(.progressed(1))
            await progressHandler?(.finished)

            await Self.notifyInterceptors(
                of: .success((Data(), httpResponse)),
                for: urlRequest,
                interceptors: interceptors
            )

            return outputURL
        } catch let error as APIError {
            throw error
        } catch {
            throw errorMapper.map(error)
        }
    }

    /// Cancels request.
    public func cancelRequest(id: UUID) {
        runningTasks[id]?.cancel()
        runningTasks[id] = nil
    }

    /// Cancels all requests.
    public func cancelAllRequests() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
    }

    /// Handles execute.
    private func execute<Response>(
        _ request: APIRequest<Response>,
        cancellationToken: APICancellationToken?
    ) -> Task<Response, Error> where Response: Sendable {
        let task = Task<Response, Error> { [configuration, session, interceptors, errorMapper, retrySleeper] in
            if let stubResponse = request.stubResponse {
                try await cancellationToken?.throwIfCancelled()
                try Task.checkCancellation()

                let (_, response) = try await Self.executeStubResponse(
                    for: request,
                    configuration: configuration,
                    interceptors: interceptors,
                    errorMapper: errorMapper,
                    operation: stubResponse
                )
                return response
            }

            let baseURLRequest = try makeURLRequest(for: request, configuration: configuration)

            var attempt = 0

            while true {
                var urlRequest = baseURLRequest
                urlRequest = try await Self.prepareRequest(
                    from: urlRequest,
                    interceptors: interceptors
                )

                try await cancellationToken?.throwIfCancelled()
                try Task.checkCancellation()

                do {
                    let (data, response) = try await session.data(for: urlRequest)
                    try await cancellationToken?.throwIfCancelled()
                    try Task.checkCancellation()

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }

                    guard isStatusCodeValid(httpResponse.statusCode, for: request) else {
                        let error = APIError.invalidStatusCode(httpResponse.statusCode)
                        await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)

                        if try await Self.performRetryIfNeeded(
                            for: error,
                            attempt: &attempt,
                            request: urlRequest,
                            interceptors: interceptors,
                            retrySleeper: retrySleeper
                        ) {
                            continue
                        }

                        throw error
                    }

                    await Self.notifyInterceptors(
                        of: .success((data, httpResponse)),
                        for: urlRequest,
                        interceptors: interceptors
                    )

                    guard let responseParser = request.responseParser else {
                        throw APIError.invalidResponse
                    }

                    return try responseParser(data, httpResponse)
                } catch let error as APIError {
                    if try await Self.performRetryIfNeeded(
                        for: error,
                        attempt: &attempt,
                        request: urlRequest,
                        interceptors: interceptors,
                        retrySleeper: retrySleeper
                    ) {
                        continue
                    }

                    throw error
                } catch is CancellationError {
                    throw APIError.requestCancelled
                } catch let error as URLError {
                    let apiError = errorMapper.map(error)

                    if try await Self.performRetryIfNeeded(
                        for: apiError,
                        attempt: &attempt,
                        request: urlRequest,
                        interceptors: interceptors,
                        retrySleeper: retrySleeper
                    ) {
                        continue
                    }

                    throw apiError
                } catch {
                    let apiError = errorMapper.map(error)

                    if try await Self.performRetryIfNeeded(
                        for: apiError,
                        attempt: &attempt,
                        request: urlRequest,
                        interceptors: interceptors,
                        retrySleeper: retrySleeper
                    ) {
                        continue
                    }

                    throw apiError
                }
            }
        }

        runningTasks[request.id] = TaskBox<Response>(task: task)
        return task
    }

    /// Handles retry delay.
    private static func retryDelay(
        for error: APIError,
        attempt: Int,
        request: URLRequest,
        interceptors: [any APIRequestIntercepting]
    ) async -> UInt64? {
        for interceptor in interceptors {
            let directive = await interceptor.retryDirective(
                for: APIRetryContext(
                    error: error,
                    attempt: attempt,
                    request: request
                )
            )

            switch directive {
            case .doNotRetry:
                continue
            case .retry(let delay):
                return delay
            }
        }

        return nil
    }

    /// Checks whether status code valid.
    private func isStatusCodeValid<Response>(
        _ statusCode: Int,
        for request: APIRequest<Response>
    ) -> Bool where Response: Sendable {
        (request.validStatusCodes ?? (200 ..< 300)).contains(statusCode)
    }

    /// Builds and prepares a request through the interceptor pipeline.
    private static func prepareRequest<Response>(
        for request: APIRequest<Response>,
        configuration: APIConfiguration,
        interceptors: [any APIRequestIntercepting]
    ) async throws -> URLRequest where Response: Sendable {
        let urlRequest = try makeURLRequest(for: request, configuration: configuration)
        return try await Self.prepareRequest(from: urlRequest, interceptors: interceptors)
    }

    /// Applies request interceptors to an already built URL request.
    private static func prepareRequest(
        from urlRequest: URLRequest,
        interceptors: [any APIRequestIntercepting]
    ) async throws -> URLRequest {
        var preparedRequest = urlRequest

        for interceptor in interceptors {
            preparedRequest = try await interceptor.prepare(preparedRequest)
        }

        return preparedRequest
    }

    /// Broadcasts a transport result to the interceptor pipeline.
    private static func notifyInterceptors(
        of result: Result<(Data, HTTPURLResponse), APIError>,
        for request: URLRequest,
        interceptors: [any APIRequestIntercepting]
    ) async {
        for interceptor in interceptors {
            await interceptor.didReceive(result: result, request: request)
        }
    }

    /// Broadcasts a scheduled retry event to the interceptor pipeline.
    private static func notifyRetryScheduled(
        for error: APIError,
        attempt: Int,
        delayNanoseconds: UInt64,
        request: URLRequest,
        interceptors: [any APIRequestIntercepting]
    ) async {
        for interceptor in interceptors {
            await interceptor.didScheduleRetry(
                for: error,
                attempt: attempt,
                delayNanoseconds: delayNanoseconds,
                request: request
            )
        }
    }

    /// Executes a stubbed request with the same interceptor notifications as a live request.
    private static func executeStubResponse<Response>(
        for request: APIRequest<Response>,
        configuration: APIConfiguration,
        interceptors: [any APIRequestIntercepting],
        errorMapper: any APIErrorMapping,
        operation: @Sendable () async throws -> Response
    ) async throws -> (URLRequest, Response) where Response: Sendable {
        let preparedRequest = try await Self.prepareRequest(
            for: request,
            configuration: configuration,
            interceptors: interceptors
        )

        return try await executeStubResponse(
            for: preparedRequest,
            interceptors: interceptors,
            errorMapper: errorMapper,
            operation: operation
        )
    }

    /// Executes a stubbed operation for an already prepared request.
    private static func executeStubResponse<Response>(
        for request: URLRequest,
        interceptors: [any APIRequestIntercepting],
        errorMapper: any APIErrorMapping,
        operation: @Sendable () async throws -> Response
    ) async throws -> (URLRequest, Response) where Response: Sendable {
        do {
            let response = try await operation()
            await Self.notifyInterceptors(
                of: .success((Data(), Self.makeStubHTTPURLResponse(for: request))),
                for: request,
                interceptors: interceptors
            )
            return (request, response)
        } catch let error as APIError {
            await Self.notifyInterceptors(of: .failure(error), for: request, interceptors: interceptors)
            throw error
        } catch {
            let mappedError = errorMapper.map(error)
            await Self.notifyInterceptors(of: .failure(mappedError), for: request, interceptors: interceptors)
            throw mappedError
        }
    }

    /// Performs retry notification and delay handling when interceptors allow another attempt.
    private static func performRetryIfNeeded(
        for error: APIError,
        attempt: inout Int,
        request: URLRequest,
        interceptors: [any APIRequestIntercepting],
        retrySleeper: APIRetrySleeper
    ) async throws -> Bool {
        guard let delay = await Self.retryDelay(
            for: error,
            attempt: attempt,
            request: request,
            interceptors: interceptors
        ) else {
            return false
        }

        await notifyRetryScheduled(
            for: error,
            attempt: attempt,
            delayNanoseconds: delay,
            request: request,
            interceptors: interceptors
        )
        attempt += 1
        try await retrySleeper(delay)
        return true
    }

    /// Creates a synthetic successful HTTP response for stub-driven requests.
    private static func makeStubHTTPURLResponse(for request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url ?? URL(string: "https://stub.local")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
    }
}

/// Lightweight mock implementation for previews and unit tests.
