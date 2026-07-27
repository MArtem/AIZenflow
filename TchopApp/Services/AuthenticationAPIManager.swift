import Foundation

/// Configurable endpoint contract for backend authentication routes.
///
/// The app can lock its service boundaries now without binding itself to final backend naming.
/// When real endpoints arrive, most changes should stay inside this configuration and the DTOs below.
struct AuthenticationAPIEndpointConfiguration: Sendable {
    let usernameSignInPath: String
    let credentialSignInPath: String
    let registrationPath: String
    let appleSignInPath: String
    let refreshPath: String
    let revokePath: String

    static let `default` = AuthenticationAPIEndpointConfiguration(
        usernameSignInPath: "auth/sign-in",
        credentialSignInPath: "auth/login",
        registrationPath: "auth/register",
        appleSignInPath: "auth/apple/sign-in",
        refreshPath: "auth/refresh",
        revokePath: "auth/revoke"
    )

    /// ReqRes demo-auth routes used by the external development environment.
    static let reqResDemo = AuthenticationAPIEndpointConfiguration(
        usernameSignInPath: "api/login",
        credentialSignInPath: "api/login",
        registrationPath: "api/register",
        appleSignInPath: "api/login",
        refreshPath: "api/login",
        revokePath: "api/logout"
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

private struct CredentialSignInRequestDTO: Encodable, Sendable {
    let email: String
    let password: String
}

private struct AppleSignInRequestDTO: Encodable, Sendable {
    let userID: String
    let identityToken: String?
    let authorizationCode: String?
    let nonce: String?
    let state: String?
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

private struct ReqResDemoTokenResponseDTO: Decodable, Sendable {
    let id: Int?
    let token: String
}

private extension ReqResDemoTokenResponseDTO {
    func makeTokenSet(subject: String, referenceDate: Date = Date()) -> AuthTokenSet {
        AuthTokenSet(
            accessToken: token,
            refreshToken: "reqres-demo-refresh-\(subject)",
            expiresAt: referenceDate.addingTimeInterval(3600),
            tokenType: "Bearer"
        )
    }
}

/// Production-shaped auth API manager that can run either against synthetic development stub tokens
/// or against real transport routes once backend endpoints exist.
struct DefaultAuthenticationAPIManager: AuthenticationAPIManaging {
    enum Mode {
        case developmentSynthetic
        case remoteBackend
        case reqResDemo
    }

    private let apiManager: any APIManaging
    private let endpointConfiguration: AuthenticationAPIEndpointConfiguration
    private let mode: Mode

    init(
        apiManager: any APIManaging,
        endpointConfiguration: AuthenticationAPIEndpointConfiguration = .default,
        mode: Mode
    ) {
        self.apiManager = apiManager
        self.endpointConfiguration = endpointConfiguration
        self.mode = mode
    }

    func signIn(username: String) async throws -> AuthTokenSet {
        switch mode {
        case .developmentSynthetic:
            return makeSyntheticTokenSet(subject: "username:\(username)")
        case .remoteBackend:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.usernameSignInPath,
                    method: .post,
                    payload: UsernameSignInRequestDTO(username: username)
                )
            )
            return response.makeTokenSet()
        case .reqResDemo:
            // ReqRes external auth is email/password-based. Username login remains a synthetic
            // fallback so local launch/test helpers do not need a parallel bootstrap path.
            return makeSyntheticTokenSet(subject: "username:\(username)")
        }
    }

    func signIn(email: String, password: String) async throws -> AuthTokenSet {
        switch mode {
        case .developmentSynthetic:
            return makeSyntheticTokenSet(subject: "email:\(email)")
        case .remoteBackend:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.credentialSignInPath,
                    method: .post,
                    payload: CredentialSignInRequestDTO(email: email, password: password)
                )
            )
            return response.makeTokenSet()
        case .reqResDemo:
            let response = try await apiManager.perform(
                reqResDemoTokenRequest(
                    path: endpointConfiguration.credentialSignInPath,
                    payload: CredentialSignInRequestDTO(email: email, password: password)
                )
            )
            return response.makeTokenSet(subject: email)
        }
    }

    func register(email: String, password: String) async throws -> AuthTokenSet {
        switch mode {
        case .developmentSynthetic:
            return makeSyntheticTokenSet(subject: "register:\(email)")
        case .remoteBackend:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.registrationPath,
                    method: .post,
                    payload: CredentialSignInRequestDTO(email: email, password: password)
                )
            )
            return response.makeTokenSet()
        case .reqResDemo:
            let response = try await apiManager.perform(
                reqResDemoTokenRequest(
                    path: endpointConfiguration.registrationPath,
                    payload: CredentialSignInRequestDTO(email: email, password: password)
                )
            )
            return response.makeTokenSet(subject: "register-\(email)")
        }
    }

    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet {
        switch mode {
        case .developmentSynthetic:
            return makeSyntheticTokenSet(subject: "apple:\(identity.userID)")
        case .remoteBackend:
            guard identity.identityToken != nil || identity.authorizationCode != nil else {
                throw AuthenticationSessionError.missingAppleIdentityProof
            }

            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.appleSignInPath,
                    method: .post,
                    payload: AppleSignInRequestDTO(
                        userID: identity.userID,
                        identityToken: identity.identityToken,
                        authorizationCode: identity.authorizationCode,
                        nonce: identity.nonce,
                        state: identity.state,
                        displayName: identity.displayName,
                        email: identity.email,
                        preferredUsername: identity.preferredUsername
                    )
                )
            )
            return response.makeTokenSet()
        case .reqResDemo:
            return makeSyntheticTokenSet(subject: "apple:\(identity.userID)")
        }
    }

    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet {
        switch mode {
        case .developmentSynthetic:
            return makeSyntheticTokenSet(subject: "refresh:\(refreshToken)")
        case .remoteBackend:
            let response = try await apiManager.perform(
                tokenRequest(
                    path: endpointConfiguration.refreshPath,
                    method: .post,
                    payload: RefreshTokenRequestDTO(refreshToken: refreshToken)
                )
            )
            return response.makeTokenSet()
        case .reqResDemo:
            return makeSyntheticTokenSet(subject: "refresh:\(refreshToken)")
        }
    }

    func revokeSession(accessToken: String?) async throws {
        switch mode {
        case .developmentSynthetic, .reqResDemo:
            return
        case .remoteBackend:
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
            body: makeJSONEncoder().encode(payload),
            jsonDecoder: makeJSONDecoder()
        )
    }

    /// ReqRes demo auth returns `{ token, id? }`, not the app's production-shaped token DTO.
    private func reqResDemoTokenRequest<Payload: Encodable & Sendable>(
        path: String,
        payload: Payload
    ) throws -> APIRequest<ReqResDemoTokenResponseDTO> {
        try APIRequest<ReqResDemoTokenResponseDTO>.json(
            path: path,
            method: .post,
            headers: ["Content-Type": "application/json"],
            body: makeJSONEncoder().encode(payload),
            jsonDecoder: makeJSONDecoder()
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
            body: makeJSONEncoder().encode(payload),
            jsonDecoder: makeJSONDecoder()
        )
    }

    /// Explicit development synthetic tokens keep the auth/session foundation exercised before real endpoints exist.
    private func makeSyntheticTokenSet(subject: String) -> AuthTokenSet {
        let issuedAt = Date()
        let normalizedSubject = subject.replacingOccurrences(of: " ", with: "-")
        return AuthTokenSet(
            accessToken: "dev-access-\(normalizedSubject)-\(issuedAt.timeIntervalSince1970)",
            refreshToken: "dev-refresh-\(normalizedSubject)",
            expiresAt: issuedAt.addingTimeInterval(3600),
            tokenType: "Bearer"
        )
    }

    /// Builds the per-request JSON encoder used for auth payloads.
    private func makeJSONEncoder() -> JSONEncoder {
        JSONEncoder()
    }

    /// Builds the per-request JSON decoder used for auth responses.
    private func makeJSONDecoder() -> JSONDecoder {
        JSONDecoder()
    }
}
