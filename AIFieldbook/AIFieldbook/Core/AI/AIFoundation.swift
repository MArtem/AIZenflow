import Foundation

/// Stable identifiers for AI capabilities that produce persisted local results.
///
/// Persistence contract:
/// Raw values are durable metadata. Renaming a value requires a migration decision.
enum AICapabilityIdentifier: String, Codable, Sendable {
    case imageTextRecognition = "vision.image-text-recognition"
}

/// Product-level capability availability, kept separate from transient execution state.
enum AICapabilityAvailability: Equatable, Sendable {
    case available
    case unsupported
}

/// Durable terminal state for a locally produced AI result.
enum AIResultCompletionState: String, Codable, Sendable {
    case completed
    case empty
}

/// Auditable metadata for one persisted AI result.
///
/// Privacy:
/// Contains only local identifiers and safe implementation labels. It never stores prompts,
/// hidden reasoning, file-system URLs, account data, or network credentials.
struct AIResultProvenance: Equatable, Sendable {
    let resultID: UUID
    let sourceItemID: UUID
    let sourceAttachmentID: UUID
    let capability: AICapabilityIdentifier
    let routeIdentifier: String
    let providerIdentifier: String
    let modelIdentifier: String
    let processorVersion: String
    let createdAt: Date
    let inputRevision: String
    let completionState: AIResultCompletionState
    let userEdited: Bool
    let meanConfidence: Double?
    let latencyMilliseconds: Int64
}

/// Detached output produced by local image text recognition.
struct RecognizedImageText: Equatable, Sendable {
    let text: String
    let provenance: AIResultProvenance
}

/// Capability policy for the first AI Fieldbook AI surface.
enum ImageTextRecognitionCapability {
    static let identifier = AICapabilityIdentifier.imageTextRecognition

    static func availability(for kind: KnowledgeItemKind) -> AICapabilityAvailability {
        kind == .image ? .available : .unsupported
    }
}
