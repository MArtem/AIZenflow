import Foundation

/// Result of a permission request attempt.
public struct PermissionRequestOutcome: Codable, Sendable, Equatable {
    public let kind: PermissionKind
    public let state: PermissionState
    public let didPromptUser: Bool
    public let timestamp: Date

    public init(
        kind: PermissionKind,
        state: PermissionState,
        didPromptUser: Bool,
        timestamp: Date = Date()
    ) {
        self.kind = kind
        self.state = state
        self.didPromptUser = didPromptUser
        self.timestamp = timestamp
    }
}
