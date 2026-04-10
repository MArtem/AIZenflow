import Foundation

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

    /// Creates the shell view model from repository-backed content.
    init(
        contentRepository: any AppContentRepository,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = "Select a destination here or from the bottom bar. Both stay in sync through the same tab state."
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelInfo = Self.resolveChannelInfo(from: contentRepository)
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = NewsFeedViewModel(repository: contentRepository)
    }

    /// Whether the shell should render the floating action button for the current tab.
    var showsFloatingActionButton: Bool {
        true
    }

    /// Toggles the side menu state.
    func toggleMenu() {
        isMenuOpen.toggle()
    }

    /// Closes the side menu explicitly.
    func closeMenu() {
        isMenuOpen = false
    }

    private static func resolveChannelInfo(from repository: any AppContentRepository) -> ChannelHeaderInfo {
        (try? repository.fetchChannelInfo()) ?? ChannelHeaderInfo(
            title: "Tchop",
            subtitle: "New channel name"
        )
    }
}
