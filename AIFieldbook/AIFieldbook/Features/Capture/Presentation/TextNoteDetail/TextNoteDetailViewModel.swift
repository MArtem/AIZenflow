import Foundation
import Observation

/// Owns detail state and destructive deletion for one text note.
///
/// SwiftData remains the source of truth; this composition-created model is cached only as
/// bounded runtime UI state for the current route.
@Observable
@MainActor
final class TextNoteDetailViewModel {
    private let repository: FieldbookRepository
    private let stateBuilder: TextNoteDetailViewStateBuilder
    let noteID: UUID

    private(set) var state: TextNoteDetailViewState

    init(
        repository: FieldbookRepository,
        noteID: UUID,
        stateBuilder: TextNoteDetailViewStateBuilder = TextNoteDetailViewStateBuilder()
    ) {
        self.repository = repository
        self.noteID = noteID
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
            state = stateBuilder.loaded(detail: try repository.fetchTextNote(id: noteID))
        } catch {
            applyLoadFailure(previousContent: previousContent)
        }
    }

    func actionFailureDismissed() {
        reloadRequested()
    }

    func deleteConfirmed() -> Bool {
        do {
            try repository.deleteTextNote(id: noteID)
            return true
        } catch {
            applyActionFailure(String(localized: "The note couldn’t be deleted."))
            return false
        }
    }

    private func applyLoadFailure(previousContent: TextNoteDetailContentState?) {
        let message = String(localized: "This note couldn’t be loaded.")
        if let previousContent {
            state = stateBuilder.actionFailure(content: previousContent, message: message)
        } else {
            state = stateBuilder.unavailable(message: message)
        }
    }

    private func applyActionFailure(_ message: String) {
        guard let content = state.content else {
            state = stateBuilder.unavailable(message: message)
            return
        }
        state = stateBuilder.actionFailure(content: content, message: message)
    }
}
