import Foundation
import Observation

/// Owns loading, image text recognition, and deletion for one imported-item detail route.
///
/// `AudioPlaybackModel` deliberately remains a separate resource owner. It is created once for
/// this composition-owned route model and never becomes passive render state.
@Observable
@MainActor
final class ImportedItemDetailViewModel {
    private let repository: FieldbookRepository
    private let fileStore: AppFileStore
    private let textRecognitionService: VisionTextRecognitionService
    private let stateBuilder: ImportedItemDetailViewStateBuilder
    let itemID: UUID
    let playbackModel = AudioPlaybackModel()

    private(set) var state: ImportedItemDetailViewState
    @ObservationIgnored private var recognitionTask: Task<Void, Never>?
    @ObservationIgnored private var recognitionTaskID: UUID?
    @ObservationIgnored private var loadedDetail: ImportedItemDetailState?
    @ObservationIgnored private var loadedFileURL: URL?

    init(
        repository: FieldbookRepository,
        fileStore: AppFileStore,
        textRecognitionService: VisionTextRecognitionService,
        itemID: UUID,
        stateBuilder: ImportedItemDetailViewStateBuilder = ImportedItemDetailViewStateBuilder()
    ) {
        self.repository = repository
        self.fileStore = fileStore
        self.textRecognitionService = textRecognitionService
        self.itemID = itemID
        self.stateBuilder = stateBuilder
        self.state = stateBuilder.loading()
    }

    func appeared() async {
        await reloadRequested()
    }

    func reloadRequested() async {
        let previousContent = state.content
        if previousContent == nil {
            state = stateBuilder.loading()
        }

        do {
            let detail = try repository.fetchImportedItem(id: itemID)
            let fileURL = try await fileStore.resolvedURL(for: detail.reference)
            loadedDetail = detail
            loadedFileURL = fileURL
            state = stateBuilder.loaded(detail: detail, fileURL: fileURL)
        } catch let error as LocalizedError {
            applyLoadFailure(
                previousContent: previousContent,
                message: error.errorDescription ?? String(localized: "This item couldn’t be loaded.")
            )
        } catch {
            applyLoadFailure(
                previousContent: previousContent,
                message: String(localized: "This item couldn’t be loaded.")
            )
        }
    }

    func actionFailureDismissed() async {
        await reloadRequested()
    }

    /// Starts one user-requested local OCR pass for the currently loaded image.
    func recognizeTextRequested() {
        guard let detail = loadedDetail,
              let fileURL = loadedFileURL,
              detail.kind == .image,
              let content = state.content else {
            return
        }

        recognitionTask?.cancel()
        let taskID = UUID()
        recognitionTaskID = taskID
        state = stateBuilder.recognizingText(content: content)
        recognitionTask = Task { [weak self] in
            await self?.performTextRecognition(
                taskID: taskID,
                detail: detail,
                fileURL: fileURL
            )
        }
    }

    func textRecognitionCancellationRequested() {
        recognitionTaskID = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        if let content = state.content {
            state = stateBuilder.recognitionStopped(content: content)
        }
    }

    /// Cancels transient OCR work when the route leaves the visible hierarchy.
    func disappeared() {
        recognitionTaskID = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }

    func deleteConfirmed() async -> Bool {
        var staged = StagedDeletionBatch.empty

        do {
            let references = try repository.itemFileReferences(id: itemID)
            staged = try await fileStore.stageDeletion(references)
            do {
                try repository.deleteItem(id: itemID)
            } catch {
                do {
                    try await fileStore.rollbackDeletion(staged)
                } catch {
                    throw AppFileStoreError.deletionRecoveryConflict
                }
                throw error
            }
            try await fileStore.commitDeletion(staged)
            return true
        } catch {
            applyActionFailure(String(localized: "The item couldn’t be deleted completely."))
            return false
        }
    }

    private func applyLoadFailure(
        previousContent: ImportedItemDetailContentState?,
        message: String
    ) {
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

    private func performTextRecognition(
        taskID: UUID,
        detail: ImportedItemDetailState,
        fileURL: URL
    ) async {
        do {
            let result = try await textRecognitionService.recognizeText(
                in: fileURL,
                sourceItemID: detail.id,
                sourceAttachmentID: detail.attachmentID,
                inputRevision: detail.reference.relativePath
            )
            try Task.checkCancellation()
            guard recognitionTaskID == taskID else { return }

            try repository.replaceRecognizedImageText(itemID: detail.id, result: result)
            let refreshedDetail = try repository.fetchImportedItem(id: detail.id)
            loadedDetail = refreshedDetail
            state = stateBuilder.loaded(detail: refreshedDetail, fileURL: fileURL)
            finishRecognitionTask(id: taskID)
        } catch is CancellationError {
            guard recognitionTaskID == taskID else { return }
            if let content = state.content {
                state = stateBuilder.recognitionStopped(content: content)
            }
            finishRecognitionTask(id: taskID)
        } catch {
            guard recognitionTaskID == taskID else { return }
            applyActionFailure(String(localized: "Text recognition couldn’t be completed."))
            finishRecognitionTask(id: taskID)
        }
    }

    private func finishRecognitionTask(id: UUID) {
        guard recognitionTaskID == id else { return }
        recognitionTaskID = nil
        recognitionTask = nil
    }
}
