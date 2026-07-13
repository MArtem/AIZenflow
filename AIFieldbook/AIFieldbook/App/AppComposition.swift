import Foundation
import SwiftData
import Observation

/// Composition root for app-owned services and observable feature state.
///
/// Ownership:
/// Created once by `AppShellView` for one app scene. It owns long-lived app services,
/// repositories, screen-level state owners, and modal state. SwiftUI views receive these
/// dependencies from here instead of constructing persistence, file, search, or navigation
/// objects themselves.
///
/// Invariants:
/// - App Intents and AI surfaces are not composed during Iteration 1.
/// - Detail models are cached only as a bounded runtime convenience; SwiftData remains the
///   source of truth.
@MainActor
@Observable
final class AppComposition {
    private let detailCacheLimit = 24

    let coordinator = AppCoordinator()
    let fileStore = AppFileStore()
    let spotlight = SpotlightIndexService()
    let searchIndex: FieldbookSearchIndex
    let repository: FieldbookRepository

    let workspaceListModel: WorkspaceListViewModel
    let captureWorkspaceModel: WorkspaceListViewModel
    let searchModel: SearchViewModel
    let settingsModel: SettingsViewModel
    var deepLinkErrorMessage: String?

    private var workspaceDetails: [UUID: WorkspaceDetailViewModel] = [:]
    private var textDetails: [UUID: TextNoteDetailViewModel] = [:]
    private var importedDetails: [UUID: ImportedItemDetailViewModel] = [:]
    private var urlDetails: [UUID: URLReferenceDetailViewModel] = [:]
    @ObservationIgnored private var postMutationMaintenanceTask: Task<Void, Never>?
    @ObservationIgnored private var importedDetailReloadTasks: [UUID: Task<Void, Never>] = [:]

    private(set) var workspaceEditorModel: WorkspaceEditorViewModel?
    private(set) var textEditorModel: TextNoteEditorViewModel?
    private(set) var tagManagerModel: TagManagerViewModel?
    private(set) var importItemModel: ImportItemViewModel?
    private(set) var urlEditorModel: URLReferenceEditorViewModel?
    private(set) var audioRecorderModel: AudioRecorderViewModel?
    private(set) var moveItemModel: MoveItemViewModel?

    init(container: ModelContainer) {
        let repository = FieldbookRepository(context: container.mainContext)
        self.repository = repository
        self.searchIndex = FieldbookSearchIndex(modelContainer: container)
        workspaceListModel = WorkspaceListViewModel(repository: repository)
        captureWorkspaceModel = WorkspaceListViewModel(repository: repository)
        searchModel = SearchViewModel(repository: repository, searchIndex: searchIndex)
        settingsModel = SettingsViewModel(repository: repository, fileStore: fileStore, spotlight: spotlight)
    }

    func workspaceDetailModel(id: UUID) -> WorkspaceDetailViewModel {
        if let model = workspaceDetails[id] { return model }
        trimDetailCacheIfNeeded(&workspaceDetails)
        let model = WorkspaceDetailViewModel(repository: repository, fileStore: fileStore, workspaceID: id)
        workspaceDetails[id] = model
        return model
    }

    func textDetailModel(id: UUID) -> TextNoteDetailViewModel {
        if let model = textDetails[id] { return model }
        trimDetailCacheIfNeeded(&textDetails)
        let model = TextNoteDetailViewModel(repository: repository, noteID: id)
        textDetails[id] = model
        return model
    }

    func importedDetailModel(id: UUID) -> ImportedItemDetailViewModel {
        if let model = importedDetails[id] { return model }
        trimDetailCacheIfNeeded(&importedDetails)
        let model = ImportedItemDetailViewModel(repository: repository, fileStore: fileStore, itemID: id)
        importedDetails[id] = model
        return model
    }

    func urlDetailModel(id: UUID) -> URLReferenceDetailViewModel {
        if let model = urlDetails[id] { return model }
        trimDetailCacheIfNeeded(&urlDetails)
        let model = URLReferenceDetailViewModel(repository: repository, itemID: id)
        urlDetails[id] = model
        return model
    }

    func presentCreateWorkspace() {
        workspaceEditorModel = WorkspaceEditorViewModel(repository: repository, mode: .create)
        coordinator.present(.createWorkspace)
    }

    func presentRenameWorkspace(id: UUID, name: String) {
        workspaceEditorModel = WorkspaceEditorViewModel(
            repository: repository,
            mode: .rename(id: id, currentName: name)
        )
        coordinator.present(.renameWorkspace(id))
    }

    func presentCreateTextNote(workspaceID: UUID?) {
        textEditorModel = TextNoteEditorViewModel(
            repository: repository,
            mode: .create(preselectedWorkspaceID: workspaceID)
        )
        coordinator.present(.createTextNote(workspaceID))
    }

    func presentEditTextNote(id: UUID) {
        textEditorModel = TextNoteEditorViewModel(repository: repository, mode: .edit(noteID: id))
        coordinator.present(.editTextNote(id))
    }

    func presentTagManager(itemID: UUID) {
        tagManagerModel = TagManagerViewModel(repository: repository, itemID: itemID)
        coordinator.present(.manageTags(itemID))
    }

    func presentImport(kind: ImportKind) {
        importItemModel = ImportItemViewModel(repository: repository, fileStore: fileStore, kind: kind)
        coordinator.present(.importItem(kind))
    }

    func presentCreateURLReference() {
        urlEditorModel = URLReferenceEditorViewModel(repository: repository, mode: .create)
        coordinator.present(.createURLReference)
    }

    func presentAudioRecorder() {
        audioRecorderModel = AudioRecorderViewModel(repository: repository, fileStore: fileStore)
        coordinator.present(.recordAudio)
    }

    func presentMoveItem(id: UUID) {
        moveItemModel = MoveItemViewModel(repository: repository, itemID: id)
        coordinator.present(.moveItem(id))
    }

    func presentEditURLReference(id: UUID) {
        urlEditorModel = URLReferenceEditorViewModel(repository: repository, mode: .edit(id))
        coordinator.present(.editURLReference(id))
    }

    func presentationDismissed() {
        let dismissedPresentation = coordinator.presentation
        coordinator.dismissPresentation()
        workspaceEditorModel = nil
        textEditorModel = nil
        tagManagerModel = nil
        importItemModel = nil
        urlEditorModel = nil
        audioRecorderModel = nil
        moveItemModel = nil
        reloadAfterPresentation(dismissedPresentation)
    }

    /// Refreshes screen models after app-owned modal mutations.
    ///
    /// External usage:
    /// Called by the sheet dismissal path after create/edit/delete/tag/move/import flows.
    ///
    /// Behavior:
    /// Uses the dismissed presentation to keep reload scope as narrow as the modal contract
    /// allows. List/search surfaces still reload because modal flows may create or remove
    /// records whose identifiers are not returned through the sheet API.
    func reloadAfterPresentation(_ presentation: AppPresentation?) {
        workspaceListModel.reloadRequested()
        captureWorkspaceModel.reloadRequested()
        searchModel.appeared()
        switch presentation {
        case let .renameWorkspace(id):
            workspaceDetails[id]?.reloadRequested()
        case let .editTextNote(id), let .manageTags(id), let .moveItem(id):
            textDetails[id]?.reloadRequested()
            reloadImportedDetailIfCached(id: id)
            urlDetails[id]?.reloadRequested()
        case let .editURLReference(id):
            urlDetails[id]?.reloadRequested()
        case .createWorkspace, .createTextNote(_), .importItem(_), .createURLReference, .recordAudio, .none:
            break
        }
        schedulePostMutationMaintenance()
    }

    func started() async {
        await fileStore.cleanupAbandonedStaging()
        await spotlight.rebuildIfAllowed(searchIndex: searchIndex)
    }

    func handleOpenURL(_ url: URL) {
        guard let destination = DeepLinkParser.destination(for: url) else {
            deepLinkErrorMessage = String(localized: "This AI Fieldbook link is not supported.")
            return
        }
        do {
            switch destination {
            case let .workspace(id):
                _ = try repository.fetchWorkspaceDetail(id: id)
                coordinator.openWorkspace(id: id)
            case let .item(id, suppliedKind):
                let kind: KnowledgeItemKind
                if let suppliedKind { kind = suppliedKind }
                else { kind = try repository.itemKind(id: id) }
                coordinator.openItem(id: id, kind: kind, from: .workspace)
            }
        } catch {
            coordinator.selectedTab = .workspace
            deepLinkErrorMessage = String(localized: "The linked item is no longer available.")
        }
    }

    func deepLinkErrorDismissed() {
        deepLinkErrorMessage = nil
    }

    /// Clears runtime-only navigation and detail state after a confirmed destructive data reset.
    ///
    /// External usage:
    /// Called only after Settings completes delete-all successfully. SwiftData and file storage
    /// are already cleared by then; this method removes stale in-memory detail models and routes
    /// so relaunch is not required to leave deleted records.
    func localDataResetCompleted() {
        workspaceDetails.removeAll()
        textDetails.removeAll()
        importedDetails.removeAll()
        urlDetails.removeAll()
        workspaceListModel.reloadRequested()
        captureWorkspaceModel.reloadRequested()
        searchModel.clearTapped()
        coordinator.selectedTab = .workspace
        coordinator.workspaceRouter.popToRoot()
        coordinator.captureRouter.popToRoot()
        coordinator.searchRouter.popToRoot()
        coordinator.settingsRouter.popToRoot()
    }

    private func trimDetailCacheIfNeeded<Model>(_ cache: inout [UUID: Model]) {
        guard cache.count >= detailCacheLimit, let firstKey = cache.keys.first else { return }
        cache[firstKey] = nil
    }

    private func reloadImportedDetailIfCached(id: UUID) {
        guard importedDetails[id] != nil else { return }
        importedDetailReloadTasks[id]?.cancel()
        importedDetailReloadTasks[id] = Task { [weak self] in
            await self?.importedDetails[id]?.reloadRequested()
            self?.importedDetailReloadFinished(id: id)
        }
    }

    private func importedDetailReloadFinished(id: UUID) {
        importedDetailReloadTasks[id] = nil
    }

    private func schedulePostMutationMaintenance() {
        postMutationMaintenanceTask?.cancel()
        postMutationMaintenanceTask = Task { [spotlight, searchIndex] in
            await spotlight.rebuildIfAllowed(searchIndex: searchIndex)
        }
    }
}
