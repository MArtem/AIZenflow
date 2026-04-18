import Foundation

/// Serializable representation of app navigation state across tabs.
struct NavigationSnapshot: Codable, Equatable {
    /// Snapshot version supported by the current app build.
    static let supportedVersion = 2

    /// Upper limit used to protect restore from oversized stacks.
    static let maxRoutesPerTab = 20

    /// Snapshot version for future schema migrations.
    let version: Int

    /// Creation time used for diagnostics and restore observability.
    let createdAt: Date

    /// Active tab selected when snapshot was created.
    let selectedTab: AppTab

    /// Serialized stack for each tab.
    let newsPath: [NewsRoute]
    let mixesPath: [MixesRoute]
    let pinnedPath: [PinnedRoute]
    let chatPath: [ChatRoute]
    let profilePath: [ProfileRoute]

    init(
        version: Int = NavigationSnapshot.supportedVersion,
        createdAt: Date = Date(),
        selectedTab: AppTab,
        newsPath: [NewsRoute],
        mixesPath: [MixesRoute],
        pinnedPath: [PinnedRoute],
        chatPath: [ChatRoute],
        profilePath: [ProfileRoute]
    ) {
        self.version = version
        self.createdAt = createdAt
        self.selectedTab = selectedTab
        self.newsPath = newsPath
        self.mixesPath = mixesPath
        self.pinnedPath = pinnedPath
        self.chatPath = chatPath
        self.profilePath = profilePath
    }

    /// Returns snapshot migrated to the currently supported schema version.
    func migratedToSupportedVersion() -> NavigationSnapshot {
        guard version < NavigationSnapshot.supportedVersion else {
            return self
        }

        return NavigationSnapshot(
            version: NavigationSnapshot.supportedVersion,
            createdAt: createdAt,
            selectedTab: selectedTab,
            newsPath: newsPath,
            mixesPath: mixesPath,
            pinnedPath: pinnedPath,
            chatPath: chatPath,
            profilePath: profilePath
        )
    }

    /// Returns snapshot with bounded path sizes to keep restore safe.
    func sanitized(maxRoutesPerTab: Int = NavigationSnapshot.maxRoutesPerTab) -> NavigationSnapshot {
        NavigationSnapshot(
            version: version,
            createdAt: createdAt,
            selectedTab: selectedTab,
            newsPath: Array(newsPath.prefix(maxRoutesPerTab)),
            mixesPath: Array(mixesPath.prefix(maxRoutesPerTab)),
            pinnedPath: Array(pinnedPath.prefix(maxRoutesPerTab)),
            chatPath: Array(chatPath.prefix(maxRoutesPerTab)),
            profilePath: Array(profilePath.prefix(maxRoutesPerTab))
        )
    }

    enum CodingKeys: String, CodingKey {
        case version
        case createdAt
        case selectedTab
        case newsPath
        case mixesPath
        case pinnedPath
        case chatPath
        case profilePath
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.version = try container.decodeIfPresent(Int.self, forKey: .version) ?? 1
        self.createdAt = try container.decodeIfPresent(Date.self, forKey: .createdAt) ?? .distantPast
        self.selectedTab = try container.decode(AppTab.self, forKey: .selectedTab)
        self.newsPath = try container.decode([NewsRoute].self, forKey: .newsPath)
        self.mixesPath = try container.decode([MixesRoute].self, forKey: .mixesPath)
        self.pinnedPath = try container.decode([PinnedRoute].self, forKey: .pinnedPath)
        self.chatPath = try container.decode([ChatRoute].self, forKey: .chatPath)
        self.profilePath = try container.decode([ProfileRoute].self, forKey: .profilePath)
    }
}
