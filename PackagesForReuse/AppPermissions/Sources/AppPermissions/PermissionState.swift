import Foundation

/// Cross-platform normalized authorization state.
public enum PermissionState: String, Codable, Sendable, Equatable, CaseIterable {
    case notDetermined
    case authorized
    case denied
    case restricted
    case limited
    case provisional
    case ephemeral
    case unavailable
    case unknown

    public var grantsAccess: Bool {
        switch self {
        case .authorized, .limited, .provisional, .ephemeral:
            true
        case .notDetermined, .denied, .restricted, .unavailable, .unknown:
            false
        }
    }

    public var canPromptUser: Bool {
        self == .notDetermined
    }

    public var usuallyRequiresSettingsRedirect: Bool {
        switch self {
        case .denied, .restricted, .unavailable:
            true
        case .notDetermined, .authorized, .limited, .provisional, .ephemeral, .unknown:
            false
        }
    }
}
