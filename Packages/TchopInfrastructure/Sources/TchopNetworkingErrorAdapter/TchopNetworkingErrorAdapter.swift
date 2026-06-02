import TchopErrorsCore
import TchopNetworking

/// Maps networking failures into stable app-facing error semantics.
public struct APIErrorAppErrorMapper: AppErrorMapping {
    public init() {}

    /// Maps an arbitrary error into app-facing semantics, delegating known API errors to the API mapper.
    public func map(_ error: Error, context: AppErrorContext? = nil) -> AppError {
        guard let apiError = error as? APIError else {
            return AppError(
                category: .unknown,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.unknown",
                debugDescription: String(describing: error),
                context: context
            )
        }

        return mapAPIError(apiError, context: context)
    }

    /// Maps a concrete networking `APIError` while preserving call-site type inference for API-specific tests/callers.
    public func map(_ error: APIError, context: AppErrorContext? = nil) -> AppError {
        mapAPIError(error, context: context)
    }

    /// Maps a concrete networking `APIError` into stable app-facing error semantics.
    public func mapAPIError(_ error: APIError, context: AppErrorContext? = nil) -> AppError {
        switch error {
        case .requestCancelled:
            return AppError(
                category: .client,
                severity: .info,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.request.cancelled",
                debugDescription: "Request cancelled.",
                context: context
            )
        case .noConnection:
            return AppError(
                category: .network,
                severity: .warning,
                suggestion: .checkConnection,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.network.offline",
                debugDescription: "Network unavailable.",
                context: context
            )
        case .timeout:
            return AppError(
                category: .network,
                severity: .warning,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.network.timeout",
                debugDescription: "Request timed out.",
                context: context
            )
        case .invalidStatusCode(let code) where code == 401:
            return AppError(
                category: .authentication,
                severity: .error,
                suggestion: .reauthenticate,
                isRetryable: false,
                isSessionRecoveryRequired: true,
                messageKey: "error.auth.required",
                debugDescription: "Unauthorized status code \(code).",
                context: context
            )
        case .invalidStatusCode(let code) where code >= 500:
            return AppError(
                category: .server,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.server.unavailable",
                debugDescription: "Server failure status code \(code).",
                context: context
            )
        case .invalidStatusCode(let code):
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.invalidResponse",
                debugDescription: "Invalid status code \(code).",
                context: context
            )
        case .decodingFailed(let reason):
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.decoding",
                debugDescription: "Decoding failed: \(reason)",
                context: context
            )
        case .badURL(let path):
            return AppError(
                category: .client,
                severity: .critical,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.badURL",
                debugDescription: "Bad URL path: \(path)",
                context: context
            )
        case .invalidResponse, .transportFailure(_):
            return AppError(
                category: .unknown,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.unknown",
                debugDescription: String(describing: error),
                context: context
            )
        }
    }
}

/// Fallback mapper that normalizes known infrastructure errors and degrades safely for unknown ones.
public struct DefaultAppErrorMapper: AppErrorMapping {
    private let apiErrorMapper: APIErrorAppErrorMapper

    public init(apiErrorMapper: APIErrorAppErrorMapper = APIErrorAppErrorMapper()) {
        self.apiErrorMapper = apiErrorMapper
    }

    /// Maps an arbitrary error into app-facing semantics, delegating known API errors to the API mapper.
    public func map(_ error: Error, context: AppErrorContext? = nil) -> AppError {
        if error is APIError {
            return apiErrorMapper.map(error, context: context)
        }

        return AppError(
            category: .unknown,
            severity: .error,
            suggestion: .retry,
            isRetryable: true,
            isSessionRecoveryRequired: false,
            messageKey: "error.unknown",
            debugDescription: String(describing: error),
            context: context
        )
    }
}

