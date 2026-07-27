import AppIntents
import Foundation

/// Privacy-minimal workspace value exposed to App Intents.
struct WorkspaceEntity: AppEntity {
    typealias ID = UUID

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Workspace")
    }

    static var defaultQuery: WorkspaceEntityQuery {
        WorkspaceEntityQuery()
    }

    let id: ID
    let name: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)")
    }
}

struct WorkspaceEntityQuery: EntityStringQuery {
    init() {}

    func entities(for identifiers: [UUID]) async throws -> [WorkspaceEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.workspaces(with: identifiers).map(WorkspaceEntity.init(snapshot:))
    }

    func entities(matching string: String) async throws -> [WorkspaceEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.workspaces(matching: string).map(WorkspaceEntity.init(snapshot:))
    }

    func suggestedEntities() async throws -> [WorkspaceEntity] {
        let source = try await FieldbookIntentDataSourceProvider.source()
        return try await source.suggestedWorkspaces().map(WorkspaceEntity.init(snapshot:))
    }
}

private extension WorkspaceEntity {
    init(snapshot: WorkspaceIntentSnapshot) {
        self.init(id: snapshot.id, name: snapshot.name)
    }
}
