import SwiftUI
import UIKit

/// UIKit entry point for the share extension.
///
/// Responsibilities:
/// - imports shared item-provider content;
/// - restores app session/channel context from app-group storage;
/// - hosts the shared composer;
/// - writes published cards back to the app-group pending queue.
///
/// Ownership:
/// Created by the extension runtime for one share request.
final class ShareViewController: UIViewController {
    private static let importBudget = ShareItemImportBudget(
        maximumImageFileCount: 10,
        maximumNonImageFileCount: 1,
        maximumFileBytes: 100_000_000,
        maximumTotalFileBytes: 200_000_000,
        allowsMixedFileKinds: false
    )

    private let importer: NSItemProviderShareItemImporter? = try? NSItemProviderShareItemImporter(
        groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier,
        budget: ShareViewController.importBudget
    )
    private let shareExtensionSessionContextManager: ShareExtensionSessionContextManager? = try? ShareExtensionSessionContextManager(
        groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
    )
    private let sharedFeedCardSyncManager: SharedFeedCardSyncManager? = try? SharedFeedCardSyncManager(
        groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
    )

    private var hostingController: UIHostingController<ShareExtensionRootView>?
    private var composerViewModel: FeedComposerViewModel?
    private var publishFailureMessage: String?
    private var initialLoadTask: Task<Void, Never>?
    private var requestCancellationTask: Task<Void, Never>?
    private var importedItemsForCleanup: [ShareImportedItem] = []
    private var publishedImportedFileURLStrings: Set<String> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        installRootView(state: .loading)
        initialLoadTask = Task { @MainActor [weak self] in
            await self?.loadInitialState()
        }
    }

    deinit {
        initialLoadTask?.cancel()
    }

    private func installRootView(state: ShareExtensionRootView.State) {
        let rootView = ShareExtensionRootView(
            state: state,
            onClose: { [weak self] in
                self?.cancelShareRequest()
            },
            onOpenApp: { [weak self] in
                self?.openContainingApp()
            },
            onPublish: { [weak self] in
                self?.publishComposer()
            }
        )

        if let hostingController {
            hostingController.rootView = rootView
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        addChild(hostingController)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        hostingController.didMove(toParent: self)
        self.hostingController = hostingController
    }

    @MainActor
    private func loadInitialState() async {
        defer { initialLoadTask = nil }

        guard
            let importer,
            let shareExtensionSessionContextManager,
            let sharedFeedCardSyncManager
        else {
            guard !Task.isCancelled else { return }
            installRootView(
                state: .failed(
                    title: AppLocalization.text("share.failure.unavailable.title"),
                    message: AppLocalization.text("share.failure.unavailable.message")
                )
            )
            return
        }

        do {
            guard
                let sessionContext = try shareExtensionSessionContextManager.loadContext(),
                sessionContext.isAuthenticated
            else {
                guard !Task.isCancelled else { return }
                installRootView(
                    state: .signInRequired(
                        message: AppLocalization.text("share.signInRequired.message"),
                        openAppErrorMessage: nil
                    )
                )
                return
            }

            let itemProviders = inputItemProviders
            let importedItems = try await importer.loadItems(from: itemProviders)
            let composerViewModel: FeedComposerViewModel
            do {
                try Task.checkCancellation()
                composerViewModel = try makeComposerViewModel(
                    sessionContext: sessionContext,
                    importedItems: importedItems,
                    sharedFeedCardSyncManager: sharedFeedCardSyncManager
                )
                try Task.checkCancellation()
            } catch {
                try importer.discardImportSession()
                throw error
            }
            importedItemsForCleanup = importedItems
            self.composerViewModel = composerViewModel
            installRootView(state: .composer(composerViewModel))
        } catch is CancellationError {
            return
        } catch {
            guard !Task.isCancelled else { return }
            let failure = failurePresentation(for: error)
            installRootView(state: .failed(title: failure.title, message: failure.message))
        }
    }

    private func cancelShareRequest() {
        guard requestCancellationTask == nil else {
            return
        }
        initialLoadTask?.cancel()
        initialLoadTask = nil
        composerViewModel = nil
        requestCancellationTask = Task { @MainActor [weak self] in
            guard let self else { return }
            do {
                try await importer?.cancelAndDiscardImportSession()
                importedItemsForCleanup.removeAll()
                publishedImportedFileURLStrings.removeAll()
                extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
            } catch {
                requestCancellationTask = nil
                installRootView(
                    state: .failed(
                        title: AppLocalization.text("share.failure.unavailable.title"),
                        message: AppLocalization.text("share.failure.unavailable.message")
                    )
                )
            }
        }
    }

    private func makeComposerViewModel(
        sessionContext: ShareExtensionSessionContext,
        importedItems: [ShareImportedItem],
        sharedFeedCardSyncManager: SharedFeedCardSyncManager
    ) throws -> FeedComposerViewModel {
        let channelsStore = ChannelsStore(
            selectionStore: UserDefaultsChannelSelectionStore(
                userDefaults: UserDefaults(suiteName: AppGroupConfiguration.sharedContainerIdentifier) ?? .standard,
                keyPrefix: "share_extension_selected_channel_id"
            )
        )
        channelsStore.setAvailableChannels(sessionContext.availableChannels)
        _ = channelsStore.selectChannel(id: sessionContext.selectedChannelID)

        let selectedChannelID = channelsStore.selectionSnapshot.selectedChannelID
            ?? channelsStore.selectionSnapshot.selectedChannel?.id
            ?? AppChannel.defaultChannel.id

        let viewModel = FeedComposerViewModel(
            selectedChannelID: selectedChannelID,
            channelsStore: channelsStore,
            publishAction: { [weak self] feedCard in
                guard let self else {
                    return
                }

                do {
                    try sharedFeedCardSyncManager.publishImportedCard(feedCard)
                    self.publishedImportedFileURLStrings = Self.importedFileURLStrings(in: feedCard)
                } catch {
                    self.publishFailureMessage = AppLocalization.text("share.failure.publish.message")
                }
            }
        )
        try viewModel.applyImportedItems(importedItems)
        return viewModel
    }

    private func publishComposer() {
        guard let composerViewModel else {
            return
        }

        publishFailureMessage = nil
        publishedImportedFileURLStrings.removeAll()
        guard composerViewModel.publish() else {
            return
        }

        if let publishFailureMessage {
            installRootView(
                state: .failed(
                    title: AppLocalization.text("share.failure.publish.title"),
                    message: publishFailureMessage
                )
            )
            return
        }

        let omittedImportedItems = importedItemsForCleanup.filter { item in
            guard case let .file(file) = item else {
                return false
            }
            return !publishedImportedFileURLStrings.contains(file.fileURL.absoluteString)
        }
        let retainsImportedFile = importedItemsForCleanup.contains { item in
            guard case let .file(file) = item else {
                return false
            }
            return publishedImportedFileURLStrings.contains(file.fileURL.absoluteString)
        }
        if !retainsImportedFile {
            try? importer?.discardImportSession()
        } else {
            importer?.discardImportedFiles(in: omittedImportedItems)
        }
        importedItemsForCleanup.removeAll()
        publishedImportedFileURLStrings.removeAll()
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private static func importedFileURLStrings(in feedCard: FeedCard) -> Set<String> {
        guard let media = feedCard.mediaContent else {
            return []
        }

        switch media {
        case let .photos(items):
            return Set(items.compactMap(\.fileURLString))
        case let .file(file):
            return Set([file.fileURLString, file.teaserImage?.fileURLString].compactMap { $0 })
        }
    }

    private func openContainingApp() {
        guard
            let scheme = Bundle.main.object(forInfoDictionaryKey: "TchopContainingAppURLScheme") as? String,
            let url = URL(string: "\(scheme)://"),
            let extensionContext
        else {
            showOpenAppFailure()
            return
        }

        extensionContext.open(url) { [weak self] didOpen in
            Task { @MainActor [weak self] in
                guard let self else { return }
                guard didOpen else {
                    self.showOpenAppFailure()
                    return
                }
                self.cancelShareRequest()
            }
        }
    }

    private func showOpenAppFailure() {
        let message = AppLocalization.text("share.failure.openApp.message")
        installRootView(
            state: .signInRequired(
                message: AppLocalization.text("share.signInRequired.message"),
                openAppErrorMessage: message
            )
        )
        UIAccessibility.post(notification: .announcement, argument: message)
    }

    private var inputItemProviders: [NSItemProvider] {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return []
        }

        return inputItems.flatMap { $0.attachments ?? [] }
    }

    private func failurePresentation(for error: Error) -> ShareFailurePresentation {
        switch error {
        case ShareItemImportError.unsupportedProvider:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.unsupported.title"),
                message: AppLocalization.text("share.failure.unsupported.message")
            )
        case ShareItemImportError.unableToDecodeText:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.textLoad.title"),
                message: AppLocalization.text("share.failure.textLoad.message")
            )
        case ShareItemImportError.unableToLoadFileRepresentation:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.fileLoad.title"),
                message: AppLocalization.text("share.failure.fileLoad.message")
            )
        case ShareItemImportError.unsupportedMixedMediaAttachments:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.mixedMedia.title"),
                message: AppLocalization.text("share.failure.mixedMedia.message")
            )
        case ShareItemImportError.tooManyImageFiles, ShareItemImportError.tooManyNonImageFiles:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.selectionLimit.title"),
                message: AppLocalization.text("share.failure.selectionLimit.message")
            )
        case ShareItemImportError.fileTooLarge:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.fileTooLarge.title"),
                message: AppLocalization.text("share.failure.fileTooLarge.message")
            )
        case ShareItemImportError.totalFileSizeExceeded:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.totalTooLarge.title"),
                message: AppLocalization.text("share.failure.totalTooLarge.message")
            )
        case FeedComposerImportError.unsupportedMixedMediaAttachments:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.mixedMedia.title"),
                message: AppLocalization.text("share.failure.mixedMedia.message")
            )
        case FeedComposerImportError.unsupportedMultipleFileAttachments:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.multipleFiles.title"),
                message: AppLocalization.text("share.failure.multipleFiles.message")
            )
        case FeedComposerImportError.incompatibleWithExistingMedia:
            return ShareFailurePresentation(
                title: AppLocalization.text("share.failure.incompatible.title"),
                message: AppLocalization.text("share.failure.incompatible.message")
            )
        default:
            return ShareFailurePresentation(
                title: "Share couldn't be prepared",
                message: "The shared content couldn't be prepared for card creation."
            )
        }
    }
}

private enum ShareExtensionError: LocalizedError {
    case cancelled
}

private struct ShareFailurePresentation {
    let title: String
    let message: String
}
