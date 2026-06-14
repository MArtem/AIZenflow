import Foundation

public protocol UploadRetrySleeping: Sendable {
    func sleep(nanoseconds: UInt64) async throws
}

public struct TaskUploadRetrySleeper: UploadRetrySleeping {
    public init() {}

    public func sleep(nanoseconds: UInt64) async throws {
        try await Task.sleep(nanoseconds: nanoseconds)
    }
}

public actor UploadService {
    private let transport: any UploadTransport
    private let bodyWorker: UploadBodyLoadWorker
    private let retrySleeper: any UploadRetrySleeping

    public init(
        transport: any UploadTransport = FoundationUploadTransport(),
        bodyWorker: UploadBodyLoadWorker = UploadBodyLoadWorker(),
        retrySleeper: any UploadRetrySleeping = TaskUploadRetrySleeper()
    ) {
        self.transport = transport
        self.bodyWorker = bodyWorker
        self.retrySleeper = retrySleeper
    }

    public func upload(
        _ request: UploadRequest,
        progress: (@Sendable (UploadProgress) -> Void)? = nil
    ) async throws -> UploadResponse {
        let prepared = try await bodyWorker.prepare(request)
        var lastFailure: UploadFailure?

        for attempt in 1...request.retryPolicy.maximumAttempts {
            do {
                let response = try await transport.send(prepared, progress: progress)
                if let maximumResponseBytes = request.maximumResponseBytes, response.responseByteCount > maximumResponseBytes {
                    throw UploadFailure(.responseTooLarge, operation: .transport)
                }
                return response
            } catch let failure as UploadFailure {
                lastFailure = failure
            } catch is CancellationError {
                throw CancellationError()
            } catch {
                if Task.isCancelled {
                    throw CancellationError()
                }
                lastFailure = UploadFailure(.transportUnavailable, operation: .transport)
            }

            if attempt < request.retryPolicy.maximumAttempts, request.retryPolicy.delayNanoseconds > 0 {
                try await retrySleeper.sleep(nanoseconds: request.retryPolicy.delayNanoseconds)
            }
        }

        throw lastFailure ?? UploadFailure(.retryLimitExceeded, operation: .retry)
    }
}
