import AppIntents
import Foundation

/// Privacy-minimal local knowledge-item value exposed to App Intents.
struct KnowledgeItemEntity: AppEntity {
    typealias ID = UUID

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Knowledge Item")
    }

    static var defaultQuery: KnowledgeItemEntityQuery {
        KnowledgeItemEntityQuery()
    }

    let id: ID
    let title: String
    let kind: KnowledgeItemKind
    let workspaceName: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: "\(displayTitle)",
            subtitle: "\(kind.displayName) · \(workspaceName)"
        )
    }

    private var displayTitle: String {
        title.isEmpty ? String(localized: "Untitled Item") : title
    }
}

struct KnowledgeItemEntityQuery: EntityStringQuery {
    init() {}

    func entities(for identifiers: [UUID]) async throws -> [KnowledgeItemEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.knowledgeItems(with: identifiers).map(KnowledgeItemEntity.init(snapshot:))
    }

    func entities(matching string: String) async throws -> [KnowledgeItemEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.knowledgeItems(matching: string).map(KnowledgeItemEntity.init(snapshot:))
    }

    func suggestedEntities() async throws -> [KnowledgeItemEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.suggestedKnowledgeItems().map(KnowledgeItemEntity.init(snapshot:))
    }
}

extension KnowledgeItemEntity {
    init(snapshot: KnowledgeItemIntentSnapshot) {
        self.init(
            id: snapshot.id,
            title: snapshot.title,
            kind: snapshot.kind,
            workspaceName: snapshot.workspaceName
        )
    }
}
