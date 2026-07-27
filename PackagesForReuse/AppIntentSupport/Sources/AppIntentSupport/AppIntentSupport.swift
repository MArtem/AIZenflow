import Foundation

#if canImport(AppIntents)
import AppIntents
#endif

/// Stable validation failures shared by app-owned App Intent implementations.
///
/// Ownership:
/// The package owns generic input validation mechanics only. Host apps still own product-specific
/// intent names, phrases, business behavior, persistence, routing and localized copy.
public enum AppIntentSupportValidationFailure: Error, Equatable, Sendable, LocalizedError {
    case emptyRequiredText(fieldName: String)
    case textExceedsLimit(fieldName: String, maximumCharacterCount: Int)

    public var errorDescription: String? {
        switch self {
        case let .emptyRequiredText(fieldName):
            return "\(fieldName) is required."
        case let .textExceedsLimit(fieldName, maximumCharacterCount):
            return "\(fieldName) must be \(maximumCharacterCount) characters or fewer."
        }
    }
}

/// Product-independent normalized text payload for simple App Intents.
public struct AppIntentTextInput: Codable, Equatable, Sendable {
    public let value: String

    public init(
        _ rawValue: String,
        fieldName: String,
        maximumCharacterCount: Int? = nil
    ) throws {
        let normalized = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !normalized.isEmpty else {
            throw AppIntentSupportValidationFailure.emptyRequiredText(fieldName: fieldName)
        }

        if let maximumCharacterCount, normalized.count > maximumCharacterCount {
            throw AppIntentSupportValidationFailure.textExceedsLimit(
                fieldName: fieldName,
                maximumCharacterCount: maximumCharacterCount
            )
        }

        self.value = normalized
    }
}

/// Small helper namespace for App Intent input validation.
public enum AppIntentTextNormalizer {
    public static func requiredText(
        _ rawValue: String,
        fieldName: String,
        maximumCharacterCount: Int? = nil
    ) throws -> String {
        try AppIntentTextInput(
            rawValue,
            fieldName: fieldName,
            maximumCharacterCount: maximumCharacterCount
        ).value
    }
}

#if canImport(AppIntents)
/// Package marker for future App Intents package composition.
///
/// App Shortcut-facing intents still belong in the host app target in this worktree, because the
/// shortcuts provider and the exposed shortcut intents must compile into the app target for reliable
/// metadata discovery. This package intentionally stays mechanism-only.
@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)
public enum AppIntentSupportPackage: AppIntentsPackage {}
#endif
