import Foundation

public protocol PermissionUsageDescriptionChecking: Sendable {
    func validateUsageDescriptions(for kind: PermissionKind) throws
}

/// Validates required Info.plist usage-description keys before a native permission request.
///
/// This prevents silent or late platform failures and avoids triggering native APIs that may
/// terminate the app when mandatory privacy strings are missing.
public struct PermissionUsageDescriptionChecker: PermissionUsageDescriptionChecking {
    private let valueProvider: @Sendable (String) -> String?

    public init(valueProvider: @escaping @Sendable (String) -> String?) {
        self.valueProvider = valueProvider
    }

    public static let mainBundle = PermissionUsageDescriptionChecker { key in
        Bundle.main.object(forInfoDictionaryKey: key) as? String
    }

    public func validateUsageDescriptions(for kind: PermissionKind) throws {
        for requirement in PermissionUsageDescriptions.requirements(for: kind) where requirement.requiredBeforeRequest {
            let value = valueProvider(requirement.infoPlistKey)?.trimmingCharacters(in: .whitespacesAndNewlines)
            guard let value, !value.isEmpty else {
                throw PermissionError.missingUsageDescription(kind: kind, key: requirement.infoPlistKey)
            }
        }
    }
}

public struct NoopPermissionUsageDescriptionChecker: PermissionUsageDescriptionChecking {
    public init() {}
    public func validateUsageDescriptions(for kind: PermissionKind) throws {}
}
