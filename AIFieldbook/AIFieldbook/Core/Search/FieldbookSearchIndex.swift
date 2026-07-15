import Foundation
import SwiftData

/// Value criteria for background search snapshots.
///
/// Responsibilities:
/// - carries only Sendable filter values across actor boundaries;
/// - keeps UI/search feature code independent from live SwiftData records.
///
/// Important:
/// Empty criteria intentionally return no results so search screens do not accidentally
/// fetch the whole local database during first render.
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

/// Sendable snapshot used by optional system indexing.
///
/// The value contains only user-visible metadata approved by the local privacy contract.
/// It must not contain full note bodies, imported file payloads, audio data, or provider URLs.
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

    /// Searches local knowledge items without exposing live SwiftData records to the UI.
    ///
    /// External usage:
    /// Called by query/filter-driven search flows after debounce/cancellation has already
    /// been decided by the feature state owner.
    ///
    /// Behavior:
    /// - returns an empty result for empty criteria;
    /// - applies workspace, kind, tag, and text filters together;
    /// - caps results to keep UI rendering bounded as the local database grows.
    ///
    /// Errors:
    /// Propagates SwiftData fetch failures so the caller can render an explicit error state.
    func search(criteria: FieldbookSearchCriteria) throws -> [KnowledgeItemSummary] {
        guard criteria.hasActiveCriteria else { return [] }

        let trimmedQuery = criteria.query.trimmingCharacters(in: .whitespacesAndNewlines)
        let predicate: Predicate<KnowledgeItemRecord>?
        switch (criteria.workspaceID, criteria.kind?.rawValue) {
        case let (workspaceID?, kindRawValue?):
            predicate = #Predicate {
                $0.workspace?.id == workspaceID && $0.kindRawValue == kindRawValue
            }
        case let (workspaceID?, nil):
            predicate = #Predicate { $0.workspace?.id == workspaceID }
        case let (nil, kindRawValue?):
            predicate = #Predicate { $0.kindRawValue == kindRawValue }
        case (nil, nil):
            predicate = nil
        }
        var descriptor = FetchDescriptor<KnowledgeItemRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )
        if trimmedQuery.isEmpty, criteria.tagID == nil {
            descriptor.fetchLimit = maximumSearchResultCount
        }

        var results: [KnowledgeItemSummary] = []
        for item in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            guard criteria.tagID == nil || item.tags.contains(where: { $0.id == criteria.tagID }) else {
                continue
            }
            if !trimmedQuery.isEmpty {
                let searchableValues = [
                    item.title,
                    item.textContent,
                    item.attachments.first?.originalFilename ?? "",
                    item.tags.map(\.name).joined(separator: " ")
                ]
                guard searchableValues.contains(where: { $0.localizedStandardContains(trimmedQuery) }) else {
                    continue
                }
            }
            if let summary = makeItemSummary(item) {
                results.append(summary)
                if results.count == maximumSearchResultCount { break }
            }
        }
        return results
    }

    /// Builds privacy-scoped snapshots for optional Spotlight indexing.
    ///
    /// External usage:
    /// Called by app-owned indexing maintenance after the product privacy setting permits
    /// indexing. Iteration 1 keeps indexing disabled by default but still clears stale
    /// system indexes during delete-all flows.
    ///
    /// Side effects:
    /// This method performs read-only SwiftData access. It does not write to Core Spotlight;
    /// `SpotlightIndexService` owns system indexing and deletion side effects.
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
