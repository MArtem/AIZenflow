import Foundation

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
        case let .failure(error):
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
