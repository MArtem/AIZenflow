import Foundation

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

    public func matches(localeIdentifier: String) -> Bool {
        normalizedLanguageIdentifier == OnDeviceLanguage(
            localeIdentifier: localeIdentifier
        ).normalizedLanguageIdentifier
    }
}

public struct OnDeviceTranslationSegment: Hashable, Sendable, Codable, Identifiable {
    public let id: String
    public let text: String

    public init(id: String, text: String) {
        self.id = id
        self.text = text
    }
}

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

public enum OnDeviceAIAvailability: Equatable, Sendable {
    case available(supportedLanguages: Set<OnDeviceLanguage>)
    case unavailable(OnDeviceAIUnavailableReason)
}

public enum OnDeviceAIUnavailableReason: Equatable, Sendable {
    case unsupportedOS
    case deviceNotEligible
    case appleIntelligenceNotEnabled
    case modelNotReady
    case modelAssetsUnavailable
    case unsupportedLocale
}

public enum OnDeviceAIError: Error, Equatable, Sendable {
    case unavailable(OnDeviceAIUnavailableReason)
    case emptyRequest
    case incompleteResponse
    case invalidResponse
}

public protocol OnDeviceAIManaging: Sendable {
    func translationAvailability(for localeIdentifier: String?) -> OnDeviceAIAvailability
    func translate(_ request: OnDeviceTranslationRequest) async throws -> OnDeviceTranslationResult
}

public enum OnDeviceAIManagerFactory {
    public static func makeDefaultManager() -> any OnDeviceAIManaging {
        if #available(iOS 26.0, macOS 26.0, visionOS 26.0, *) {
            return FoundationModelsOnDeviceAIManager()
        }

        return UnavailableOnDeviceAIManager(reason: .unsupportedOS)
    }
}
