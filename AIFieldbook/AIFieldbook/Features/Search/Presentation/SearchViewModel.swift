import Foundation
import Observation

/// Owns local search criteria, presentation state, and the one cancellable debounced query task.
///
/// The model is created by `AppComposition` for the scene lifetime. Search queries execute in
/// `FieldbookSearchIndex`; this main-actor owner cancels previous work on every criterion change
/// and ignores a result unless it still belongs to the current criterion snapshot.
@Observable
@MainActor
final class SearchViewModel {
    private let repository: FieldbookRepository
    private let searchIndex: FieldbookSearchIndex
    private let stateBuilder: SearchViewStateBuilder
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    private var query = ""
    private var selectedWorkspaceID: UUID?
    private var selectedKind: KnowledgeItemKind?
    private var selectedTagID: UUID?
    private var workspaces: [WorkspaceSummary] = []
    private var tags: [TagSummary] = []

    private(set) var state: SearchViewState

    init(
        repository: FieldbookRepository,
        searchIndex: FieldbookSearchIndex,
        stateBuilder: SearchViewStateBuilder = SearchViewStateBuilder()
    ) {
        self.repository = repository
        self.searchIndex = searchIndex
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.criteria(form: SearchFormState.empty)
    }

    func appeared() {
        do {
            workspaces = try repository.fetchWorkspaces()
            tags = try repository.fetchTags()
            scheduleSearchCriteriaChange()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Search filters couldn’t be loaded.")
            )
        }
    }

    func disappeared() {
        cancelSearch()
    }

    func queryChanged(_ query: String) {
        self.query = query
        scheduleSearchCriteriaChange()
    }

    func workspaceSelectionChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        scheduleSearchCriteriaChange()
    }

    func kindSelectionChanged(_ kind: KnowledgeItemKind?) {
        selectedKind = kind
        scheduleSearchCriteriaChange()
    }

    func tagSelectionChanged(_ tagID: UUID?) {
        selectedTagID = tagID
        scheduleSearchCriteriaChange()
    }

    func clearTapped() {
        cancelSearch()
        query = ""
        selectedWorkspaceID = nil
        selectedKind = nil
        selectedTagID = nil
        state = stateBuilder.criteria(form: formState())
    }

    func retryTapped() {
        appeared()
    }

    private func scheduleSearchCriteriaChange() {
        let criteria = currentCriteria
        guard criteria.hasActiveCriteria else {
            cancelSearch()
            state = stateBuilder.criteria(form: formState())
            return
        }

        cancelSearch()
        let existingRows = state.rows
        state = stateBuilder.searching(form: formState(), existingRows: existingRows)
        searchTask = Task { [weak self, searchIndex, criteria] in
            do {
                try await Task.sleep(for: .milliseconds(250))
                let foundResults = try await searchIndex.search(criteria: criteria)
                guard !Task.isCancelled else { return }
                self?.applySearchResults(foundResults, for: criteria)
            } catch is CancellationError {
                return
            } catch {
                self?.applySearchFailure(for: criteria)
            }
        }
    }

    private func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }

    private var currentCriteria: FieldbookSearchCriteria {
        FieldbookSearchCriteria(
            query: query,
            workspaceID: selectedWorkspaceID,
            kind: selectedKind,
            tagID: selectedTagID
        )
    }

    private func applySearchResults(
        _ results: [KnowledgeItemSummary],
        for criteria: FieldbookSearchCriteria
    ) {
        guard currentCriteria == criteria else { return }
        let form = formState()
        state = results.isEmpty
            ? stateBuilder.empty(form: form)
            : stateBuilder.results(form: form, results: results)
    }

    private func applySearchFailure(for criteria: FieldbookSearchCriteria) {
        guard currentCriteria == criteria else { return }
        state = stateBuilder.failure(
            form: formState(),
            message: String(localized: "Local search couldn’t be completed.")
        )
    }

    private func formState() -> SearchFormState {
        stateBuilder.form(
            query: query,
            selectedWorkspaceID: selectedWorkspaceID,
            selectedKind: selectedKind,
            selectedTagID: selectedTagID,
            workspaces: workspaces,
            tags: tags
        )
    }
}
