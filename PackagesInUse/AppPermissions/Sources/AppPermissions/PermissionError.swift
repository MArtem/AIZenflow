import Foundation

/// Sanitized permission errors. No raw platform error text is stored here.
public enum PermissionError: Error, Sendable, Equatable, CustomStringConvertible {
    case unsupportedKind(PermissionKind)
    case unavailable(PermissionKind)
    case denied(PermissionKind, state: PermissionState)
    case missingUsageDescription(kind: PermissionKind, key: String)
    case requestRequiresAppManagedDelegate(PermissionKind)
    case platformRequestFailed(kind: PermissionKind, code: String)

    public var description: String {
        switch self {
        case .unsupportedKind(let kind):
            "unsupported_permission_kind:\(kind.rawValue)"
        case .unavailable(let kind):
            "permission_unavailable:\(kind.rawValue)"
        case .denied(let kind, let state):
            "permission_denied:\(kind.rawValue):\(state.rawValue)"
        case .missingUsageDescription(let kind, let key):
            "missing_usage_description:\(kind.rawValue):\(key)"
        case .requestRequiresAppManagedDelegate(let kind):
            "permission_request_requires_app_managed_delegate:\(kind.rawValue)"
        case .platformRequestFailed(let kind, let code):
            "permission_platform_request_failed:\(kind.rawValue):\(code)"
        }
    }
}
