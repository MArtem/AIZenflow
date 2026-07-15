import Foundation
import Observation

/// Owns create/edit state for a text note form.
///
/// Ownership:
/// Created by `AppComposition` for text-note sheets. The model owns unsaved form state until
/// the user saves or dismisses the sheet.
///
/// Side effects:
/// Writes to SwiftData through `FieldbookRepository` only from `saveTapped()`.
///
/// Invariant:
/// Empty notes are not saved; either title or body must contain user text.
@Observable
@MainActor
final class TextNoteEditorViewModel {
    enum Mode {
        case create(preselectedWorkspaceID: UUID?)
        case edit(noteID: UUID)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    private var initialTitle = ""
    private var initialBody = ""
    private var initialWorkspaceID: UUID?

    var title = ""
    var body = ""
    var selectedWorkspaceID: UUID?
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var isLoading = false
    private(set) var isSaving = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, mode: Mode) {
        self.repository = repository
        self.mode = mode

        switch mode {
        case let .create(preselectedWorkspaceID):
            selectedWorkspaceID = preselectedWorkspaceID
            initialWorkspaceID = preselectedWorkspaceID
        case .edit:
            break
        }
    }

    var navigationTitle: String {
        switch mode {
        case .create: String(localized: "New Text Note")
        case .edit: String(localized: "Edit Text Note")
        }
    }

    var showsWorkspacePicker: Bool {
        if case .create(preselectedWorkspaceID: nil) = mode { return true }
        return false
    }

    var canSave: Bool {
        selectedWorkspaceID != nil && (!trimmedTitle.isEmpty || !trimmedBody.isEmpty)
    }

    var hasUnsavedChanges: Bool {
        title != initialTitle || body != initialBody || selectedWorkspaceID != initialWorkspaceID
    }

    func appeared() {
        guard workspaces.isEmpty else { return }
        loadContent()
    }

    func saveTapped() -> Bool {
        guard let workspaceID = selectedWorkspaceID else {
            errorMessage = String(localized: "Choose a workspace.")
            return false
        }
        guard !trimmedTitle.isEmpty || !trimmedBody.isEmpty else {
            errorMessage = String(localized: "Enter a title or note text.")
            return false
        }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

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
            initialTitle = trimmedTitle
            initialBody = trimmedBody
            initialWorkspaceID = workspaceID
            return true
        } catch {
            errorMessage = String(localized: "The note couldn’t be saved.")
            return false
        }
    }

    private func loadContent() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            workspaces = try repository.fetchWorkspaces()

            switch mode {
            case let .create(preselectedWorkspaceID):
                let selectedID = preselectedWorkspaceID ?? workspaces.first?.id
                selectedWorkspaceID = selectedID
                initialWorkspaceID = selectedID
            case let .edit(noteID):
                let note = try repository.fetchTextNote(id: noteID)
                title = note.title
                body = note.body
                selectedWorkspaceID = note.workspaceID
                initialTitle = note.title
                initialBody = note.body
                initialWorkspaceID = note.workspaceID
            }
        } catch {
            errorMessage = String(localized: "The note editor couldn’t be loaded.")
        }
    }

    private var trimmedTitle: String {
        title.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var trimmedBody: String {
        body.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}

/// Owns read/delete state for a text note detail screen.
///
/// Ownership:
/// Created by `AppComposition` for the current note route and cached only as a bounded runtime
/// convenience. SwiftData remains the source of truth.
///
/// Side effects:
/// Delete mutates local SwiftData through the repository; callers own navigation dismissal.
@Observable
@MainActor
final class TextNoteDetailViewModel {
    private let repository: FieldbookRepository
    let noteID: UUID

    private(set) var detail: TextNoteDetailState?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, noteID: UUID) {
        self.repository = repository
        self.noteID = noteID
    }

    func appeared() {
        reloadRequested()
    }

    func reloadRequested() {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            detail = try repository.fetchTextNote(id: noteID)
        } catch {
            errorMessage = String(localized: "This note couldn’t be loaded.")
        }
    }

    func deleteConfirmed() -> Bool {
        errorMessage = nil
        do {
            try repository.deleteTextNote(id: noteID)
            return true
        } catch {
            errorMessage = String(localized: "The note couldn’t be deleted.")
            return false
        }
    }
}
