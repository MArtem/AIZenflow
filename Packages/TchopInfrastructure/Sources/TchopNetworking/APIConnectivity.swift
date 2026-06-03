import Foundation

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

struct QueuedOperation: Sendable {
    let id: UUID
    let operation: @Sendable () async -> Void
}

final class AnySendableResult: Sendable {
    let result: Result<any Sendable, APIError>

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
func makeURLRequest<Response>(
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
func mapTransportError(_ error: URLError) -> APIError {
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
