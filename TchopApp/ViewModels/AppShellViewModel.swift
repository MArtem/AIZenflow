import Foundation
import Observation
#if !APP_EXTENSION
#endif

@MainActor
/// Persistence boundary used by feed-card runtime stores.
///
/// External usage:
/// Implemented by app repositories and injected into `FeedCardStore` by composition code.
protocol FeedCardPersisting {
    func loadCards(for userID: String) throws -> [FeedCard]
    func saveCards(_ cards: [FeedCard], for userID: String) throws
    func saveCard(_ card: FeedCard, for userID: String) throws
}

enum FeedCardStoreError: Error {
    case missingActiveUser
}

@MainActor
@Observable
/// Main-actor owner for published feed cards visible in the app runtime.
///
/// Responsibilities:
/// - loads persisted cards at startup;
/// - publishes composer/share-extension cards;
/// - keeps in-memory feed rows aligned with persistence.
///
/// Ownership:
/// Created by the app dependency container and shared with feed/composer flows.
final class FeedCardStore {
    private(set) var cards: [NewsFeedCard] = []

    private let repository: any FeedCardPersisting
    private var persistedCards: [FeedCard]
    private var activeUserID: String?

    init(repository: any FeedCardPersisting) {
        self.repository = repository
        self.persistedCards = []
    }

    func publish(_ card: FeedCard) {
        do {
            try sync([card])
        } catch {
            assertionFailure("Failed to persist feed card: \(error)")
        }
    }

    func activateUser(id userID: String) {
        activeUserID = userID
        persistedCards = (try? repository.loadCards(for: userID)) ?? []
        refreshCards()
    }

    func clearUser() {
        activeUserID = nil
        persistedCards = []
        cards = []
    }

    func cards(for channelID: String?) -> [NewsFeedCard] {
        guard let channelID else {
            return []
        }

        return cards.filter { $0.channelID == channelID }
    }

    func sync(_ feedCards: [FeedCard]) throws {
        guard !feedCards.isEmpty else {
            return
        }
        guard let activeUserID else {
            throw FeedCardStoreError.missingActiveUser
        }

        let existingIDs = Set(persistedCards.map(\.id))
        let newCards = feedCards.filter { !existingIDs.contains($0.id) }
        guard !newCards.isEmpty else {
            return
        }

        try repository.saveCards(newCards, for: activeUserID)
        persistedCards = newCards + persistedCards
        cards = newCards.map(\.newsFeedCard) + cards
    }

    func updatePersistedCard(
        id: String,
        transform: (FeedCard) -> FeedCard
    ) {
        guard let index = persistedCards.firstIndex(where: { $0.id == id }) else {
            return
        }
        guard let activeUserID else {
            return
        }

        let updatedCard = transform(persistedCards[index])
        do {
            try repository.saveCard(updatedCard, for: activeUserID)
            persistedCards[index] = updatedCard
            cards[index] = updatedCard.newsFeedCard
        } catch {
            assertionFailure("Failed to update persisted feed card: \(error)")
        }
    }

    private func refreshCards() {
        cards = persistedCards.map(\.newsFeedCard)
    }
}

@MainActor
@Observable
/// Main-actor presentation owner for the shared card composer.
///
/// Responsibilities:
/// - owns the editable composer draft;
/// - exposes available insertions/channels to SwiftUI;
/// - publishes a source-neutral `FeedCard` through the injected action.
///
/// Ownership:
/// Created per composer presentation by app or share-extension composition.
final class FeedComposerViewModel {
    private(set) var draft: FeedComposerDraft
    private let channelsStore: ChannelsStore
    private let publishAction: @MainActor (FeedCard) -> Void

    convenience init(
        selectedChannelID: String,
        channelsStore: ChannelsStore,
        feedCardStore: FeedCardStore
    ) {
        self.init(
            selectedChannelID: selectedChannelID,
            channelsStore: channelsStore,
            publishAction: feedCardStore.publish
        )
    }

    init(
        selectedChannelID: String,
        channelsStore: ChannelsStore,
        publishAction: @escaping @MainActor (FeedCard) -> Void
    ) {
        self.channelsStore = channelsStore
        self.publishAction = publishAction
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

    var orderedVisiblePrimaryTextFieldKinds: [ChannelCardTextFieldKind] {
        draft.orderedVisiblePrimaryTextFieldKinds
    }

    var isSourceFieldVisible: Bool {
        draft.isSourceFieldVisible
    }

    var showsPhotoToolbarAction: Bool {
        draft.showsPhotoToolbarAction
    }

    var isFileCaptionFieldVisible: Bool {
        draft.isFileCaptionFieldVisible
    }

    var isTeaserCopyrightFieldVisible: Bool {
        draft.isTeaserCopyrightFieldVisible
    }

    var fileCaptionText: String {
        draft.fileCaptionText ?? ""
    }

    var photoItems: [ChannelCardPhotoItem] {
        draft.photoItems
    }

    var teaserCopyrightText: String {
        draft.teaserCopyrightText ?? ""
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

    func addPickedPhoto(displayTitle: String?, fileURL: URL?) {
        draft.addPickedPhoto(displayTitle: displayTitle, fileURL: fileURL)
    }

    func selectVideo() {
        draft.selectVideo()
    }

    func selectPickedFile(kind: ChannelCardMediaKind, displayTitle: String, fileURL: URL?) {
        draft.selectPickedFile(kind: kind, displayTitle: displayTitle, fileURL: fileURL)
    }

    func removeMedia() {
        draft.removeMedia()
    }

    func removePhoto(id: String) {
        draft.removePhoto(id: id)
    }

    func replacePickedPhoto(id: String, displayTitle: String?, fileURL: URL?) {
        draft.replacePickedPhoto(id: id, displayTitle: displayTitle, fileURL: fileURL)
    }

    func updatePhotoCaption(_ value: String?, id: String) {
        draft.updatePhotoCaption(value, id: id)
    }

    func showPhotoCaptionField(id: String) {
        draft.showPhotoCaptionField(id: id)
    }

    func removePhotoCaptionFieldIfEmpty(id: String) {
        draft.removePhotoCaptionFieldIfEmpty(id: id)
    }

    func isPhotoCaptionFieldVisible(id: String) -> Bool {
        draft.visiblePhotoCaptionFieldIDs.contains(id)
    }

    func photoCaptionText(id: String) -> String {
        draft.photoCaptionText(id: id) ?? ""
    }

    func updatePhotoCopyright(_ value: String?, id: String) {
        draft.updatePhotoCopyright(value, id: id)
    }

    func showPhotoCopyrightField(id: String) {
        draft.showPhotoCopyrightField(id: id)
    }

    func removePhotoCopyrightFieldIfEmpty(id: String) {
        draft.removePhotoCopyrightFieldIfEmpty(id: id)
    }

    func isPhotoCopyrightFieldVisible(id: String) -> Bool {
        draft.visiblePhotoCopyrightFieldIDs.contains(id)
    }

    func photoCopyrightText(id: String) -> String {
        draft.photoCopyrightText(id: id) ?? ""
    }

    func updateFileCaption(_ value: String?) {
        draft.updateFileCaption(value)
    }

    func showFileCaptionField() {
        draft.showFileCaptionField()
    }

    func removeFileCaptionFieldIfEmpty() {
        draft.removeFileCaptionFieldIfEmpty()
    }

    func addOrReplaceTeaserImage(displayTitle: String = "Teaser image", fileURL: URL? = nil) {
        draft.addOrReplaceTeaserImage(displayTitle: displayTitle, fileURL: fileURL)
    }

    func removeTeaserImage() {
        draft.removeTeaserImage()
    }

    func updateTeaserCopyright(_ value: String?) {
        draft.updateTeaserCopyright(value)
    }

    func showTeaserCopyrightField() {
        draft.showTeaserCopyrightField()
    }

    func removeTeaserCopyrightFieldIfEmpty() {
        draft.removeTeaserCopyrightFieldIfEmpty()
    }

    func textValue(for kind: ChannelCardTextFieldKind) -> String {
        draft.textValue(for: kind)
    }

    func updateText(_ value: String, for kind: ChannelCardTextFieldKind) {
        draft.updateText(value, for: kind)
    }

    func updateSourceURLString(_ value: String?) {
        draft.updateSourceURLString(value)
    }

    func applyImportedItems(_ items: [ShareImportedItem]) throws {
        try draft.applyImportedItems(items)
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

    func publish() -> Bool {
        guard let card = draft.makeCard() else {
            return false
        }
        publishAction(card.feedCardModel)
        return true
    }
}

#if !APP_EXTENSION
/// View model for the authenticated shell.
///
/// Owns shell-scoped UI state such as the menu visibility and exposes child
/// feature view models required by the tab content.
@MainActor
@Observable
final class AppShellViewModel {
    /// Explicit shell runtime state observed by shell views.
    struct State {
        var isMenuOpen: Bool
        var showsFloatingActionButton: Bool
        var isNewsFeedNearTop: Bool
        var activeComposer: FeedComposerViewModel?
    }

    private(set) var state: State

    /// Footer text shown in the side menu.
    let sideMenuFooterText: String

    /// View model for the news feed feature.
    let newsFeedViewModel: NewsFeedViewModel

    private let uiConfigurationManager: any UIConfigurationManaging<ShellUIConfiguration>
    private let errorManager: any AppErrorManaging
    private let shareExtensionSessionContextManager: ShareExtensionSessionContextManager?
    let channelsStore: ChannelsStore
    private let feedCardStore: FeedCardStore

    var isMenuOpen: Bool { state.isMenuOpen }
    var showsFloatingActionButton: Bool { state.showsFloatingActionButton }
    var isNewsFeedNearTop: Bool { state.isNewsFeedNearTop }
    var activeComposer: FeedComposerViewModel? { state.activeComposer }
    private var selectedChannelIDForComposer: String {
        channelsStore.selectionSnapshot.selectedChannelID
            ?? channelsStore.selectionSnapshot.selectedChannel?.id
            ?? AppChannel.defaultChannel.id
    }

    /// Creates the shell view model from repository-backed content.
    init(
        channelsStore: ChannelsStore,
        feedCardStore: FeedCardStore,
        newsFeedViewModel: NewsFeedViewModel,
        errorManager: any AppErrorManaging,
        uiConfigurationManager: any UIConfigurationManaging<ShellUIConfiguration>,
        shareExtensionSessionContextManager: ShareExtensionSessionContextManager? = nil,
        isMenuOpen: Bool = false,
        sideMenuFooterText: String = AppLocalization.text("shell.sideMenu.footer")
    ) {
        self.state = State(
            isMenuOpen: isMenuOpen,
            showsFloatingActionButton: true,
            isNewsFeedNearTop: true,
            activeComposer: nil
        )
        self.channelsStore = channelsStore
        self.feedCardStore = feedCardStore
        self.sideMenuFooterText = sideMenuFooterText
        self.newsFeedViewModel = newsFeedViewModel
        self.errorManager = errorManager
        self.uiConfigurationManager = uiConfigurationManager
        self.shareExtensionSessionContextManager = shareExtensionSessionContextManager

        startUIConfigurationLoad()
    }

    /// Toggles the side menu state.
    func toggleMenu() {
        state.isMenuOpen.toggle()
    }

    /// Closes the side menu explicitly.
    func closeMenu() {
        state.isMenuOpen = false
    }

    func activateFeedScope(for userID: String) {
        feedCardStore.activateUser(id: userID)
        newsFeedViewModel.send(.channelCardsChanged)
    }

    func clearFeedScope() {
        feedCardStore.clearUser()
        newsFeedViewModel.send(.channelCardsChanged)
    }

    /// Applies one new active channel choice to the shared runtime store.
    func selectChannel(id: String) {
        if channelsStore.selectChannel(id: id) {
            newsFeedViewModel.send(.selectedChannelChanged)
            syncShareExtensionSessionContextIfNeeded()
        }
    }

    func presentComposer() {
        state.activeComposer = FeedComposerViewModel(
            selectedChannelID: selectedChannelIDForComposer,
            channelsStore: channelsStore,
            feedCardStore: feedCardStore
        )
    }

    func dismissComposer() {
        state.activeComposer = nil
    }

    func publishComposer() {
        newsFeedViewModel.send(.channelCardsChanged)
        dismissComposer()
    }

    /// Updates shell runtime visibility state for the news-feed floating action button.
    ///
    /// The shell owns the button itself, but the scroll-position signal comes from the news list.
    func setNewsFeedNearTop(_ isNearTop: Bool) {
        guard state.isNewsFeedNearTop != isNearTop else {
            return
        }

        state.isNewsFeedNearTop = isNearTop
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
    private func applyShellConfiguration(_ configuration: AppUIConfigurationSnapshot) {
        state.showsFloatingActionButton = configuration.payload.showsFloatingActionButton
    }

    /// Handles non-fatal refresh failures after the cached configuration has already been applied.
    private func handleUIConfigurationRefreshFailure(_ error: any Error) {
        Task { [errorManager] in
            _ = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "refreshUIConfiguration",
                    feature: "appShell"
                )
            )
        }
    }

    private func syncShareExtensionSessionContextIfNeeded() {
        guard let shareExtensionSessionContextManager else {
            return
        }

        let snapshot = channelsStore.selectionSnapshot

        do {
            try shareExtensionSessionContextManager.syncContext(
                isAuthenticated: true,
                availableChannels: snapshot.availableChannels,
                selectedChannelID: snapshot.selectedChannelID
            )
        } catch {
            Task { [errorManager] in
                _ = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "syncShareExtensionSessionContext",
                        feature: "shareExtension"
                    )
                )
            }
        }
    }
}
#endif
