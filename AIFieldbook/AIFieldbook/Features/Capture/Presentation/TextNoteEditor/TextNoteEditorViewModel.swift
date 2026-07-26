import Foundation
import Observation

/// Owns create/edit text-note form state and persistence.
///
/// The note is written through `FieldbookRepository` only from `saveTapped()`. Empty notes are
/// rejected: at least a title or body is required.
@Observable
@MainActor
final class TextNoteEditorViewModel {
    enum Mode {
        case create(preselectedWorkspaceID: UUID?)
        case edit(noteID: UUID)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    private let stateBuilder: TextNoteEditorViewStateBuilder
    private var initialTitle = ""
    private var initialBody = ""
    private var initialWorkspaceID: UUID?
    private var title = ""
    private var body = ""
    private var selectedWorkspaceID: UUID?
    private var workspaces: [WorkspaceSummary] = []

    private(set) var state: TextNoteEditorViewState

    init(
        repository: FieldbookRepository,
        mode: Mode,
        stateBuilder: TextNoteEditorViewStateBuilder = TextNoteEditorViewStateBuilder()
    ) {
        self.repository = repository
        self.mode = mode
        self.stateBuilder = stateBuilder

        let initialWorkspaceID: UUID?
        if case let .create(preselectedWorkspaceID) = mode {
            initialWorkspaceID = preselectedWorkspaceID
        } else {
            initialWorkspaceID = nil
        }
        self.selectedWorkspaceID = initialWorkspaceID
        self.initialWorkspaceID = initialWorkspaceID
        self.state = stateBuilder.loading(mode: mode)
    }

    func appeared() {
        guard state.isLoading else { return }
        reloadRequested()
    }

    func reloadRequested() {
        state = stateBuilder.loading(mode: mode)
        do {
            workspaces = try repository.fetchWorkspaces()

            switch mode {
            case let .create(preselectedWorkspaceID):
                let workspaceID = preselectedWorkspaceID ?? workspaces.first?.id
                selectedWorkspaceID = workspaceID
                initialWorkspaceID = workspaceID
            case let .edit(noteID):
                let note = try repository.fetchTextNote(id: noteID)
                title = note.title
                body = note.body
                selectedWorkspaceID = note.workspaceID
                initialTitle = note.title
                initialBody = note.body
                initialWorkspaceID = note.workspaceID
            }
            state = editingState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The note editor couldn’t be loaded.")
            )
        }
    }

    func titleChanged(_ title: String) {
        self.title = title
        state = editingState()
    }

    func bodyChanged(_ body: String) {
        self.body = body
        state = editingState()
    }

    func workspaceSelectionChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        state = editingState()
    }

    func saveTapped() -> Bool {
        guard let workspaceID = selectedWorkspaceID else {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Choose a workspace.")
            )
            return false
        }
        guard !trimmedTitle.isEmpty || !trimmedBody.isEmpty else {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Enter a title or note text.")
            )
            return false
        }

        state = stateBuilder.saving(form: formState())
        do {
            switch mode {
            case .create:
                try repository.createTextNote(
                    workspaceID: workspaceID,
                    title: trimmedTitle,
                    body: trimmedBody
                )
            case let .edit(noteID):
                try repository.updateTextNote(
                    id: noteID,
                    title: trimmedTitle,
                    body: trimmedBody
                )
            }
            title = trimmedTitle
            body = trimmedBody
            initialTitle = trimmedTitle
            initialBody = trimmedBody
            initialWorkspaceID = workspaceID
            state = editingState()
            return true
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The note couldn’t be saved.")
            )
            return false
        }
    }

    private func editingState() -> TextNoteEditorViewState {
        stateBuilder.editing(form: formState())
    }

    private func formState() -> TextNoteEditorFormState {
        stateBuilder.form(
            mode: mode,
            title: title,
            body: body,
            selectedWorkspaceID: selectedWorkspaceID,
            workspaces: workspaces,
            initialTitle: initialTitle,
            initialBody: initialBody,
            initialWorkspaceID: initialWorkspaceID
        )
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
