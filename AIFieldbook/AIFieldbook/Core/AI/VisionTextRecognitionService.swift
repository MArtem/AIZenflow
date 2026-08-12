import Foundation
import ImageIO
import Vision

private enum VisionTextRecognitionError: Error {
    case imageDecodingFailed
    case outputTooLarge
}

/// Performs image text recognition entirely on device with Apple Vision.
///
/// Concurrency:
/// Actor isolation keeps recognition work off `MainActor` and serializes requests owned by the
/// app scene. Callers retain ownership of task cancellation and UI state.
///
/// Privacy:
/// The service reads one app-owned local image URL and does not perform network requests.
/// ImageIO applies orientation and bounds the decoded OCR input before Vision sees it.
actor VisionTextRecognitionService {
    private static let routeIdentifier = "on-device"
    private static let providerIdentifier = "apple.vision"
    private static let modelIdentifier = "recognize-text-revision-3"
    private static let processorVersion = "2"
    // Bounds the OCR decode to at most 16.8 MP; the stored source remains unchanged.
    private static let maximumInputDimension = 4_096

    func recognizeText(
        in imageURL: URL,
        sourceItemID: UUID,
        sourceAttachmentID: UUID,
        inputRevision: String
    ) async throws -> RecognizedImageText {
        try Task.checkCancellation()
        let startedAt = Date()
        let image = try downsampledImage(at: imageURL)
        try Task.checkCancellation()
        var request = RecognizeTextRequest(.revision3)
        request.recognitionLevel = .accurate
        request.automaticallyDetectsLanguage = true
        request.usesLanguageCorrection = true

        let observations = try await request.perform(on: image)
        try Task.checkCancellation()

        var lines: [String] = []
        var outputByteCount = 0
        for observation in observations {
            let line = observation.transcript.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !line.isEmpty else { continue }
            let additionalBytes = line.utf8.count + (lines.isEmpty ? 0 : 1)
            guard outputByteCount <= AIResultOutputLimits.maximumTextUTF8Bytes - additionalBytes else {
                throw VisionTextRecognitionError.outputTooLarge
            }
            outputByteCount += additionalBytes
            lines.append(line)
        }
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

    private func downsampledImage(at imageURL: URL) throws -> CGImage {
        let sourceOptions = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(imageURL as CFURL, sourceOptions) else {
            throw VisionTextRecognitionError.imageDecodingFailed
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceThumbnailMaxPixelSize: Self.maximumInputDimension,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldCacheImmediately: true
        ] as CFDictionary
        guard let image = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            throw VisionTextRecognitionError.imageDecodingFailed
        }
        return image
    }
}
