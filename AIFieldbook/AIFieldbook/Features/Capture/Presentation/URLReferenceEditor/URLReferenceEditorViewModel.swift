import Foundation
import Observation

/// Owns create/edit web-link form state, validation, and local persistence.
///
/// Only normalized `http` and `https` URLs with a host are stored. Credentials and URLs longer
/// than 2,048 UTF-8 bytes are rejected before any repository mutation.
@MainActor
@Observable
final class URLReferenceEditorViewModel {
    enum Mode {
        case create
        case edit(UUID)
    }

    private let repository: FieldbookRepository
    private let mode: Mode
    private let stateBuilder: URLReferenceEditorViewStateBuilder
    private var selectedWorkspaceID: UUID?
    private var title = ""
    private var urlText = ""
    private var notes = ""
    private var workspaces: [WorkspaceSummary] = []

    private(set) var state: URLReferenceEditorViewState

    init(
        repository: FieldbookRepository,
        mode: Mode,
        stateBuilder: URLReferenceEditorViewStateBuilder = URLReferenceEditorViewStateBuilder()
    ) {
        self.repository = repository
        self.mode = mode
        self.stateBuilder = stateBuilder
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
            case .create:
                selectedWorkspaceID = workspaces.first?.id
            case let .edit(id):
                let detail = try repository.fetchURLReference(id: id)
                selectedWorkspaceID = detail.workspaceID
                title = detail.title
                urlText = detail.url.absoluteString
                notes = detail.notes
            }
            state = editingState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The web link editor couldn’t be loaded.")
            )
        }
    }

    func workspaceSelectionChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        state = editingState()
    }

    func titleChanged(_ title: String) {
        self.title = title
        state = editingState()
    }

    func urlTextChanged(_ urlText: String) {
        self.urlText = urlText
        state = editingState()
    }

    func notesChanged(_ notes: String) {
        self.notes = notes
        state = editingState()
    }

    func saveTapped() -> Bool {
        guard let workspaceID = selectedWorkspaceID, let url = normalizedURL else {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Enter a complete http or https address.")
            )
            return false
        }
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Enter a title.")
            )
            return false
        }

        state = stateBuilder.saving(form: formState())
        do {
            switch mode {
            case .create:
                try repository.createURLReference(
                    workspaceID: workspaceID,
                    title: cleanTitle,
                    url: url,
                    notes: notes
                )
            case let .edit(id):
                try repository.updateURLReference(
                    id: id,
                    workspaceID: workspaceID,
                    title: cleanTitle,
                    url: url,
                    notes: notes
                )
            }
            title = cleanTitle
            urlText = url.absoluteString
            state = editingState()
            return true
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The web link couldn’t be saved.")
            )
            return false
        }
    }

    private func editingState() -> URLReferenceEditorViewState {
        stateBuilder.editing(form: formState())
    }

    private func formState() -> URLReferenceEditorFormState {
        stateBuilder.form(
            mode: mode,
            selectedWorkspaceID: selectedWorkspaceID,
            title: title,
            urlText: urlText,
            notes: notes,
            workspaces: workspaces,
            normalizedURL: normalizedURL
        )
    }

    private var normalizedURL: URL? {
        let trimmed = urlText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.utf8.count <= 2_048,
              var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              scheme == "http" || scheme == "https",
              components.host?.isEmpty == false,
              components.user == nil,
              components.password == nil else { return nil }
        components.scheme = scheme
        return components.url
    }
}
