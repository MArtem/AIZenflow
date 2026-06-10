import Foundation

/// Keychain-style accessibility policy used when saving a value.
public enum SecureStorageAccessibility: String, Codable, Hashable, Sendable {
    /// Item is accessible after the first device unlock and can migrate to a new device.
    case afterFirstUnlock

    /// Item is accessible after first unlock and stays on the current device only.
    case afterFirstUnlockThisDeviceOnly

    /// Item is accessible only while the device is unlocked and can migrate to a new device.
    case whenUnlocked

    /// Item is accessible only while unlocked and stays on the current device only.
    case whenUnlockedThisDeviceOnly

    /// Item is accessible only when a passcode is set and stays on the current device only.
    case whenPasscodeSetThisDeviceOnly
}

/// Optional user-presence policy for values that require local authentication.
public enum SecureStorageAuthenticationPolicy: String, Codable, Hashable, Sendable {
    case userPresence
    case biometryAny
    case biometryCurrentSet
}

/// Options applied when storing a value.
public struct SecureStorageSaveOptions: Codable, Hashable, Sendable {
    public var accessibility: SecureStorageAccessibility
    public var authenticationPolicy: SecureStorageAuthenticationPolicy?
    public var synchronizable: Bool

    public init(
        accessibility: SecureStorageAccessibility = .afterFirstUnlockThisDeviceOnly,
        authenticationPolicy: SecureStorageAuthenticationPolicy? = nil,
        synchronizable: Bool = false
    ) {
        self.accessibility = accessibility
        self.authenticationPolicy = authenticationPolicy
        self.synchronizable = synchronizable
    }

    public static let `default` = SecureStorageSaveOptions()
}

/// Metadata returned with a secure storage value.
///
/// Keychain does not expose all timestamps consistently across platforms, so this
/// record only contains metadata this package can guarantee for all implementations.
public struct SecureStorageRecord: Equatable, Sendable {
    public let key: SecureStorageKey
    public let data: Data
    public let approximateSizeInBytes: Int

    public init(key: SecureStorageKey, data: Data) {
        self.key = key
        self.data = data
        self.approximateSizeInBytes = data.count
    }
}
