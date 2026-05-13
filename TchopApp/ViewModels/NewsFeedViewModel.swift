import Foundation
import Observation
import TchopErrors
import TchopOnDeviceAI

@MainActor
final class CardTranslationStore {
    private enum Keys {
        static let snapshots = "card_translation_snapshots"
    }

    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private var snapshotsByCardID: [String: CardTranslationSnapshot]

    init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        if
            let data = userDefaults.data(forKey: Keys.snapshots),
            let snapshots = try? decoder.decode([String: CardTranslationSnapshot].self, from: data)
        {
            self.snapshotsByCardID = snapshots
        } else {
            self.snapshotsByCardID = [:]
        }
    }

    func snapshot(for cardID: String) -> CardTranslationSnapshot? {
        snapshotsByCardID[cardID]
    }

    func save(_ snapshot: CardTranslationSnapshot) {
        snapshotsByCardID[snapshot.cardID] = snapshot
        persist()
    }

    func remove(cardID: String) {
        snapshotsByCardID.removeValue(forKey: cardID)
        persist()
    }

    private func persist() {
        guard let data = try? encoder.encode(snapshotsByCardID) else {
            return
        }

        userDefaults.set(data, forKey: Keys.snapshots)
    }
}

/// Explicit runtime state for the news feed screen.
enum NewsFeedState: Equatable {
    case loading(NewsFeedContent)
    case content(NewsFeedContent)
    case empty(NewsFeedContent)
    case offline(NewsFeedContent)
    case failed(content: NewsFeedContent, message: String)

    /// Feed content currently available to the UI.
    var content: NewsFeedContent {
        switch self {
        case let .loading(content):
            return content
        case let .content(content):
            return content
        case let .empty(content):
            return content
        case let .offline(content):
            return content
        case let .failed(content, _):
            return content
        }
    }

    /// Whether the screen is currently performing a refresh.
    var isLoading: Bool {
        if case .loading = self {
            return true
        }

        return false
    }

    /// User-facing error message for failed states.
    var errorMessage: String? {
        guard case let .failed(_, message) = self else {
            return nil
        }

        return message
    }

    /// Whether the resolved feed contains no cards.
    var isEmpty: Bool {
        if case .empty = self {
            return true
        }

        return false
    }

    /// Whether the feed is currently showing a persisted offline snapshot.
    var isOffline: Bool {
        if case .offline = self {
            return true
        }

        return false
    }
}

/// Internal load policies that separate initial load, manual refresh and retry semantics.
private enum NewsFeedLoadPolicy {
    case initial
    case refresh
    case retry
}

/// Whether a failed card action should restore the optimistic snapshot or keep the persisted one on screen.
private enum CardActionFailureResolution {
    case rollback
    case preserveVisibleSnapshot
}

/// Presentation policy applied after a card action fails.
private struct CardActionFailurePolicy {
    let resolution: CardActionFailureResolution
    let message: String
}

/// Start decision for one card action after evaluating the current per-card runtime policy.
private enum CardActionStartDecision {
    case start
    case queue
    case ignore
}

/// View model responsible for loading and exposing the home feed state.
@MainActor
@Observable
final class NewsFeedViewModel {
    /// Explicit screen state used by the news feed UI.
    private(set) var state: NewsFeedState

    /// Current free-text search query applied to cards from the selected channel only.
    var searchQuery: String = ""

    /// Whether the search field for the current channel is currently visible.
    private(set) var isSearchPresented: Bool = false
    private var translatingCardIDs: Set<String> = []

    private let repository: any NewsFeedRepository
    private let channelsStore: ChannelsStore
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let errorManager: any AppErrorManaging
    private let localFeedCardStore: LocalFeedCardStore
    private let sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager?
    private let onDeviceAIManager: any OnDeviceAIManaging
    private let cardTranslationStore: CardTranslationStore
    private let loadFailureContent: NewsFeedContent
    private let loadFailureMessage: String
    private var loadingTask: Task<Void, Never>?
    /// Serializes article actions and queues additive taps per visible card.
    private let photoActionCoordinator = NewsFeedCardActionCoordinator()
    /// Serializes discussion actions and queues additive taps per visible card.
    private let discussionActionCoordinator = NewsFeedCardActionCoordinator()

    /// Creates the feed view model and immediately starts the first load.
    init(
        repository: any NewsFeedRepository,
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        localFeedCardStore: LocalFeedCardStore = LocalFeedCardStore(),
        sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager? = nil,
        onDeviceAIManager: any OnDeviceAIManaging = OnDeviceAIManagerFactory.makeDefaultManager(),
        cardTranslationStore: CardTranslationStore = CardTranslationStore(),
        initialContent: NewsFeedContent,
        loadFailureContent: NewsFeedContent,
        loadFailureMessage: String
    ) {
        self.repository = repository
        self.channelsStore = channelsStore
        self.widgetContentSyncManager = widgetContentSyncManager
        self.errorManager = errorManager
        self.localFeedCardStore = localFeedCardStore
        self.sharedLocalFeedCardSyncManager = sharedLocalFeedCardSyncManager
        self.onDeviceAIManager = onDeviceAIManager
        self.cardTranslationStore = cardTranslationStore
        self.state = Self.resolvedState(for: initialContent)
        self.loadFailureContent = loadFailureContent
        self.loadFailureMessage = loadFailureMessage
        widgetContentSyncManager.syncFeed(content: initialContent)
        load(using: .initial)
    }

    /// Current feed content shown by the news screen.
    var content: NewsFeedContent {
        state.content
    }

    /// Feed content visible after applying the current channel-local search query.
    var visibleContent: NewsFeedContent {
        let scopedContent = state.content.scoped(to: currentChannelID)
        let localCards = localFeedCardStore.cards(for: currentChannelID)
        return NewsFeedContent(
            cards: filteredCards(from: localCards + scopedContent.cards, query: searchQuery),
            availability: scopedContent.availability
        )
    }

    func showsTranslationAction(for card: NewsFeedCard) -> Bool {
        isCardTranslated(card.id) ||
            (
                AppLocalization.supportedLocaleIdentifiers.count > 1 &&
            !translationTargetLanguages(for: card).isEmpty
            )
    }

    func translationTargetLanguages(for card: NewsFeedCard) -> [OnDeviceLanguage] {
        guard !card.translationPayload.isEmpty else {
            return []
        }

        guard case let .available(supportedLanguages) = onDeviceAIManager.translationAvailability(
            for: AppLocalization.preferredLocaleIdentifier
        ) else {
            return []
        }

        let preferredLocaleIdentifier = AppLocalization.preferredLocaleIdentifier
        return AppLocalization.supportedLocaleIdentifiers
            .filter { $0 != preferredLocaleIdentifier }
            .map(OnDeviceLanguage.init(localeIdentifier:))
            .filter { candidate in
                supportedLanguages.contains { $0.matches(localeIdentifier: candidate.localeIdentifier) }
            }
    }

    func isCardTranslated(_ cardID: String) -> Bool {
        cardTranslationStore.snapshot(for: cardID) != nil
    }

    func isTranslationInFlight(_ cardID: String) -> Bool {
        translatingCardIDs.contains(cardID)
    }

    func translationActionTitle(for cardID: String) -> String {
        isCardTranslated(cardID)
            ? AppLocalization.text("news.card.translation.original")
            : AppLocalization.text("news.card.translation.see")
    }

    func translatedPhotoCard(_ card: PhotoCardModel) -> PhotoCardModel {
        card.translated(using: cardTranslationStore.snapshot(for: card.id))
    }

    func translatedTextCard(_ card: TextCardModel) -> TextCardModel {
        card.translated(using: cardTranslationStore.snapshot(for: card.id))
    }

    func translatedLocalFeedCard(_ card: LocalFeedCardModel) -> LocalFeedCardModel {
        card.translated(using: cardTranslationStore.snapshot(for: card.id))
    }

    func translatedRoute(for route: NewsRoute) -> NewsRoute {
        guard
            let cardID = route.cardID,
            let snapshot = cardTranslationStore.snapshot(for: cardID)
        else {
            return route
        }

        switch route.destinationID {
        case "photo-details":
            return NewsRoute(
                id: route.id,
                cardID: route.cardID,
                destinationID: route.destinationID,
                title: snapshot.text(for: .photoHeadline) ?? route.title,
                subtitle: route.subtitle,
                bodyText: snapshot.text(for: .photoSummary) ?? route.bodyText,
                accentLabel: snapshot.text(for: .photoTranslationLabel) ?? route.accentLabel
            )
        case "text-details":
            return NewsRoute(
                id: route.id,
                cardID: route.cardID,
                destinationID: route.destinationID,
                title: snapshot.text(for: .textCategoryTitle) ?? route.title,
                subtitle: route.subtitle,
                bodyText: snapshot.text(for: .textHeadline) ?? route.bodyText,
                accentLabel: route.accentLabel
            )
        default:
            return route
        }
    }

    func translateCard(
        _ card: NewsFeedCard,
        targetLanguage: OnDeviceLanguage
    ) async throws {
        let payload = card.translationPayload
        guard !payload.isEmpty else {
            return
        }

        let request = payload.makeRequest(
            sourceLanguage: OnDeviceLanguage(localeIdentifier: AppLocalization.preferredLocaleIdentifier),
            targetLanguage: targetLanguage
        )
        let result = try await onDeviceAIManager.translate(request)
        let snapshot = NewsFeedCardTranslationPayload.snapshot(
            cardID: card.id,
            targetLanguageIdentifier: targetLanguage.localeIdentifier,
            result: result
        )
        cardTranslationStore.save(snapshot)
        state = Self.resolvedState(for: state.content)
    }

    func performTranslation(
        for card: NewsFeedCard,
        targetLanguage: OnDeviceLanguage
    ) async {
        guard !translatingCardIDs.contains(card.id) else {
            return
        }

        translatingCardIDs.insert(card.id)
        defer { translatingCardIDs.remove(card.id) }

        do {
            try await translateCard(card, targetLanguage: targetLanguage)
        } catch is CancellationError {
            return
        } catch {
            _ = await cardActionFailureMessage(for: error, feature: "translation")
        }
    }

    func restoreOriginalCardText(cardID: String) {
        cardTranslationStore.remove(cardID: cardID)
        state = Self.resolvedState(for: state.content)
    }

    func handleLocalChannelCardsChanged() {
        state = Self.resolvedState(for: state.content)
    }

    /// Whether a feed refresh is currently running.
    var isLoading: Bool {
        state.isLoading
    }

    /// User-facing error message shown when a refresh fails.
    var errorMessage: String? {
        state.errorMessage
    }

    /// Whether the active query produced no matches inside the current channel.
    var showsNoSearchResults: Bool {
        isSearchPresented &&
            !trimmedSearchQuery.isEmpty &&
            visibleContent.cards.isEmpty &&
            !state.content.cards.isEmpty
    }

    /// Starts a user-driven refresh when no feed request is already running.
    /// Online refresh goes through the API path; offline refresh keeps the stored snapshot and updates the UI source metadata.
    func refresh() {
        syncSharedLocalCardsIfNeeded()
        load(using: .refresh)
    }

    /// Retries feed loading only after a visible failed state.
    func retry() {
        load(using: .retry)
    }

    /// Opens or closes the current-channel search UI.
    func toggleSearchPresentation() {
        isSearchPresented.toggle()
        if !isSearchPresented {
            searchQuery = ""
        }
    }

    /// Handles a user intent emitted by a featured article card in the visible feed.
    func handlePhotoAction(
        articleID: String,
        action: PhotoCardAction
    ) {
        switch photoActionStartDecision(for: action, articleID: articleID) {
        case .start:
            break
        case .queue:
            photoActionCoordinator.queueAdditiveAction(for: articleID)
            return
        case .ignore:
            return
        }

        switch action {
        case .toggleLike:
            startPhotoLikeTask(for: articleID)
        case .addComment:
            startPhotoCommentTask(for: articleID)
        case let .setDisplayMode(displayMode):
            startPhotoDisplayModeTask(displayMode, for: articleID)
        case .refreshContent:
            startPhotoRefreshTask(for: articleID)
        case .runLongTask:
            startPhotoUpdateTask(for: articleID)
        }
    }

    /// Handles a user intent emitted by a discussion card in the visible feed.
    func handleTextAction(
        discussionID: String,
        action: TextCardAction
    ) {
        switch discussionActionStartDecision(for: action, discussionID: discussionID) {
        case .start:
            break
        case .queue:
            discussionActionCoordinator.queueAdditiveAction(for: discussionID)
            return
        case .ignore:
            return
        }

        switch action {
        case .toggleParticipation:
            startTextParticipationTask(for: discussionID)
        case .addReply:
            startTextReplyTask(for: discussionID)
        case let .setDisplayMode(displayMode):
            startTextDisplayModeTask(displayMode, for: discussionID)
        case .refreshContent:
            startTextRefreshTask(for: discussionID)
        case .runLongTask:
            startTextUpdateTask(for: discussionID)
        }
    }

    /// Cancels the current feed refresh and clears the loading state.
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        cancelCardActionTasks()

        if case let .loading(content) = state {
            state = Self.resolvedState(for: content)
        }
    }

    /// Cleans up any in-flight resources before release.
    deinit {
        MainActor.assumeIsolated {
            loadingTask?.cancel()
        }
    }

    /// Applies freshly loaded feed content to published state and side effects.
    ///
    /// Any in-flight card actions are cancelled because the screen now has a newer persisted
    /// snapshot and stale per-card tasks should no longer write back into the visible list.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        cancelCardActionTasks()
        state = Self.resolvedState(for: content)
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    ///
    /// This is a feed-level failure path. Card-level inline errors use a different policy and
    /// intentionally keep the surrounding feed snapshot visible.
    private func applyLoadFailureState(message: String? = nil) {
        cancelCardActionTasks()
        state = .failed(content: loadFailureContent, message: message ?? loadFailureMessage)
        widgetContentSyncManager.syncFeed(content: loadFailureContent)
    }

    private func cancelCardActionTasks() {
        cancelPhotoTasks()
        cancelTextTasks()
    }

    /// Applies load policy guards and starts a new request when the transition is allowed.
    ///
    /// Initial load, retry and manual refresh intentionally share the same execution path so
    /// the screen always converges through repository-backed state instead of branching into
    /// separate ad-hoc loaders.
    private func load(using policy: NewsFeedLoadPolicy) {
        guard currentChannelID != nil else {
            setEmptyState()
            return
        }

        guard shouldStartLoad(for: policy) else {
            return
        }

        if case .initial = policy {
            loadingTask?.cancel()
        }

        state = .loading(content)
        loadingTask = makeLoadingTask()
    }

    /// Re-resolves the persisted bootstrap snapshot for a newly selected channel before refreshing.
    func handleSelectedChannelChange() {
        cancelLoading()
        searchQuery = ""
        isSearchPresented = false

        guard let channelID = currentChannelID else {
            setEmptyState()
            return
        }

        if let persistedContent = try? repository.currentNewsFeedContent(channelID: channelID) {
            state = .loading(persistedContent)
        } else {
            state = .loading(Self.emptyContent)
        }

        load(using: .initial)
    }

    func syncSharedLocalCardsIfNeeded() {
        guard let sharedLocalFeedCardSyncManager else {
            return
        }

        do {
            let importedCount = try sharedLocalFeedCardSyncManager.syncPendingCards(into: localFeedCardStore)
            guard importedCount > 0 else {
                return
            }

            handleLocalChannelCardsChanged()
        } catch {
            Task { @MainActor [errorManager] in
                _ = await errorManager.presentableError(
                    from: error,
                    context: AppErrorContext(
                        operation: "syncSharedLocalCards",
                        feature: "newsFeed"
                    )
                )
            }
        }
    }

    private func setEmptyState() {
        state = .empty(Self.emptyContent)
    }

    /// Maps repository-backed content into the explicit feed state used by the screen.
    private static func resolvedState(for content: NewsFeedContent) -> NewsFeedState {
        if content.cards.isEmpty {
            return .empty(content)
        }

        if case .cached(_, .offline) = content.availability {
            return .offline(content)
        }

        return .content(content)
    }

    /// Current search query normalized for UI decisions.
    private var trimmedSearchQuery: String {
        searchQuery.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Filters visible cards and ranks matches by field priority.
    private func filteredCards(
        from cards: [NewsFeedCard],
        query: String
    ) -> [NewsFeedCard] {
        let tokens = normalizedSearchTokens(from: query)
        guard !tokens.isEmpty else {
            return cards
        }

        return cards.enumerated()
            .compactMap { element -> (card: NewsFeedCard, score: Int, index: Int)? in
                let (index, card) = element

                guard let score = searchScore(for: card, tokens: tokens) else {
                    return nil
                }

                return (card: card, score: score, index: index)
            }
            .sorted {
                if $0.score == $1.score {
                    return $0.index < $1.index
                }

                return $0.score > $1.score
            }
            .map(\.card)
    }

    /// Splits one free-text query into normalized tokens.
    private func normalizedSearchTokens(from query: String) -> [String] {
        query
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .split(whereSeparator: \.isWhitespace)
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    /// Returns the best search score for one card or `nil` when the card does not match.
    private func searchScore(
        for card: NewsFeedCard,
        tokens: [String]
    ) -> Int? {
        prioritizedSearchScore(tokens: tokens, fields: card.searchFields)
    }

    /// Chooses the highest-priority field that contains all query tokens.
    private func prioritizedSearchScore(
        tokens: [String],
        fields: [NewsFeedCardSearchField]
    ) -> Int? {
        for field in fields {
            let normalizedField = field.value.folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )
            if tokens.allSatisfy({ normalizedField.contains($0) }) {
                return field.priority
            }
        }

        return nil
    }

    /// Empty feed content used when the selected channel has no persisted snapshot yet.
    private static let emptyContent = NewsFeedContent(
        cards: [],
        availability: .live
    )

    /// Starts an optimistic like toggle and then persists the new state through the repository path.
    ///
    /// Lightweight actions apply an optimistic screen update first and rely on the failure
    /// policy to rollback to the previous persisted snapshot if the repository rejects them.
    private func startPhotoLikeTask(for articleID: String) {
        guard canStartPhotoAction(for: articleID) else {
            return
        }

        let previousArticle = photoCard(withID: articleID)

        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: !$0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .liking,
                    inlineStatusMessage: nil
                )
            }
        }

        photoActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performPhotoAction(
                    articleID: articleID,
                    action: .toggleLike
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishPhotoAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: updatedArticle.uiState.isLiked
                            ? AppLocalization.text("news.photo.status.liked")
                            : AppLocalization.text("news.photo.status.unliked")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handlePhotoFailure(
                    action: .toggleLike,
                    articleID: articleID,
                    previousArticle: previousArticle,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Starts the additive comment action for one article.
    ///
    /// Comments are intentionally not optimistic inserts. The UI shows a loader and increments
    /// the persisted count only after the repository returns the updated card snapshot.
    private func startPhotoCommentTask(for articleID: String) {
        guard canStartPhotoAction(for: articleID) else { return }

        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .addingComment,
                    inlineStatusMessage: nil
                )
            }
        }

        photoActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                while true {
                    let updatedArticle = try await self.repository.performPhotoAction(
                        articleID: articleID,
                        action: .addComment
                    )
                    try Task.checkCancellation()

                    let hasMoreQueuedComments = await MainActor.run {
                        self.applyPhotoQueuedCommentProgress(
                            updatedArticle,
                            articleID: articleID
                        )
                    }

                    if !hasMoreQueuedComments {
                        await MainActor.run {
                            self.finishPhotoAction(
                                updatedArticle,
                                articleID: articleID,
                                statusMessage: AppLocalization.text("news.photo.status.commented")
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handlePhotoFailure(
                    action: .addComment,
                    articleID: articleID,
                    previousArticle: nil,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Persists a display-mode preference for one article.
    ///
    /// The active layout is updated optimistically because the local persisted preference is
    /// owned by the app and does not require server-side reconciliation yet.
    private func startPhotoDisplayModeTask(
        _ displayMode: PhotoCardDisplayMode,
        for articleID: String
    ) {
        guard let currentArticle = photoCard(withID: articleID),
              !currentArticle.uiState.blocksActions else { return }

        let previousArticle = currentArticle
        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: displayMode,
                    pendingOperation: .updatingDisplayMode,
                    inlineStatusMessage: nil
                )
            }
        }

        photoActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performPhotoAction(
                    articleID: articleID,
                    action: .setDisplayMode(displayMode)
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishPhotoAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: nil
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handlePhotoFailure(
                    action: .setDisplayMode(displayMode),
                    articleID: articleID,
                    previousArticle: previousArticle,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Starts a targeted content refresh for one article card.
    ///
    /// This is a non-optimistic operation: the current visible content stays on screen until a
    /// fresh repository snapshot arrives.
    private func startPhotoRefreshTask(for articleID: String) {
        guard canStartPhotoAction(for: articleID) else {
            return
        }

        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .refreshingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        photoActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performPhotoAction(
                    articleID: articleID,
                    action: .refreshContent
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishPhotoAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: AppLocalization.text("news.photo.status.refreshed")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handlePhotoFailure(
                    action: .refreshContent,
                    articleID: articleID,
                    previousArticle: nil,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Starts a simulated long-running article update and replaces the card content on success.
    private func startPhotoUpdateTask(for articleID: String) {
        guard canStartPhotoAction(for: articleID) else {
            return
        }

        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .updatingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        photoActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performPhotoAction(
                    articleID: articleID,
                    action: .runLongTask
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishPhotoAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: AppLocalization.text("news.photo.status.updated")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handlePhotoFailure(
                    action: .runLongTask,
                    articleID: articleID,
                    previousArticle: nil,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Replaces the visible featured article with the latest persisted snapshot.
    private func finishPhotoAction(
        _ updatedArticle: PhotoCardModel,
        articleID: String,
        statusMessage: String?
    ) {
        photoActionCoordinator.clear(cardID: articleID)
        updatePhoto(articleID: articleID) { _ in
            updatedArticle.updatingUIState { _ in
                PhotoCardUIState(
                    isLiked: updatedArticle.uiState.isLiked,
                    displayMode: updatedArticle.uiState.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: statusMessage
                )
            }
        }
    }

    /// Marks one featured article action as failed without destroying its persisted content.
    private func failPhotoAction(
        articleID: String,
        message: String
    ) {
        photoActionCoordinator.clear(cardID: articleID)
        updatePhoto(articleID: articleID) { article in
            article.updatingUIState {
                PhotoCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: message
                )
            }
        }
    }

    /// Restores the previous article snapshot after a failed optimistic action.
    private func rollbackPhoto(
        articleID: String,
        previousArticle: PhotoCardModel?
    ) {
        rollbackPhoto(
            articleID: articleID,
            previousArticle: previousArticle,
            message: genericCardActionFailureMessage
        )
    }

    /// Restores the previous article snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackPhoto(
        articleID: String,
        previousArticle: PhotoCardModel?,
        message: String
    ) {
        photoActionCoordinator.clear(cardID: articleID)
        guard let previousArticle else {
            return
        }

        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case .photo(.remote) = $0, $0.id == articleID else {
                        return $0
                    }
                    return .photo(.remote(
                        previousArticle.updatingUIState {
                            PhotoCardUIState(
                                isLiked: $0.isLiked,
                                displayMode: $0.displayMode,
                                pendingOperation: nil,
                                inlineStatusMessage: message
                            )
                        }
                    ))
                },
                availability: content.availability
            )
        }
    }

    /// Updates one featured article card inside the currently visible feed content.
    private func updatePhoto(
        articleID: String,
        transform: (PhotoCardModel) -> PhotoCardModel
    ) {
        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case let .photo(.remote(article)) = $0, article.id == articleID else {
                        return $0
                    }
                    return .photo(.remote(transform(article)))
                },
                availability: content.availability
            )
        }
    }

    /// Applies a content transformation while preserving the current screen-state case.
    private func updateVisibleContent(
        _ transform: (NewsFeedContent) -> NewsFeedContent
    ) {
        switch state {
        case let .loading(content):
            state = .loading(transform(content))
        case let .content(content), let .empty(content), let .offline(content):
            let updatedContent = transform(content)
            state = Self.resolvedState(for: updatedContent)
            widgetContentSyncManager.syncFeed(content: updatedContent)
        case let .failed(content, message):
            state = .failed(content: transform(content), message: message)
        }
    }

    /// Returns the visible featured article snapshot for a given identifier.
    private func photoCard(withID articleID: String) -> PhotoCardModel? {
        for card in state.content.cards {
            if case let .photo(.remote(article)) = card, article.id == articleID {
                return article
            }
        }

        return nil
    }

    /// Whether a new card-level action can start for the target article.
    private func canStartPhotoAction(for articleID: String) -> Bool {
        photoCard(withID: articleID)?.uiState.blocksActions == false
    }

    /// Evaluates whether one featured article action should start now, queue behind an additive in-flight action, or be ignored.
    private func photoActionStartDecision(
        for action: PhotoCardAction,
        articleID: String
    ) -> CardActionStartDecision {
        guard let article = photoCard(withID: articleID) else {
            return .ignore
        }

        if case let .setDisplayMode(displayMode) = action,
           article.uiState.displayMode == displayMode {
            return .ignore
        }

        switch action {
        case .addComment where article.uiState.pendingOperation == .addingComment:
            return .queue
        default:
            return article.uiState.blocksActions ? .ignore : .start
        }
    }

    /// Applies one successful intermediate comment result and returns whether another queued request should continue immediately.
    private func applyPhotoQueuedCommentProgress(
        _ updatedArticle: PhotoCardModel,
        articleID: String
    ) -> Bool {
        guard photoActionCoordinator.consumeQueuedAdditiveAction(for: articleID) else {
            return false
        }

        updatePhoto(articleID: articleID) { _ in
            updatedArticle.updatingUIState { _ in
                PhotoCardUIState(
                    isLiked: updatedArticle.uiState.isLiked,
                    displayMode: updatedArticle.uiState.displayMode,
                    pendingOperation: .addingComment,
                    inlineStatusMessage: nil
                )
            }
        }
        return true
    }

    /// Cancels all active card-level tasks and clears the registry.
    private func cancelPhotoTasks() {
        photoActionCoordinator.cancelAll()
    }

    /// Resolves the rollback/preserve policy for a failed featured article action and applies it to the visible card.
    private func handlePhotoFailure(
        action: PhotoCardAction,
        articleID: String,
        previousArticle: PhotoCardModel?,
        error: Error
    ) async {
        let policy = await photoFailurePolicy(for: action, error: error)
        switch policy.resolution {
        case .rollback:
            rollbackPhoto(
                articleID: articleID,
                previousArticle: previousArticle,
                message: policy.message
            )
        case .preserveVisibleSnapshot:
            failPhotoAction(articleID: articleID, message: policy.message)
        }
    }

    /// Determines how featured article UI should recover from a repository/network failure.
    private func photoFailurePolicy(
        for action: PhotoCardAction,
        error: Error
    ) async -> CardActionFailurePolicy {
        let fallbackMessage = await cardActionFailureMessage(for: error, feature: "photo")
        switch action {
        case .toggleLike, .setDisplayMode:
            return CardActionFailurePolicy(resolution: .rollback, message: fallbackMessage)
        case .addComment, .refreshContent, .runLongTask:
            return CardActionFailurePolicy(resolution: .preserveVisibleSnapshot, message: fallbackMessage)
        }
    }

    /// Starts an optimistic participation toggle for one discussion card.
    private func startTextParticipationTask(for discussionID: String) {
        guard canStartTextAction(for: discussionID) else {
            return
        }

        let previousDiscussion = discussion(withID: discussionID)
        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: !$0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: .togglingParticipation,
                    inlineStatusMessage: nil
                )
            }
        }

        discussionActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedDiscussion = try await self.repository.performTextAction(
                    discussionID: discussionID,
                    action: .toggleParticipation
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishTextAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: updatedDiscussion.uiState.isParticipating
                            ? AppLocalization.text("news.text.status.joined")
                            : AppLocalization.text("news.text.status.left")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleTextFailure(
                    action: .toggleParticipation,
                    discussionID: discussionID,
                    previousDiscussion: previousDiscussion,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Starts the additive reply action for one discussion card.
    ///
    /// Repeated taps are queued and replayed serially so each successful repository call can
    /// increment the stored reply count instead of being cancelled by a later tap.
    private func startTextReplyTask(for discussionID: String) {
        guard canStartTextAction(for: discussionID) else { return }

        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: .addingReply,
                    inlineStatusMessage: nil
                )
            }
        }

        discussionActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                while true {
                    let updatedDiscussion = try await self.repository.performTextAction(
                        discussionID: discussionID,
                        action: .addReply
                    )
                    try Task.checkCancellation()

                    let hasMoreQueuedReplies = await MainActor.run {
                        self.applyTextQueuedReplyProgress(
                            updatedDiscussion,
                            discussionID: discussionID
                        )
                    }

                    if !hasMoreQueuedReplies {
                        await MainActor.run {
                            self.finishTextAction(
                                updatedDiscussion,
                                discussionID: discussionID,
                                statusMessage: AppLocalization.text("news.text.status.replied")
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleTextFailure(
                    action: .addReply,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Persists a display-mode preference for one discussion card.
    private func startTextDisplayModeTask(
        _ displayMode: TextCardDisplayMode,
        for discussionID: String
    ) {
        guard let currentDiscussion = discussion(withID: discussionID),
              !currentDiscussion.uiState.blocksActions else { return }

        let previousDiscussion = currentDiscussion
        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: displayMode,
                    pendingOperation: .updatingDisplayMode,
                    inlineStatusMessage: nil
                )
            }
        }

        discussionActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedDiscussion = try await self.repository.performTextAction(
                    discussionID: discussionID,
                    action: .setDisplayMode(displayMode)
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishTextAction(updatedDiscussion, discussionID: discussionID, statusMessage: nil)
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleTextFailure(
                    action: .setDisplayMode(displayMode),
                    discussionID: discussionID,
                    previousDiscussion: previousDiscussion,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Starts a targeted refresh for one discussion card without replacing visible content first.
    private func startTextRefreshTask(for discussionID: String) {
        guard canStartTextAction(for: discussionID) else {
            return
        }

        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: .refreshingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        discussionActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedDiscussion = try await self.repository.performTextAction(
                    discussionID: discussionID,
                    action: .refreshContent
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishTextAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: AppLocalization.text("news.text.status.refreshed")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleTextFailure(
                    action: .refreshContent,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Starts a simulated long-running discussion update and applies the refreshed card on success.
    private func startTextUpdateTask(for discussionID: String) {
        guard canStartTextAction(for: discussionID) else {
            return
        }

        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: .updatingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        discussionActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedDiscussion = try await self.repository.performTextAction(
                    discussionID: discussionID,
                    action: .runLongTask
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishTextAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: AppLocalization.text("news.text.status.updated")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleTextFailure(
                    action: .runLongTask,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Replaces the visible discussion card with the latest persisted snapshot.
    private func finishTextAction(
        _ updatedDiscussion: TextCardModel,
        discussionID: String,
        statusMessage: String?
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        updateText(discussionID: discussionID) { _ in
            updatedDiscussion.updatingUIState { _ in
                TextCardUIState(
                    isParticipating: updatedDiscussion.uiState.isParticipating,
                    displayMode: updatedDiscussion.uiState.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: statusMessage
                )
            }
        }
    }

    /// Marks one discussion action as failed without destroying its persisted content.
    private func failTextAction(
        discussionID: String,
        message: String
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        updateText(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                TextCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: message
                )
            }
        }
    }

    /// Restores the previous discussion snapshot after a failed optimistic action.
    private func rollbackText(
        discussionID: String,
        previousDiscussion: TextCardModel?
    ) {
        rollbackText(
            discussionID: discussionID,
            previousDiscussion: previousDiscussion,
            message: genericCardActionFailureMessage
        )
    }

    /// Restores the previous discussion snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackText(
        discussionID: String,
        previousDiscussion: TextCardModel?,
        message: String
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        guard let previousDiscussion else {
            return
        }

        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case .text(.remote) = $0, $0.id == discussionID else {
                        return $0
                    }
                    return .text(.remote(
                        previousDiscussion.updatingUIState {
                            TextCardUIState(
                                isParticipating: $0.isParticipating,
                                displayMode: $0.displayMode,
                                pendingOperation: nil,
                                inlineStatusMessage: message
                            )
                        }
                    ))
                },
                availability: content.availability
            )
        }
    }

    /// Updates one discussion card inside the currently visible feed content.
    private func updateText(
        discussionID: String,
        transform: (TextCardModel) -> TextCardModel
    ) {
        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case let .text(.remote(discussion)) = $0, discussion.id == discussionID else {
                        return $0
                    }
                    return .text(.remote(transform(discussion)))
                },
                availability: content.availability
            )
        }
    }

    /// Returns the visible discussion snapshot for a given identifier.
    private func discussion(withID discussionID: String) -> TextCardModel? {
        for card in state.content.cards {
            if case let .text(.remote(discussion)) = card, discussion.id == discussionID {
                return discussion
            }
        }

        return nil
    }

    /// Whether a new card-level action can start for the target discussion.
    private func canStartTextAction(for discussionID: String) -> Bool {
        discussion(withID: discussionID)?.uiState.blocksActions == false
    }

    /// Evaluates whether one discussion action should start now, queue behind an additive in-flight action, or be ignored.
    private func discussionActionStartDecision(
        for action: TextCardAction,
        discussionID: String
    ) -> CardActionStartDecision {
        guard let discussion = discussion(withID: discussionID) else {
            return .ignore
        }

        if case let .setDisplayMode(displayMode) = action,
           discussion.uiState.displayMode == displayMode {
            return .ignore
        }

        switch action {
        case .addReply where discussion.uiState.pendingOperation == .addingReply:
            return .queue
        default:
            return discussion.uiState.blocksActions ? .ignore : .start
        }
    }

    /// Applies one successful intermediate reply result and returns whether another queued request should continue immediately.
    private func applyTextQueuedReplyProgress(
        _ updatedDiscussion: TextCardModel,
        discussionID: String
    ) -> Bool {
        guard discussionActionCoordinator.consumeQueuedAdditiveAction(for: discussionID) else {
            return false
        }

        updateText(discussionID: discussionID) { _ in
            updatedDiscussion.updatingUIState { _ in
                TextCardUIState(
                    isParticipating: updatedDiscussion.uiState.isParticipating,
                    displayMode: updatedDiscussion.uiState.displayMode,
                    pendingOperation: .addingReply,
                    inlineStatusMessage: nil
                )
            }
        }
        return true
    }

    /// Cancels all active discussion tasks and clears the registry.
    private func cancelTextTasks() {
        discussionActionCoordinator.cancelAll()
    }

    /// Resolves the rollback/preserve policy for a failed discussion action and applies it to the visible card.
    private func handleTextFailure(
        action: TextCardAction,
        discussionID: String,
        previousDiscussion: TextCardModel?,
        error: Error
    ) async {
        let policy = await discussionFailurePolicy(for: action, error: error)
        switch policy.resolution {
        case .rollback:
            rollbackText(
                discussionID: discussionID,
                previousDiscussion: previousDiscussion,
                message: policy.message
            )
        case .preserveVisibleSnapshot:
            failTextAction(discussionID: discussionID, message: policy.message)
        }
    }

    /// Determines how discussion UI should recover from a repository/network failure.
    private func discussionFailurePolicy(
        for action: TextCardAction,
        error: Error
    ) async -> CardActionFailurePolicy {
        let fallbackMessage = await cardActionFailureMessage(for: error, feature: "text")
        switch action {
        case .toggleParticipation, .setDisplayMode:
            return CardActionFailurePolicy(resolution: .rollback, message: fallbackMessage)
        case .addReply, .refreshContent, .runLongTask:
            return CardActionFailurePolicy(resolution: .preserveVisibleSnapshot, message: fallbackMessage)
        }
    }

    /// Maps repository/network failures into stable user-facing card status text.
    private func cardActionFailureMessage(
        for error: Error,
        feature: String
    ) async -> String {
        if let repositoryError = error as? RepositoryError {
            return repositoryCardActionFailureMessage(for: repositoryError)
        }

        let presentation = await errorManager.presentableError(
            from: error,
            context: AppErrorContext(
                operation: "cardAction",
                feature: feature
            )
        )

        return presentation.userMessage
    }

    /// Preserves explicit product messaging for repository-defined offline and stale-card policies.
    private func repositoryCardActionFailureMessage(for repositoryError: RepositoryError) -> String {
        switch repositoryError {
        case .offlineCardAction:
            return AppLocalization.text("news.card.status.offline")
        case .missingPersistedFeedCard:
            return AppLocalization.text("news.card.status.stale")
        case .missingChannel, .missingPersistedFeed, .unsupportedCardAction, .unsupportedLocalFeedCardPersistence:
            return genericCardActionFailureMessage
        }
    }

    /// Shared fallback used when a card action fails without a more specific product policy.
    private var genericCardActionFailureMessage: String {
        AppLocalization.text("news.card.status.failed")
    }

    /// Evaluates whether the requested load policy is valid in the current runtime state.
    private func shouldStartLoad(for policy: NewsFeedLoadPolicy) -> Bool {
        switch policy {
        case .initial:
            return true
        case .refresh:
            return !isLoading
        case .retry:
            guard !isLoading else {
                return false
            }

            if case .failed = state {
                return true
            }

            return false
        }
    }

    /// Creates the async task that resolves repository content into published state.
    private func makeLoadingTask() -> Task<Void, Never> {
        Task { [weak self] in
            guard let self else {
                return
            }

            do {
                guard let channelID = currentChannelID else {
                    await MainActor.run {
                        self.setEmptyState()
                    }
                    return
                }

                let content = try await repository.refreshNewsFeedContent(channelID: channelID)
                guard !Task.isCancelled else {
                    return
                }
                self.applyLoadedContent(content)
            } catch is CancellationError {
                return
            } catch {
                let failureMessage = await self.feedLoadFailureMessage(for: error)
                self.applyLoadFailureState(message: failureMessage)
            }
        }
    }

    /// Maps feed-level refresh failures through the shared app error manager while preserving the local fallback copy.
    private func feedLoadFailureMessage(for error: Error) async -> String {
        if error is RepositoryError {
            return loadFailureMessage
        }

        let presentation = await errorManager.presentableError(
            from: error,
            context: AppErrorContext(
                operation: "refreshFeed",
                feature: "newsFeed"
            )
        )
        return presentation.userMessage
    }

    /// Currently selected channel identifier used for feed queries.
    private var currentChannelID: String? {
        channelsStore.selectionSnapshot.selectedChannelID ?? channelsStore.selectionSnapshot.selectedChannel?.id
    }
}
