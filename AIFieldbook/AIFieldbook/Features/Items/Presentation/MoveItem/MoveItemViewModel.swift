import Foundation
import Observation

/// Owns destination selection and local repository mutation for one item move.
@Observable
@MainActor
final class MoveItemViewModel {
    private let repository: FieldbookRepository
    private let stateBuilder: MoveItemViewStateBuilder
    let itemID: UUID

    private var selectedWorkspaceID: UUID?
    private var workspaces: [WorkspaceSummary] = []

    private(set) var state: MoveItemViewState

    init(
        repository: FieldbookRepository,
        itemID: UUID,
        stateBuilder: MoveItemViewStateBuilder = MoveItemViewStateBuilder()
    ) {
        self.repository = repository
        self.itemID = itemID
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() {
        guard state.isLoading else { return }
        reloadRequested()
    }

    func retryTapped() {
        reloadRequested()
    }

    func destinationChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        state = displayState()
    }

    func moveTapped() -> Bool {
        guard let selectedWorkspaceID else { return false }
        state = stateBuilder.moving(form: formState())
        do {
            try repository.moveItem(id: itemID, to: selectedWorkspaceID)
            state = displayState()
            return true
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The item couldn’t be moved.")
            )
            return false
        }
    }

    private func reloadRequested() {
        state = stateBuilder.loading()
        do {
            workspaces = try repository.fetchWorkspaces()
            selectedWorkspaceID = selectedWorkspaceID ?? workspaces.first?.id
            state = displayState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Workspaces couldn’t be loaded.")
            )
        }
    }

    private func displayState() -> MoveItemViewState {
        let form = formState()
        return form.workspaces.isEmpty
            ? stateBuilder.empty(form: form)
            : stateBuilder.content(form: form)
    }

    private func formState() -> MoveItemFormState {
        stateBuilder.form(selectedWorkspaceID: selectedWorkspaceID, workspaces: workspaces)
    }
}
