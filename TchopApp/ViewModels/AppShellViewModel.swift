import Combine
import Foundation
import TchopErrors
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
    @Published private(set) var channelInfo: ChannelHeaderInfo

    /// Footer text shown in the side menu.
    let sideMenuFooterText: String

    /// View model for the news feed feature.
    let newsFeedViewModel: NewsFeedViewModel

    /// Channels currently available to the active user session.
    @Published private(set) var channels: [AppChannel]

    /// Currently selected channel identifier.
    @Published private(set) var selectedChannelID: String?

    /// Whether the floating action button should be rendered for the active shell.
    @Published private(set) var showsFloatingActionButton: Bool

    /// Whether the news feed list is currently close enough to the top to allow the floating action button.
    @Published private(set) var isNewsFeedNearTop: Bool

    private let uiConfigurationManager: any UIConfigurationManaging
    private let errorManager: any AppErrorManaging
    private let channelsStore: ChannelsStore
    private var storeBindings: Set<AnyCancellable> = []

    /// Creates the shell view model from repository-backed content.
    init(
        channelsStore: ChannelsStore,
        newsFeedViewModel: NewsFeedViewModel,
        errorManager: any AppErrorManaging,
        uiConfigurationManager: any UIConfigurationManaging,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text("shell.sideMenu.footer")
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelsStore = channelsStore
        self.channelInfo = channelsStore.selectedChannelHeaderInfo ?? AppChannel.defaultChannel.headerInfo
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = newsFeedViewModel
        self.channels = channelsStore.channels
        self.selectedChannelID = channelsStore.selectedChannelID ?? channelsStore.selectedChannel?.id
        self.showsFloatingActionButton = true
        self.isNewsFeedNearTop = true
        self.errorManager = errorManager
        self.uiConfigurationManager = uiConfigurationManager

        setupChannelBindings()
        startUIConfigurationLoad()
    }

    /// Toggles the side menu state.
    func toggleMenu() {
        isMenuOpen.toggle()
    }

    /// Closes the side menu explicitly.
    func closeMenu() {
        isMenuOpen = false
    }

    /// Applies one new active channel choice to the shared runtime store.
    func selectChannel(id: String) {
        channelsStore.selectChannel(id: id)
    }

    /// Updates shell runtime visibility state for the news-feed floating action button.
    ///
    /// The shell owns the button itself, but the scroll-position signal comes from the news list.
    func setNewsFeedNearTop(_ isNearTop: Bool) {
        guard isNewsFeedNearTop != isNearTop else {
            return
        }

        isNewsFeedNearTop = isNearTop
    }

    /// Starts the asynchronous shell configuration bootstrap sequence.
    ///
    /// The shell first applies cached configuration and then asks for a refreshed snapshot so
    /// first paint stays fast even when remote configuration is slow or unavailable.
    private func startUIConfigurationLoad() {
        Task {
            await loadUIConfiguration()
        }
    }

    /// Loads cached and refreshed shell configuration in order.
    private func loadUIConfiguration() async {
        let currentConfiguration = await uiConfigurationManager.currentConfiguration()
        applyShellConfiguration(currentConfiguration)
        await refreshUIConfiguration()
    }

    /// Refreshes shell configuration from the remote-backed configuration manager.
    private func refreshUIConfiguration() async {
        do {
            let refreshedConfiguration = try await uiConfigurationManager.refreshConfiguration()
            applyShellConfiguration(refreshedConfiguration)
        } catch {
            handleUIConfigurationRefreshFailure(error)
        }
    }

    /// Applies shell-specific UI settings from a full configuration snapshot.
    private func applyShellConfiguration(_ configuration: UIConfigurationSnapshot) {
        showsFloatingActionButton = configuration.shell.showsFloatingActionButton
    }

    /// Handles non-fatal refresh failures after the cached configuration has already been applied.
    private func handleUIConfigurationRefreshFailure(_ error: any Error) {
        Task { [errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "refreshUIConfiguration",
                    feature: "appShell"
                )
            )
            assertionFailure("Failed to fetch UI configuration: \(presentation.error.debugDescription)")
        }
    }

    /// Keeps shell chrome in sync with the currently selected app-wide channel.
    private func setupChannelBindings() {
        channelsStore.$channels
            .sink { [weak self] channels in
                self?.channels = channels
            }
            .store(in: &storeBindings)

        channelsStore.$selectedChannelID
            .removeDuplicates()
            .sink { [weak self] _ in
                self?.channelInfo = self?.channelsStore.selectedChannelHeaderInfo ?? AppChannel.defaultChannel.headerInfo
                self?.selectedChannelID = self?.channelsStore.selectedChannelID ?? self?.channelsStore.selectedChannel?.id
            }
            .store(in: &storeBindings)
    }
}
