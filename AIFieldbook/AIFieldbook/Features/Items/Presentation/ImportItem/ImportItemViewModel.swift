import Foundation
import Observation

/// Owns import destination selection and the validated copy/create/rollback transaction.
///
/// `AppFileStore` validates and copies an untrusted provider file into app-owned storage first.
/// If SwiftData persistence then fails, the copied file is removed to prevent an orphaned file.
@Observable
@MainActor
final class ImportItemViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private let stateBuilder: ImportItemViewStateBuilder
    let kind: ImportKind

    private var selectedWorkspaceID: UUID?
    private var workspaces: [WorkspaceSummary] = []

    private(set) var state: ImportItemViewState

    init(
        repository: FieldbookRepository,
        fileStore: AppFileStore,
        kind: ImportKind,
        stateBuilder: ImportItemViewStateBuilder = ImportItemViewStateBuilder()
    ) {
        self.repository = repository
        self.fileStore = fileStore
        self.kind = kind
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading(kind: kind)
    }

    func appeared() {
        guard state.isLoading else { return }
        reloadRequested()
    }

    func retryTapped() {
        reloadRequested()
    }

    func destinationChanged(_ workspaceID: UUID?) {
        selectedWorkspaceID = workspaceID
        state = displayState()
    }

    func fileSelected(_ url: URL) async -> Bool {
        guard let workspaceID = selectedWorkspaceID else {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Choose a workspace.")
            )
            return false
        }

        state = stateBuilder.importing(form: formState())
        do {
            let metadata = try await fileStore.importFile(at: url, kind: kind)
            do {
                try repository.createImportedItem(
                    workspaceID: workspaceID,
                    kind: kind.knowledgeItemKind,
                    metadata: metadata
                )
                state = displayState()
                return true
            } catch {
                try? await fileStore.remove(metadata.reference)
                throw error
            }
        } catch let error as LocalizedError {
            state = stateBuilder.failure(
                form: formState(),
                message: error.errorDescription ?? String(localized: "The file couldn’t be imported.")
            )
            return false
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "The file couldn’t be imported.")
            )
            return false
        }
    }

    private func reloadRequested() {
        state = stateBuilder.loading(kind: kind)
        do {
            workspaces = try repository.fetchWorkspaces()
            if selectedWorkspaceID == nil {
                selectedWorkspaceID = workspaces.first?.id
            }
            state = displayState()
        } catch {
            state = stateBuilder.failure(
                form: formState(),
                message: String(localized: "Workspaces couldn’t be loaded.")
            )
        }
    }

    private func displayState() -> ImportItemViewState {
        let form = formState()
        return form.workspaces.isEmpty
            ? stateBuilder.empty(form: form)
            : stateBuilder.ready(form: form)
    }

    private func formState() -> ImportItemFormState {
        stateBuilder.form(kind: kind, selectedWorkspaceID: selectedWorkspaceID, workspaces: workspaces)
    }
}
