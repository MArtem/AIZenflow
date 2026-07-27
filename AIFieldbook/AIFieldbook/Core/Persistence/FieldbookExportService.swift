import Foundation
import SwiftData

/// Builds a detached, user-shareable snapshot of all local fieldbook content.
///
/// Ownership:
/// Created by `AppComposition` from the app's `ModelContainer` and shared with Settings.
///
/// Concurrency:
/// SwiftData reads, snapshot construction, sorting, and JSON encoding run on this model actor,
/// never on the main actor. Cancellation is checked between workspaces and items.
@ModelActor
actor FieldbookExportService {
    /// Encodes the current local source of truth without exposing live SwiftData models.
    func manifestData() throws -> Data {
        struct Manifest: Codable {
            struct Workspace: Codable {
                let id: UUID
                let name: String
                let items: [Item]
            }

            struct Item: Codable {
                struct AIResult: Codable {
                    let id: UUID
                    let sourceAttachmentID: UUID
                    let capability: String
                    let route: String
                    let provider: String
                    let model: String
                    let processorVersion: String
                    let createdAt: Date
                    let inputRevision: String
                    let completionState: String
                    let outputText: String
                    let userEdited: Bool
                    let meanConfidence: Double?
                    let latencyMilliseconds: Int64
                }

                let id: UUID
                let kind: String
                let title: String
                let textContent: String
                let tags: [String]
                let files: [String]
                let aiResults: [AIResult]
                let updatedAt: Date
            }

            let formatVersion: Int
            let exportedAt: Date
            let workspaces: [Workspace]
        }

        let descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.name, order: .forward)]
        )
        var workspaceSnapshots: [Manifest.Workspace] = []
        for workspace in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            var itemSnapshots: [Manifest.Item] = []
            for item in workspace.items.sorted(by: { $0.updatedAt > $1.updatedAt }) {
                try Task.checkCancellation()
                itemSnapshots.append(
                    Manifest.Item(
                        id: item.id,
                        kind: item.kindRawValue,
                        title: item.title,
                        textContent: item.textContent,
                        tags: item.tags.map(\.name).sorted(),
                        files: item.attachments.map(\.relativePath).sorted(),
                        aiResults: item.aiResults
                            .sorted(by: { $0.createdAt < $1.createdAt })
                            .map {
                                Manifest.Item.AIResult(
                                    id: $0.id,
                                    sourceAttachmentID: $0.sourceAttachmentID,
                                    capability: $0.capabilityRawValue,
                                    route: $0.routeIdentifier,
                                    provider: $0.providerIdentifier,
                                    model: $0.modelIdentifier,
                                    processorVersion: $0.processorVersion,
                                    createdAt: $0.createdAt,
                                    inputRevision: $0.inputRevision,
                                    completionState: $0.completionStateRawValue,
                                    outputText: $0.outputText,
                                    userEdited: $0.userEdited,
                                    meanConfidence: $0.meanConfidence,
                                    latencyMilliseconds: $0.latencyMilliseconds
                                )
                            },
                        updatedAt: item.updatedAt
                    )
                )
            }
            workspaceSnapshots.append(
                Manifest.Workspace(id: workspace.id, name: workspace.name, items: itemSnapshots)
            )
        }

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(
            Manifest(formatVersion: 2, exportedAt: .now, workspaces: workspaceSnapshots)
        )
    }
}
