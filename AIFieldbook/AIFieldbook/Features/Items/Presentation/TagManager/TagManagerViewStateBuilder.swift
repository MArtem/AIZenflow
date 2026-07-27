import Foundation

/// Pure mapper for tag-manager form values and immutable assignment rows.
struct TagManagerViewStateBuilder {
    func loading() -> TagManagerViewState {
        .loading
    }

    func content(form: TagManagerFormState) -> TagManagerViewState {
        .content(form)
    }

    func empty(form: TagManagerFormState) -> TagManagerViewState {
        .empty(form)
    }

    func mutating(form: TagManagerFormState) -> TagManagerViewState {
        .mutating(form)
    }

    func failure(form: TagManagerFormState, message: String) -> TagManagerViewState {
        .failure(form: form, message: message)
    }

    func form(
        newTagName: String,
        tags: [TagSummary],
        assignedTagIDs: Set<UUID>
    ) -> TagManagerFormState {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        return TagManagerFormState(
            newTagName: newTagName,
            rows: tags.map {
                TagManagerTagRowState(
                    id: $0.id,
                    title: $0.name,
                    isAssigned: assignedTagIDs.contains($0.id)
                )
            },
            canCreateTag: !trimmedName.isEmpty
        )
    }
}
