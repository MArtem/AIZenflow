import Foundation

/// Describes the HTTP verb used by a request.
public enum HTTPMethod: String, Sendable, Equatable {
    case delete = "DELETE"
    case get = "GET"
    case patch = "PATCH"
    case post = "POST"
    case put = "PUT"
}

/// Defines runtime settings shared by all requests executed through an API client.
public struct APIConfiguration: Sendable, Equatable {
    /// Base URL used to resolve request paths.
    public let baseURL: URL

    /// Headers applied to every outgoing request unless overridden by the request itself.
    public let defaultHeaders: [String: String]

    /// Default timeout interval for requests that do not provide a custom value.
    public let timeoutInterval: TimeInterval

    /// Creates a new runtime configuration.
    /// - Parameters:
    ///   - baseURL: Base URL used to resolve request paths.
    ///   - defaultHeaders: Headers applied to every request.
    ///   - timeoutInterval: Default request timeout in seconds.
    public init(
        baseURL: URL,
        defaultHeaders: [String: String] = [:],
        timeoutInterval: TimeInterval = 30
    ) {
        self.baseURL = baseURL
        self.defaultHeaders = defaultHeaders
        self.timeoutInterval = timeoutInterval
    }

    /// Default configuration used by local stub-based development flows.
    public static let stub = APIConfiguration(
        baseURL: URL(string: "https://stub.tchop.local")!,
        defaultHeaders: [:],
        timeoutInterval: 30
    )
}

/// Typed errors surfaced by the networking layer.
public enum APIError: Error, Equatable, Sendable {
    case badURL(path: String)
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed(String)
    case requestCancelled
    case transportFailure(String)
}

/// Provides cooperative cancellation for requests started outside direct task ownership.
public actor APICancellationToken {
    private var isCancelled = false

    /// Creates a new token.
    public init() {}

    /// Marks the token as cancelled.
    public func cancel() {
        isCancelled = true
    }

    /// Throws ``APIError/requestCancelled`` if the token was cancelled.
    public func throwIfCancelled() throws {
        if isCancelled {
            throw APIError.requestCancelled
        }
    }
}

/// Describes a typed request handled by ``APIManaging``.
public struct APIRequest<Response>: Sendable where Response: Sendable {
    /// Stable request identifier used for task tracking and cancellation.
    public let id: UUID

    /// Relative request path appended to the configured base URL.
    public let path: String

    /// HTTP method used by the request.
    public let method: HTTPMethod

    /// Request-specific headers that override configuration defaults.
    public let headers: [String: String]

    /// Query items appended to the request URL.
    public let queryItems: [URLQueryItem]

    /// Raw request body.
    public let body: Data?

    /// Optional per-request timeout override.
    public let timeoutInterval: TimeInterval?

    /// Optional stubbed response for previews, tests, and local development.
    public let stubResponse: (@Sendable () async throws -> Response)?

    /// Parses the raw transport payload into the expected response type.
    public let responseParser: (@Sendable (Data, HTTPURLResponse) throws -> Response)?

    /// Creates a typed request.
    public init(
        id: UUID = UUID(),
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        timeoutInterval: TimeInterval? = nil,
        stubResponse: (@Sendable () async throws -> Response)? = nil,
        responseParser: (@Sendable (Data, HTTPURLResponse) throws -> Response)? = nil
    ) {
        self.id = id
        self.path = path
        self.method = method
        self.headers = headers
        self.queryItems = queryItems
        self.body = body
        self.timeoutInterval = timeoutInterval
        self.stubResponse = stubResponse
        self.responseParser = responseParser
    }
}

/// Produces a typed request from endpoint-specific data.
public protocol APIRouting: Sendable {
    associatedtype Response: Sendable

    /// Converts the route into a request consumable by the API client.
    func makeRequest() -> APIRequest<Response>
}

/// Provides request adaptation, logging hooks, and retry decisions.
public protocol APIRequestIntercepting: Sendable {
    /// Adapts the outgoing request before execution.
    func prepare(_ request: URLRequest) async throws -> URLRequest

    /// Receives the transport result for side effects such as logging.
    func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async

    /// Allows the interceptor to request a retry after a failure.
    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective
}

public extension APIRequestIntercepting {
    func prepare(_ request: URLRequest) async throws -> URLRequest { request }
    func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async {}
    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        .doNotRetry
    }
}

/// Describes whether a request should be retried after a failed attempt.
public enum APIRetryDirective: Sendable, Equatable {
    case doNotRetry
    case retry(afterNanoseconds: UInt64)
}

/// Controls log verbosity for the logging interceptor.
public enum APILogLevel: Sendable, Equatable {
    case none
    case request
    case requestAndResponse
}

/// Logs request and response metadata for debugging and diagnostics.
public struct APILoggingInterceptor: APIRequestIntercepting {
    private let level: APILogLevel
    private let logger: @Sendable (String) -> Void

    /// Creates a logging interceptor.
    public init(
        level: APILogLevel,
        logger: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.level = level
        self.logger = logger
    }

    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        guard level != .none else {
            return request
        }

        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "<missing-url>"
        logger("[API] \(method) \(url)")
        return request
    }

    public func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async {
        guard level == .requestAndResponse else {
            return
        }

        switch result {
        case let .success((data, response)):
            logger("[API] Response \(response.statusCode) for \(request.url?.absoluteString ?? "<missing-url>") (\(data.count) bytes)")
        case let .failure(error):
            logger("[API] Failure for \(request.url?.absoluteString ?? "<missing-url>"): \(error)")
        }
    }
}

/// Retries transient failures with exponential backoff and optional jitter.
public struct APIRetryInterceptor: APIRequestIntercepting {
    /// Configuration describing retry behavior.
    public struct Configuration: Sendable, Equatable {
        public let maxRetries: Int
        public let baseDelayNanoseconds: UInt64
        public let maxDelayNanoseconds: UInt64
        public let jitterFactor: Double

        /// Creates a retry policy.
        public init(
            maxRetries: Int = 2,
            baseDelayNanoseconds: UInt64 = 250_000_000,
            maxDelayNanoseconds: UInt64 = 2_000_000_000,
            jitterFactor: Double = 0.15
        ) {
            self.maxRetries = maxRetries
            self.baseDelayNanoseconds = baseDelayNanoseconds
            self.maxDelayNanoseconds = maxDelayNanoseconds
            self.jitterFactor = jitterFactor
        }
    }

    private let configuration: Configuration

    /// Creates a retry interceptor.
    public init(configuration: Configuration = .init()) {
        self.configuration = configuration
    }

    public func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        guard attempt < configuration.maxRetries else {
            return .doNotRetry
        }

        switch error {
        case .invalidStatusCode(let statusCode) where statusCode >= 500:
            return .retry(afterNanoseconds: makeDelay(attempt: attempt))
        case .transportFailure:
            return .retry(afterNanoseconds: makeDelay(attempt: attempt))
        default:
            return .doNotRetry
        }
    }

    private func makeDelay(attempt: Int) -> UInt64 {
        let multiplier = UInt64(pow(2.0, Double(attempt)))
        let baseDelay = min(configuration.baseDelayNanoseconds * multiplier, configuration.maxDelayNanoseconds)
        guard configuration.jitterFactor > 0 else {
            return baseDelay
        }

        let jitter = Double(baseDelay) * configuration.jitterFactor
        let randomized = Double(baseDelay) + Double.random(in: -jitter ... jitter)
        return UInt64(max(0, randomized))
    }
}

/// Defines the public contract for a typed API client.
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

    /// Cancels a running request with the matching identifier.
    func cancelRequest(id: UUID)

    /// Cancels every in-flight request.
    func cancelAllRequests()
}

private protocol CancellableTask {
    func cancel()
}

private final class TaskBox<Response>: CancellableTask {
    let task: Task<Response, Error>

    init(task: Task<Response, Error>) {
        self.task = task
    }

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

    /// Creates a new API client.
    public init(
        configuration: APIConfiguration,
        session: URLSession = .shared,
        interceptors: [any APIRequestIntercepting] = []
    ) {
        self.configuration = configuration
        self.session = session
        self.interceptors = interceptors
        self.runningTasks = [:]
    }

    public func updateConfiguration(_ configuration: APIConfiguration) {
        self.configuration = configuration
    }

    public func updateInterceptors(_ interceptors: [any APIRequestIntercepting]) {
        self.interceptors = interceptors
    }

    public func perform<Response>(_ request: APIRequest<Response>) async throws -> Response where Response: Sendable {
        try await perform(request, cancellationToken: nil)
    }

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
        } catch is CancellationError {
            throw APIError.requestCancelled
        } catch let error as URLError {
            throw mapTransportError(error)
        } catch {
            throw APIError.transportFailure(String(describing: error))
        }
    }

    public func cancelRequest(id: UUID) {
        runningTasks[id]?.cancel()
        runningTasks[id] = nil
    }

    public func cancelAllRequests() {
        for task in runningTasks.values {
            task.cancel()
        }
        runningTasks.removeAll()
    }

    private func execute<Response>(
        _ request: APIRequest<Response>,
        cancellationToken: APICancellationToken?
    ) -> Task<Response, Error> where Response: Sendable {
        let task = Task<Response, Error> { [configuration, session, interceptors] in
            if let stubResponse = request.stubResponse {
                try await cancellationToken?.throwIfCancelled()
                try Task.checkCancellation()
                return try await stubResponse()
            }

            var urlRequest = try makeURLRequest(for: request, configuration: configuration)

            for interceptor in interceptors {
                urlRequest = try await interceptor.prepare(urlRequest)
            }

            var attempt = 0

            while true {
                try await cancellationToken?.throwIfCancelled()
                try Task.checkCancellation()

                do {
                    let (data, response) = try await session.data(for: urlRequest)
                    try await cancellationToken?.throwIfCancelled()
                    try Task.checkCancellation()

                    guard let httpResponse = response as? HTTPURLResponse else {
                        throw APIError.invalidResponse
                    }

                    guard 200 ..< 300 ~= httpResponse.statusCode else {
                        let error = APIError.invalidStatusCode(httpResponse.statusCode)
                        for interceptor in interceptors {
                            await interceptor.didReceive(result: .failure(error), request: urlRequest)
                        }

                        if let delay = await retryDelay(for: error, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                            attempt += 1
                            try await Task.sleep(nanoseconds: delay)
                            continue
                        }

                        throw error
                    }

                    for interceptor in interceptors {
                        await interceptor.didReceive(result: .success((data, httpResponse)), request: urlRequest)
                    }

                    guard let responseParser = request.responseParser else {
                        throw APIError.invalidResponse
                    }

                    return try responseParser(data, httpResponse)
                } catch let error as APIError {
                    if let delay = await retryDelay(for: error, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        attempt += 1
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }

                    throw error
                } catch is CancellationError {
                    throw APIError.requestCancelled
                } catch let error as URLError {
                    let apiError = mapTransportError(error)

                    if let delay = await retryDelay(for: apiError, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        attempt += 1
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }

                    throw apiError
                } catch {
                    let apiError = APIError.transportFailure(String(describing: error))

                    if let delay = await retryDelay(for: apiError, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        attempt += 1
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }

                    throw apiError
                }
            }
        }

        runningTasks[request.id] = TaskBox(task: task)
        return task
    }

    private func retryDelay(
        for error: APIError,
        attempt: Int,
        request: URLRequest,
        interceptors: [any APIRequestIntercepting]
    ) async -> UInt64? {
        for interceptor in interceptors {
            let directive = await interceptor.retryDirective(for: error, attempt: attempt, request: request)

            switch directive {
            case .doNotRetry:
                continue
            case .retry(let delay):
                return delay
            }
        }

        return nil
    }
}

/// Lightweight mock implementation for previews and unit tests.
public actor MockAPIManager: APIManaging {
    private var configuration: APIConfiguration
    private var interceptors: [any APIRequestIntercepting]
    private var stubs: [UUID: AnySendableResult]

    /// Creates a mock client.
    public init(
        configuration: APIConfiguration = .stub,
        interceptors: [any APIRequestIntercepting] = []
    ) {
        self.configuration = configuration
        self.interceptors = interceptors
        self.stubs = [:]
    }

    /// Registers a stubbed result for a specific request identifier.
    public func registerStub<Response>(
        for requestID: UUID,
        result: Result<Response, APIError>
    ) where Response: Sendable {
        stubs[requestID] = AnySendableResult(result)
    }

    public func updateConfiguration(_ configuration: APIConfiguration) {
        self.configuration = configuration
    }

    public func updateInterceptors(_ interceptors: [any APIRequestIntercepting]) {
        self.interceptors = interceptors
    }

    public func perform<Response>(_ request: APIRequest<Response>) async throws -> Response where Response: Sendable {
        try await perform(request, cancellationToken: nil)
    }

    public func perform<Response>(
        _ request: APIRequest<Response>,
        cancellationToken: APICancellationToken?
    ) async throws -> Response where Response: Sendable {
        try await cancellationToken?.throwIfCancelled()

        if let stubResponse = request.stubResponse {
            return try await stubResponse()
        }

        guard let stored = stubs[request.id] else {
            throw APIError.transportFailure("Missing mock stub for request \(request.id)")
        }

        switch stored.result {
        case let .success(value as Response):
            return value
        case let .failure(error as APIError):
            throw error
        default:
            throw APIError.transportFailure("Type mismatch for mock stub \(request.id)")
        }
    }

    public func cancelRequest(id: UUID) {}
    public func cancelAllRequests() {}
}

private final class AnySendableResult: @unchecked Sendable {
    let result: Result<Any, Error>

    init<Response: Sendable>(_ result: Result<Response, APIError>) {
        switch result {
        case .success(let value):
            self.result = .success(value)
        case .failure(let error):
            self.result = .failure(error)
        }
    }
}

private func makeURLRequest<Response>(
    for request: APIRequest<Response>,
    configuration: APIConfiguration
) throws -> URLRequest where Response: Sendable {
    var components = URLComponents(
        url: configuration.baseURL.appendingPathComponent(request.path),
        resolvingAgainstBaseURL: false
    )
    components?.queryItems = request.queryItems.isEmpty ? nil : request.queryItems

    guard let url = components?.url else {
        throw APIError.badURL(path: request.path)
    }

    var urlRequest = URLRequest(
        url: url,
        timeoutInterval: request.timeoutInterval ?? configuration.timeoutInterval
    )
    urlRequest.httpMethod = request.method.rawValue
    urlRequest.httpBody = request.body

    for (header, value) in configuration.defaultHeaders {
        urlRequest.setValue(value, forHTTPHeaderField: header)
    }

    for (header, value) in request.headers {
        urlRequest.setValue(value, forHTTPHeaderField: header)
    }

    return urlRequest
}

private func mapTransportError(_ error: URLError) -> APIError {
    switch error.code {
    case .cancelled:
        return .requestCancelled
    default:
        return .transportFailure(error.localizedDescription)
    }
}
