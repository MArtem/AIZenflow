import Foundation
import Observation

/// Owns read and destructive-delete state for one locally stored web link.
///
/// SwiftData remains the source of truth. Opening or sharing a URL stays in the view layer so
/// external navigation occurs only from an explicit user action.
@MainActor
@Observable
final class URLReferenceDetailViewModel {
    private let repository: FieldbookRepository
    private let stateBuilder: URLReferenceDetailViewStateBuilder
    let itemID: UUID

    private(set) var state: URLReferenceDetailViewState

    init(
        repository: FieldbookRepository,
        itemID: UUID,
        stateBuilder: URLReferenceDetailViewStateBuilder = URLReferenceDetailViewStateBuilder()
    ) {
        self.repository = repository
        self.itemID = itemID
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
            state = stateBuilder.loaded(detail: try repository.fetchURLReference(id: itemID))
        } catch {
            applyLoadFailure(previousContent: previousContent)
        }
    }

    func actionFailureDismissed() {
        reloadRequested()
    }

    func deleteConfirmed() -> Bool {
        do {
            try repository.deleteItem(id: itemID)
            return true
        } catch {
            applyActionFailure(String(localized: "The web link couldn’t be deleted."))
            return false
        }
    }

    private func applyLoadFailure(previousContent: URLReferenceDetailContentState?) {
        let message = String(localized: "This web link couldn’t be loaded.")
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
