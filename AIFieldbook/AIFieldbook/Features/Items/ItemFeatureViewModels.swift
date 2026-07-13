import Foundation
import Observation

@Observable
@MainActor
final class TagManagerViewModel {
    private let repository: FieldbookRepository
    let itemID: UUID

    var newTagName = ""
    private(set) var tags: [TagSummary] = []
    private(set) var assignedTagIDs: Set<UUID> = []
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, itemID: UUID) {
        self.repository = repository
        self.itemID = itemID
    }

    var canCreateTag: Bool {
        !newTagName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func appeared() {
        reload()
    }

    func createTagTapped() {
        let trimmedName = newTagName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedName.isEmpty else { return }

        do {
            let tagID = try repository.createTag(name: trimmedName)
            try repository.setTagAssignment(itemID: itemID, tagID: tagID, isAssigned: true)
            newTagName = ""
            reload()
        } catch {
            errorMessage = String(localized: "The tag couldn’t be created.")
        }
    }

    func assignmentChanged(tagID: UUID, isAssigned: Bool) {
        do {
            try repository.setTagAssignment(itemID: itemID, tagID: tagID, isAssigned: isAssigned)
            reload()
        } catch {
            errorMessage = String(localized: "The tag assignment couldn’t be changed.")
        }
    }

    private func reload() {
        errorMessage = nil
        do {
            tags = try repository.fetchTags()
            assignedTagIDs = try repository.itemTagIDs(itemID: itemID)
        } catch {
            errorMessage = String(localized: "Tags couldn’t be loaded.")
        }
    }
}

/// Owns Search tab filter state and local result presentation.
///
/// Ownership:
/// Created by `AppComposition` and shared by the Search tab for the app scene lifetime.
///
/// Concurrency:
/// The model owns a cancellable debounced search task. Filter lists are loaded from the
/// main-scene repository, while potentially growing result queries run through the background
/// `FieldbookSearchIndex` model actor and return Sendable snapshots.
@Observable
@MainActor
final class SearchViewModel {
    private let repository: FieldbookRepository
    private let searchIndex: FieldbookSearchIndex
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    var query = ""
    var selectedWorkspaceID: UUID?
    var selectedKind: KnowledgeItemKind?
    var selectedTagID: UUID?
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var tags: [TagSummary] = []
    private(set) var results: [KnowledgeItemSummary] = []
    private(set) var hasSearched = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, searchIndex: FieldbookSearchIndex) {
        self.repository = repository
        self.searchIndex = searchIndex
    }

    var hasActiveCriteria: Bool {
        currentCriteria.hasActiveCriteria
    }

    func appeared() {
        do {
            workspaces = try repository.fetchWorkspaces()
            tags = try repository.fetchTags()
        } catch {
            errorMessage = String(localized: "Search filters couldn’t be loaded.")
        }
        scheduleSearchCriteriaChange()
    }

    func searchCriteriaChanged() {
        scheduleSearchCriteriaChange()
    }

    func disappeared() {
        searchTask?.cancel()
        searchTask = nil
    }

    func scheduleSearchCriteriaChange() {
        errorMessage = nil
        let criteria = currentCriteria
        guard criteria.hasActiveCriteria else {
            searchTask?.cancel()
            searchTask = nil
            results = []
            hasSearched = false
            return
        }

        searchTask?.cancel()
        searchTask = Task { [weak self, searchIndex, criteria] in
            do {
                try await Task.sleep(for: .milliseconds(250))
                let foundResults = try await searchIndex.search(criteria: criteria)
                guard !Task.isCancelled else { return }
                self?.applySearchResults(foundResults, for: criteria)
            } catch is CancellationError {
                return
            } catch {
                self?.applySearchFailure(for: criteria)
            }
        }
    }

    func clearTapped() {
        searchTask?.cancel()
        searchTask = nil
        query = ""
        selectedWorkspaceID = nil
        selectedKind = nil
        selectedTagID = nil
        results = []
        hasSearched = false
        errorMessage = nil
    }

    private var currentCriteria: FieldbookSearchCriteria {
        FieldbookSearchCriteria(
            query: query,
            workspaceID: selectedWorkspaceID,
            kind: selectedKind,
            tagID: selectedTagID
        )
    }

    private func applySearchResults(_ newResults: [KnowledgeItemSummary], for criteria: FieldbookSearchCriteria) {
        guard currentCriteria == criteria else { return }
        results = newResults
        hasSearched = true
        errorMessage = nil
    }

    private func applySearchFailure(for criteria: FieldbookSearchCriteria) {
        guard currentCriteria == criteria else { return }
        results = []
        hasSearched = true
        errorMessage = String(localized: "Local search couldn’t be completed.")
    }
}

@Observable
@MainActor
final class ImportItemViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    let kind: ImportKind

    var selectedWorkspaceID: UUID?
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var isImporting = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, fileStore: AppFileStore, kind: ImportKind) {
        self.repository = repository
        self.fileStore = fileStore
        self.kind = kind
    }

    var canChooseFile: Bool {
        selectedWorkspaceID != nil && !isImporting
    }

    func appeared() {
        do {
            workspaces = try repository.fetchWorkspaces()
            if selectedWorkspaceID == nil {
                selectedWorkspaceID = workspaces.first?.id
            }
        } catch {
            errorMessage = String(localized: "Workspaces couldn’t be loaded.")
        }
    }

    func fileSelected(_ url: URL) async -> Bool {
        guard let workspaceID = selectedWorkspaceID else {
            errorMessage = String(localized: "Choose a workspace.")
            return false
        }

        isImporting = true
        errorMessage = nil
        defer { isImporting = false }

        do {
            let metadata = try await fileStore.importFile(at: url, kind: kind)
            do {
                try repository.createImportedItem(
                    workspaceID: workspaceID,
                    kind: kind.knowledgeItemKind,
                    metadata: metadata
                )
                return true
            } catch {
                try? await fileStore.remove(metadata.reference)
                throw error
            }
        } catch let error as LocalizedError {
            errorMessage = error.errorDescription ?? String(localized: "The file couldn’t be imported.")
            return false
        } catch {
            errorMessage = String(localized: "The file couldn’t be imported.")
            return false
        }
    }
}

@Observable
@MainActor
final class ImportedItemDetailViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    let itemID: UUID
    let playbackModel = AudioPlaybackModel()

    private(set) var detail: ImportedItemDetailState?
    private(set) var fileURL: URL?
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, fileStore: AppFileStore, itemID: UUID) {
        self.repository = repository
        self.fileStore = fileStore
        self.itemID = itemID
    }

    func appeared() async {
        await reloadRequested()
    }

    func reloadRequested() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let loadedDetail = try repository.fetchImportedItem(id: itemID)
            let resolvedURL = try await fileStore.resolvedURL(for: loadedDetail.reference)
            detail = loadedDetail
            fileURL = resolvedURL
        } catch let error as LocalizedError {
            detail = nil
            fileURL = nil
            errorMessage = error.errorDescription ?? String(localized: "This item couldn’t be loaded.")
        } catch {
            detail = nil
            fileURL = nil
            errorMessage = String(localized: "This item couldn’t be loaded.")
        }
    }

    func deleteConfirmed() async -> Bool {
        errorMessage = nil
        var staged: [StagedDeletion] = []

        do {
            let references = try repository.itemFileReferences(id: itemID)
            staged = try await fileStore.stageDeletion(references)
            do {
                try repository.deleteItem(id: itemID)
            } catch {
                try? await fileStore.rollbackDeletion(staged)
            }
            await fileStore.commitDeletion(staged)
            return true
        } catch {
            errorMessage = String(localized: "The item couldn’t be deleted completely.")
            return false
        }
    }
}

@Observable
@MainActor
final class MoveItemViewModel {
    private let repository: FieldbookRepository
    let itemID: UUID
    var selectedWorkspaceID: UUID?
    private(set) var workspaces: [WorkspaceSummary] = []
    private(set) var errorMessage: String?

    init(repository: FieldbookRepository, itemID: UUID) {
        self.repository = repository
        self.itemID = itemID
    }

    func appeared() {
        do {
            workspaces = try repository.fetchWorkspaces()
            selectedWorkspaceID = selectedWorkspaceID ?? workspaces.first?.id
        } catch { errorMessage = String(localized: "Workspaces couldn’t be loaded.") }
    }

    func moveTapped() -> Bool {
        guard let selectedWorkspaceID else { return false }
        do { try repository.moveItem(id: itemID, to: selectedWorkspaceID); return true }
        catch { errorMessage = String(localized: "The item couldn’t be moved."); return false }
    }
}
