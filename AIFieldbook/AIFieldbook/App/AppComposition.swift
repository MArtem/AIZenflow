import Foundation
import SwiftData
import Observation

/// Composition root for app-owned services and observable feature state.
@MainActor
@Observable
final class AppComposition {
    let coordinator = AppCoordinator()
    let fileStore = AppFileStore()
    let spotlight = SpotlightIndexService()
    let repository: FieldbookRepository

    let workspaceListModel: WorkspaceListViewModel
    let captureWorkspaceModel: WorkspaceListViewModel
    let searchModel: SearchViewModel
    let settingsModel: SettingsViewModel

    private var workspaceDetails: [UUID: WorkspaceDetailViewModel] = [:]
    private var textDetails: [UUID: TextNoteDetailViewModel] = [:]
    private var importedDetails: [UUID: ImportedItemDetailViewModel] = [:]
    private var urlDetails: [UUID: URLReferenceDetailViewModel] = [:]

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
        workspaceListModel = WorkspaceListViewModel(repository: repository)
        captureWorkspaceModel = WorkspaceListViewModel(repository: repository)
        searchModel = SearchViewModel(repository: repository)
        settingsModel = SettingsViewModel(repository: repository, fileStore: fileStore)
    }

    func workspaceDetailModel(id: UUID) -> WorkspaceDetailViewModel {
        if let model = workspaceDetails[id] { return model }
        let model = WorkspaceDetailViewModel(repository: repository, fileStore: fileStore, workspaceID: id)
        workspaceDetails[id] = model
        return model
    }

    func textDetailModel(id: UUID) -> TextNoteDetailViewModel {
        if let model = textDetails[id] { return model }
        let model = TextNoteDetailViewModel(repository: repository, noteID: id)
        textDetails[id] = model
        return model
    }

    func importedDetailModel(id: UUID) -> ImportedItemDetailViewModel {
        if let model = importedDetails[id] { return model }
        let model = ImportedItemDetailViewModel(repository: repository, fileStore: fileStore, itemID: id)
        importedDetails[id] = model
        return model
    }

    func urlDetailModel(id: UUID) -> URLReferenceDetailViewModel {
        if let model = urlDetails[id] { return model }
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
        coordinator.dismissPresentation()
        workspaceEditorModel = nil
        textEditorModel = nil
        tagManagerModel = nil
        importItemModel = nil
        urlEditorModel = nil
        audioRecorderModel = nil
        moveItemModel = nil
        reloadVisibleContent()
    }

    func reloadVisibleContent() {
        workspaceListModel.reloadRequested()
        captureWorkspaceModel.reloadRequested()
        searchModel.appeared()
        workspaceDetails.values.forEach { $0.reloadRequested() }
        textDetails.values.forEach { $0.reloadRequested() }
        for model in importedDetails.values {
            Task { await model.reloadRequested() }
        }
        urlDetails.values.forEach { $0.reloadRequested() }
        Task { await spotlight.rebuild(repository: repository) }
    }

    func started() async {
        await fileStore.cleanupAbandonedStaging()
        await spotlight.rebuild(repository: repository)
    }

    func handleOpenURL(_ url: URL) {
        guard let destination = DeepLinkParser.destination(for: url) else { return }
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
        }
    }
}
