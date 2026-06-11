import AuthenticationServices
import Foundation

/// Normalized Apple identity payload that app code can consume without parsing framework types.
public struct AppleAuthenticationIdentity: Sendable, Equatable {
    /// Stable Apple identity identifier returned by the authorization credential.
    public let userID: String

    /// Preferred human-readable name resolved from the Apple credential, when available.
    public let displayName: String?

    /// Email returned by the Apple credential, when available.
    public let email: String?

    /// Best-effort preferred username suitable for local profile creation.
    public var preferredUsername: String? {
        if let displayName, !displayName.isEmpty {
            return displayName
        }

        guard let email else {
            return nil
        }

        return email.split(separator: "@").first.map(String.init) ?? email
    }

    /// Creates a normalized Apple identity payload.
    public init(
        userID: String,
        displayName: String? = nil,
        email: String? = nil
    ) {
        self.userID = userID
        self.displayName = displayName
        self.email = email
    }
}

/// Stable credential-state mapping exposed without leaking AuthenticationServices enums to app logic.
public enum AppleAuthenticationCredentialState: Sendable, Equatable {
    case authorized
    case revoked
    case notFound
    case transferred
}

/// Apple authentication failures that app code may need to handle explicitly.
public enum AppleAuthenticationError: Error, Equatable {
    case invalidCredential
    case credentialStateUnavailable
}

/// Contract for normalizing Apple authorization results and querying credential state.
public protocol AppleAuthenticationManaging: Sendable {
    /// Extracts a normalized identity from an Apple authorization payload.
    func identity(from authorization: ASAuthorization) throws -> AppleAuthenticationIdentity

    /// Returns whether the provided error represents a user-cancelled Apple auth flow.
    func isCancellationError(_ error: Error) -> Bool

    /// Resolves the current credential state for a previously stored Apple identity.
    func credentialState(for userID: String) async throws -> AppleAuthenticationCredentialState
}

/// Default Apple authentication adapter backed by AuthenticationServices.
public struct AppleAuthenticationManager: AppleAuthenticationManaging {
    /// Creates a new manager instance.
    public init() {}

    /// Extracts a normalized identity from an Apple authorization payload.
    public func identity(from authorization: ASAuthorization) throws -> AppleAuthenticationIdentity {
        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw AppleAuthenticationError.invalidCredential
        }

        return AppleAuthenticationIdentity(
            userID: credential.user,
            displayName: makeDisplayName(from: credential.fullName),
            email: credential.email
        )
    }

    /// Returns whether the provided error represents a user-cancelled Apple auth flow.
    public func isCancellationError(_ error: Error) -> Bool {
        guard let authorizationError = error as? ASAuthorizationError else {
            return false
        }

        return authorizationError.code == .canceled
    }

    /// Resolves the current credential state for a previously stored Apple identity.
    public func credentialState(for userID: String) async throws -> AppleAuthenticationCredentialState {
        try await withCheckedThrowingContinuation { continuation in
            ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { state, error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let credentialState = mapCredentialState(state) else {
                    continuation.resume(throwing: AppleAuthenticationError.credentialStateUnavailable)
                    return
                }

                continuation.resume(returning: credentialState)
            }
        }
    }

    /// Formats a display name from Apple-provided person name components.
    private func makeDisplayName(from components: PersonNameComponents?) -> String? {
        guard let components else {
            return nil
        }

        let formattedName = PersonNameComponentsFormatter().string(from: components)
            .trimmingCharacters(in: .whitespacesAndNewlines)
        return formattedName.isEmpty ? nil : formattedName
    }

    /// Maps the framework credential-state enum to the package-level representation.
    private func mapCredentialState(
        _ state: ASAuthorizationAppleIDProvider.CredentialState
    ) -> AppleAuthenticationCredentialState? {
        switch state {
        case .authorized:
            return .authorized
        case .revoked:
            return .revoked
        case .notFound:
            return .notFound
        case .transferred:
            return .transferred
        @unknown default:
            return nil
        }
    }
}
