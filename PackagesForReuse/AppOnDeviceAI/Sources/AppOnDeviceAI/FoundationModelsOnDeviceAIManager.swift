import Foundation

#if canImport(FoundationModels)
import FoundationModels

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
/// Foundation Models-backed on-device AI manager for supported OS versions.
///
/// Ownership:
/// Created by `OnDeviceAIManagerFactory` or dependency composition when platform support is available.
///
/// Sendability:
/// The manager is an immutable value around the SDK's `Sendable` model reference. Each translation
/// creates its own session, so no mutable session state crosses task boundaries.
public struct FoundationModelsOnDeviceAIManager: OnDeviceAIManaging, Sendable {
    private let model: SystemLanguageModel

    public init(
        model: SystemLanguageModel = .default
    ) {
        self.model = model
    }

    /// Reports whether translation can run for the requested source language on this device.
    public func translationAvailability(for localeIdentifier: String?) -> OnDeviceAIAvailability {
        let availability = model.availability

        switch availability {
        case .available:
            let supportedLanguages = model.supportedLanguages.map {
                OnDeviceLanguage(localeIdentifier: $0.maximalIdentifier)
            }
            let requestedLocale = localeIdentifier.map(Locale.init(identifier:))

            if let requestedLocale, !model.supportsLocale(requestedLocale) {
                return .unavailable(.unsupportedLocale)
            }

            return .available(supportedLanguages: Set(supportedLanguages))
        case let .unavailable(reason):
            return .unavailable(mapUnavailableReason(reason))
        }
    }

    /// Translates all request segments while preserving segment identifiers in the result.
    ///
    /// Throws:
    /// `OnDeviceAIError` when the platform model is unavailable or returns incomplete output.
    public func translate(_ request: OnDeviceTranslationRequest) async throws -> OnDeviceTranslationResult {
        guard !request.segments.isEmpty else {
            throw OnDeviceAIError.emptyRequest
        }

        let requestedAvailability = translationAvailability(
            for: request.targetLanguage.localeIdentifier
        )

        guard case .available = requestedAvailability else {
            if case let .unavailable(reason) = requestedAvailability {
                throw OnDeviceAIError.unavailable(reason)
            }
            throw OnDeviceAIError.invalidResponse
        }

        let session = LanguageModelSession(
            model: model,
            instructions: {
                """
                You translate user-visible app text into the requested target language.
                Return only translated text.
                Preserve the incoming segment ids exactly.
                Preserve segment ordering.
                Do not omit any segment.
                Do not translate URLs.
                Do not add commentary.
                """
            }
        )

        let response: LanguageModelSession.Response<GeneratedTranslationResponse>
        do {
            response = try await session.respond(
                to: translationPrompt(for: request),
                generating: GeneratedTranslationResponse.self,
                includeSchemaInPrompt: true,
                options: GenerationOptions(
                    sampling: .greedy,
                    maximumResponseTokens: 1_024
                )
            )
        } catch {
            if isModelCatalogAssetsFailure(error) {
                throw OnDeviceAIError.unavailable(.modelAssetsUnavailable)
            }

            throw error
        }

        let translatedSegments = response.content.segments.map {
            OnDeviceTranslationSegment(id: $0.id, text: $0.text)
        }

        guard translatedSegments.count == request.segments.count else {
            throw OnDeviceAIError.incompleteResponse
        }

        let requestIDs = request.segments.map(\.id)
        let responseIDs = translatedSegments.map(\.id)
        guard requestIDs == responseIDs else {
            throw OnDeviceAIError.invalidResponse
        }

        return OnDeviceTranslationResult(
            targetLanguage: request.targetLanguage,
            segments: translatedSegments
        )
    }

    private func translationPrompt(for request: OnDeviceTranslationRequest) -> String {
        let sourceLanguageClause: String
        if let sourceLanguage = request.sourceLanguage?.localeIdentifier {
            sourceLanguageClause = "Source language locale identifier: \(sourceLanguage).\n"
        } else {
            sourceLanguageClause = ""
        }

        let segmentLines = request.segments.map { segment in
            """
            - id: \(segment.id)
              text: \(segment.text)
            """
        }
        .joined(separator: "\n")

        return """
        Translate every segment into locale \(request.targetLanguage.localeIdentifier).
        \(sourceLanguageClause)Return the translated segments with the same ids and in the same order.

        Segments:
        \(segmentLines)
        """
    }

    private func mapUnavailableReason(
        _ reason: SystemLanguageModel.Availability.UnavailableReason
    ) -> OnDeviceAIUnavailableReason {
        switch reason {
        case .deviceNotEligible:
            return .deviceNotEligible
        case .appleIntelligenceNotEnabled:
            return .appleIntelligenceNotEnabled
        case .modelNotReady:
            return .modelNotReady
        @unknown default:
            return .modelNotReady
        }
    }

    private func isModelCatalogAssetsFailure(_ error: Error) -> Bool {
        let nsError = error as NSError
        if nsError.domain == "com.apple.UnifiedAssetFramework", nsError.code == 5000 {
            return true
        }

        if nsError.domain == "ModelManagerServices.ModelManagerError", nsError.code == 1026 {
            return true
        }

        if
            let underlyingError = nsError.userInfo[NSUnderlyingErrorKey] as? NSError,
            isModelCatalogAssetsFailure(underlyingError)
        {
            return true
        }

        let combinedDescription = [
            nsError.domain,
            nsError.localizedDescription,
            nsError.localizedFailureReason ?? ""
        ]
        .joined(separator: " ")
        .lowercased()

        return combinedDescription.contains("modelcatalog")
            || combinedDescription.contains("unifiedassetframework")
    }
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@Generable
private struct GeneratedTranslationResponse {
    let segments: [GeneratedTranslationSegment]
}

@available(iOS 26.0, macOS 26.0, visionOS 26.0, *)
@Generable
private struct GeneratedTranslationSegment {
    let id: String
    let text: String
}

#endif
