import Foundation
import Security
import TchopAppleAuthentication
import TchopNetworking

/// Stable auth token payload expected from authenticated backend sessions.
struct AuthTokenSet: Codable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date
    let tokenType: String

    init(
        accessToken: String,
        refreshToken: String,
        expiresAt: Date,
        tokenType: String = "Bearer"
    ) {
        self.accessToken = accessToken
        self.refreshToken = refreshToken
        self.expiresAt = expiresAt
        self.tokenType = tokenType
    }

    /// Whether the access token should be considered expired at the provided reference time.
    func isAccessTokenExpired(at referenceDate: Date = Date()) -> Bool {
        expiresAt <= referenceDate
    }
}

/// Contract used by auth-aware network layers to persist and restore secure token material.
protocol AuthTokenStoring {
    func loadTokenSet() throws -> AuthTokenSet?
    func saveTokenSet(_ tokenSet: AuthTokenSet) throws
    func clearTokenSet() throws
}

/// Contract for auth API calls that mutate or refresh backend session credentials.
protocol AuthenticationAPIManaging {
    /// Exchanges a username login flow for backend credentials when that flow is enabled.
    func signIn(username: String) async throws -> AuthTokenSet
    /// Exchanges a normalized Apple identity for backend credentials.
    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet
    /// Uses the long-lived refresh token to obtain a fresh access token set.
    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet
    /// Invalidates the current backend session when the server supports explicit revoke/logout.
    func revokeSession(accessToken: String?) async throws
}

/// Auth-specific failures surfaced by the token/session stack.
enum AuthenticationSessionError: Error, Equatable {
    case signInUnavailable
    case missingRefreshToken
    case refreshUnavailable
    case revokeUnavailable
}

/// Keychain-backed token store used for production credentials.
final class KeychainAuthTokenStore: AuthTokenStoring {
    private let service: String
    private let account: String
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init(
        service: String = Bundle.main.bundleIdentifier ?? "com.tchop.app",
        account: String = "auth-token-set"
    ) {
        self.service = service
        self.account = account
    }

    func loadTokenSet() throws -> AuthTokenSet? {
        var query = makeBaseQuery()
        query[kSecReturnData as String] = kCFBooleanTrue
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        switch status {
        case errSecSuccess:
            guard let data = item as? Data else {
                return nil
            }
            return try decoder.decode(AuthTokenSet.self, from: data)
        case errSecItemNotFound:
            return nil
        default:
            throw NSError(
                domain: NSOSStatusErrorDomain,
                code: Int(status)
            )
        }
    }

    func saveTokenSet(_ tokenSet: AuthTokenSet) throws {
        let encodedTokenSet = try encoder.encode(tokenSet)
        var query = makeBaseQuery()
        let attributes: [String: Any] = [
            kSecValueData as String: encodedTokenSet
        ]

        let updateStatus = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
        if updateStatus == errSecItemNotFound {
            query[kSecValueData as String] = encodedTokenSet
            let addStatus = SecItemAdd(query as CFDictionary, nil)
            guard addStatus == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(addStatus))
            }
            return
        }

        guard updateStatus == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(updateStatus))
        }
    }

    func clearTokenSet() throws {
        let status = SecItemDelete(makeBaseQuery() as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
        }
    }

    private func makeBaseQuery() -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}

/// Minimal auth provider that integrates secure tokens with the networking interceptors.
actor SessionAuthenticationProvider: APIAuthenticationRefreshing {
    private let tokenStore: any AuthTokenStoring
    private let authenticationAPIManager: any AuthenticationAPIManaging
    /// Deduplicates concurrent refresh attempts so parallel 401s wait on the same refresh result.
    private var refreshTask: Task<AuthTokenSet, Error>?

    init(
        tokenStore: any AuthTokenStoring,
        authenticationAPIManager: any AuthenticationAPIManaging
    ) {
        self.tokenStore = tokenStore
        self.authenticationAPIManager = authenticationAPIManager
    }

    func authorizationHeaders() async throws -> [String: String] {
        guard let tokenSet = try tokenStore.loadTokenSet() else {
            return [:]
        }

        if tokenSet.isAccessTokenExpired() {
            return try await refreshAuthorizationHeaders()
        }

        return [
            "Authorization": "\(tokenSet.tokenType) \(tokenSet.accessToken)"
        ]
    }

    func refreshAuthorizationHeaders() async throws -> [String: String] {
        if let refreshTask {
            let refreshedTokenSet = try await refreshTask.value
            return makeAuthorizationHeaders(from: refreshedTokenSet)
        }

        guard let tokenSet = try tokenStore.loadTokenSet() else {
            throw AuthenticationSessionError.missingRefreshToken
        }

        guard !tokenSet.refreshToken.isEmpty else {
            throw AuthenticationSessionError.missingRefreshToken
        }

        let refreshTask = Task {
            try await authenticationAPIManager.refreshToken(using: tokenSet.refreshToken)
        }
        self.refreshTask = refreshTask

        do {
            let refreshedTokenSet = try await refreshTask.value
            try tokenStore.saveTokenSet(refreshedTokenSet)
            self.refreshTask = nil
            return makeAuthorizationHeaders(from: refreshedTokenSet)
        } catch {
            self.refreshTask = nil
            throw error
        }
    }

    private func makeAuthorizationHeaders(from tokenSet: AuthTokenSet) -> [String: String] {
        [
            "Authorization": "\(tokenSet.tokenType) \(tokenSet.accessToken)"
        ]
    }
}

/// Temporary auth API manager used until a real auth backend contract is available.
struct StubAuthenticationAPIManager: AuthenticationAPIManaging {
    func signIn(username: String) async throws -> AuthTokenSet {
        throw AuthenticationSessionError.signInUnavailable
    }

    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet {
        throw AuthenticationSessionError.signInUnavailable
    }

    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet {
        throw AuthenticationSessionError.refreshUnavailable
    }

    func revokeSession(accessToken: String?) async throws {
        throw AuthenticationSessionError.revokeUnavailable
    }
}

/// Session service contract used by app-level state.
@MainActor
protocol UserSessionManaging {
    /// Signs in with the provided username and persists the active session marker.
    func signIn(username: String) throws -> AppUser

    /// Signs in with a normalized Apple identity payload and persists the active session marker.
    func signInWithApple(identity: AppleAuthenticationIdentity) throws -> AppUser

    /// Restores the active user if a valid persisted session exists.
    func restoreSession() throws -> AppUser?

    /// Clears the persisted active session marker.
    func signOut()

    /// Restores a user session while applying auth-token validity policy when credentials exist.
    func restoreAuthenticatedSession() async throws -> AppUser?
}

extension UserSessionManaging {
    /// Default implementation keeps existing local-session behavior for simpler conformers and test doubles.
    func restoreAuthenticatedSession() async throws -> AppUser? {
        try restoreSession()
    }
}

/// Default session service backed by `UserDefaults` and the user repository.
@MainActor
final class UserSessionService: UserSessionManaging {
    private enum Keys {
        static let activeUserID = "active_user_id"
        static let legacyActiveUsername = "active_username"
    }

    private let userRepository: any UserRepository
    private let userDefaults: UserDefaults
    private let tokenStore: (any AuthTokenStoring)?
    private let authenticationAPIManager: (any AuthenticationAPIManaging)?

    /// Creates a session service.
    init(
        userRepository: any UserRepository,
        userDefaults: UserDefaults = .standard,
        tokenStore: (any AuthTokenStoring)? = nil,
        authenticationAPIManager: (any AuthenticationAPIManaging)? = nil
    ) {
        self.userRepository = userRepository
        self.userDefaults = userDefaults
        self.tokenStore = tokenStore
        self.authenticationAPIManager = authenticationAPIManager
    }

    /// Signs in and stores the active user identifier for future restoration.
    func signIn(username: String) throws -> AppUser {
        let user = try userRepository.findOrCreateUser(username: username)
        userDefaults.set(user.id, forKey: Keys.activeUserID)
        return user
    }

    /// Signs in with Apple and stores the active user identifier for future restoration.
    func signInWithApple(identity: AppleAuthenticationIdentity) throws -> AppUser {
        let user = try userRepository.findOrCreateAppleUser(
            appleUserID: identity.userID,
            preferredUsername: identity.preferredUsername
        )
        userDefaults.set(user.id, forKey: Keys.activeUserID)
        return user
    }

    /// Restores the active session and clears stale usernames automatically.
    func restoreSession() throws -> AppUser? {
        try restorePersistedUser()
    }

    /// Restores the active session and upgrades to token-aware policy when secure credentials exist.
    func restoreAuthenticatedSession() async throws -> AppUser? {
        guard let restoredUser = try restorePersistedUser() else {
            return nil
        }

        guard let tokenStore else {
            return restoredUser
        }

        guard let tokenSet = try tokenStore.loadTokenSet() else {
            return restoredUser
        }

        if !tokenSet.isAccessTokenExpired() {
            return restoredUser
        }

        guard !tokenSet.refreshToken.isEmpty else {
            signOut()
            return nil
        }

        guard let authenticationAPIManager else {
            signOut()
            return nil
        }

        let refreshedTokenSet = try await authenticationAPIManager.refreshToken(
            using: tokenSet.refreshToken
        )
        try tokenStore.saveTokenSet(refreshedTokenSet)
        return restoredUser
    }

    /// Resolves the persisted app user independently from backend auth-token state.
    private func restorePersistedUser() throws -> AppUser? {
        guard let userID = try activeUserIDForRestore() else {
            return nil
        }

        guard let user = try userRepository.findUser(id: userID) else {
            userDefaults.removeObject(forKey: Keys.activeUserID)
            return nil
        }

        return user
    }

    /// Clears the active persisted session.
    func signOut() {
        userDefaults.removeObject(forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
        try? tokenStore?.clearTokenSet()
    }

    /// Resolves the current persisted user identifier and upgrades legacy username-based session storage.
    private func activeUserIDForRestore() throws -> String? {
        if let activeUserID = userDefaults.string(forKey: Keys.activeUserID) {
            return activeUserID
        }

        guard let legacyUsername = userDefaults.string(forKey: Keys.legacyActiveUsername) else {
            return nil
        }

        guard let user = try userRepository.findUser(username: legacyUsername) else {
            userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
            return nil
        }

        userDefaults.set(user.id, forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
        return user.id
    }
}
