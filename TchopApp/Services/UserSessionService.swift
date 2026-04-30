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
protocol AuthTokenStoring: Sendable {
    func loadTokenSet() throws -> AuthTokenSet?
    func saveTokenSet(_ tokenSet: AuthTokenSet) throws
    func clearTokenSet() throws
}

/// Contract for auth API calls that mutate or refresh backend session credentials.
protocol AuthenticationAPIManaging: Sendable {
    /// Exchanges a username login flow for backend credentials when that flow is enabled.
    func signIn(username: String) async throws -> AuthTokenSet
    /// Exchanges email/password credentials for backend credentials when that flow is enabled.
    func signIn(email: String, password: String) async throws -> AuthTokenSet
    /// Creates a backend account and returns the initial credential set.
    func register(email: String, password: String) async throws -> AuthTokenSet
    /// Exchanges a normalized Apple identity for backend credentials.
    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AuthTokenSet
    /// Uses the long-lived refresh token to obtain a fresh access token set.
    func refreshToken(using refreshToken: String) async throws -> AuthTokenSet
    /// Invalidates the current backend session when the server supports explicit revoke/logout.
    func revokeSession(accessToken: String?) async throws
}

/// Auth-specific failures surfaced by the token/session stack.
enum AuthenticationSessionError: Error, Equatable {
    case missingRefreshToken
}

/// Keychain-backed token store used for production credentials.
final class KeychainAuthTokenStore: AuthTokenStoring, @unchecked Sendable {
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

/// In-memory token store used by deterministic UI test flows.
///
/// UI-driven API tests should exercise the full auth/request/session chain without depending on
/// simulator-specific Keychain availability. This store keeps the same contract while removing the
/// platform storage variable from those tests.
final class InMemoryAuthTokenStore: AuthTokenStoring, @unchecked Sendable {
    private var tokenSet: AuthTokenSet?

    func loadTokenSet() throws -> AuthTokenSet? {
        tokenSet
    }

    func saveTokenSet(_ tokenSet: AuthTokenSet) throws {
        self.tokenSet = tokenSet
    }

    func clearTokenSet() throws {
        tokenSet = nil
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

/// Session service contract used by app-level state.
@MainActor
protocol UserSessionManaging {
    /// Signs in with the provided username and persists both backend credentials and the local session marker.
    func signIn(username: String) async throws -> AppUser

    /// Signs in with external email/password credentials and persists both backend credentials and local session state.
    func signIn(email: String, password: String) async throws -> AppUser

    /// Registers a new external account and persists both backend credentials and local session state.
    func register(email: String, password: String) async throws -> AppUser

    /// Signs in with a normalized Apple identity payload and persists both backend credentials and the local session marker.
    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AppUser

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
    ///
    /// When a backend auth manager is wired, this path persists secure credentials first and only then
    /// marks the local app user as authenticated. Until real auth endpoints exist the flow falls back
    /// to local-user creation so the rest of the app can keep moving.
    func signIn(username: String) async throws -> AppUser {
        if let authenticationAPIManager, let tokenStore {
            let tokenSet = try await authenticationAPIManager.signIn(username: username)
            try tokenStore.saveTokenSet(tokenSet)

            do {
                let user = try userRepository.findOrCreateUser(username: username)
                userDefaults.set(user.id, forKey: Keys.activeUserID)
                return user
            } catch {
                try? tokenStore.clearTokenSet()
                throw error
            }
        }

        let user = try userRepository.findOrCreateUser(username: username)
        userDefaults.set(user.id, forKey: Keys.activeUserID)
        return user
    }

    /// Signs in with external credentials and mirrors the backend identifier locally using the email value.
    ///
    /// Until the real backend exposes a richer profile contract, the email acts as the local account
    /// display name and stable lookup key. This keeps session restoration and profile ownership
    /// deterministic without introducing a second local user model.
    func signIn(email: String, password: String) async throws -> AppUser {
        guard let authenticationAPIManager, let tokenStore else {
            return try await signIn(username: email)
        }

        let tokenSet = try await authenticationAPIManager.signIn(email: email, password: password)
        try tokenStore.saveTokenSet(tokenSet)

        do {
            let user = try userRepository.findOrCreateUser(username: email)
            userDefaults.set(user.id, forKey: Keys.activeUserID)
            return user
        } catch {
            try? tokenStore.clearTokenSet()
            throw error
        }
    }

    /// Registers an external account and persists the initial session locally.
    func register(email: String, password: String) async throws -> AppUser {
        guard let authenticationAPIManager, let tokenStore else {
            return try await signIn(username: email)
        }

        let tokenSet = try await authenticationAPIManager.register(email: email, password: password)
        try tokenStore.saveTokenSet(tokenSet)

        do {
            let user = try userRepository.findOrCreateUser(username: email)
            userDefaults.set(user.id, forKey: Keys.activeUserID)
            return user
        } catch {
            try? tokenStore.clearTokenSet()
            throw error
        }
    }

    /// Signs in with Apple and stores the active user identifier for future restoration.
    ///
    /// The backend token exchange is optional for now, but the method already prefers the production
    /// path when an auth manager is available so the UI flow does not need another signature change later.
    func signInWithApple(identity: AppleAuthenticationIdentity) async throws -> AppUser {
        if let authenticationAPIManager, let tokenStore {
            let tokenSet = try await authenticationAPIManager.signInWithApple(identity: identity)
            try tokenStore.saveTokenSet(tokenSet)

            do {
                let user = try userRepository.findOrCreateAppleUser(
                    appleUserID: identity.userID,
                    preferredUsername: identity.preferredUsername
                )
                userDefaults.set(user.id, forKey: Keys.activeUserID)
                return user
            } catch {
                try? tokenStore.clearTokenSet()
                throw error
            }
        }

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
        let restoredUser = try restorePersistedUser()

        guard let tokenStore else {
            return restoredUser
        }

        let tokenSet: AuthTokenSet?
        do {
            tokenSet = try tokenStore.loadTokenSet()
        } catch {
            // Startup restore should degrade to a clean signed-out state if secure storage is
            // temporarily unavailable or corrupted. Crashing here prevents the user from ever
            // reaching the login screen that could establish a fresh session.
            clearPersistedSessionState()
            return nil
        }

        guard let restoredUser else {
            clearSecureCredentials()
            return nil
        }

        guard let tokenSet else {
            return restoredUser
        }

        if !tokenSet.isAccessTokenExpired() {
            return restoredUser
        }

        guard !tokenSet.refreshToken.isEmpty else {
            clearPersistedSessionState()
            return nil
        }

        guard let authenticationAPIManager else {
            clearPersistedSessionState()
            return nil
        }

        do {
            let refreshedTokenSet = try await authenticationAPIManager.refreshToken(
                using: tokenSet.refreshToken
            )
            try tokenStore.saveTokenSet(refreshedTokenSet)
            return restoredUser
        } catch {
            clearPersistedSessionState()
            throw error
        }
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
        let accessToken: String?
        if let tokenStore {
            accessToken = try? tokenStore.loadTokenSet()?.accessToken
        } else {
            accessToken = nil
        }

        userDefaults.removeObject(forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
        try? tokenStore?.clearTokenSet()

        guard let authenticationAPIManager else {
            return
        }

        Task {
            do {
                try await authenticationAPIManager.revokeSession(accessToken: accessToken)
            } catch {
                // Logout remains local-first and non-blocking; revoke failures are intentionally best-effort.
            }
        }
    }

    /// Clears only the local app-session marker, without attempting remote revoke.
    private func clearLocalSessionState() {
        userDefaults.removeObject(forKey: Keys.activeUserID)
        userDefaults.removeObject(forKey: Keys.legacyActiveUsername)
    }

    /// Clears secure credentials without touching user-facing session revoke semantics.
    private func clearSecureCredentials() {
        try? tokenStore?.clearTokenSet()
    }

    /// Clears the locally persisted session state during startup/session-recovery cleanup paths.
    ///
    /// This differs from `signOut()`: restore-time corruption or stale local state should not
    /// trigger a best-effort remote revoke because the app may no longer have coherent credentials.
    private func clearPersistedSessionState() {
        clearLocalSessionState()
        clearSecureCredentials()
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
