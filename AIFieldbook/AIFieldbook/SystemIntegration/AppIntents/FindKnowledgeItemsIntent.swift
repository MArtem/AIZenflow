import AppIntents
import Foundation

/// Finds up to twenty local knowledge items without exposing their private content.
struct FindKnowledgeItemsIntent: AppIntent {
    static let title: LocalizedStringResource = "Find Knowledge Items"
    static let description = IntentDescription("Find local knowledge items in AI Fieldbook.")
    static let supportedModes: IntentModes = .foreground(.immediate)
    static let isDiscoverable = true

    @Parameter(title: "Search")
    var query: String

    @Parameter(title: "Workspace")
    var workspace: WorkspaceEntity?

    static var parameterSummary: some ParameterSummary {
        Summary("Find \(\.$query)")
    }

    init() {}

    func perform() async throws -> some IntentResult & ReturnsValue<[KnowledgeItemEntity]> {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else {
            throw FindKnowledgeItemsIntentError.emptyQuery
        }
        try Task.checkCancellation()

        let source = try await FieldbookIntentDataSourceProvider.source()
        if let workspace,
           try await source.workspaces(with: [workspace.id]).isEmpty {
            throw FindKnowledgeItemsIntentError.workspaceUnavailable
        }

        do {
            let items = try await source.knowledgeItems(
                matching: trimmedQuery,
                workspaceID: workspace?.id
            ).map(KnowledgeItemEntity.init(snapshot:))
            return .result(value: items)
        } catch is CancellationError {
            throw CancellationError()
        } catch {
            throw FindKnowledgeItemsIntentError.searchUnavailable
        }
    }
}

private enum FindKnowledgeItemsIntentError: LocalizedError {
    case emptyQuery
    case workspaceUnavailable
    case searchUnavailable

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            String(localized: "Enter text to find local knowledge items.")
        case .workspaceUnavailable:
            String(localized: "The selected workspace no longer exists.")
        case .searchUnavailable:
            String(localized: "Knowledge items couldn’t be searched.")
        }
    }
}
