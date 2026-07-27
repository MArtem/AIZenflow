import Foundation
import SwiftData

/// Detached, privacy-minimal workspace value used by App Intents adapters.
struct WorkspaceIntentSnapshot: Sendable {
    let id: UUID
    let name: String
}

/// Detached, privacy-minimal knowledge-item value used by App Intents adapters.
struct KnowledgeItemIntentSnapshot: Sendable {
    let id: UUID
    let title: String
    let kind: KnowledgeItemKind
    let workspaceName: String
}

/// Local read boundary shared by the completed App Intents slices.
///
/// It returns detached values only. Search may inspect locally stored text and metadata, but
/// note bodies, tags, URLs, filenames, paths, attachments, and media never cross this boundary.
@ModelActor
actor FieldbookIntentDataSource {
    private let maximumEntityResolutionCount = 20
    private let maximumSuggestionCount = 20
    private let maximumWorkspaceNameSearchCount = 100
    private let maximumKnowledgeItemSearchCount = 100

    func workspaces(with identifiers: [UUID]) throws -> [WorkspaceIntentSnapshot] {
        var snapshots: [WorkspaceIntentSnapshot] = []
        snapshots.reserveCapacity(min(identifiers.count, maximumEntityResolutionCount))

        for identifier in identifiers.prefix(maximumEntityResolutionCount) {
            try Task.checkCancellation()
            var descriptor = FetchDescriptor<WorkspaceRecord>(
                predicate: #Predicate { $0.id == identifier }
            )
            descriptor.fetchLimit = 1

            if let workspace = try modelContext.fetch(descriptor).first {
                snapshots.append(workspaceSnapshot(for: workspace))
            }
        }

        return snapshots
    }

    func workspaces(matching query: String) throws -> [WorkspaceIntentSnapshot] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            return try suggestedWorkspaces()
        }

        var descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.name)]
        )
        descriptor.fetchLimit = maximumWorkspaceNameSearchCount

        var snapshots: [WorkspaceIntentSnapshot] = []
        for workspace in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            guard workspace.name.localizedStandardContains(trimmedQuery) else { continue }
            snapshots.append(workspaceSnapshot(for: workspace))
            if snapshots.count == maximumSuggestionCount { break }
        }
        return snapshots
    }

    func suggestedWorkspaces() throws -> [WorkspaceIntentSnapshot] {
        var descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maximumSuggestionCount

        return try modelContext.fetch(descriptor).map(workspaceSnapshot(for:))
    }

    func knowledgeItems(with identifiers: [UUID]) throws -> [KnowledgeItemIntentSnapshot] {
        var snapshots: [KnowledgeItemIntentSnapshot] = []
        snapshots.reserveCapacity(min(identifiers.count, maximumEntityResolutionCount))

        for identifier in identifiers.prefix(maximumEntityResolutionCount) {
            try Task.checkCancellation()
            var descriptor = FetchDescriptor<KnowledgeItemRecord>(
                predicate: #Predicate { $0.id == identifier }
            )
            descriptor.fetchLimit = 1

            if let item = try modelContext.fetch(descriptor).first,
               let snapshot = knowledgeItemSnapshot(for: item) {
                snapshots.append(snapshot)
            }
        }

        return snapshots
    }

    func knowledgeItems(
        matching query: String,
        workspaceID: UUID? = nil
    ) throws -> [KnowledgeItemIntentSnapshot] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return [] }

        let predicate: Predicate<KnowledgeItemRecord>?
        if let workspaceID {
            predicate = #Predicate { $0.workspace?.id == workspaceID }
        } else {
            predicate = nil
        }
        var descriptor = FetchDescriptor<KnowledgeItemRecord>(
            predicate: predicate,
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maximumKnowledgeItemSearchCount

        var snapshots: [KnowledgeItemIntentSnapshot] = []
        for item in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            let searchableValues = [
                item.title,
                item.textContent,
                item.attachments.first?.originalFilename ?? "",
                item.tags.map(\.name).joined(separator: " ")
            ]
            guard searchableValues.contains(where: { $0.localizedStandardContains(trimmedQuery) }),
                  let snapshot = knowledgeItemSnapshot(for: item) else {
                continue
            }
            snapshots.append(snapshot)
            if snapshots.count == maximumSuggestionCount { break }
        }
        return snapshots
    }

    func suggestedKnowledgeItems() throws -> [KnowledgeItemIntentSnapshot] {
        var descriptor = FetchDescriptor<KnowledgeItemRecord>(
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )
        descriptor.fetchLimit = maximumKnowledgeItemSearchCount

        var snapshots: [KnowledgeItemIntentSnapshot] = []
        for item in try modelContext.fetch(descriptor) {
            try Task.checkCancellation()
            guard let snapshot = knowledgeItemSnapshot(for: item) else { continue }
            snapshots.append(snapshot)
            if snapshots.count == maximumSuggestionCount { break }
        }
        return snapshots
    }

    private func workspaceSnapshot(for workspace: WorkspaceRecord) -> WorkspaceIntentSnapshot {
        WorkspaceIntentSnapshot(id: workspace.id, name: workspace.name)
    }

    private func knowledgeItemSnapshot(for item: KnowledgeItemRecord) -> KnowledgeItemIntentSnapshot? {
        guard let kind = item.kind,
              let workspace = item.workspace else {
            return nil
        }
        return KnowledgeItemIntentSnapshot(
            id: item.id,
            title: item.title,
            kind: kind,
            workspaceName: workspace.name
        )
    }
}

/// Process-local provider that reuses the app's cached SwiftData container.
@MainActor
enum FieldbookIntentDataSourceProvider {
    private static var cachedSource: FieldbookIntentDataSource?

    static func source() throws -> FieldbookIntentDataSource {
        if let cachedSource { return cachedSource }

        guard case let .ready(container) = PersistenceBootstrap.load() else {
            throw FieldbookIntentDataSourceError.persistenceUnavailable
        }

        let source = FieldbookIntentDataSource(modelContainer: container)
        cachedSource = source
        return source
    }
}

enum FieldbookIntentDataSourceError: LocalizedError {
    case persistenceUnavailable

    var errorDescription: String? {
        String(localized: "AI Fieldbook couldn’t access local content.")
    }
}
