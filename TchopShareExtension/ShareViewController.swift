import SwiftUI
import UIKit
import TchopShareSupport

final class ShareViewController: UIViewController {
    private let importer: NSItemProviderShareItemImporter? = try? NSItemProviderShareItemImporter(
        groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
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

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        installRootView(state: .loading)
        Task { @MainActor in
            await loadInitialState()
        }
    }

    private func installRootView(state: ShareExtensionRootView.State) {
        let rootView = ShareExtensionRootView(
            state: state,
            onClose: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
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
        guard
            let importer,
            let shareExtensionSessionContextManager,
            let sharedFeedCardSyncManager
        else {
            installRootView(
                state: .failed(
                    title: "Share unavailable",
                    message: "The share extension couldn't be prepared in this session."
                )
            )
            return
        }

        do {
            guard
                let sessionContext = try shareExtensionSessionContextManager.loadContext(),
                sessionContext.isAuthenticated
            else {
                installRootView(
                    state: .signInRequired(
                        message: "Open the app and sign in before creating cards from the share sheet."
                    )
                )
                return
            }

            let itemProviders = inputItemProviders
            let importedItems = try await importer.loadItems(from: itemProviders)
            let composerViewModel = try makeComposerViewModel(
                sessionContext: sessionContext,
                importedItems: importedItems,
                sharedFeedCardSyncManager: sharedFeedCardSyncManager
            )
            self.composerViewModel = composerViewModel
            installRootView(state: .composer(composerViewModel))
        } catch {
            let failure = failurePresentation(for: error)
            installRootView(state: .failed(title: failure.title, message: failure.message))
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
                } catch {
                    self.publishFailureMessage = "Failed to publish shared card."
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
        guard composerViewModel.publish() else {
            return
        }

        if let publishFailureMessage {
            installRootView(
                state: .failed(
                    title: "Publish failed",
                    message: publishFailureMessage
                )
            )
            return
        }

        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    private func openContainingApp() {
        guard
            let scheme = Bundle.main.object(forInfoDictionaryKey: "TchopContainingAppURLScheme") as? String,
            let url = URL(string: "\(scheme)://")
        else {
            return
        }

        extensionContext?.open(url) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
            }
        }
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
                title: "This content can't be shared here",
                message: "This app can create cards from text, images, video, audio, or PDF content."
            )
        case ShareItemImportError.unableToDecodeText:
            return ShareFailurePresentation(
                title: "Text couldn't be loaded",
                message: "The shared text wasn't readable in this share session."
            )
        case ShareItemImportError.unableToLoadFileRepresentation:
            return ShareFailurePresentation(
                title: "File couldn't be loaded",
                message: "The shared file wasn't available to the extension."
            )
        case FeedComposerImportError.unsupportedMixedMediaAttachments:
            return ShareFailurePresentation(
                title: "This selection mixes media types",
                message: "A single card can't start with mixed imported media like image and video together. Share one media type at a time."
            )
        case FeedComposerImportError.unsupportedMultipleFileAttachments:
            return ShareFailurePresentation(
                title: "This selection includes multiple files",
                message: "A single card can start with one imported video, audio file, or PDF. Share one file at a time."
            )
        case FeedComposerImportError.incompatibleWithExistingMedia:
            return ShareFailurePresentation(
                title: "This content can't be combined",
                message: "The imported content doesn't fit the current card media rules. Remove the conflicting media and try again."
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
