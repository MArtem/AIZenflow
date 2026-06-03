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

    /// Default configuration used by stub-based tests and local development flows.
    public static let stub = APIConfiguration(
        baseURL: URL(string: "https://stub.local")!,
        defaultHeaders: [:],
        timeoutInterval: 30
    )
}

/// Captured HTTP failure details available to endpoint-specific error mappers.
///
/// Security:
/// The response body and headers may contain sensitive server data. Callers must not log them without explicit
/// redaction. Body capture is bounded to avoid retaining arbitrarily large error responses.
public struct APIHTTPFailure: Error, Equatable, Sendable {
    /// Maximum number of response-body bytes retained by default.
    public static let defaultMaximumCapturedBodyBytes = 64 * 1024

    /// HTTP status code returned by the server.
    public let statusCode: Int

    /// Bounded UTF-8 response body, when one was available.
    ///
    /// Text capture is intentional: backend error payloads are expected to be JSON/text, while retaining arbitrary
    /// binary bodies inside long-lived error values adds memory and tooling risk without useful mapping semantics.
    public let bodyText: String?

    /// Response headers normalized to string keys and values.
    public let headers: [String: String]

    /// Creates a captured HTTP failure.
    public init(
        statusCode: Int,
        body: Data?,
        headers: [String: String],
        maximumCapturedBodyBytes: Int = APIHTTPFailure.defaultMaximumCapturedBodyBytes
    ) {
        self.statusCode = statusCode
        self.bodyText = body.flatMap {
            String(data: Data($0.prefix(max(0, maximumCapturedBodyBytes))), encoding: .utf8)
        }
        self.headers = headers
    }
}

/// Typed errors surfaced by the networking layer.
public enum APIError: Error, Equatable, Sendable {
    case badURL(path: String)
    case noConnection
    case invalidResponse
    /// Legacy status-only error retained for source compatibility with existing callers.
    case invalidStatusCode(Int)
    case decodingFailed(String)
    case requestCancelled
    case timeout
    case transportFailure(String)

    /// HTTP status code for status-code failures.
    public var statusCode: Int? {
        switch self {
        case .invalidStatusCode(let statusCode):
            return statusCode
        default:
            return nil
        }
    }
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
        if let httpFailure = error as? APIHTTPFailure {
            return .invalidStatusCode(httpFailure.statusCode)
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
