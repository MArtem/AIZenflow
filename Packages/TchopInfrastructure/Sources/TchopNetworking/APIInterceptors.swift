import Foundation

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
        logger: @escaping @Sendable (String) -> Void = { _ in }
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
    private let coordinator: APIAuthorizationRefreshCoordinator

    /// Creates an authorization refresh interceptor.
    public init(
        provider: any APIAuthenticationRefreshing,
        coordinator: APIAuthorizationRefreshCoordinator = APIAuthorizationRefreshCoordinator()
    ) {
        self.provider = provider
        self.coordinator = coordinator
    }

    /// Handles retry directive.
    public func retryDirective(for error: APIError, attempt: Int, request: URLRequest) async -> APIRetryDirective {
        guard attempt == 0 else {
            return .doNotRetry
        }

        guard error.statusCode == 401 else {
            return .doNotRetry
        }

        do {
            _ = try await coordinator.refreshAuthorizationHeaders(using: provider)
            return .retry(afterNanoseconds: 0)
        } catch {
            return .doNotRetry
        }
    }
}

/// Coalesces concurrent authorization refresh requests so one 401 wave triggers one refresh operation.
public actor APIAuthorizationRefreshCoordinator {
    private var refreshTask: Task<[String: String], Error>?

    /// Creates an empty refresh coordinator.
    public init() {}

    /// Returns refreshed authorization headers, joining an in-flight refresh when one already exists.
    public func refreshAuthorizationHeaders(
        using provider: any APIAuthenticationRefreshing
    ) async throws -> [String: String] {
        if let refreshTask {
            return try await refreshTask.value
        }

        let task = Task<[String: String], Error> {
            try await provider.refreshAuthorizationHeaders()
        }
        refreshTask = task

        do {
            let headers = try await task.value
            refreshTask = nil
            return headers
        } catch {
            refreshTask = nil
            throw error
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

        switch error.statusCode {
        case .some(let statusCode) where statusCode >= 500:
            return .retry(afterNanoseconds: makeDelay(attempt: attempt))
        default:
            break
        }

        switch error {
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
