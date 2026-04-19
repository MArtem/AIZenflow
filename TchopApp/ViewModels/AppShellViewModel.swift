import Foundation
import TchopUIConfiguration

/// View model for the authenticated shell.
///
/// Owns shell-scoped UI state such as the menu visibility and exposes child
/// feature view models required by the tab content.
@MainActor
final class AppShellViewModel: ObservableObject {
    /// Whether the side menu is currently open.
    @Published var isMenuOpen: Bool

    /// Channel information rendered by the fixed top bar.
    let channelInfo: ChannelHeaderInfo

    /// Footer text shown in the side menu.
    let sideMenuFooterText: String

    /// View model for the news feed feature.
    let newsFeedViewModel: NewsFeedViewModel

    /// Whether the floating action button should be rendered for the active shell.
    @Published private(set) var showsFloatingActionButton: Bool

    private let uiConfigurationManager: any UIConfigurationManaging

    /// Creates the shell view model from repository-backed content.
    init(
        contentRepository: any AppContentRepository,
        uiConfigurationManager: any UIConfigurationManaging,
        widgetContentSyncManager: (any WidgetContentSyncing)? = nil,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text(
            "shell.sideMenu.footer",
            fallback: "Select a destination here or from the bottom bar. Both stay in sync through the same tab state."
        )
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelInfo = Self.resolveChannelInfo(from: contentRepository)
        self.sideMenuFooterText = sideMenuFooterText
        let resolvedWidgetContentSyncManager = widgetContentSyncManager ?? NoopWidgetContentSyncManager()
        self.newsFeedViewModel = NewsFeedViewModel(
            repository: contentRepository,
            widgetContentSyncManager: resolvedWidgetContentSyncManager
        )
        self.showsFloatingActionButton = true
        self.uiConfigurationManager = uiConfigurationManager

        Task {
            await loadUIConfiguration()
        }
    }

    /// Toggles the side menu state.
    func toggleMenu() {
        isMenuOpen.toggle()
    }

    /// Closes the side menu explicitly.
    func closeMenu() {
        isMenuOpen = false
    }

    private func loadUIConfiguration() async {
        do {
            let configuration = try await uiConfigurationManager.fetchConfiguration()
            showsFloatingActionButton = configuration.shell.showsFloatingActionButton
        } catch {
            assertionFailure("Failed to fetch UI configuration: \(error)")
        }
    }

    private static func resolveChannelInfo(from repository: any AppContentRepository) -> ChannelHeaderInfo {
        (try? repository.fetchChannelInfo()) ?? ChannelHeaderInfo(
            title: AppLocalization.text("channel.default.title", fallback: "Tchop"),
            subtitle: AppLocalization.text("channel.default.subtitle", fallback: "New channel name")
        )
    }
}
