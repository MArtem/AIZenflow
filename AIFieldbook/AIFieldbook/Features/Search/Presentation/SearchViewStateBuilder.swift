import Foundation

/// Pure mapper for local-search criteria, filter options, and immutable result rows.
struct SearchViewStateBuilder {
    func criteria(form: SearchFormState) -> SearchViewState {
        .criteria(form)
    }

    func searching(
        form: SearchFormState,
        existingRows: [SearchResultRowState]
    ) -> SearchViewState {
        .searching(form: form, existingRows: existingRows)
    }

    func results(form: SearchFormState, results: [KnowledgeItemSummary]) -> SearchViewState {
        .results(form: form, rows: rows(from: results))
    }

    func empty(form: SearchFormState) -> SearchViewState {
        .empty(form)
    }

    func failure(form: SearchFormState, message: String) -> SearchViewState {
        .failure(form: form, message: message)
    }

    func form(
        query: String,
        selectedWorkspaceID: UUID?,
        selectedKind: KnowledgeItemKind?,
        selectedTagID: UUID?,
        workspaces: [WorkspaceSummary],
        tags: [TagSummary]
    ) -> SearchFormState {
        SearchFormState(
            query: query,
            selectedWorkspaceID: selectedWorkspaceID,
            selectedKind: selectedKind,
            selectedTagID: selectedTagID,
            workspaces: workspaces.map {
                SearchWorkspaceOptionState(id: $0.id, title: $0.name)
            },
            kinds: KnowledgeItemKind.allCases.map {
                SearchKindOptionState(kind: $0, title: $0.displayName)
            },
            tags: tags.map {
                SearchTagOptionState(id: $0.id, title: $0.name)
            }
        )
    }

    private func rows(from results: [KnowledgeItemSummary]) -> [SearchResultRowState] {
        results.map {
            SearchResultRowState(
                id: $0.id,
                kind: $0.kind,
                title: $0.displayTitle,
                subtitle: $0.subtitle,
                updatedAtText: $0.updatedAt.formatted(.dateTime.month().day().hour().minute())
            )
        }
    }
}
