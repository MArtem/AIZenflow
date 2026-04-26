import Foundation
import TchopAppleAuthentication
import TchopNetworking

/// Configurable endpoint contract for backend authentication routes.
///
/// The app can lock its service boundaries now without binding itself to final backend naming.
/// When real endpoints arrive, most changes should stay inside this configuration and the DTOs below.
struct AuthenticationAPIEndpointConfiguration {
    let usernameSignInPath: String
    let appleSignInPath: String
    let refreshPath: String
    let revokePath: String

    static let `default` = AuthenticationAPIEndpointConfiguration(
        usernameSignInPath: "auth/sign-in",
        appleSignInPath: "auth/apple/sign-in",
        refreshPath: "auth/refresh",
        revokePath: "auth/revoke"
    )
}

/// Backend auth response contract that can absorb either absolute expiry timestamps or expires-in values.
private struct AuthenticationTokenResponseDTO: Decodable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date?
    let expiresIn: TimeInterval?
    let tokenType: String?
}

private extension AuthenticationTokenResponseDTO {
    func makeTokenSet(referenceDate: Date = Date()) -> AuthTokenSet {
        let resolvedExpiry = expiresAt
            ?? referenceDate.addingTimeInterval(expiresIn ?? 3600)

        return AuthTokenSet(
            accessToken: accessToken,
            refreshToken: refreshToken,
            expiresAt: resolvedExpiry,
            tokenType: tokenType ?? "Bearer"
        )
    }
}

private struct UsernameSignInRequestDTO: Encodable, Sendable {
    let username: String
}

private struct AppleSignInRequestDTO: Encodable, Sendable {
    let userID: String
    let displayName: String?
    let email: String?
    let preferredUsername: String?
}

private struct RefreshTokenRequestDTO: Encodable, Sendable {
    let refreshToken: String
}

private struct RevokeSessionRequestDTO: Encodable, Sendable {
    let accessToken: String?
}

/// Production-shaped auth API manager that can run either against synthetic local stub tokens
/// or against real transport routes once backend endpoints exist.
struct DefaultAuthenticationAPIManager: AuthenticationAPIManaging {
    enum Mode {
        case localStub
        case remote
    }

    private let apiManager: any APIManaging
    private let endpointConfiguration: AuthenticationAPIEndpointConfiguration
    private let mode: Mode
    private let jsonEncoder: JSONEncoder
    private let jsonDecoder: JSONDecoder

    init(
        apiManager: any APIManaging,
        endpointConfiguration: AuthenticationAPIEndpointConfiguration = .default,
        mode: Mode,
        jsonEncoder: JSONEncoder = JSONEncoder(),
        jsonDecoder: JSONDecoder = JSONDecoder()
    ) {
        self.apiManager = apiManager
        self.endpointConfiguration = endpointConfiguration
        self.mode = mode
        self.jsonEncoder = jsonEncoder
        self.jsonDecoder = jsonDecoder
    }

    func signIn(username: String) async throws -> AuthTokenSet {
        switch mode {
        case .localStub:
            return makeSyntheticTokenSet(subject: "username:\(username)")
        case .remote:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.usernameSignInPath,
                    method: .post,
                    payload: UsernameSignInRequestDTO(username: username)
                )
            )
            return response.makeTokenSet()
        }
    }

    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet {
        switch mode {
        case .localStub:
            return makeSyntheticTokenSet(subject: "apple:\(identity.userID)")
        case .remote:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.appleSignInPath,
                    method: .post,
                    payload: AppleSignInRequestDTO(
                        userID: identity.userID,
                        displayName: identity.displayName,
                        email: identity.email,
                        preferredUsername: identity.preferredUsername
                    )
                )
            )
            return response.makeTokenSet()
        }
    }

    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet {
        switch mode {
        case .localStub:
            return makeSyntheticTokenSet(subject: "refresh:\(refreshToken)")
        case .remote:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.refreshPath,
                    method: .post,
                    payload: RefreshTokenRequestDTO(refreshToken: refreshToken)
                )
            )
            return response.makeTokenSet()
        }
    }

    func revokeSession(accessToken: String?) async throws {
        switch mode {
        case .localStub:
            return
        case .remote:
            _ = try await apiManager.perform(
                emptyResponseRequest(
                    path: endpointConfiguration.revokePath,
                    method: .post,
                    payload: RevokeSessionRequestDTO(accessToken: accessToken)
                )
            ) as APIEmptyResponse
        }
    }

    /// Builds a JSON-decoding auth request with the manager's shared encoder/decoder policy.
    private func tokenRequest<Payload: Encodable & Sendable>(
        path: String,
        method: HTTPMethod,
        payload: Payload
    ) throws -> APIRequest<AuthenticationTokenResponseDTO> {
        try APIRequest<AuthenticationTokenResponseDTO>.json(
            path: path,
            method: method,
            headers: ["Content-Type": "application/json"],
            body: jsonEncoder.encode(payload),
            jsonDecoder: jsonDecoder
        )
    }

    /// Builds a JSON request that expects no response payload.
    private func emptyResponseRequest<Payload: Encodable & Sendable>(
        path: String,
        method: HTTPMethod,
        payload: Payload
    ) throws -> APIRequest<APIEmptyResponse> {
        try APIRequest<APIEmptyResponse>.json(
            path: path,
            method: method,
            headers: ["Content-Type": "application/json"],
            body: jsonEncoder.encode(payload),
            jsonDecoder: jsonDecoder
        )
    }

    /// Synthetic stub tokens keep the auth/session foundation exercised locally before real endpoints exist.
    private func makeSyntheticTokenSet(subject: String) -> AuthTokenSet {
        let issuedAt = Date()
        let normalizedSubject = subject.replacingOccurrences(of: " ", with: "-")
        return AuthTokenSet(
            accessToken: "stub-access-\(normalizedSubject)-\(issuedAt.timeIntervalSince1970)",
            refreshToken: "stub-refresh-\(normalizedSubject)",
            expiresAt: issuedAt.addingTimeInterval(3600),
            tokenType: "Bearer"
        )
    }
}
