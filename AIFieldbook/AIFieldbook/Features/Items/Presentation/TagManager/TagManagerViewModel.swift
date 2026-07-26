import Foundation
import Observation

/// Owns tag creation and assignment state for one locally stored item.
///
/// A mutation always reloads tags and assignments from the repository before rendering content,
/// so the ViewState remains a detached immutable snapshot.
@Observable
@MainActor
final class TagManagerViewModel {
    private let repository: FieldbookRepository
    private let stateBuilder: TagManagerViewStateBuilder
    let itemID: UUID

    private var newTagName = ""
    private var tags: [TagSummary] = []
    private var assignedTagIDs: Set<UUID> = []

    private(set) var state: TagManagerViewState

    init(
        repository: FieldbookRepository,
        itemID: UUID,
        stateBuilder: TagManagerViewStateBuilder = TagManagerViewStateBuilder()
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

    func newTagNameChanged(_ name: String) {
        newTagName = name
        state = displayState()
    }

    func createTagTapped() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        state = stateBuilder.mutating(form: formState())
        do {
            let tagID = try repository.createTag(name: trimmedName)
            try repository.setTagAssignment(itemID: itemID, tagID: tagID, isAssigned: true)
            newTagName = ""
            try reloadContent()
            state = displayState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The tag couldn’t be created.")
            )
        }
    }

    func assignmentChanged(tagID: UUID, isAssigned: Bool) {
        state = stateBuilder.mutating(form: formState())
        do {
            try repository.setTagAssignment(itemID: itemID, tagID: tagID, isAssigned: isAssigned)
            try reloadContent()
            state = displayState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The tag assignment couldn’t be changed.")
            )
        }
    }

    private func reloadRequested() {
        state = stateBuilder.loading()
        do {
            try reloadContent()
            state = displayState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Tags couldn’t be loaded.")
            )
        }
    }

    private func reloadContent() throws {
        tags = try repository.fetchTags()
        assignedTagIDs = try repository.itemTagIDs(itemID: itemID)
    }

    private func displayState() -> TagManagerViewState {
        let form = formState()
        return form.rows.isEmpty
            ? stateBuilder.empty(form: form)
            : stateBuilder.content(form: form)
    }

    private func formState() -> TagManagerFormState {
        stateBuilder.form(
            newTagName: newTagName,
            tags: tags,
            assignedTagIDs: assignedTagIDs
        )
    }
}
