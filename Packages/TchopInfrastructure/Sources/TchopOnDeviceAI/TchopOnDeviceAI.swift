import Foundation

/// Stable language identifier wrapper used by on-device AI translation APIs.
public struct OnDeviceLanguage: Hashable, Sendable, Codable {
    public let localeIdentifier: String

    public init(localeIdentifier: String) {
        self.localeIdentifier = localeIdentifier
    }

    public var normalizedLanguageIdentifier: String {
        let locale = Locale(identifier: localeIdentifier)
        return locale.language.languageCode?.identifier
            ?? locale.languageCode
            ?? localeIdentifier
    }

        /// Compares language identity using normalized language code rather than exact locale string.
public func matches(localeIdentifier: String) -> Bool {
        normalizedLanguageIdentifier == OnDeviceLanguage(
            localeIdentifier: localeIdentifier
        ).normalizedLanguageIdentifier
    }
}

/// One translatable text segment with stable identity for preserving field order across requests.
public struct OnDeviceTranslationSegment: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

/// Request contract for translating multiple text segments to one target language.
public struct OnDeviceTranslationRequest: Hashable, Sendable, Codable {
    public let sourceLanguage: OnDeviceLanguage?
    public let targetLanguage: OnDeviceLanguage
    public let segments: [OnDeviceTranslationSegment]

    public init(
        sourceLanguage: OnDeviceLanguage? = nil,
        targetLanguage: OnDeviceLanguage,
        segments: [OnDeviceTranslationSegment]
    ) {
        self.sourceLanguage = sourceLanguage
        self.targetLanguage = targetLanguage
        self.segments = segments
    }
}

/// Translation result preserving the caller-provided segment identities.
public struct OnDeviceTranslationResult: Hashable, Sendable, Codable {
    public let targetLanguage: OnDeviceLanguage
    public let segments: [OnDeviceTranslationSegment]

    public init(
        targetLanguage: OnDeviceLanguage,
        segments: [OnDeviceTranslationSegment]
    ) {
        self.targetLanguage = targetLanguage
        self.segments = segments
    }
}

/// Runtime availability of on-device AI capabilities for the current OS/device/language.
public enum OnDeviceAIAvailability: Equatable, Sendable {
    case available(supportedLanguages: Set<OnDeviceLanguage>)
    case unavailable(OnDeviceAIUnavailableReason)
}

/// Stable reason code for why on-device AI cannot currently run.
public enum OnDeviceAIUnavailableReason: Equatable, Sendable {
    case unsupportedOS
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case modelAssetsUnavailable
    case unsupportedLocale
}

/// Errors thrown by the on-device AI boundary.
public enum OnDeviceAIError: Error, Equatable, Sendable {
    case unavailable(OnDeviceAIUnavailableReason)
    case emptyRequest
    case incompleteResponse
    case invalidResponse
}

/// App-facing boundary for on-device AI features.
///
/// Contract:
/// Implementations must report availability before translation and preserve segment identity in results.
public protocol OnDeviceAIManaging: Sendable {
    func translationAvailability(for localeIdentifier: String?) -> OnDeviceAIAvailability
    func translate(_ request: OnDeviceTranslationRequest) async throws -> OnDeviceTranslationResult
}

/// Factory for the default platform-backed on-device AI manager with safe unavailable fallback.
public enum OnDeviceAIManagerFactory {
    public static func makeDefaultManager() -> any OnDeviceAIManaging {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return FoundationModelsOnDeviceAIManager()
        }

        return UnavailableOnDeviceAIManager(reason: .unsupportedOS)
    }
}
