import Foundation
import Observation

/// Owns the Workspace tab's lifecycle and authoritative render state.
///
/// Ownership:
/// Created by `AppComposition` and reused for the app scene lifetime.
///
/// Failure behavior:
/// A failed reload preserves already-rendered content. An initial load failure transitions to
/// the explicit unavailable state so the screen can offer retry.
@Observable
@MainActor
final class WorkspaceListViewModel {
    private let repository: FieldbookRepository
    private let stateBuilder: WorkspaceListViewStateBuilder

    private(set) var state: WorkspaceListViewState

    init(
        repository: FieldbookRepository,
        stateBuilder: WorkspaceListViewStateBuilder = WorkspaceListViewStateBuilder()
    ) {
        self.repository = repository
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() {
        reloadRequested()
    }

    func reloadRequested() {
        let previousContent = state.content
        if previousContent == nil {
            state = stateBuilder.loading()
        }

        do {
            state = stateBuilder.loaded(workspaces: try repository.fetchWorkspaces())
        } catch {
            if let previousContent {
                state = .content(previousContent)
            } else {
                state = stateBuilder.unavailable(
                    message: String(localized: "Your workspaces couldn’t be loaded.")
                )
            }
        }
    }
}
