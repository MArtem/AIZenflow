import Foundation
import SwiftData

struct FieldbookSearchCriteria: Equatable, Sendable {
    let query: String
    let workspaceID: UUID?
    let kind: KnowledgeItemKind?
    let tagID: UUID?

    var hasActiveCriteria: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ||
            workspaceID != nil || kind != nil || tagID != nil
    }
}

struct SpotlightIndexEntry: Sendable {
    enum Kind: Sendable {
        case workspace
        case item(KnowledgeItemKind)
    }

    let id: UUID
    let kind: Kind
    let title: String
    let subtitle: String
    let keywords: [String]
}

/// Background SwiftData read actor for search and indexing snapshots.
///
/// Ownership:
/// Created by `AppComposition` from the app's `ModelContainer` and shared by search and
/// optional Spotlight indexing for one app scene.
///
/// Rationale:
/// User-facing state remains on `@MainActor`, while potentially growing local search/index
/// reads execute through this separate SwiftData model actor. Returned values are Sendable
/// snapshots, never live persistent models.
@ModelActor
actor FieldbookSearchIndex {
    private let maximumSearchResultCount = 100

    func search(criteria: FieldbookSearchCriteria) throws -> [KnowledgeItemSummary] {
        guard criteria.hasActiveCriteria else { return [] }

        let trimmedQuery = criteria.query.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<KnowledgeItemRecord>(
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )

        return Array(try modelContext.fetch(descriptor)
            .lazy
            .filter { item in
                guard criteria.workspaceID == nil || item.workspace?.id == criteria.workspaceID else { return false }
                guard criteria.kind == nil || item.kind == criteria.kind else { return false }
                guard criteria.tagID == nil || item.tags.contains(where: { $0.id == criteria.tagID }) else { return false }
                guard !trimmedQuery.isEmpty else { return true }

                let searchableValues = [
                    item.title,
                    item.textContent,
                    item.attachments.first?.originalFilename ?? "",
                    item.tags.map(\.name).joined(separator: " ")
                ]
                return searchableValues.contains { value in
                    value.localizedStandardContains(trimmedQuery)
                }
            }
            .compactMap(makeItemSummary)
            .prefix(maximumSearchResultCount))
    }

    func spotlightEntries() throws -> [SpotlightIndexEntry] {
        let workspaceDescriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.updatedAt, order: .reverse)]
        )

        var entries: [SpotlightIndexEntry] = []
        for workspace in try modelContext.fetch(workspaceDescriptor) {
            entries.append(
                SpotlightIndexEntry(
                    id: workspace.id,
                    kind: .workspace,
                    title: workspace.name,
                    subtitle: String(localized: "AI Fieldbook workspace"),
                    keywords: [workspace.name]
                )
            )

            for item in workspace.items.sorted(by: { $0.updatedAt > $1.updatedAt }) {
                guard let summary = makeItemSummary(item) else { continue }
                entries.append(
                    SpotlightIndexEntry(
                        id: summary.id,
                        kind: .item(summary.kind),
                        title: summary.displayTitle,
                        subtitle: summary.subtitle,
                        keywords: summary.tags.map(\.name) + [workspace.name, summary.kind.displayName]
                    )
                )
            }
        }
        return entries
    }

    private func makeItemSummary(_ item: KnowledgeItemRecord) -> KnowledgeItemSummary? {
        guard let kind = item.kind else { return nil }
        return KnowledgeItemSummary(
            id: item.id,
            kind: kind,
            title: item.title,
            filename: item.attachments.first?.originalFilename,
            tags: tagSummaries(item.tags),
            updatedAt: item.updatedAt
        )
    }

    private func tagSummaries(_ tags: [TagRecord]) -> [TagSummary] {
        tags
            .map { TagSummary(id: $0.id, name: $0.name) }
            .sorted { $0.name.localizedStandardCompare($1.name) == .orderedAscending }
    }
}
