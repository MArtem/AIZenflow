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
    private(set) var draft: FeedComposerDraft
    private let channelsStore: ChannelsStore
    private let channelCardStore: ChannelCardStore

    init(
        selectedChannelID: String,
        channelsStore: ChannelsStore,
        channelCardStore: ChannelCardStore
    ) {
        self.channelsStore = channelsStore
        self.channelCardStore = channelCardStore
        self.draft = FeedComposerDraft(selectedChannelID: selectedChannelID)
    }

    var selectedChannelID: String { draft.selectedChannelID }

    var media: ChannelCardMediaContent? { draft.media }

    var visibleTextFieldKinds: Set<ChannelCardTextFieldKind> { draft.visibleTextFieldKinds }

    var availableChannels: [AppChannel] {
        channelsStore.selectionSnapshot.availableChannels
    }

    var selectedChannelTitle: String {
        availableChannels.first(where: { $0.id == selectedChannelID })?.title ?? "Channel"
    }

    var canPublish: Bool {
        draft.canPublish
    }

    var availableInsertions: [FeedComposerInsertion] {
        draft.availableInsertions
    }

    var orderedVisibleTextFieldKinds: [ChannelCardTextFieldKind] {
        draft.orderedVisibleTextFieldKinds
    }

    var showsPhotoToolbarAction: Bool {
        draft.showsPhotoToolbarAction
    }

    func selectChannel(id: String) {
        draft.selectChannel(id: id)
    }

    func applyInsertion(_ insertion: FeedComposerInsertion) {
        draft.applyInsertion(insertion)
    }

    func addPhoto() {
        draft.addPhoto()
    }

    func selectVideo() {
        draft.selectVideo()
    }

    func removeMedia() {
        draft.removeMedia()
    }

    func removePhoto(id: String) {
        draft.removePhoto(id: id)
    }

    func updatePhotoCaption(_ value: String?, id: String) {
        draft.updatePhotoCaption(value, id: id)
    }

    func updatePhotoCopyright(_ value: String?, id: String) {
        draft.updatePhotoCopyright(value, id: id)
    }

    func updateFileCaption(_ value: String?) {
        draft.updateFileCaption(value)
    }

    func addOrReplaceTeaserImage(displayTitle: String = "Teaser image") {
        draft.addOrReplaceTeaserImage(displayTitle: displayTitle)
    }

    func removeTeaserImage() {
        draft.removeTeaserImage()
    }

    func updateTeaserCopyright(_ value: String?) {
        draft.updateTeaserCopyright(value)
    }

    func textValue(for kind: ChannelCardTextFieldKind) -> String {
        draft.textValue(for: kind)
    }

    func updateText(_ value: String, for kind: ChannelCardTextFieldKind) {
        draft.updateText(value, for: kind)
    }

    func handleBackspaceOnEmptyField(_ kind: ChannelCardTextFieldKind) {
        draft.handleBackspaceOnEmptyField(kind)
    }

    func removeFieldIfOptionalAndEmpty(_ kind: ChannelCardTextFieldKind) {
        draft.removeFieldIfOptionalAndEmpty(kind)
    }

    func fieldPlaceholder(for kind: ChannelCardTextFieldKind) -> String {
        draft.fieldPlaceholder(for: kind)
    }

    func fieldIsRequired(_ kind: ChannelCardTextFieldKind) -> Bool {
        draft.fieldIsRequired(kind)
    }

    func fieldSupportsRemoval(_ kind: ChannelCardTextFieldKind) -> Bool {
        draft.fieldSupportsRemoval(kind)
    }

    func publish() -> ChannelCardContent? {
        guard let card = draft.makeCard() else {
            return nil
        }
        channelCardStore.publish(card)
        return card
    }
}

extension FeedComposerInsertion {
    var textFieldKind: ChannelCardTextFieldKind {
        switch self {
        case .text:
            return .text
        case .headline:
            return .headline
        case .subheadline:
            return .subheadline
        case .source:
            return .source
        case .photoOrVideo, .photo, .audio, .pdf:
            return .text
        }
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
