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
    case noConnection
    case invalidResponse
    case invalidStatusCode(Int)
    case decodingFailed(String)
    case requestCancelled
    case timeout
    case transportFailure(String)
}

/// Maps arbitrary runtime errors into typed ``APIError`` values.
public protocol APIErrorMapping: Sendable {
    /// Converts any error into an API error.
    func map(_ error: Error) -> APIError
}

/// Default mapping strategy used by ``APIManager``.
public struct APIDefaultErrorMapper: APIErrorMapping {
    /// Creates default mapper.
    public init() {}

    /// Maps this operation.
    public func map(_ error: Error) -> APIError {
        if let apiError = error as? APIError {
            return apiError
        }
        if error is CancellationError {
            return .requestCancelled
        }
        if let urlError = error as? URLError {
            return mapTransportError(urlError)
        }
        return .transportFailure(String(describing: error))
    }
}

/// Progress event emitted by upload and download operations.
public enum APITransferProgress: Sendable, Equatable {
    case started
    case progressed(Double)
    case finished
}

/// Empty marker response for endpoints that intentionally return no payload.
public struct APIEmptyResponse: Sendable, Decodable, Equatable {
    /// Creates a new APIEmptyResponse instance.
    public init() {}
}

/// Async callback used to report transfer progress.
public typealias APIProgressHandler = @Sendable (APITransferProgress) async -> Void

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

    /// Optional set of accepted HTTP status codes.
    ///
    /// When omitted, `200..<300` is used.
    public let validStatusCodes: Range<Int>?

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
        responseParser: (@Sendable (Data, HTTPURLResponse) throws -> Response)? = nil,
        validStatusCodes: Range<Int>? = nil
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
        self.validStatusCodes = validStatusCodes
    }
}

public extension APIRequest where Response: Decodable {
    /// Builds a request that decodes JSON into `Response` with a configurable decoder.
    static func json(
        id: UUID = UUID(),
        path: String,
        method: HTTPMethod = .get,
        headers: [String: String] = [:],
        queryItems: [URLQueryItem] = [],
        body: Data? = nil,
        timeoutInterval: TimeInterval? = nil,
        stubResponse: (@Sendable () async throws -> Response)? = nil,
        jsonDecoder: JSONDecoder = JSONDecoder(),
        validStatusCodes: Range<Int>? = nil
    ) -> APIRequest<Response> {
        APIRequest<Response>(
            id: id,
            path: path,
            method: method,
            headers: headers,
            queryItems: queryItems,
            body: body,
            timeoutInterval: timeoutInterval,
            stubResponse: stubResponse,
            responseParser: { data, _ in
                do {
                    return try jsonDecoder.decode(Response.self, from: data)
                } catch {
                    throw APIError.decodingFailed(String(describing: error))
                }
            },
            validStatusCodes: validStatusCodes
        )
    }
}

/// Produces a typed request from endpoint-specific data.
public protocol APIRouting: Sendable {
    associatedtype Response: Sendable

    /// Converts the route into a request consumable by the API client.
    func makeRequest() -> APIRequest<Response>
}

/// Provides authorization headers for authenticated requests.
public protocol APIAuthenticationProviding: Sendable {
    /// Returns headers that should be applied to authenticated requests.
    func authorizationHeaders() async throws -> [String: String]
}

/// Extends auth providers with token refresh capability used by retry interceptors.
public protocol APIAuthenticationRefreshing: APIAuthenticationProviding {
    /// Refreshes auth state and returns updated authorization headers.
    func refreshAuthorizationHeaders() async throws -> [String: String]
}

/// Exposes current network reachability for offline queue orchestration.
public protocol APIConnectivityProviding: Sendable {
    /// Indicates whether the network is currently reachable.
    func isConnected() async -> Bool
}

/// Provides request adaptation, logging hooks, and retry decisions.
public protocol APIRequestIntercepting: Sendable {
    /// Adapts the outgoing request before execution.
    func prepare(_ request: URLRequest) async throws -> URLRequest

    /// Receives the transport result for side effects such as logging.
    func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async

    /// Allows the interceptor to request a retry after a failure.
    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective

    /// Allows the interceptor to request a retry based on typed retry context.
    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective

    /// Notifies interceptor that retry was scheduled for a failed attempt.
    func didScheduleRetry(
        for error: APIError,
        attempt: Int,
        delayNanoseconds: UInt64,
        request: URLRequest
    ) async
}

public extension APIRequestIntercepting {
    /// Handles prepare.
    func prepare(_ request: URLRequest) async throws -> URLRequest { request }
    /// Handles receive.
    func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async {}
    /// Handles retry directive.
    func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        .doNotRetry
    }
    /// Handles retry directive.
    func retryDirective(for context: APIRetryContext) async -> APIRetryDirective {
        await retryDirective(for: context.error, attempt: context.attempt, request: context.request)
    }
    /// Handles schedule retry.
    func didScheduleRetry(
        for error: APIError,
        attempt: Int,
        delayNanoseconds: UInt64,
        request: URLRequest
    ) async {}
}

/// Describes whether a request should be retried after a failed attempt.
public enum APIRetryDirective: Sendable, Equatable {
    case doNotRetry
    case retry(afterNanoseconds: UInt64)
}

/// Retry metadata passed to interceptor retry policies.
public struct APIRetryContext: Sendable {
    public let error: APIError
    public let attempt: Int
    public let request: URLRequest

    /// Creates a new APIRetryContext instance.
    public init(
        error: APIError,
        attempt: Int,
        request: URLRequest
    ) {
        self.error = error
        self.attempt = attempt
        self.request = request
    }
}

/// Typed metric events emitted by networking observability interceptors.
public enum APIMetricsEvent: Sendable, Equatable {
    case requestPrepared(method: String, url: String)
    case requestSucceeded(statusCode: Int, bytes: Int, url: String)
    case requestFailed(error: APIError, url: String)
    case retryScheduled(error: APIError, attempt: Int, delayNanoseconds: UInt64, url: String)
}

/// Sink contract for API metric events.
public protocol APIMetricsCollecting: Sendable {
    /// Records a metrics event.
    func record(_ event: APIMetricsEvent) async
}

/// In-memory metrics collector useful for debug overlays and tests.
public actor APIMemoryMetricsCollector: APIMetricsCollecting {
    private var eventsStorage: [APIMetricsEvent] = []

    /// Creates an empty collector.
    public init() {}

    /// Recorded events in insertion order.
    public var events: [APIMetricsEvent] {
        eventsStorage
    }

    /// Clears all recorded events.
    public func reset() {
        eventsStorage.removeAll()
    }

    /// Handles record.
    public func record(_ event: APIMetricsEvent) async {
        eventsStorage.append(event)
    }
}

/// Interceptor that emits typed lifecycle metrics for each request.
public struct APIMetricsInterceptor: APIRequestIntercepting {
    private let collector: any APIMetricsCollecting

    /// Creates a metrics interceptor.
    public init(collector: any APIMetricsCollecting) {
        self.collector = collector
    }

    /// Handles prepare.
    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        let method = request.httpMethod ?? "UNKNOWN"
        let url = request.url?.absoluteString ?? "<missing-url>"
        await collector.record(.requestPrepared(method: method, url: url))
        return request
    }

    /// Handles receive.
    public func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async {
        let url = request.url?.absoluteString ?? "<missing-url>"
        switch result {
        case let .success((data, response)):
            await collector.record(
                .requestSucceeded(statusCode: response.statusCode, bytes: data.count, url: url)
            )
        case let .failure(error):
            await collector.record(.requestFailed(error: error, url: url))
        }
    }

    /// Handles schedule retry.
    public func didScheduleRetry(
        for error: APIError,
        attempt: Int,
        delayNanoseconds: UInt64,
        request: URLRequest
    ) async {
        let url = request.url?.absoluteString ?? "<missing-url>"
        await collector.record(
            .retryScheduled(
                error: error,
                attempt: attempt,
                delayNanoseconds: delayNanoseconds,
                url: url
            )
        )
    }
}

/// Controls log verbosity for the logging interceptor.
public enum APILogLevel: Sendable, Equatable {
    case none
    case request
    case requestAndResponse
}

/// Logs request and response metadata for debugging and diagnostics.
public struct APILoggingInterceptor: APIRequestIntercepting {
    /// Redaction rules applied before request/response metadata is logged.
    public struct RedactionConfiguration: Sendable, Equatable {
        public let sensitiveHeaders: Set<String>
        public let sensitiveQueryItems: Set<String>
        public let redactedPlaceholder: String

        /// Creates a new RedactionConfiguration instance.
        public init(
            sensitiveHeaders: Set<String> = [
                "authorization",
                "x-api-key",
                "api-key",
                "cookie",
                "set-cookie"
            ],
            sensitiveQueryItems: Set<String> = [
                "token",
                "access_token",
                "refresh_token",
                "api_key",
                "key"
            ],
            redactedPlaceholder: String = "<redacted>"
        ) {
            self.sensitiveHeaders = Set(sensitiveHeaders.map { $0.lowercased() })
            self.sensitiveQueryItems = Set(sensitiveQueryItems.map { $0.lowercased() })
            self.redactedPlaceholder = redactedPlaceholder
        }
    }

    private let level: APILogLevel
    private let redaction: RedactionConfiguration
    private let logger: @Sendable (String) -> Void

    /// Creates a logging interceptor.
    public init(
        level: APILogLevel,
        redaction: RedactionConfiguration = .init(),
        logger: @escaping @Sendable (String) -> Void = { print($0) }
    ) {
        self.level = level
        self.redaction = redaction
        self.logger = logger
    }

    /// Handles prepare.
    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        guard level != .none else {
            return request
        }

        let method = request.httpMethod ?? "UNKNOWN"
        let url = redact(url: request.url)
        if level == .requestAndResponse, let headers = request.allHTTPHeaderFields, !headers.isEmpty {
            let redactedHeaders = redact(headers: headers)
            logger("[API] \(method) \(url) headers=\(redactedHeaders)")
        } else {
            logger("[API] \(method) \(url)")
        }
        return request
    }

    /// Handles receive.
    public func didReceive(result: Result<(Data, HTTPURLResponse), APIError>, request: URLRequest) async {
        guard level == .requestAndResponse else {
            return
        }

        let redactedURL = redact(url: request.url)

        switch result {
        case let .success((data, response)):
            logger("[API] Response \(response.statusCode) for \(redactedURL) (\(data.count) bytes)")
        case let .failure(error):
            logger("[API] Failure for \(redactedURL): \(error)")
        }
    }

    /// Handles redact.
    private func redact(url: URL?) -> String {
        guard
            let url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else {
            return "<missing-url>"
        }

        if let queryItems = components.queryItems, !queryItems.isEmpty {
            components.queryItems = queryItems.map { item in
                guard redaction.sensitiveQueryItems.contains(item.name.lowercased()) else {
                    return item
                }
                return URLQueryItem(
                    name: item.name,
                    value: redaction.redactedPlaceholder
                )
            }
        }

        return components.string ?? url.absoluteString
    }

    /// Handles redact.
    private func redact(headers: [String: String]) -> String {
        let sorted = headers.keys.sorted(by: { $0.lowercased() < $1.lowercased() })
        let pairs = sorted.map { key -> String in
            let isSensitive = redaction.sensitiveHeaders.contains(key.lowercased())
            let value = isSensitive ? redaction.redactedPlaceholder : (headers[key] ?? "")
            return "\(key)=\(value)"
        }
        return "{\(pairs.joined(separator: ", "))}"
    }
}

/// Injects authorization headers into outgoing requests.
public struct APIAuthenticationInterceptor: APIRequestIntercepting {
    private let provider: any APIAuthenticationProviding

    /// Creates an authentication interceptor.
    public init(provider: any APIAuthenticationProviding) {
        self.provider = provider
    }

    /// Handles prepare.
    public func prepare(_ request: URLRequest) async throws -> URLRequest {
        let headers = try await provider.authorizationHeaders()
        var mutableRequest = request

        for (header, value) in headers {
            mutableRequest.setValue(value, forHTTPHeaderField: header)
        }

        return mutableRequest
    }
}

/// Performs a one-shot auth refresh and triggers request retry after HTTP 401 responses.
public struct APIAuthorizationRefreshInterceptor: APIRequestIntercepting {
    private let provider: any APIAuthenticationRefreshing

    /// Creates an authorization refresh interceptor.
    public init(provider: any APIAuthenticationRefreshing) {
        self.provider = provider
    }

    /// Handles retry directive.
    public func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        guard attempt == 0 else {
            return .doNotRetry
        }

        guard case .invalidStatusCode(let statusCode) = error, statusCode == 401 else {
            return .doNotRetry
        }

        do {
            _ = try await provider.refreshAuthorizationHeaders()
            return .retry(afterNanoseconds: 0)
        } catch {
            return .doNotRetry
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

    /// Handles retry directive.
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

    /// Creates delay.
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

private final class TaskBox<Response>: CancellableTask {
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

    /// Creates a new API client.
    public init(
        configuration: APIConfiguration,
        session: URLSession = .shared,
        interceptors: [any APIRequestIntercepting] = [],
        errorMapper: any APIErrorMapping = APIDefaultErrorMapper()
    ) {
        self.configuration = configuration
        self.session = session
        self.interceptors = interceptors
        self.runningTasks = [:]
        self.errorMapper = errorMapper
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
            let urlRequest = try await Self.prepareRequest(
                for: request,
                configuration: configuration,
                interceptors: interceptors
            )

            try await cancellationToken?.throwIfCancelled()
            await progressHandler?(.started)

            do {
                let response = try await stubResponse()
                try await cancellationToken?.throwIfCancelled()
                await progressHandler?(.finished)

                await Self.notifyInterceptors(
                    of: .success((Data(), Self.makeStubHTTPURLResponse(for: urlRequest))),
                    for: urlRequest,
                    interceptors: interceptors
                )

                return response
            } catch let error as APIError {
                await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)
                throw error
            } catch {
                let mappedError = errorMapper.map(error)
                await Self.notifyInterceptors(of: .failure(mappedError), for: urlRequest, interceptors: interceptors)
                throw mappedError
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
            let urlRequest = try await Self.prepareRequest(
                for: request,
                configuration: configuration,
                interceptors: interceptors
            )

            try await cancellationToken?.throwIfCancelled()
            await progressHandler?(.started)

            do {
                let data = try await stubResponse()
                try await cancellationToken?.throwIfCancelled()
                let outputURL = destinationURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("\(request.id.uuidString).tmp")
                try data.write(to: outputURL, options: .atomic)
                await progressHandler?(.progressed(1))
                await progressHandler?(.finished)

                await Self.notifyInterceptors(
                    of: .success((data, Self.makeStubHTTPURLResponse(for: urlRequest))),
                    for: urlRequest,
                    interceptors: interceptors
                )

                return outputURL
            } catch let error as APIError {
                await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)
                throw error
            } catch {
                let mappedError = errorMapper.map(error)
                await Self.notifyInterceptors(of: .failure(mappedError), for: urlRequest, interceptors: interceptors)
                throw mappedError
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
        let task = Task<Response, Error> { [configuration, session, interceptors, errorMapper] in
            if let stubResponse = request.stubResponse {
                let urlRequest = try await Self.prepareRequest(
                    for: request,
                    configuration: configuration,
                    interceptors: interceptors
                )

                try await cancellationToken?.throwIfCancelled()
                try Task.checkCancellation()

                do {
                    let response = try await stubResponse()

                    await Self.notifyInterceptors(
                        of: .success((Data(), Self.makeStubHTTPURLResponse(for: urlRequest))),
                        for: urlRequest,
                        interceptors: interceptors
                    )

                    return response
                } catch let error as APIError {
                    await Self.notifyInterceptors(of: .failure(error), for: urlRequest, interceptors: interceptors)
                    throw error
                } catch {
                    let mappedError = errorMapper.map(error)
                    await Self.notifyInterceptors(of: .failure(mappedError), for: urlRequest, interceptors: interceptors)
                    throw mappedError
                }
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

                        if let delay = await retryDelay(for: error, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                            await Self.notifyRetryScheduled(
                                for: error,
                                attempt: attempt,
                                delayNanoseconds: delay,
                                request: urlRequest,
                                interceptors: interceptors
                            )
                            attempt += 1
                            try await Task.sleep(nanoseconds: delay)
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
                    if let delay = await retryDelay(for: error, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        await Self.notifyRetryScheduled(
                            for: error,
                            attempt: attempt,
                            delayNanoseconds: delay,
                            request: urlRequest,
                            interceptors: interceptors
                        )
                        attempt += 1
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }

                    throw error
                } catch is CancellationError {
                    throw APIError.requestCancelled
                } catch let error as URLError {
                    let apiError = errorMapper.map(error)

                    if let delay = await retryDelay(for: apiError, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        await Self.notifyRetryScheduled(
                            for: apiError,
                            attempt: attempt,
                            delayNanoseconds: delay,
                            request: urlRequest,
                            interceptors: interceptors
                        )
                        attempt += 1
                        try await Task.sleep(nanoseconds: delay)
                        continue
                    }

                    throw apiError
                } catch {
                    let apiError = errorMapper.map(error)

                    if let delay = await retryDelay(for: apiError, attempt: attempt, request: urlRequest, interceptors: interceptors) {
                        await Self.notifyRetryScheduled(
                            for: apiError,
                            attempt: attempt,
                            delayNanoseconds: delay,
                            request: urlRequest,
                            interceptors: interceptors
                        )
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

    /// Handles retry delay.
    private func retryDelay(
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

    /// Creates a synthetic successful HTTP response for stub-driven requests.
    private static func makeStubHTTPURLResponse(for request: URLRequest) -> HTTPURLResponse {
        HTTPURLResponse(
            url: request.url ?? URL(string: "https://stub.tchop.local")!,
            statusCode: 200,
            httpVersion: "HTTP/1.1",
            headerFields: nil
        )!
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
        try await cancellationToken?.throwIfCancelled()
        await progressHandler?(.started)
        let response = try await perform(request, cancellationToken: cancellationToken)
        try await cancellationToken?.throwIfCancelled()
        await progressHandler?(.finished)
        return response
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
        try await cancellationToken?.throwIfCancelled()
        await progressHandler?(.started)
        let data = try await perform(request, cancellationToken: cancellationToken)
        try await cancellationToken?.throwIfCancelled()
        let outputURL = destinationURL ?? FileManager.default.temporaryDirectory.appendingPathComponent("\(request.id.uuidString).mock-download")
        try data.write(to: outputURL, options: .atomic)
        await progressHandler?(.finished)
        return outputURL
    }

    /// Cancels request.
    public func cancelRequest(id: UUID) {}
    /// Cancels all requests.
    public func cancelAllRequests() {}
}

/// In-memory offline queue foundation for deferred request execution.
public actor APIOfflineRequestQueue {
    private var queuedOperations: [QueuedOperation] = []

    /// Creates an empty queue.
    public init() {}

    /// Number of requests currently waiting for connectivity.
    public var pendingRequestCount: Int {
        queuedOperations.count
    }

    /// Enqueues an operation for later execution.
    public func enqueue(
        id: UUID = UUID(),
        operation: @escaping @Sendable () async -> Void
    ) {
        queuedOperations.append(
            QueuedOperation(id: id, operation: operation)
        )
    }

    /// Executes and clears queued operations when the connectivity provider reports an active connection.
    public func drainIfConnected(using connectivityProvider: any APIConnectivityProviding) async {
        guard await connectivityProvider.isConnected() else {
            return
        }

        let operations = queuedOperations
        queuedOperations.removeAll()

        for operation in operations {
            await operation.operation()
        }
    }

    /// Clears all queued operations without executing them.
    public func removeAll() {
        queuedOperations.removeAll()
    }
}

/// Describes a single persisted offline queue item.
public struct APIOfflineQueueEntry<Payload>: Codable, Sendable where Payload: Codable & Sendable {
    /// Stable identifier of queued operation.
    public let id: UUID

    /// Creation timestamp for ordering and diagnostics.
    public let createdAt: Date

    /// Current retry attempt count.
    public let attempts: Int

    /// Domain payload used to reconstruct operation execution.
    public let payload: Payload

    /// Creates a queue entry.
    public init(
        id: UUID = UUID(),
        createdAt: Date = Date(),
        attempts: Int = 0,
        payload: Payload
    ) {
        self.id = id
        self.createdAt = createdAt
        self.attempts = attempts
        self.payload = payload
    }

    /// Returns a copy of the entry with incremented attempt count.
    public func incrementingAttempts() -> APIOfflineQueueEntry<Payload> {
        APIOfflineQueueEntry(
            id: id,
            createdAt: createdAt,
            attempts: attempts + 1,
            payload: payload
        )
    }
}

/// Persistence contract for payload-based offline queue entries.
public protocol APIOfflineQueueStoring: Sendable {
    associatedtype Payload: Codable & Sendable

    /// Loads all persisted queue entries.
    func loadEntries() throws -> [APIOfflineQueueEntry<Payload>]

    /// Persists queue entries atomically.
    func saveEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws

    /// Loads all persisted dead-letter entries.
    func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>]

    /// Persists dead-letter entries atomically.
    func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws
}

public extension APIOfflineQueueStoring {
    /// Loads dead letter entries.
    func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        []
    }

    /// Saves dead letter entries.
    func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {}
}

/// File-backed store for payload-based offline queue entries.
public struct FileAPIOfflineQueueStore<Payload>: APIOfflineQueueStoring where Payload: Codable & Sendable {
    /// Defines how store behaves when persisted JSON is corrupted.
    public enum CorruptionPolicy: Sendable, Equatable {
        /// Surface decoding/read errors to caller.
        case throwError

        /// Move corrupted file aside and recover with empty entries.
        case recoverToEmpty
    }

    private let fileURL: URL
    private let deadLetterFileURL: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder
    private let corruptionPolicy: CorruptionPolicy

    /// Creates a file-backed queue store.
    public init(
        fileURL: URL,
        corruptionPolicy: CorruptionPolicy = .recoverToEmpty,
        encoder: JSONEncoder = JSONEncoder(),
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.fileURL = fileURL
        self.deadLetterFileURL = fileURL.deletingPathExtension()
            .appendingPathExtension("deadletters")
            .appendingPathExtension(fileURL.pathExtension.isEmpty ? "json" : fileURL.pathExtension)
        self.corruptionPolicy = corruptionPolicy
        self.encoder = encoder
        self.decoder = decoder
    }

    /// Loads entries.
    public func loadEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: fileURL)
            return try decoder.decode([APIOfflineQueueEntry<Payload>].self, from: data)
        } catch let decodingError as DecodingError {
            return try recoverOrThrow(for: fileURL, error: decodingError)
        } catch {
            throw error
        }
    }

    /// Saves entries.
    public func saveEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {
        let directoryURL = fileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        let data = try encoder.encode(entries)
        try data.write(to: fileURL, options: .atomic)
    }

    /// Loads dead letter entries.
    public func loadDeadLetterEntries() throws -> [APIOfflineQueueEntry<Payload>] {
        guard FileManager.default.fileExists(atPath: deadLetterFileURL.path) else {
            return []
        }

        do {
            let data = try Data(contentsOf: deadLetterFileURL)
            return try decoder.decode([APIOfflineQueueEntry<Payload>].self, from: data)
        } catch let decodingError as DecodingError {
            return try recoverOrThrow(for: deadLetterFileURL, error: decodingError)
        } catch {
            throw error
        }
    }

    /// Saves dead letter entries.
    public func saveDeadLetterEntries(_ entries: [APIOfflineQueueEntry<Payload>]) throws {
        let directoryURL = deadLetterFileURL.deletingLastPathComponent()
        if !FileManager.default.fileExists(atPath: directoryURL.path) {
            try FileManager.default.createDirectory(
                at: directoryURL,
                withIntermediateDirectories: true
            )
        }

        let data = try encoder.encode(entries)
        try data.write(to: deadLetterFileURL, options: .atomic)
    }

    /// Handles recover or throw.
    private func recoverOrThrow(
        for url: URL,
        error: Error
    ) throws -> [APIOfflineQueueEntry<Payload>] {
        switch corruptionPolicy {
        case .throwError:
            throw error
        case .recoverToEmpty:
            let backupURL = url.appendingPathExtension("corrupted-\(Int(Date().timeIntervalSince1970))")
            try? FileManager.default.moveItem(at: url, to: backupURL)
            return []
        }
    }
}

/// Durable payload-based offline queue with retry and dead-letter handling.
public actor APIPersistedOfflineQueue<Store>: Sendable where Store: APIOfflineQueueStoring {
    /// Export payload for diagnostics, support tooling, and state transfers.
    public struct DiagnosticsPayload: Codable, Sendable where Store.Payload: Codable & Sendable {
        public let exportedAt: Date
        public let pendingEntries: [APIOfflineQueueEntry<Store.Payload>]
        public let deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>]

        /// Creates a new DiagnosticsPayload instance.
        public init(
            exportedAt: Date = Date(),
            pendingEntries: [APIOfflineQueueEntry<Store.Payload>],
            deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>]
        ) {
            self.exportedAt = exportedAt
            self.pendingEntries = pendingEntries
            self.deadLetterEntries = deadLetterEntries
        }
    }

    /// Defines how imported diagnostics payload should be applied.
    public enum DiagnosticsImportStrategy: Sendable, Equatable {
        case replace
        case append
    }

    /// Snapshot of current queue state.
    public struct Snapshot: Sendable, Equatable {
        public let pendingCount: Int
        public let deadLetterCount: Int
        public let oldestPendingCreatedAt: Date?
        public let oldestDeadLetterCreatedAt: Date?

        /// Creates a new Snapshot instance.
        public init(
            pendingCount: Int,
            deadLetterCount: Int,
            oldestPendingCreatedAt: Date?,
            oldestDeadLetterCreatedAt: Date?
        ) {
            self.pendingCount = pendingCount
            self.deadLetterCount = deadLetterCount
            self.oldestPendingCreatedAt = oldestPendingCreatedAt
            self.oldestDeadLetterCreatedAt = oldestDeadLetterCreatedAt
        }
    }

    /// Drain execution report for diagnostics and metrics.
    public struct DrainReport: Sendable, Equatable {
        public let skippedDueToNoConnectivity: Bool
        public let attempted: Int
        public let succeeded: Int
        public let failed: Int
        public let retried: Int
        public let movedToDeadLetters: Int

        /// Creates a new DrainReport instance.
        public init(
            skippedDueToNoConnectivity: Bool,
            attempted: Int,
            succeeded: Int,
            failed: Int,
            retried: Int,
            movedToDeadLetters: Int
        ) {
            self.skippedDueToNoConnectivity = skippedDueToNoConnectivity
            self.attempted = attempted
            self.succeeded = succeeded
            self.failed = failed
            self.retried = retried
            self.movedToDeadLetters = movedToDeadLetters
        }
    }

    /// Runtime settings for queue drain and retry behavior.
    public struct Configuration: Sendable, Equatable {
        /// Maximum attempts before moving an entry to dead letters.
        public let maxAttempts: Int

        /// Creates queue configuration.
        public init(maxAttempts: Int = 3) {
            self.maxAttempts = maxAttempts
        }
    }

    private let store: Store
    private let configuration: Configuration
    private var entries: [APIOfflineQueueEntry<Store.Payload>] = []
    private var deadLetterEntries: [APIOfflineQueueEntry<Store.Payload>] = []

    /// Creates a persisted offline queue.
    public init(
        store: Store,
        configuration: Configuration = .init()
    ) throws {
        self.store = store
        self.configuration = configuration
        self.entries = try store.loadEntries().sorted { $0.createdAt < $1.createdAt }
        self.deadLetterEntries = try store.loadDeadLetterEntries().sorted { $0.createdAt < $1.createdAt }
    }

    /// Number of entries waiting for execution.
    public var pendingCount: Int {
        entries.count
    }

    /// Entries that exhausted retry attempts.
    public var deadLetters: [APIOfflineQueueEntry<Store.Payload>] {
        deadLetterEntries
    }

    /// Returns a deterministic snapshot of current queue state.
    public func makeSnapshot() -> Snapshot {
        Snapshot(
            pendingCount: entries.count,
            deadLetterCount: deadLetterEntries.count,
            oldestPendingCreatedAt: entries.first?.createdAt,
            oldestDeadLetterCreatedAt: deadLetterEntries.first?.createdAt
        )
    }

    /// Exports current queue state for diagnostics or offline support workflows.
    public func exportDiagnosticsPayload() -> DiagnosticsPayload {
        DiagnosticsPayload(
            pendingEntries: entries,
            deadLetterEntries: deadLetterEntries
        )
    }

    /// Imports diagnostics payload into queue state.
    public func importDiagnosticsPayload(
        _ payload: DiagnosticsPayload,
        strategy: DiagnosticsImportStrategy = .replace
    ) throws {
        switch strategy {
        case .replace:
            entries = payload.pendingEntries.sorted { $0.createdAt < $1.createdAt }
            deadLetterEntries = payload.deadLetterEntries.sorted { $0.createdAt < $1.createdAt }
        case .append:
            entries = (entries + payload.pendingEntries).sorted { $0.createdAt < $1.createdAt }
            deadLetterEntries = (deadLetterEntries + payload.deadLetterEntries)
                .sorted { $0.createdAt < $1.createdAt }
        }

        try persist()
    }

    /// Adds payload as a new queue entry and persists state.
    public func enqueue(
        payload: Store.Payload,
        id: UUID = UUID(),
        createdAt: Date = Date()
    ) throws {
        entries.append(
            APIOfflineQueueEntry(
                id: id,
                createdAt: createdAt,
                payload: payload
            )
        )
        try persist()
    }

    /// Clears all pending entries and persists state.
    public func removeAll() throws {
        entries.removeAll()
        try persist()
    }

    /// Executes queued entries when connected.
    ///
    /// Failed entries are retried up to `maxAttempts`. Entries that exceed retries
    /// are moved to dead letters.
    public func drainIfConnected(
        using connectivityProvider: any APIConnectivityProviding,
        execute: @escaping @Sendable (Store.Payload) async throws -> Void
    ) async throws {
        _ = try await drainWithReportIfConnected(using: connectivityProvider, execute: execute)
    }

    /// Executes queued entries when connected and returns detailed drain diagnostics.
    public func drainWithReportIfConnected(
        using connectivityProvider: any APIConnectivityProviding,
        execute: @escaping @Sendable (Store.Payload) async throws -> Void
    ) async throws -> DrainReport {
        guard await connectivityProvider.isConnected() else {
            return DrainReport(
                skippedDueToNoConnectivity: true,
                attempted: 0,
                succeeded: 0,
                failed: 0,
                retried: 0,
                movedToDeadLetters: 0
            )
        }

        let drainingEntries = entries
        entries.removeAll()
        var retryEntries: [APIOfflineQueueEntry<Store.Payload>] = []
        var succeededCount = 0
        var failedCount = 0
        var retryCount = 0
        var deadLetterCount = 0

        for entry in drainingEntries {
            do {
                try await execute(entry.payload)
                succeededCount += 1
            } catch {
                failedCount += 1
                let nextEntry = entry.incrementingAttempts()
                if nextEntry.attempts >= configuration.maxAttempts {
                    deadLetterEntries.append(nextEntry)
                    deadLetterCount += 1
                } else {
                    retryEntries.append(nextEntry)
                    retryCount += 1
                }
            }
        }

        // Preserve entries enqueued while drain was in progress.
        entries = retryEntries + entries
        try persist()

        return DrainReport(
            skippedDueToNoConnectivity: false,
            attempted: drainingEntries.count,
            succeeded: succeededCount,
            failed: failedCount,
            retried: retryCount,
            movedToDeadLetters: deadLetterCount
        )
    }

    /// Handles persist.
    private func persist() throws {
        try store.saveEntries(entries)
        try store.saveDeadLetterEntries(deadLetterEntries)
    }
}

/// Static connectivity provider useful for tests and previews.
public struct StaticConnectivityProvider: APIConnectivityProviding {
    private let connected: Bool

    /// Creates a provider with a fixed connectivity state.
    public init(connected: Bool) {
        self.connected = connected
    }

    /// Checks whether connected.
    public func isConnected() async -> Bool {
        connected
    }
}

private struct QueuedOperation: Sendable {
    let id: UUID
    let operation: @Sendable () async -> Void
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

/// Creates urlrequest.
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

/// Maps transport error.
private func mapTransportError(_ error: URLError) -> APIError {
    switch error.code {
    case .cancelled:
        return .requestCancelled
    case .notConnectedToInternet:
        return .noConnection
    case .timedOut:
        return .timeout
    default:
        return .transportFailure(error.localizedDescription)
    }
}
