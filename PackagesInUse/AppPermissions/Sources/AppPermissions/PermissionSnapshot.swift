import Foundation

/// A read model suitable for UI state, diagnostics, and tests.
public struct PermissionSnapshot: Codable, Sendable, Equatable {
    public let kind: PermissionKind
    public let state: PermissionState
    public let canRequestInApp: Bool
    public let requiresSettingsRedirect: Bool
    public let updatedAt: Date

    public init(
        kind: PermissionKind,
        state: PermissionState,
        canRequestInApp: Bool? = nil,
        requiresSettingsRedirect: Bool? = nil,
        updatedAt: Date = Date()
    ) {
        self.kind = kind
        self.state = state
        self.canRequestInApp = canRequestInApp ?? state.canPromptUser
        self.requiresSettingsRedirect = requiresSettingsRedirect ?? state.usuallyRequiresSettingsRedirect
        self.updatedAt = updatedAt
    }
}

/// Privacy-safe diagnostic projection. It intentionally does not contain user-facing copy.
public struct PermissionDiagnosticSnapshot: Codable, Sendable, Equatable {
    public let kind: PermissionKind
    public let stateCode: String
    public let grantsAccess: Bool
    public let canRequestInApp: Bool
    public let requiresSettingsRedirect: Bool

    public init(snapshot: PermissionSnapshot) {
        self.kind = snapshot.kind
        self.stateCode = snapshot.state.rawValue
        self.grantsAccess = snapshot.state.grantsAccess
        self.canRequestInApp = snapshot.canRequestInApp
        self.requiresSettingsRedirect = snapshot.requiresSettingsRedirect
    }
}
