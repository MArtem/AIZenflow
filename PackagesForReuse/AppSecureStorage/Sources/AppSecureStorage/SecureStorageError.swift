import Foundation

/// Errors produced by secure storage implementations.
///
/// Error descriptions intentionally avoid exposing raw keys, values, tokens,
/// service names, access groups, URLs, or OS-provided debug strings.
public enum SecureStorageError: Error, Equatable, Sendable, LocalizedError {
    case invalidKey
    case valueTooLarge(maximumBytes: Int, actualBytes: Int)
    case encodingFailed
    case decodingFailed
    case unsupportedPlatform
    case accessDenied
    case interactionNotAllowed
    case accessControlCreationFailed
    case itemNotFound
    case keychainFailure(status: Int32)
    case unknown

    public var errorDescription: String? {
        switch self {
        case .invalidKey:
            return "The secure storage key is invalid."
        case let .valueTooLarge(maximumBytes, actualBytes):
            return "The value is too large for secure storage. Maximum: \(maximumBytes) bytes. Actual: \(actualBytes) bytes."
        case .encodingFailed:
            return "The value could not be encoded for secure storage."
        case .decodingFailed:
            return "The stored value could not be decoded."
        case .unsupportedPlatform:
            return "Secure storage is not supported on this platform."
        case .accessDenied:
            return "Access to secure storage was denied."
        case .interactionNotAllowed:
            return "Secure storage interaction is not allowed in the current context."
        case .accessControlCreationFailed:
            return "Secure storage could not create the requested access-control policy."
        case .itemNotFound:
            return "The requested secure storage item was not found."
        case let .keychainFailure(status):
            return "Secure storage failed with status code \(status)."
        case .unknown:
            return "Secure storage failed with an unknown error."
        }
    }
}
