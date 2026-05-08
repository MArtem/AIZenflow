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
    private let sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager? = try? SharedLocalFeedCardSyncManager(
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
            let sharedLocalFeedCardSyncManager
        else {
            installRootView(state: .failed(message: "Share extension is unavailable."))
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

            let importedItems = try await importer.loadItems(from: inputItemProviders)
            let composerViewModel = try makeComposerViewModel(
                sessionContext: sessionContext,
                importedItems: importedItems,
                sharedLocalFeedCardSyncManager: sharedLocalFeedCardSyncManager
            )
            self.composerViewModel = composerViewModel
            installRootView(state: .composer(composerViewModel))
        } catch {
            installRootView(state: .failed(message: "Failed to prepare shared content."))
        }
    }

    private func makeComposerViewModel(
        sessionContext: ShareExtensionSessionContext,
        importedItems: [ShareImportedItem],
        sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager
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
            publishAction: { [weak self] localFeedCard, _ in
                guard let self else {
                    return
                }

                do {
                    try sharedLocalFeedCardSyncManager.publishImportedCard(localFeedCard)
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
        guard composerViewModel.publish() != nil else {
            return
        }

        if let publishFailureMessage {
            installRootView(state: .failed(message: publishFailureMessage))
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
            self?.extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
        }
    }

    private var inputItemProviders: [NSItemProvider] {
        guard let inputItems = extensionContext?.inputItems as? [NSExtensionItem] else {
            return []
        }

        return inputItems.flatMap { $0.attachments ?? [] }
    }
}

private enum ShareExtensionError: LocalizedError {
    case cancelled
}
