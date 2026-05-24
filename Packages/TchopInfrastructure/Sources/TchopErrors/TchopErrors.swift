import Foundation
import TchopNetworking

/// Stable top-level error categories used by app-facing layers.
public enum AppErrorCategory: String, Sendable, Equatable, Codable {
    case authentication
    case authorization
    case network
    case server
    case client
    case persistence
    case validation
    case unknown
}

/// Severity hint used by UI and telemetry pipelines.
public enum AppErrorSeverity: String, Sendable, Equatable, Codable {
    case info
    case warning
    case error
    case critical
}

/// Recovery hint that higher layers can use for user guidance.
public enum AppRecoverySuggestion: String, Sendable, Equatable, Codable {
    case retry
    case reauthenticate
    case checkConnection
    case restartFlow
    case none
}

/// Optional metadata attached to mapped app errors.
public struct AppErrorContext: Sendable, Equatable, Codable {
    public let operation: String
    public let feature: String
    public let metadata: [String: String]

    public init(
        operation: String,
        feature: String,
        metadata: [String: String] = [:]
    ) {
        self.operation = operation
        self.feature = feature
        self.metadata = metadata
    }
}

/// App-facing error type that normalizes raw infra/domain failures.
public struct AppError: Error, Sendable, Equatable, Codable {
    public let category: AppErrorCategory
    public let severity: AppErrorSeverity
    public let suggestion: AppRecoverySuggestion
    public let isRetryable: Bool
    public let isSessionRecoveryRequired: Bool
    public let messageKey: String
    public let debugDescription: String
    public let context: AppErrorContext?

    public init(
        category: AppErrorCategory,
        severity: AppErrorSeverity,
        suggestion: AppRecoverySuggestion,
        isRetryable: Bool,
        isSessionRecoveryRequired: Bool,
        messageKey: String,
        debugDescription: String,
        context: AppErrorContext? = nil
    ) {
        self.category = category
        self.severity = severity
        self.suggestion = suggestion
        self.isRetryable = isRetryable
        self.isSessionRecoveryRequired = isSessionRecoveryRequired
        self.messageKey = messageKey
        self.debugDescription = debugDescription
        self.context = context
    }
}

/// Logging/reporting payload emitted for one normalized app error.
public struct AppErrorLoggingPayload: Sendable, Equatable, Codable {
    public let category: AppErrorCategory
    public let severity: AppErrorSeverity
    public let suggestion: AppRecoverySuggestion
    public let messageKey: String
    public let debugDescription: String
    public let feature: String?
    public let operation: String?

    public init(error: AppError) {
        self.category = error.category
        self.severity = error.severity
        self.suggestion = error.suggestion
        self.messageKey = error.messageKey
        self.debugDescription = error.debugDescription
        self.feature = error.context?.feature
        self.operation = error.context?.operation
    }
}

/// Message catalog used by presentation layers to convert mapped errors into user text.
public protocol AppErrorMessageCatalog: Sendable {
    func userMessage(for error: AppError) -> String
}

/// Maps arbitrary runtime errors into stable app-facing errors.
public protocol AppErrorMapping: Sendable {
    func map(_ error: Error, context: AppErrorContext?) -> AppError
}

/// Default fallback catalog for app errors when no feature-specific localization is injected.
public struct DefaultAppErrorMessageCatalog: AppErrorMessageCatalog {
    public init() {}

    public func userMessage(for error: AppError) -> String {
        switch error.messageKey {
        case "error.auth.required":
            return "Session expired. Please sign in again."
        case "error.network.offline":
            return "No internet connection. Try again when you are back online."
        case "error.network.timeout":
            return "The request timed out. Please retry."
        case "error.server.unavailable":
            return "Service is temporarily unavailable. Please retry."
        default:
            return "Something went wrong. Please try again."
        }
    }
}

/// Reporter interface for app error observability sinks.
public protocol AppErrorReporting: Sendable {
    func report(_ payload: AppErrorLoggingPayload) async
}

/// In-memory reporter useful for diagnostics and tests.
public actor MemoryAppErrorReporter: AppErrorReporting {
    private var payloadsStorage: [AppErrorLoggingPayload] = []

    public init() {}

    public var payloads: [AppErrorLoggingPayload] {
        payloadsStorage
    }

        /// Stores one mapped error payload for later diagnostics/test assertions.
public func report(_ payload: AppErrorLoggingPayload) async {
        payloadsStorage.append(payload)
    }
}

/// Maps networking failures into stable app-facing error semantics.
public struct APIErrorAppErrorMapper: AppErrorMapping {
    public init() {}

        /// Maps an arbitrary error into app-facing semantics, delegating known API errors to the API mapper.
public func map(_ error: Error, context: AppErrorContext?) -> AppError {
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
public func map(_ error: Error, context: AppErrorContext?) -> AppError {
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

/// Presentation-ready error payload returned by the manager for UI-facing consumers.
public struct AppErrorPresentation: Sendable, Equatable {
    public let error: AppError
    public let userMessage: String

    public init(error: AppError, userMessage: String) {
        self.error = error
        self.userMessage = userMessage
    }
}

/// High-level facade that normalizes, reports, and localizes app errors in one place.
public protocol AppErrorManaging: Sendable {
    func presentableError(
        from error: Error,
        context: AppErrorContext?
    ) async -> AppErrorPresentation
}

/// Default production-ready error manager used by app-facing layers.
public struct AppErrorManager: AppErrorManaging {
    private let mapper: any AppErrorMapping
    private let messageCatalog: any AppErrorMessageCatalog
    private let reporter: (any AppErrorReporting)?

    public init(
        mapper: any AppErrorMapping = DefaultAppErrorMapper(),
        messageCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog(),
        reporter: (any AppErrorReporting)? = nil
    ) {
        self.mapper = mapper
        self.messageCatalog = messageCatalog
        self.reporter = reporter
    }

        /// Normalizes, reports, and localizes an error for UI presentation.
public func presentableError(
        from error: Error,
        context: AppErrorContext? = nil
    ) async -> AppErrorPresentation {
        let mappedError = mapper.map(error, context: context)

        if let reporter {
            await reporter.report(AppErrorLoggingPayload(error: mappedError))
        }

        return AppErrorPresentation(
            error: mappedError,
            userMessage: messageCatalog.userMessage(for: mappedError)
        )
    }
}
