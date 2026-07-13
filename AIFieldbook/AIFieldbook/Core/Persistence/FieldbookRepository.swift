import Foundation
import SwiftData

struct WorkspaceSummary: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
    let itemCount: Int
    let updatedAt: Date
}

struct TagSummary: Identifiable, Hashable, Sendable {
    let id: UUID
    let name: String
}

struct KnowledgeItemSummary: Identifiable, Hashable, Sendable {
    let id: UUID
    let kind: KnowledgeItemKind
    let title: String
    let filename: String?
    let tags: [TagSummary]
    let updatedAt: Date

    var displayTitle: String {
        if !title.isEmpty { return title }
        if let filename, !filename.isEmpty { return filename }
        return String(localized: "Untitled Item")
    }

    var subtitle: String {
        var components = [kind.displayName]
        if !tags.isEmpty {
            components.append(tags.map(\.name).joined(separator: ", "))
        }
        return components.joined(separator: " · ")
    }
}

struct TextNoteSummary: Identifiable, Hashable, Sendable {
    let id: UUID
    let title: String
    let updatedAt: Date

    var displayTitle: String {
        title.isEmpty ? String(localized: "Untitled Note") : title
    }
}

struct WorkspaceDetailState: Equatable, Sendable {
    let id: UUID
    let name: String
    let items: [KnowledgeItemSummary]

    var notes: [TextNoteSummary] {
        items.compactMap { item in
            guard item.kind == .textNote else { return nil }
            return TextNoteSummary(id: item.id, title: item.title, updatedAt: item.updatedAt)
        }
    }
}

struct TextNoteDetailState: Equatable, Sendable {
    let id: UUID
    let workspaceID: UUID
    let title: String
    let body: String
    let tags: [TagSummary]
    let createdAt: Date
    let updatedAt: Date

    var displayTitle: String {
        title.isEmpty ? String(localized: "Untitled Note") : title
    }
}

struct ImportedItemDetailState: Equatable, Sendable {
    let id: UUID
    let workspaceID: UUID
    let kind: KnowledgeItemKind
    let title: String
    let tags: [TagSummary]
    let reference: DurableFileReference
    let originalFilename: String
    let contentType: String
    let byteCount: Int64
    let durationSeconds: Double?
    let pixelWidth: Int?
    let pixelHeight: Int?
    let pageCount: Int?
    let createdAt: Date
    let updatedAt: Date

    var displayTitle: String {
        title.isEmpty ? originalFilename : title
    }
}

struct URLReferenceDetailState: Equatable, Sendable {
    let id: UUID
    let workspaceID: UUID
    let title: String
    let url: URL
    let notes: String
    let tags: [TagSummary]
    let createdAt: Date
    let updatedAt: Date
}

private struct URLReferencePayload: Codable {
    let url: String
    let notes: String
}

enum FieldbookRepositoryError: Error {
    case workspaceNotFound
    case itemNotFound
    case noteNotFound
    case attachmentNotFound
    case tagNotFound
}

@MainActor
final class FieldbookRepository {
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
    }

    func fetchWorkspaces() throws -> [WorkspaceSummary] {
        let descriptor = FetchDescriptor<WorkspaceRecord>(
            sortBy: [SortDescriptor(\WorkspaceRecord.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor).map { workspace in
            WorkspaceSummary(
                id: workspace.id,
                name: workspace.name,
                itemCount: workspace.items.count,
                updatedAt: workspace.updatedAt
            )
        }
    }

    @discardableResult
    func createWorkspace(name: String) throws -> UUID {
        let workspace = WorkspaceRecord(name: name)
        context.insert(workspace)
        try context.save()
        return workspace.id
    }

    func renameWorkspace(id: UUID, name: String) throws {
        let workspace = try workspaceRecord(id: id)
        workspace.name = name
        workspace.updatedAt = .now
        try context.save()
    }

    func workspaceFileReferences(id: UUID) throws -> [DurableFileReference] {
        let workspace = try workspaceRecord(id: id)
        return try workspace.items.flatMap { item in
            try item.attachments.map { try DurableFileReference(relativePath: $0.relativePath) }
        }
    }

    func deleteWorkspace(id: UUID) throws {
        let workspace = try workspaceRecord(id: id)
        context.delete(workspace)
        try context.save()
    }

    func fetchWorkspaceDetail(id: UUID) throws -> WorkspaceDetailState {
        let workspace = try workspaceRecord(id: id)
        return WorkspaceDetailState(
            id: workspace.id,
            name: workspace.name,
            items: workspace.items
                .sorted { $0.updatedAt > $1.updatedAt }
                .compactMap(makeItemSummary)
        )
    }

    func fetchKnowledgeItems(workspaceID: UUID? = nil) throws -> [KnowledgeItemSummary] {
        let descriptor = FetchDescriptor<KnowledgeItemRecord>(
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )
        return try context.fetch(descriptor)
            .filter { workspaceID == nil || $0.workspace?.id == workspaceID }
            .compactMap(makeItemSummary)
    }

    func itemKind(id: UUID) throws -> KnowledgeItemKind {
        guard let kind = try itemRecord(id: id).kind else { throw FieldbookRepositoryError.itemNotFound }
        return kind
    }

    @discardableResult
    func createTextNote(workspaceID: UUID, title: String, body: String) throws -> UUID {
        let workspace = try workspaceRecord(id: workspaceID)
        let note = KnowledgeItemRecord(
            kind: .textNote,
            title: title,
            textContent: body,
            workspace: workspace
        )
        context.insert(note)
        workspace.updatedAt = .now
        try context.save()
        return note.id
    }

    func fetchTextNote(id: UUID) throws -> TextNoteDetailState {
        let note = try noteRecord(id: id)
        guard let workspaceID = note.workspace?.id else {
            throw FieldbookRepositoryError.workspaceNotFound
        }
        return TextNoteDetailState(
            id: note.id,
            workspaceID: workspaceID,
            title: note.title,
            body: note.textContent,
            tags: tagSummaries(note.tags),
            createdAt: note.createdAt,
            updatedAt: note.updatedAt
        )
    }

    func updateTextNote(id: UUID, title: String, body: String) throws {
        let note = try noteRecord(id: id)
        note.title = title
        note.textContent = body
        note.updatedAt = .now
        note.workspace?.updatedAt = .now
        try context.save()
    }

    @discardableResult
    func createURLReference(workspaceID: UUID, title: String, url: URL, notes: String) throws -> UUID {
        let workspace = try workspaceRecord(id: workspaceID)
        let payload = URLReferencePayload(url: url.absoluteString, notes: notes)
        let encoded = try JSONEncoder().encode(payload)
        let item = KnowledgeItemRecord(
            kind: .urlReference,
            title: title,
            textContent: String(decoding: encoded, as: UTF8.self),
            workspace: workspace
        )
        context.insert(item)
        workspace.updatedAt = .now
        try context.save()
        return item.id
    }

    func fetchURLReference(id: UUID) throws -> URLReferenceDetailState {
        let item = try itemRecord(id: id)
        guard item.kind == .urlReference,
              let workspaceID = item.workspace?.id,
              let data = item.textContent.data(using: .utf8),
              let payload = try? JSONDecoder().decode(URLReferencePayload.self, from: data),
              let url = URL(string: payload.url) else {
            throw FieldbookRepositoryError.itemNotFound
        }
        return URLReferenceDetailState(
            id: item.id,
            workspaceID: workspaceID,
            title: item.title,
            url: url,
            notes: payload.notes,
            tags: tagSummaries(item.tags),
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func updateURLReference(id: UUID, title: String, url: URL, notes: String) throws {
        let item = try itemRecord(id: id)
        guard item.kind == .urlReference else { throw FieldbookRepositoryError.itemNotFound }
        let payload = URLReferencePayload(url: url.absoluteString, notes: notes)
        item.title = title
        item.textContent = String(decoding: try JSONEncoder().encode(payload), as: UTF8.self)
        item.updatedAt = .now
        item.workspace?.updatedAt = .now
        try context.save()
    }

    func deleteTextNote(id: UUID) throws {
        try deleteItem(id: id)
    }

    @discardableResult
    func createImportedItem(
        workspaceID: UUID,
        kind: KnowledgeItemKind,
        metadata: ImportedFileMetadata,
        title preferredTitle: String? = nil
    ) throws -> UUID {
        let workspace = try workspaceRecord(id: workspaceID)
        let fallbackTitle = (metadata.originalFilename as NSString).deletingPathExtension
        let trimmedTitle = preferredTitle?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let title = trimmedTitle.isEmpty ? fallbackTitle : trimmedTitle
        let item = KnowledgeItemRecord(
            kind: kind,
            title: title,
            textContent: "",
            workspace: workspace
        )
        let attachment = AttachmentRecord(
            relativePath: metadata.reference.relativePath,
            originalFilename: metadata.originalFilename,
            contentType: metadata.contentType,
            byteCount: metadata.byteCount,
            durationSeconds: metadata.durationSeconds,
            pixelWidth: metadata.pixelWidth,
            pixelHeight: metadata.pixelHeight,
            pageCount: metadata.pageCount,
            item: item
        )
        context.insert(item)
        context.insert(attachment)
        workspace.updatedAt = .now
        try context.save()
        return item.id
    }

    func fetchImportedItem(id: UUID) throws -> ImportedItemDetailState {
        let item = try itemRecord(id: id)
        guard item.kind != .textNote, item.kind != .urlReference else {
            throw FieldbookRepositoryError.itemNotFound
        }
        guard let workspaceID = item.workspace?.id else {
            throw FieldbookRepositoryError.workspaceNotFound
        }
        guard let attachment = item.attachments.first else {
            throw FieldbookRepositoryError.attachmentNotFound
        }
        return ImportedItemDetailState(
            id: item.id,
            workspaceID: workspaceID,
            kind: item.kind ?? .plainTextDocument,
            title: item.title,
            tags: tagSummaries(item.tags),
            reference: try DurableFileReference(relativePath: attachment.relativePath),
            originalFilename: attachment.originalFilename,
            contentType: attachment.contentType,
            byteCount: attachment.byteCount,
            durationSeconds: attachment.durationSeconds,
            pixelWidth: attachment.pixelWidth,
            pixelHeight: attachment.pixelHeight,
            pageCount: attachment.pageCount,
            createdAt: item.createdAt,
            updatedAt: item.updatedAt
        )
    }

    func itemFileReferences(id: UUID) throws -> [DurableFileReference] {
        let item = try itemRecord(id: id)
        return try item.attachments.map { try DurableFileReference(relativePath: $0.relativePath) }
    }

    func deleteItem(id: UUID) throws {
        let item = try itemRecord(id: id)
        let workspace = item.workspace
        context.delete(item)
        workspace?.updatedAt = .now
        try context.save()
    }

    func moveItem(id: UUID, to workspaceID: UUID) throws {
        let item = try itemRecord(id: id)
        let destination = try workspaceRecord(id: workspaceID)
        let source = item.workspace
        guard source?.id != destination.id else { return }
        item.workspace = destination
        item.updatedAt = .now
        source?.updatedAt = .now
        destination.updatedAt = .now
        try context.save()
    }

    func fetchTags() throws -> [TagSummary] {
        let descriptor = FetchDescriptor<TagRecord>(
            sortBy: [SortDescriptor(\TagRecord.name, order: .forward)]
        )
        return try context.fetch(descriptor).map { TagSummary(id: $0.id, name: $0.name) }
    }

    func itemTagIDs(itemID: UUID) throws -> Set<UUID> {
        Set(try itemRecord(id: itemID).tags.map(\.id))
    }

    @discardableResult
    func createTag(name: String) throws -> UUID {
        let normalizedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        if let existing = try context.fetch(FetchDescriptor<TagRecord>())
            .first(where: { $0.name.compare(normalizedName, options: [.caseInsensitive, .diacriticInsensitive]) == .orderedSame }) {
            return existing.id
        }
        let tag = TagRecord(name: normalizedName)
        context.insert(tag)
        try context.save()
        return tag.id
    }

    func setTagAssignment(itemID: UUID, tagID: UUID, isAssigned: Bool) throws {
        let item = try itemRecord(id: itemID)
        let tag = try tagRecord(id: tagID)
        let currentlyAssigned = item.tags.contains { $0.id == tagID }

        if isAssigned, !currentlyAssigned {
            item.tags.append(tag)
        } else if !isAssigned, currentlyAssigned {
            item.tags.removeAll { $0.id == tagID }
        }
        item.updatedAt = .now
        item.workspace?.updatedAt = .now
        try context.save()
    }

    func search(
        query: String,
        workspaceID: UUID?,
        kind: KnowledgeItemKind?,
        tagID: UUID?
    ) throws -> [KnowledgeItemSummary] {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let descriptor = FetchDescriptor<KnowledgeItemRecord>(
            sortBy: [SortDescriptor(\KnowledgeItemRecord.updatedAt, order: .reverse)]
        )

        return try context.fetch(descriptor)
            .filter { item in
                guard workspaceID == nil || item.workspace?.id == workspaceID else { return false }
                guard kind == nil || item.kind == kind else { return false }
                guard tagID == nil || item.tags.contains(where: { $0.id == tagID }) else { return false }
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
    }

    func allFileReferences() throws -> [DurableFileReference] {
        try context.fetch(FetchDescriptor<AttachmentRecord>()).map {
            try DurableFileReference(relativePath: $0.relativePath)
        }
    }

    func exportManifestData() throws -> Data {
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

        let workspaces = try context.fetch(FetchDescriptor<WorkspaceRecord>()).map { workspace in
            Manifest.Workspace(
                id: workspace.id,
                name: workspace.name,
                items: workspace.items.map { item in
                    Manifest.Item(
                        id: item.id,
                        kind: item.kindRawValue,
                        title: item.title,
                        textContent: item.textContent,
                        tags: item.tags.map(\.name),
                        files: item.attachments.map(\.relativePath),
                        updatedAt: item.updatedAt
                    )
                }
            )
        }
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try encoder.encode(Manifest(formatVersion: 1, exportedAt: .now, workspaces: workspaces))
    }

    func deleteAllData() throws {
        try context.delete(model: WorkspaceRecord.self)
        try context.delete(model: TagRecord.self)
        try context.save()
    }

    private func workspaceRecord(id: UUID) throws -> WorkspaceRecord {
        let targetID = id
        var descriptor = FetchDescriptor<WorkspaceRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        guard let workspace = try context.fetch(descriptor).first else {
            throw FieldbookRepositoryError.workspaceNotFound
        }
        return workspace
    }

    private func itemRecord(id: UUID) throws -> KnowledgeItemRecord {
        let targetID = id
        var descriptor = FetchDescriptor<KnowledgeItemRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        guard let item = try context.fetch(descriptor).first else {
            throw FieldbookRepositoryError.itemNotFound
        }
        return item
    }

    private func noteRecord(id: UUID) throws -> KnowledgeItemRecord {
        let item = try itemRecord(id: id)
        guard item.kind == .textNote else {
            throw FieldbookRepositoryError.noteNotFound
        }
        return item
    }

    private func tagRecord(id: UUID) throws -> TagRecord {
        let targetID = id
        var descriptor = FetchDescriptor<TagRecord>(
            predicate: #Predicate { $0.id == targetID }
        )
        descriptor.fetchLimit = 1
        guard let tag = try context.fetch(descriptor).first else {
            throw FieldbookRepositoryError.tagNotFound
        }
        return tag
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
