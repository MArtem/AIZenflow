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
        channelInfo: ChannelHeaderInfo,
        newsFeedViewModel: NewsFeedViewModel,
        uiConfigurationManager: any UIConfigurationManaging,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text(
            "shell.sideMenu.footer",
            fallback: "Select a destination here or from the bottom bar. Both stay in sync through the same tab state."
        )
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelInfo = channelInfo
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = newsFeedViewModel
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

    /// Loads uiconfiguration.
    private func loadUIConfiguration() async {
        applyShellConfiguration(await uiConfigurationManager.currentConfiguration())

        do {
            applyShellConfiguration(try await uiConfigurationManager.refreshConfiguration())
        } catch {
            assertionFailure("Failed to fetch UI configuration: \(error)")
        }
    }

    /// Applies shell-specific UI settings from a full configuration snapshot.
    private func applyShellConfiguration(_ configuration: UIConfigurationSnapshot) {
        showsFloatingActionButton = configuration.shell.showsFloatingActionButton
    }
}
