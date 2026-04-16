import Foundation

/// Serializable representation of app navigation state across tabs.
struct NavigationSnapshot: Codable, Equatable {
    /// Snapshot version for future schema migrations.
    let version: Int

    /// Active tab selected when snapshot was created.
    let selectedTab: AppTab

    /// Serialized stack for each tab.
    let newsPath: [NewsRoute]
    let mixesPath: [MixesRoute]
    let pinnedPath: [PinnedRoute]
    let chatPath: [ChatRoute]
    let profilePath: [ProfileRoute]

    init(
        version: Int = 1,
        selectedTab: AppTab,
        newsPath: [NewsRoute],
        mixesPath: [MixesRoute],
        pinnedPath: [PinnedRoute],
        chatPath: [ChatRoute],
        profilePath: [ProfileRoute]
    ) {
        self.version = version
        self.selectedTab = selectedTab
        self.newsPath = newsPath
        self.mixesPath = mixesPath
        self.pinnedPath = pinnedPath
        self.chatPath = chatPath
        self.profilePath = profilePath
    }
}
