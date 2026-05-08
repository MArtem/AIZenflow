import SwiftUI
import UIKit
import TchopShareSupport

final class ShareViewController: UIViewController {
    private let importer: NSItemProviderShareItemImporter? = try? NSItemProviderShareItemImporter(
        groupIdentifier: AppGroupConfiguration.sharedContainerIdentifier
    )
    private var hostingController: UIHostingController<ShareExtensionRootView>?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        installRootView(state: .loading)
        Task { @MainActor in
            await loadSharedItems()
        }
    }

    private func installRootView(state: ShareExtensionRootView.State) {
        let rootView = ShareExtensionRootView(
            state: state,
            onClose: { [weak self] in
                self?.extensionContext?.cancelRequest(withError: ShareExtensionError.cancelled)
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
    private func loadSharedItems() async {
        guard let importer else {
            installRootView(state: .failed(message: "Share import is unavailable."))
            return
        }

        do {
            let items = try await importer.loadItems(from: inputItemProviders)
            installRootView(state: .ready(summary: ShareExtensionImportSummary(items: items)))
        } catch {
            installRootView(state: .failed(message: "Failed to prepare shared content."))
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
