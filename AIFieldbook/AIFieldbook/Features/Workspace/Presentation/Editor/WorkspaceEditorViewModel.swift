import Foundation
import Observation

/// Owns create/rename workspace form state and persistence.
///
/// Invariant:
/// Empty names are rejected, and rename is disabled until the value differs from the original
/// name captured at initialization.
@Observable
@MainActor
final class WorkspaceEditorViewModel {
    enum Mode {
        case create
        case rename(id: UUID, currentName: String)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    private let stateBuilder: WorkspaceEditorViewStateBuilder
    private var initialName: String
    private var name: String

    private(set) var state: WorkspaceEditorViewState

    init(
        repository: FieldbookRepository,
        mode: Mode,
        stateBuilder: WorkspaceEditorViewStateBuilder = WorkspaceEditorViewStateBuilder()
    ) {
        self.repository = repository
        self.mode = mode
        self.stateBuilder = stateBuilder

        let startingName: String
        switch mode {
        case .create:
            startingName = ""
        case let .rename(_, currentName):
            startingName = currentName
        }
        self.name = startingName
        self.initialName = startingName

        self.state = stateBuilder.editing(
            mode: mode,
            name: startingName,
            initialName: startingName
        )
    }

    func nameChanged(_ name: String) {
        self.name = name
        state = stateBuilder.editing(mode: mode, name: name, initialName: initialName)
    }

    func saveTapped() -> Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else {
            state = stateBuilder.failure(
                mode: mode,
                name: name,
                initialName: initialName,
                message: String(localized: "Enter a workspace name.")
            )
            return false
        }

        state = stateBuilder.saving(mode: mode, name: name, initialName: initialName)
        do {
            switch mode {
            case .create:
                try repository.createWorkspace(name: trimmedName)
            case let .rename(id, _):
                try repository.renameWorkspace(id: id, name: trimmedName)
            }
            name = trimmedName
            initialName = trimmedName
            state = stateBuilder.editing(mode: mode, name: name, initialName: initialName)
            return true
        } catch {
            state = stateBuilder.failure(
                mode: mode,
                name: name,
                initialName: initialName,
                message: String(localized: "The workspace couldn’t be saved.")
            )
            return false
        }
    }
}
