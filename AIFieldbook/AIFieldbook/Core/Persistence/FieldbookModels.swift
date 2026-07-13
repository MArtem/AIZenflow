import Foundation
import SwiftData

enum KnowledgeItemKind: String, Codable, CaseIterable, Hashable, Sendable {
    case textNote
    case image
    case pdf
    case plainTextDocument
    case audio
    case urlReference

    var displayName: String {
        switch self {
        case .textNote: String(localized: "Text Note")
        case .image: String(localized: "Image")
        case .pdf: String(localized: "PDF")
        case .plainTextDocument: String(localized: "Text Document")
        case .audio: String(localized: "Audio")
        case .urlReference: String(localized: "Web Link")
        }
    }

    var systemImage: String {
        switch self {
        case .textNote: "note.text"
        case .image: "photo"
        case .pdf: "doc.richtext"
        case .plainTextDocument: "doc.text"
        case .audio: "waveform"
        case .urlReference: "link"
        }
    }
}

/// Version 1 persisted schema kept solely for migration compatibility.
///
/// Migration contract:
/// Do not remove this schema while existing simulator/device data may have been created by
/// earlier Iteration 1 builds. New runtime code should use the `AIFieldbookSchemaV2` typealiases
/// below instead of referring to V1 records.
enum AIFieldbookSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [WorkspaceRecord.self, KnowledgeItemRecord.self, AttachmentRecord.self, TagRecord.self]
    }

    @Model
    final class WorkspaceRecord {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \KnowledgeItemRecord.workspace)
        var items: [KnowledgeItemRecord]

        init(id: UUID = UUID(), name: String, createdAt: Date = .now, updatedAt: Date = .now) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.items = []
        }
    }

    @Model
    final class KnowledgeItemRecord {
        @Attribute(.unique) var id: UUID
        var kindRawValue: String
        var title: String
        var textContent: String
        var createdAt: Date
        var updatedAt: Date
        var workspace: WorkspaceRecord?
        @Relationship(deleteRule: .cascade, inverse: \AttachmentRecord.item)
        var attachments: [AttachmentRecord]

        init(
            id: UUID = UUID(),
            kindRawValue: String,
            title: String,
            textContent: String,
            createdAt: Date = .now,
            updatedAt: Date = .now,
            workspace: WorkspaceRecord? = nil
        ) {
            self.id = id
            self.kindRawValue = kindRawValue
            self.title = title
            self.textContent = textContent
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.workspace = workspace
            self.attachments = []
        }
    }

    @Model
    final class AttachmentRecord {
        @Attribute(.unique) var id: UUID
        var relativePath: String
        var originalFilename: String
        var contentType: String
        var byteCount: Int64
        var createdAt: Date
        var item: KnowledgeItemRecord?

        init(
            id: UUID = UUID(),
            relativePath: String,
            originalFilename: String,
            contentType: String,
            byteCount: Int64,
            createdAt: Date = .now,
            item: KnowledgeItemRecord? = nil
        ) {
            self.id = id
            self.relativePath = relativePath
            self.originalFilename = originalFilename
            self.contentType = contentType
            self.byteCount = byteCount
            self.createdAt = createdAt
            self.item = item
        }
    }

    @Model
    final class TagRecord {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date

        init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
        }
    }
}

enum AIFieldbookSchemaV2: VersionedSchema {
    static let versionIdentifier = Schema.Version(2, 0, 0)

    static var models: [any PersistentModel.Type] {
        [WorkspaceRecord.self, KnowledgeItemRecord.self, AttachmentRecord.self, TagRecord.self]
    }

    @Model
    final class WorkspaceRecord {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var updatedAt: Date
        @Relationship(deleteRule: .cascade, inverse: \KnowledgeItemRecord.workspace)
        var items: [KnowledgeItemRecord]

        init(id: UUID = UUID(), name: String, createdAt: Date = .now, updatedAt: Date = .now) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.items = []
        }
    }

    @Model
    final class KnowledgeItemRecord {
        @Attribute(.unique) var id: UUID
        var kindRawValue: String
        var title: String
        var textContent: String
        var createdAt: Date
        var updatedAt: Date
        var workspace: WorkspaceRecord?
        @Relationship(deleteRule: .cascade, inverse: \AttachmentRecord.item)
        var attachments: [AttachmentRecord]
        @Relationship(deleteRule: .nullify, inverse: \TagRecord.items)
        var tags: [TagRecord]

        init(
            id: UUID = UUID(),
            kind: KnowledgeItemKind,
            title: String,
            textContent: String,
            createdAt: Date = .now,
            updatedAt: Date = .now,
            workspace: WorkspaceRecord? = nil
        ) {
            self.id = id
            self.kindRawValue = kind.rawValue
            self.title = title
            self.textContent = textContent
            self.createdAt = createdAt
            self.updatedAt = updatedAt
            self.workspace = workspace
            self.attachments = []
            self.tags = []
        }

        var kind: KnowledgeItemKind? {
            KnowledgeItemKind(rawValue: kindRawValue)
        }
    }

    @Model
    final class AttachmentRecord {
        @Attribute(.unique) var id: UUID
        var relativePath: String
        var originalFilename: String
        var contentType: String
        var byteCount: Int64
        var createdAt: Date
        var durationSeconds: Double?
        var pixelWidth: Int?
        var pixelHeight: Int?
        var pageCount: Int?
        var item: KnowledgeItemRecord?

        init(
            id: UUID = UUID(),
            relativePath: String,
            originalFilename: String,
            contentType: String,
            byteCount: Int64,
            createdAt: Date = .now,
            durationSeconds: Double? = nil,
            pixelWidth: Int? = nil,
            pixelHeight: Int? = nil,
            pageCount: Int? = nil,
            item: KnowledgeItemRecord? = nil
        ) {
            self.id = id
            self.relativePath = relativePath
            self.originalFilename = originalFilename
            self.contentType = contentType
            self.byteCount = byteCount
            self.createdAt = createdAt
            self.durationSeconds = durationSeconds
            self.pixelWidth = pixelWidth
            self.pixelHeight = pixelHeight
            self.pageCount = pageCount
            self.item = item
        }
    }

    @Model
    final class TagRecord {
        @Attribute(.unique) var id: UUID
        var name: String
        var createdAt: Date
        var items: [KnowledgeItemRecord]

        init(id: UUID = UUID(), name: String, createdAt: Date = .now) {
            self.id = id
            self.name = name
            self.createdAt = createdAt
            self.items = []
        }
    }
}

typealias WorkspaceRecord = AIFieldbookSchemaV2.WorkspaceRecord
typealias KnowledgeItemRecord = AIFieldbookSchemaV2.KnowledgeItemRecord
typealias AttachmentRecord = AIFieldbookSchemaV2.AttachmentRecord
typealias TagRecord = AIFieldbookSchemaV2.TagRecord

/// SwiftData migration plan for AI Fieldbook local records.
///
/// Compatibility:
/// The V1 → V2 stage is lightweight because V2 adds tag relationships and attachment metadata.
/// Any future destructive reset must be recorded as an app-local exception and accepted by the
/// user before changing this plan.
enum AIFieldbookMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [AIFieldbookSchemaV1.self, AIFieldbookSchemaV2.self]
    }

    static var stages: [MigrationStage] {
        [
            .lightweight(fromVersion: AIFieldbookSchemaV1.self, toVersion: AIFieldbookSchemaV2.self)
        ]
    }
}
