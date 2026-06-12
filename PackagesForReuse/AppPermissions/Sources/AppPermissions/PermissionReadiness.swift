import Foundation

public enum PermissionReadinessDecision: String, Codable, Sendable, Equatable {
    case available
    case shouldRequestInApp
    case redirectToSettings
    case unavailable
    case unknown
}

public struct PermissionReadinessEvaluator: Sendable {
    public init() {}

    public func decision(for snapshot: PermissionSnapshot) -> PermissionReadinessDecision {
        if snapshot.state.grantsAccess { return .available }
        if snapshot.state == .unavailable { return .unavailable }
        if snapshot.canRequestInApp { return .shouldRequestInApp }
        if snapshot.requiresSettingsRedirect { return .redirectToSettings }
        return .unknown
    }
}

public struct PermissionRequestPolicy: Codable, Sendable, Equatable {
    public let allowsInAppRequest: Bool
    public let allowsSettingsRedirectSuggestion: Bool

    public init(allowsInAppRequest: Bool = true, allowsSettingsRedirectSuggestion: Bool = true) {
        self.allowsInAppRequest = allowsInAppRequest
        self.allowsSettingsRedirectSuggestion = allowsSettingsRedirectSuggestion
    }

    public func canRequest(snapshot: PermissionSnapshot) -> Bool {
        allowsInAppRequest && snapshot.canRequestInApp
    }
}
