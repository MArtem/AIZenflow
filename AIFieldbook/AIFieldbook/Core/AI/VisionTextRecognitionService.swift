import Foundation
import Vision

/// Performs image text recognition entirely on device with Apple Vision.
///
/// Concurrency:
/// Actor isolation keeps recognition work off `MainActor` and serializes requests owned by the
/// app scene. Callers retain ownership of task cancellation and UI state.
///
/// Privacy:
/// The service reads one app-owned local image URL and does not perform network requests.
actor VisionTextRecognitionService {
    private static let routeIdentifier = "on-device"
    private static let providerIdentifier = "apple.vision"
    private static let modelIdentifier = "recognize-text-revision-3"
    private static let processorVersion = "1"

    func recognizeText(
        in imageURL: URL,
        sourceItemID: UUID,
        sourceAttachmentID: UUID,
        inputRevision: String
    ) async throws -> RecognizedImageText {
        try Task.checkCancellation()
        let startedAt = Date()
        var request = RecognizeTextRequest(.revision3)
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        request.usesLanguageCorrection = true

        let observations = try await request.perform(on: imageURL)
        try Task.checkCancellation()

        let lines = observations
            .map(\.transcript)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
        let text = lines.joined(separator: "\n")
        let confidence = observations.isEmpty
            ? nil
            : observations.reduce(0.0) { $0 + Double($1.confidence) } / Double(observations.count)
        let createdAt = Date()
        let latencyMilliseconds = max(
            0,
            Int64(createdAt.timeIntervalSince(startedAt) * 1_000)
        )
        let completionState: AIResultCompletionState = text.isEmpty ? .empty : .completed

        return RecognizedImageText(
            text: text,
            provenance: AIResultProvenance(
                resultID: UUID(),
                sourceItemID: sourceItemID,
                sourceAttachmentID: sourceAttachmentID,
                capability: ImageTextRecognitionCapability.identifier,
                routeIdentifier: Self.routeIdentifier,
                providerIdentifier: Self.providerIdentifier,
                modelIdentifier: Self.modelIdentifier,
                processorVersion: Self.processorVersion,
                createdAt: createdAt,
                inputRevision: inputRevision,
                completionState: completionState,
                userEdited: false,
                meanConfidence: confidence,
                latencyMilliseconds: latencyMilliseconds
            )
        )
    }
}
