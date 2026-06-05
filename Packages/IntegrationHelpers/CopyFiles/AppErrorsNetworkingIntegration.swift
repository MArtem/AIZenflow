import AppErrors
import AppNetworking

/// Optional integration helper for projects that use both `AppErrors` and `AppNetworking`.
///
/// Copy this file into the host app/integration target when both root packages are already present.
/// It intentionally lives outside both packages so each package remains single-folder standalone.
public struct APIErrorAppErrorMapper: AppErrorMapping {
    public init() {}

    public func map(_ error: Error, context: AppErrorContext? = nil) -> AppError {
        if let httpFailure = error as? APIHTTPFailure {
            return mapStatusCode(httpFailure.statusCode, context: context)
        }

        guard let apiError = error as? APIError else {
            return UnknownAppErrorMapper().map(error, context: context)
        }

        return mapAPIError(apiError, context: context)
    }

    public func map(_ error: APIError, context: AppErrorContext? = nil) -> AppError {
        mapAPIError(error, context: context)
    }

    public func mapAPIError(_ error: APIError, context: AppErrorContext? = nil) -> AppError {
        if let code = error.statusCode {
            return mapStatusCode(code, context: context)
        }

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
        case .httpFailure(let failure):
            return mapStatusCode(failure.statusCode, context: context)
        case .invalidStatusCode:
            preconditionFailure("Status-code errors are handled before the switch.")
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
        case .invalidResponse, .transportFailure:
            return AppError(
                category: .unknown,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.unknown",
                debugDescription: "Unknown transport or response failure.",
                context: context
            )
        }
    }

    private func mapStatusCode(_ code: Int, context: AppErrorContext?) -> AppError {
        switch code {
        case 401:
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
        case 500...:
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
        default:
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
        }
    }
}

/// Fallback mapper that normalizes known networking errors and degrades safely for unknown ones.
public struct DefaultNetworkingAwareAppErrorMapper: AppErrorMapping {
    private let apiErrorMapper: APIErrorAppErrorMapper

    public init(apiErrorMapper: APIErrorAppErrorMapper = APIErrorAppErrorMapper()) {
        self.apiErrorMapper = apiErrorMapper
    }

    public func map(_ error: Error, context: AppErrorContext? = nil) -> AppError {
        if error is APIError || error is APIHTTPFailure {
            return apiErrorMapper.map(error, context: context)
        }

        return UnknownAppErrorMapper().map(error, context: context)
    }
}

public extension AppErrorManager {
    /// Creates an error manager with networking-aware error mapping.
    init(
        networkingAwareMessageCatalog messageCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog(),
        reporter: (any AppErrorReporting)? = nil
    ) {
        self.init(
            mapper: DefaultNetworkingAwareAppErrorMapper(),
            messageCatalog: messageCatalog,
            reporter: reporter
        )
    }
}
