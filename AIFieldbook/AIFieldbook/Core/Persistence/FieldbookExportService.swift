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
                let id: UUID
                let kind: String
                let title: String
                let textContent: String
                let tags: [String]
                let files: [String]
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
            Manifest(formatVersion: 1, exportedAt: .now, workspaces: workspaceSnapshots)
        )
    }
}
