import Foundation

/// Render-ready state for one item's tag-management sheet.
enum TagManagerViewState: Equatable {
    case loading
    case content(TagManagerFormState)
    case empty(TagManagerFormState)
    case mutating(TagManagerFormState)
    case failure(form: TagManagerFormState, message: String)

    var form: TagManagerFormState {
        switch self {
        case .loading:
            .empty
        case let .content(form), let .empty(form), let .mutating(form), let .failure(form, _):
            form
        }
    }

    var isLoading: Bool {
        guard case .loading = self else { return false }
        return true
    }

    var isMutating: Bool {
        guard case .mutating = self else { return false }
        return true
    }
}

struct TagManagerFormState: Equatable {
    static let empty = TagManagerFormState(newTagName: "", rows: [], canCreateTag: false)

    let newTagName: String
    let rows: [TagManagerTagRowState]
    let canCreateTag: Bool
}

struct TagManagerTagRowState: Identifiable, Equatable {
    let id: UUID
    let title: String
    let isAssigned: Bool
}
