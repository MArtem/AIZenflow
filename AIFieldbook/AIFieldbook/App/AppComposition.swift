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
    let coordinator = AppCoordinator()
    let fileStore = AppFileStore()
    let spotlight = SpotlightIndexService()
    let searchIndex: FieldbookSearchIndex
    let exportService: FieldbookExportService
    let repository: FieldbookRepository

    let workspaceListModel: WorkspaceListViewModel
    let captureWorkspaceModel: WorkspaceListViewModel
    let searchModel: SearchViewModel
    let settingsModel: SettingsViewModel
    private(set) var alertTitle: String?
    private(set) var alertMessage: String?

    private var workspaceDetails = DetailModelCache<WorkspaceDetailViewModel>(limit: 24)
    private var textDetails = DetailModelCache<TextNoteDetailViewModel>(limit: 24)
    private var importedDetails = DetailModelCache<ImportedItemDetailViewModel>(limit: 24)
    private var urlDetails = DetailModelCache<URLReferenceDetailViewModel>(limit: 24)
    @ObservationIgnored private var postMutationMaintenanceTask: Task<Void, Never>?
    @ObservationIgnored private var importedDetailReloadTasks: [UUID: Task<Void, Never>] = [:]
    @ObservationIgnored private var activePresentation: AppPresentation?

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
        self.exportService = FieldbookExportService(modelContainer: container)
        workspaceListModel = WorkspaceListViewModel(repository: repository)
        captureWorkspaceModel = WorkspaceListViewModel(repository: repository)
        searchModel = SearchViewModel(repository: repository, searchIndex: searchIndex)
        settingsModel = SettingsViewModel(
            repository: repository,
            exportService: exportService,
            fileStore: fileStore,
            spotlight: spotlight
        )
    }

    func workspaceDetailModel(id: UUID) -> WorkspaceDetailViewModel {
        if let model = workspaceDetails.value(for: id) { return model }
        let model = WorkspaceDetailViewModel(repository: repository, fileStore: fileStore, workspaceID: id)
        _ = workspaceDetails.insert(model, for: id)
        return model
    }

    func textDetailModel(id: UUID) -> TextNoteDetailViewModel {
        if let model = textDetails.value(for: id) { return model }
        let model = TextNoteDetailViewModel(repository: repository, noteID: id)
        _ = textDetails.insert(model, for: id)
        return model
    }

    func importedDetailModel(id: UUID) -> ImportedItemDetailViewModel {
        if let model = importedDetails.value(for: id) { return model }
        let model = ImportedItemDetailViewModel(repository: repository, fileStore: fileStore, itemID: id)
        importedDetails.insert(model, for: id)?.playbackModel.releaseResources()
        return model
    }

    func urlDetailModel(id: UUID) -> URLReferenceDetailViewModel {
        if let model = urlDetails.value(for: id) { return model }
        let model = URLReferenceDetailViewModel(repository: repository, itemID: id)
        _ = urlDetails.insert(model, for: id)
        return model
    }

    func presentCreateWorkspace() {
        workspaceEditorModel = WorkspaceEditorViewModel(repository: repository, mode: .create)
        present(.createWorkspace)
    }

    func presentRenameWorkspace(id: UUID, name: String) {
        workspaceEditorModel = WorkspaceEditorViewModel(
            repository: repository,
            mode: .rename(id: id, currentName: name)
        )
        present(.renameWorkspace(id))
    }

    func presentCreateTextNote(workspaceID: UUID?) {
        textEditorModel = TextNoteEditorViewModel(
            repository: repository,
            mode: .create(preselectedWorkspaceID: workspaceID)
        )
        present(.createTextNote(workspaceID))
    }

    func presentEditTextNote(id: UUID) {
        textEditorModel = TextNoteEditorViewModel(repository: repository, mode: .edit(noteID: id))
        present(.editTextNote(id))
    }

    func presentTagManager(itemID: UUID) {
        tagManagerModel = TagManagerViewModel(repository: repository, itemID: itemID)
        present(.manageTags(itemID))
    }

    func presentImport(kind: ImportKind) {
        importItemModel = ImportItemViewModel(repository: repository, fileStore: fileStore, kind: kind)
        present(.importItem(kind))
    }

    func presentCreateURLReference() {
        urlEditorModel = URLReferenceEditorViewModel(repository: repository, mode: .create)
        present(.createURLReference)
    }

    func presentAudioRecorder() {
        audioRecorderModel = AudioRecorderViewModel(repository: repository, fileStore: fileStore)
        present(.recordAudio)
    }

    func presentMoveItem(id: UUID) {
        moveItemModel = MoveItemViewModel(repository: repository, itemID: id)
        present(.moveItem(id))
    }

    func presentEditURLReference(id: UUID) {
        urlEditorModel = URLReferenceEditorViewModel(repository: repository, mode: .edit(id))
        present(.editURLReference(id))
    }

    func presentationDismissed() {
        let dismissedPresentation = activePresentation
        activePresentation = nil
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
        do {
            try await fileStore.recoverAbandonedStaging(activeReferences: repository.allFileReferences())
        } catch {
            presentAlert(
                title: String(localized: "Local File Recovery Needed"),
                message: String(localized: "Local files need recovery before cleanup can continue.")
            )
        }
        await spotlight.rebuildIfAllowed(searchIndex: searchIndex)
    }

    func handleOpenURL(_ url: URL) {
        guard let destination = DeepLinkParser.destination(for: url) else {
            presentAlert(
                title: String(localized: "Link Unavailable"),
                message: String(localized: "This AI Fieldbook link is not supported.")
            )
            return
        }
        do {
            switch destination {
            case let .workspace(id):
                _ = try repository.fetchWorkspaceDetail(id: id)
                coordinator.openWorkspace(id: id)
            case let .item(id, suppliedKind):
                let kind = try repository.itemKind(id: id)
                guard suppliedKind == nil || suppliedKind == kind else {
                    presentAlert(
                        title: String(localized: "Link Unavailable"),
                        message: String(localized: "This AI Fieldbook link doesn’t match the saved item type.")
                    )
                    return
                }
                coordinator.openItem(id: id, kind: kind, from: .workspace)
            }
        } catch {
            coordinator.selectedTab = .workspace
            presentAlert(
                title: String(localized: "Link Unavailable"),
                message: String(localized: "The linked item is no longer available.")
            )
        }
    }

    func alertDismissed() {
        alertTitle = nil
        alertMessage = nil
    }

    /// Clears runtime-only navigation and detail state after a confirmed destructive data reset.
    ///
    /// External usage:
    /// Called only after Settings completes delete-all successfully. SwiftData and file storage
    /// are already cleared by then; this method removes stale in-memory detail models and routes
    /// so relaunch is not required to leave deleted records.
    func localDataResetCompleted() {
        importedDetails.removeAll().forEach { $0.playbackModel.releaseResources() }
        workspaceDetails.removeAll()
        textDetails.removeAll()
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

    /// Drops scene-local detail caches when iOS reports memory pressure.
    ///
    /// Views already on screen retain their current observable model until they disappear;
    /// later navigation recreates a fresh model from SwiftData. Media players are released
    /// immediately because they are the most expensive cache-owned resource.
    func memoryPressureReceived() {
        importedDetailReloadTasks.values.forEach { $0.cancel() }
        importedDetailReloadTasks.removeAll()
        importedDetails.removeAll().forEach { $0.playbackModel.releaseResources() }
        workspaceDetails.removeAll()
        textDetails.removeAll()
        urlDetails.removeAll()
    }

    private func present(_ presentation: AppPresentation) {
        activePresentation = presentation
        coordinator.present(presentation)
    }

    private func presentAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
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

/// Small scene-local least-recently-used cache for detail state owners.
///
/// SwiftData remains the source of truth. This cache only prevents repeated state-owner
/// construction during navigation and returns evicted values so resource-owning models can
/// release media before deallocation.
private struct DetailModelCache<Value> {
    private let limit: Int
    private var storage: [UUID: Value] = [:]
    private var accessOrder: [UUID] = []

    init(limit: Int) {
        self.limit = max(limit, 1)
    }

    subscript(id: UUID) -> Value? {
        storage[id]
    }

    mutating func value(for id: UUID) -> Value? {
        guard let value = storage[id] else { return nil }
        touch(id)
        return value
    }

    @discardableResult
    mutating func insert(_ value: Value, for id: UUID) -> Value? {
        if storage[id] != nil {
            storage[id] = value
            touch(id)
            return nil
        }
        var evictedValue: Value?
        if storage.count >= limit, let evictedID = accessOrder.first {
            accessOrder.removeFirst()
            evictedValue = storage.removeValue(forKey: evictedID)
        }
        storage[id] = value
        accessOrder.append(id)
        return evictedValue
    }

    @discardableResult
    mutating func removeAll() -> [Value] {
        let values = Array(storage.values)
        storage.removeAll()
        accessOrder.removeAll()
        return values
    }

    private mutating func touch(_ id: UUID) {
        accessOrder.removeAll { $0 == id }
        accessOrder.append(id)
    }
}
