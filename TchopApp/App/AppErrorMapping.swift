import Foundation
import TchopDatabase
import TchopErrors

/// App-local error mapper layered on top of the shared infrastructure mapper.
///
/// `TchopErrors` intentionally knows only generic infrastructure failures. This mapper keeps
/// feature-specific semantics in the app target so repository/session errors can carry stable
/// categories, retry policy, and recovery hints before a real backend is connected.
struct AppRuntimeErrorMapper: AppErrorMapping {
    private let fallbackMapper: any AppErrorMapping

    init(fallbackMapper: any AppErrorMapping = DefaultAppErrorMapper()) {
        self.fallbackMapper = fallbackMapper
    }

    func map(_ error: Error, context: AppErrorContext?) -> AppError {
        if let databaseError = error as? DatabaseError {
            return mapDatabaseError(databaseError, context: context)
        }

        if let authenticationError = error as? AuthenticationSessionError {
            return mapAuthenticationError(authenticationError, context: context)
        }

        if let userRepositoryError = error as? UserRepositoryError {
            return mapUserRepositoryError(userRepositoryError, context: context)
        }

        if let repositoryError = error as? RepositoryError {
            return mapRepositoryError(repositoryError, context: context)
        }

        let secureStorageError = error as NSError
        if secureStorageError.domain == NSOSStatusErrorDomain {
            return AppError(
                category: .persistence,
                severity: .critical,
                suggestion: .reauthenticate,
                isRetryable: false,
                isSessionRecoveryRequired: true,
                messageKey: "error.persistence.secureStorage",
                debugDescription: "Secure storage failure: \(secureStorageError.code).",
                context: context
            )
        }

        return fallbackMapper.map(error, context: context)
    }

    private func mapDatabaseError(
        _ error: DatabaseError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .backendInitializationFailed(let reason), .migrationFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .critical,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseBootstrap",
                debugDescription: reason,
                context: context
            )
        case .transactionFailed(let reason), .saveFailed(let reason), .deleteFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseWrite",
                debugDescription: reason,
                context: context
            )
        case .fetchFailed(let reason):
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.databaseRead",
                debugDescription: reason,
                context: context
            )
        case .unsupportedOperation(let reason):
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.unsupportedOperation",
                debugDescription: reason,
                context: context
            )
        }
    }

    private func mapAuthenticationError(
        _ error: AuthenticationSessionError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .missingRefreshToken:
            return AppError(
                category: .authentication,
                severity: .error,
                suggestion: .reauthenticate,
                isRetryable: false,
                isSessionRecoveryRequired: true,
                messageKey: "error.auth.refreshMissing",
                debugDescription: "Refresh was requested without a persisted refresh token.",
                context: context
            )
        }
    }

    private func mapRepositoryError(
        _ error: RepositoryError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .offlineCardAction:
            return AppError(
                category: .network,
                severity: .warning,
                suggestion: .checkConnection,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.network.offline",
                debugDescription: "Card action requires connectivity but the device is offline.",
                context: context
            )
        case .missingPersistedFeed:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.feedMissing",
                debugDescription: "Persisted feed snapshot is unavailable.",
                context: context
            )
        case .missingPersistedFeedCard:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.feedCardMissing",
                debugDescription: "Persisted feed card is unavailable for the requested action.",
                context: context
            )
        case .missingChannel:
            return AppError(
                category: .persistence,
                severity: .error,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.channelMissing",
                debugDescription: "Persisted channel bootstrap data is unavailable.",
                context: context
            )
        case .unsupportedCardAction:
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .retry,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.unsupportedCardAction",
                debugDescription: "The requested feed card action cannot be mapped into the current sync contract.",
                context: context
            )
        case .unsupportedLocalFeedCardPersistence:
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .retry,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.unsupportedCardAction",
                debugDescription: "The requested local feed card shape is not supported by the current persistence contract.",
                context: context
            )
        }
    }

    private func mapUserRepositoryError(
        _ error: UserRepositoryError,
        context: AppErrorContext?
    ) -> AppError {
        switch error {
        case .invalidUsername:
            return AppError(
                category: .validation,
                severity: .warning,
                suggestion: .none,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.validation.username",
                debugDescription: "The provided username is invalid after normalization.",
                context: context
            )
        case .unableToResolveUniqueUsername:
            return AppError(
                category: .client,
                severity: .error,
                suggestion: .retry,
                isRetryable: true,
                isSessionRecoveryRequired: false,
                messageKey: "error.client.usernameResolution",
                debugDescription: "Unable to resolve a unique local username for the account.",
                context: context
            )
        case .userNotFound:
            return AppError(
                category: .persistence,
                severity: .warning,
                suggestion: .restartFlow,
                isRetryable: false,
                isSessionRecoveryRequired: false,
                messageKey: "error.persistence.userMissing",
                debugDescription: "Expected persisted user record is missing.",
                context: context
            )
        }
    }
}

/// App-local message catalog for domain-specific failures, delegating infrastructure keys to package defaults.
struct AppRuntimeErrorMessageCatalog: AppErrorMessageCatalog {
    private let fallbackCatalog: any AppErrorMessageCatalog

    init(fallbackCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog()) {
        self.fallbackCatalog = fallbackCatalog
    }

    func userMessage(for error: AppError) -> String {
        switch error.messageKey {
        case "error.auth.refreshMissing":
            return AppLocalization.text("auth.error.refreshMissing")
        case "error.persistence.secureStorage":
            return AppLocalization.text("auth.error.secureStorage")
        case "error.persistence.feedMissing":
            return AppLocalization.text("news.error.savedFeedMissing")
        case "error.persistence.feedCardMissing":
            return AppLocalization.text("news.error.savedCardMissing")
        case "error.persistence.channelMissing":
            return AppLocalization.text("shell.error.channelMissing")
        case "error.persistence.databaseBootstrap":
            return AppLocalization.text("app.error.databaseBootstrap")
        case "error.persistence.databaseWrite":
            return AppLocalization.text("app.error.databaseWrite")
        case "error.persistence.databaseRead":
            return AppLocalization.text("app.error.databaseRead")
        case "error.validation.username":
            return AppLocalization.text("login.error.invalidUsername")
        case "error.client.usernameResolution":
            return AppLocalization.text("login.apple.error.usernameResolution")
        case "error.persistence.userMissing":
            return AppLocalization.text("profile.error.userMissing")
        default:
            return fallbackCatalog.userMessage(for: error)
        }
    }
}
