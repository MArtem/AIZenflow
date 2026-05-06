import Foundation
import Observation
import TchopErrors
import TchopUIConfiguration

@MainActor
@Observable
final class ChannelCardStore {
    private(set) var cards: [ChannelCardContent] = []

    func publish(_ card: ChannelCardContent) {
        cards.insert(card, at: 0)
    }

    func cards(for channelID: String?) -> [ChannelCardContent] {
        guard let channelID else {
            return []
        }

        return cards.filter { $0.channelID == channelID }
    }
}

@MainActor
@Observable
final class FeedComposerViewModel {
    var selectedChannelID: String
    var text: String
    var headline: String
    var subheadline: String
    var source: String
    private(set) var showsHeadlineField: Bool
    private(set) var showsSubheadlineField: Bool
    private(set) var showsSourceField: Bool
    private(set) var mediaKind: ChannelCardMediaKind?
    private let channelsStore: ChannelsStore
    private let channelCardStore: ChannelCardStore

    init(
        selectedChannelID: String,
        channelsStore: ChannelsStore,
        channelCardStore: ChannelCardStore
    ) {
        self.selectedChannelID = selectedChannelID
        self.channelsStore = channelsStore
        self.channelCardStore = channelCardStore
        self.text = ""
        self.headline = ""
        self.subheadline = ""
        self.source = ""
        self.showsHeadlineField = false
        self.showsSubheadlineField = false
        self.showsSourceField = false
    }

    var availableChannels: [AppChannel] {
        channelsStore.selectionSnapshot.availableChannels
    }

    var selectedChannelTitle: String {
        availableChannels.first(where: { $0.id == selectedChannelID })?.title ?? "Channel"
    }

    var canPublish: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || mediaKind != nil
    }

    var availableInsertions: [FeedComposerInsertion] {
        var insertions: [FeedComposerInsertion] = []

        if mediaKind == nil {
            insertions.append(.photoOrVideo)
            insertions.append(.audio)
            insertions.append(.pdf)
        }

        if !showsHeadlineField {
            insertions.append(.headline)
        }
        if !showsSubheadlineField {
            insertions.append(.subheadline)
        }
        if !showsSourceField {
            insertions.append(.source)
        }

        return insertions
    }

    func selectChannel(id: String) {
        selectedChannelID = id
    }

    func applyInsertion(_ insertion: FeedComposerInsertion) {
        switch insertion {
        case .photoOrVideo:
            if mediaKind == nil {
                mediaKind = .photo
            }
        case .audio:
            if mediaKind == nil {
                mediaKind = .audio
            }
        case .pdf:
            if mediaKind == nil {
                mediaKind = .pdf
            }
        case .headline:
            showsHeadlineField = true
        case .subheadline:
            showsSubheadlineField = true
        case .source:
            showsSourceField = true
        }
    }

    @discardableResult
    func publish() -> ChannelCardContent? {
        guard canPublish else {
            return nil
        }

        let resolvedKind: ChannelCardKind
        switch mediaKind {
        case .photo:
            resolvedKind = .photo
        case .video:
            resolvedKind = .video
        case .audio:
            resolvedKind = .audio
        case .pdf:
            resolvedKind = .pdf
        case nil:
            resolvedKind = .text
        }

        let card = ChannelCardContent(
            id: UUID().uuidString,
            channelID: selectedChannelID,
            createdAt: Date(),
            kind: resolvedKind,
            text: normalized(text),
            headline: normalized(headline),
            subheadline: normalized(subheadline),
            source: normalized(source),
            mediaKind: mediaKind
        )
        channelCardStore.publish(card)
        return card
    }

    private func normalized(_ value: String) -> String? {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}

/// View model for the authenticated shell.
///
/// Owns shell-scoped UI state such as the menu visibility and exposes child
/// feature view models required by the tab content.
@MainActor
@Observable
final class AppShellViewModel {
    /// Whether the side menu is currently open.
    var isMenuOpen: Bool

    /// Footer text shown in the side menu.
    let sideMenuFooterText: String

    /// View model for the news feed feature.
    let newsFeedViewModel: NewsFeedViewModel

    /// Whether the floating action button should be rendered for the active shell.
    private(set) var showsFloatingActionButton: Bool

    /// Whether the news feed list is currently close enough to the top to allow the floating action button.
    private(set) var isNewsFeedNearTop: Bool

    private let uiConfigurationManager: any UIConfigurationManaging
    private let errorManager: any AppErrorManaging
    let channelsStore: ChannelsStore
    private let channelCardStore: ChannelCardStore
    private(set) var activeComposer: FeedComposerViewModel?

    /// Creates the shell view model from repository-backed content.
    init(
        channelsStore: ChannelsStore,
        channelCardStore: ChannelCardStore = ChannelCardStore(),
        newsFeedViewModel: NewsFeedViewModel,
        errorManager: any AppErrorManaging,
        uiConfigurationManager: any UIConfigurationManaging,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text("shell.sideMenu.footer")
    ) {
        self.isMenuOpen = isMenuOpen
        self.channelsStore = channelsStore
        self.channelCardStore = channelCardStore
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = newsFeedViewModel
        self.showsFloatingActionButton = true
        self.isNewsFeedNearTop = true
        self.errorManager = errorManager
        self.uiConfigurationManager = uiConfigurationManager

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
        if channelsStore.selectChannel(id: id) {
            newsFeedViewModel.handleSelectedChannelChange()
        }
    }

    func presentComposer() {
        let selectedChannelID = channelsStore.selectionSnapshot.selectedChannelID
            ?? channelsStore.selectionSnapshot.selectedChannel?.id
            ?? AppChannel.defaultChannel.id

        activeComposer = FeedComposerViewModel(
            selectedChannelID: selectedChannelID,
            channelsStore: channelsStore,
            channelCardStore: channelCardStore
        )
    }

    func dismissComposer() {
        activeComposer = nil
    }

    func publishComposer() {
        newsFeedViewModel.handleLocalChannelCardsChanged()
        activeComposer = nil
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
}
