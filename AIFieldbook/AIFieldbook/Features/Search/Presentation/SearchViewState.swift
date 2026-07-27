import Foundation

/// Render-ready state for the local search tab.
enum SearchViewState: Equatable {
    case criteria(SearchFormState)
    case searching(form: SearchFormState, existingRows: [SearchResultRowState])
    case results(form: SearchFormState, rows: [SearchResultRowState])
    case empty(SearchFormState)
    case failure(form: SearchFormState, message: String)

    var form: SearchFormState {
        switch self {
        case let .criteria(form), let .empty(form):
            form
        case let .searching(form, _), let .results(form, _), let .failure(form, _):
            form
        }
    }

    var rows: [SearchResultRowState] {
        switch self {
        case let .searching(_, rows), let .results(_, rows):
            rows
        case .criteria, .empty, .failure:
            []
        }
    }
}

struct SearchFormState: Equatable {
    static let empty = SearchFormState(
        query: "",
        selectedWorkspaceID: nil,
        selectedKind: nil,
        selectedTagID: nil,
        workspaces: [],
        kinds: [],
        tags: []
    )

    let query: String
    let selectedWorkspaceID: UUID?
    let selectedKind: KnowledgeItemKind?
    let selectedTagID: UUID?
    let workspaces: [SearchWorkspaceOptionState]
    let kinds: [SearchKindOptionState]
    let tags: [SearchTagOptionState]

    var hasActiveCriteria: Bool {
        !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || selectedWorkspaceID != nil
            || selectedKind != nil
            || selectedTagID != nil
    }
}

struct SearchWorkspaceOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}

struct SearchKindOptionState: Equatable {
    let kind: KnowledgeItemKind
    let title: String
}

struct SearchTagOptionState: Identifiable, Equatable {
    let id: UUID
    let title: String
}

struct SearchResultRowState: Identifiable, Equatable {
    let id: UUID
    let kind: KnowledgeItemKind
    let title: String
    let subtitle: String
    let updatedAtText: String
}
