import Combine
import Foundation
import TchopErrors

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
final class NewsFeedViewModel: ObservableObject {
    /// Explicit screen state used by the news feed UI.
    @Published private(set) var state: NewsFeedState

    /// Current free-text search query applied to cards from the selected channel only.
    @Published var searchQuery: String = ""

    /// Whether the search field for the current channel is currently visible.
    @Published private(set) var isSearchPresented: Bool = false

    private let repository: any NewsFeedRepository
    private let channelsStore: ChannelsStore
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let errorManager: any AppErrorManaging
    private let loadFailureContent: NewsFeedContent
    private let loadFailureMessage: String
    private var loadingTask: Task<Void, Never>?
    private var storeBindings: Set<AnyCancellable> = []
    /// Serializes article actions and queues additive taps per visible card.
    private let featuredArticleActionCoordinator = NewsFeedCardActionCoordinator()
    /// Serializes discussion actions and queues additive taps per visible card.
    private let discussionActionCoordinator = NewsFeedCardActionCoordinator()

    /// Creates the feed view model and immediately starts the first load.
    init(
        repository: any NewsFeedRepository,
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        initialContent: NewsFeedContent,
        loadFailureContent: NewsFeedContent,
        loadFailureMessage: String
    ) {
        self.repository = repository
        self.channelsStore = channelsStore
        self.widgetContentSyncManager = widgetContentSyncManager
        self.errorManager = errorManager
        self.state = Self.resolvedState(for: initialContent)
        self.loadFailureContent = loadFailureContent
        self.loadFailureMessage = loadFailureMessage
        widgetContentSyncManager.syncFeed(content: initialContent)
        setupChannelBindings()
        load(using: .initial)
    }

    /// Current feed content shown by the news screen.
    var content: NewsFeedContent {
        state.content
    }

    /// Feed content visible after applying the current channel-local search query.
    var visibleContent: NewsFeedContent {
        NewsFeedContent(
            cards: filteredCards(from: state.content.cards, query: searchQuery),
            availability: state.content.availability
        )
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
        load(using: .refresh)
    }

    /// Retries feed loading only after a visible failed state.
    func retry() {
        load(using: .retry)
    }

    /// Opens or closes the current-channel search UI.
    func toggleSearchPresentation() {
        if isSearchPresented {
            isSearchPresented = false
            searchQuery = ""
        } else {
            isSearchPresented = true
        }
    }

    /// Handles a user intent emitted by a featured article card in the visible feed.
    func handleFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) {
        switch featuredArticleActionStartDecision(for: action, articleID: articleID) {
        case .start:
            break
        case .queue:
            featuredArticleActionCoordinator.queueAdditiveAction(for: articleID)
            return
        case .ignore:
            return
        }

        switch action {
        case .toggleLike:
            startFeaturedArticleLikeTask(for: articleID)
        case .addComment:
            startFeaturedArticleCommentTask(for: articleID)
        case let .setDisplayMode(displayMode):
            startFeaturedArticleDisplayModeTask(displayMode, for: articleID)
        case .refreshContent:
            startFeaturedArticleRefreshTask(for: articleID)
        case .runLongTask:
            startFeaturedArticleUpdateTask(for: articleID)
        }
    }

    /// Handles a user intent emitted by a discussion card in the visible feed.
    func handleDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction
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
            startDiscussionParticipationTask(for: discussionID)
        case .addReply:
            startDiscussionReplyTask(for: discussionID)
        case let .setDisplayMode(displayMode):
            startDiscussionDisplayModeTask(displayMode, for: discussionID)
        case .refreshContent:
            startDiscussionRefreshTask(for: discussionID)
        case .runLongTask:
            startDiscussionUpdateTask(for: discussionID)
        }
    }

    /// Cancels the current feed refresh and clears the loading state.
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        cancelFeaturedArticleTasks()
        cancelDiscussionTasks()

        if case let .loading(content) = state {
            state = Self.resolvedState(for: content)
        }
    }

    /// Cleans up any in-flight resources before release.
    deinit {
        loadingTask?.cancel()
    }

    /// Applies freshly loaded feed content to published state and side effects.
    ///
    /// Any in-flight card actions are cancelled because the screen now has a newer persisted
    /// snapshot and stale per-card tasks should no longer write back into the visible list.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        cancelFeaturedArticleTasks()
        cancelDiscussionTasks()
        state = Self.resolvedState(for: content)
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    ///
    /// This is a feed-level failure path. Card-level inline errors use a different policy and
    /// intentionally keep the surrounding feed snapshot visible.
    private func applyLoadFailureState(message: String? = nil) {
        cancelFeaturedArticleTasks()
        cancelDiscussionTasks()
        state = .failed(content: loadFailureContent, message: message ?? loadFailureMessage)
        widgetContentSyncManager.syncFeed(content: loadFailureContent)
    }

    /// Applies load policy guards and starts a new request when the transition is allowed.
    ///
    /// Initial load, retry and manual refresh intentionally share the same execution path so
    /// the screen always converges through repository-backed state instead of branching into
    /// separate ad-hoc loaders.
    private func load(using policy: NewsFeedLoadPolicy) {
        guard currentChannelID != nil else {
            state = .empty(
                NewsFeedContent(
                    cards: [],
                    availability: .live
                )
            )
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

    /// Observes app-wide selected-channel changes and reloads the visible feed against the new context.
    private func setupChannelBindings() {
        channelsStore.$selectedChannelID
            .removeDuplicates()
            .dropFirst()
            .sink { [weak self] _ in
                self?.handleSelectedChannelChange()
            }
            .store(in: &storeBindings)
    }

    /// Re-resolves the persisted bootstrap snapshot for a newly selected channel before refreshing.
    private func handleSelectedChannelChange() {
        cancelLoading()
        searchQuery = ""
        isSearchPresented = false

        guard let channelID = currentChannelID else {
            state = .empty(
                NewsFeedContent(
                    cards: [],
                    availability: .live
                )
            )
            return
        }

        if let persistedContent = (try? repository.currentNewsFeedContent(channelID: channelID)) ?? nil {
            state = .loading(persistedContent)
        } else {
            state = .loading(Self.emptyContent)
        }

        load(using: .initial)
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
            .compactMap { index, card in
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
        switch card {
        case let .featuredArticle(article):
            return prioritizedSearchScore(
                tokens: tokens,
                fields: [
                    (500, article.headline),
                    (400, article.summary),
                    (300, article.sourceTitle),
                    (250, article.brandTitle),
                    (200, article.metadataLine),
                    (150, article.translationLabel)
                ]
            )
        case let .discussion(discussion):
            return prioritizedSearchScore(
                tokens: tokens,
                fields: [
                    (500, discussion.headline),
                    (300, discussion.categoryTitle),
                    (120, discussion.participants.map(\.initials).joined(separator: " "))
                ]
            )
        }
    }

    /// Chooses the highest-priority field that contains all query tokens.
    private func prioritizedSearchScore(
        tokens: [String],
        fields: [(Int, String)]
    ) -> Int? {
        for (score, field) in fields {
            let normalizedField = field.folding(
                options: [.diacriticInsensitive, .caseInsensitive],
                locale: .current
            )
            if tokens.allSatisfy({ normalizedField.contains($0) }) {
                return score
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
    private func startFeaturedArticleLikeTask(for articleID: String) {
        guard canStartFeaturedArticleAction(for: articleID) else {
            return
        }

        let previousArticle = featuredArticle(withID: articleID)

        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: !$0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .liking,
                    inlineStatusMessage: nil
                )
            }
        }

        featuredArticleActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performFeaturedArticleAction(
                    articleID: articleID,
                    action: .toggleLike
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishFeaturedArticleAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: updatedArticle.uiState.isLiked
                            ? AppLocalization.text("news.featured.status.liked")
                            : AppLocalization.text("news.featured.status.unliked")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleFeaturedArticleFailure(
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
    private func startFeaturedArticleCommentTask(for articleID: String) {
        guard canStartFeaturedArticleAction(for: articleID) else { return }

        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .addingComment,
                    inlineStatusMessage: nil
                )
            }
        }

        featuredArticleActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                while true {
                    let updatedArticle = try await self.repository.performFeaturedArticleAction(
                        articleID: articleID,
                        action: .addComment
                    )
                    try Task.checkCancellation()

                    let hasMoreQueuedComments = await MainActor.run {
                        self.applyFeaturedArticleQueuedCommentProgress(
                            updatedArticle,
                            articleID: articleID
                        )
                    }

                    if !hasMoreQueuedComments {
                        await MainActor.run {
                            self.finishFeaturedArticleAction(
                                updatedArticle,
                                articleID: articleID,
                                statusMessage: AppLocalization.text("news.featured.status.commented")
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleFeaturedArticleFailure(
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
    private func startFeaturedArticleDisplayModeTask(
        _ displayMode: FeaturedArticleCardDisplayMode,
        for articleID: String
    ) {
        guard let currentArticle = featuredArticle(withID: articleID),
              !currentArticle.uiState.blocksActions else { return }

        let previousArticle = currentArticle
        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: displayMode,
                    pendingOperation: .updatingDisplayMode,
                    inlineStatusMessage: nil
                )
            }
        }

        featuredArticleActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performFeaturedArticleAction(
                    articleID: articleID,
                    action: .setDisplayMode(displayMode)
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishFeaturedArticleAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: nil
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleFeaturedArticleFailure(
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
    private func startFeaturedArticleRefreshTask(for articleID: String) {
        guard canStartFeaturedArticleAction(for: articleID) else {
            return
        }

        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .refreshingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        featuredArticleActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performFeaturedArticleAction(
                    articleID: articleID,
                    action: .refreshContent
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishFeaturedArticleAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: AppLocalization.text("news.featured.status.refreshed")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleFeaturedArticleFailure(
                    action: .refreshContent,
                    articleID: articleID,
                    previousArticle: nil,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Starts a simulated long-running article update and replaces the card content on success.
    private func startFeaturedArticleUpdateTask(for articleID: String) {
        guard canStartFeaturedArticleAction(for: articleID) else {
            return
        }

        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: .updatingContent,
                    inlineStatusMessage: nil
                )
            }
        }

        featuredArticleActionCoordinator.start(Task { [weak self] in
            do {
                guard let self else {
                    return
                }
                let updatedArticle = try await self.repository.performFeaturedArticleAction(
                    articleID: articleID,
                    action: .runLongTask
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishFeaturedArticleAction(
                        updatedArticle,
                        articleID: articleID,
                        statusMessage: AppLocalization.text("news.featured.status.updated")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleFeaturedArticleFailure(
                    action: .runLongTask,
                    articleID: articleID,
                    previousArticle: nil,
                    error: error
                )
            }
        }, for: articleID)
    }

    /// Replaces the visible featured article with the latest persisted snapshot.
    private func finishFeaturedArticleAction(
        _ updatedArticle: FeaturedArticleCardModel,
        articleID: String,
        statusMessage: String?
    ) {
        featuredArticleActionCoordinator.clear(cardID: articleID)
        updateFeaturedArticle(articleID: articleID) { _ in
            updatedArticle.updatingUIState { _ in
                FeaturedArticleCardUIState(
                    isLiked: updatedArticle.uiState.isLiked,
                    displayMode: updatedArticle.uiState.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: statusMessage
                )
            }
        }
    }

    /// Marks one featured article action as failed without destroying its persisted content.
    private func failFeaturedArticleAction(
        articleID: String,
        message: String
    ) {
        featuredArticleActionCoordinator.clear(cardID: articleID)
        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: message
                )
            }
        }
    }

    /// Restores the previous article snapshot after a failed optimistic action.
    private func rollbackFeaturedArticle(
        articleID: String,
        previousArticle: FeaturedArticleCardModel?
    ) {
        rollbackFeaturedArticle(
            articleID: articleID,
            previousArticle: previousArticle,
            message: genericCardActionFailureMessage
        )
    }

    /// Restores the previous article snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackFeaturedArticle(
        articleID: String,
        previousArticle: FeaturedArticleCardModel?,
        message: String
    ) {
        featuredArticleActionCoordinator.clear(cardID: articleID)
        guard let previousArticle else {
            return
        }

        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case .featuredArticle = $0, $0.id == articleID else {
                        return $0
                    }
                    return .featuredArticle(
                        previousArticle.updatingUIState {
                            FeaturedArticleCardUIState(
                                isLiked: $0.isLiked,
                                displayMode: $0.displayMode,
                                pendingOperation: nil,
                                inlineStatusMessage: message
                            )
                        }
                    )
                },
                availability: content.availability
            )
        }
    }

    /// Updates one featured article card inside the currently visible feed content.
    private func updateFeaturedArticle(
        articleID: String,
        transform: (FeaturedArticleCardModel) -> FeaturedArticleCardModel
    ) {
        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case let .featuredArticle(article) = $0, article.id == articleID else {
                        return $0
                    }
                    return .featuredArticle(transform(article))
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
    private func featuredArticle(withID articleID: String) -> FeaturedArticleCardModel? {
        for card in state.content.cards {
            if case let .featuredArticle(article) = card, article.id == articleID {
                return article
            }
        }

        return nil
    }

    /// Whether a new card-level action can start for the target article.
    private func canStartFeaturedArticleAction(for articleID: String) -> Bool {
        guard let article = featuredArticle(withID: articleID) else {
            return false
        }

        return !article.uiState.blocksActions
    }

    /// Evaluates whether one featured article action should start now, queue behind an additive in-flight action, or be ignored.
    private func featuredArticleActionStartDecision(
        for action: FeaturedArticleCardAction,
        articleID: String
    ) -> CardActionStartDecision {
        guard let article = featuredArticle(withID: articleID) else {
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
    private func applyFeaturedArticleQueuedCommentProgress(
        _ updatedArticle: FeaturedArticleCardModel,
        articleID: String
    ) -> Bool {
        guard featuredArticleActionCoordinator.consumeQueuedAdditiveAction(for: articleID) else {
            return false
        }

        updateFeaturedArticle(articleID: articleID) { _ in
            updatedArticle.updatingUIState { _ in
                FeaturedArticleCardUIState(
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
    private func cancelFeaturedArticleTasks() {
        featuredArticleActionCoordinator.cancelAll()
    }

    /// Resolves the rollback/preserve policy for a failed featured article action and applies it to the visible card.
    private func handleFeaturedArticleFailure(
        action: FeaturedArticleCardAction,
        articleID: String,
        previousArticle: FeaturedArticleCardModel?,
        error: Error
    ) async {
        let policy = await featuredArticleFailurePolicy(for: action, error: error)
        switch policy.resolution {
        case .rollback:
            rollbackFeaturedArticle(
                articleID: articleID,
                previousArticle: previousArticle,
                message: policy.message
            )
        case .preserveVisibleSnapshot:
            failFeaturedArticleAction(articleID: articleID, message: policy.message)
        }
    }

    /// Determines how featured article UI should recover from a repository/network failure.
    private func featuredArticleFailurePolicy(
        for action: FeaturedArticleCardAction,
        error: Error
    ) async -> CardActionFailurePolicy {
        let fallbackMessage = await cardActionFailureMessage(for: error, feature: "featuredArticle")
        switch action {
        case .toggleLike, .setDisplayMode:
            return CardActionFailurePolicy(resolution: .rollback, message: fallbackMessage)
        case .addComment, .refreshContent, .runLongTask:
            return CardActionFailurePolicy(resolution: .preserveVisibleSnapshot, message: fallbackMessage)
        }
    }

    /// Starts an optimistic participation toggle for one discussion card.
    private func startDiscussionParticipationTask(for discussionID: String) {
        guard canStartDiscussionAction(for: discussionID) else {
            return
        }

        let previousDiscussion = discussion(withID: discussionID)
        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
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
                let updatedDiscussion = try await self.repository.performDiscussionAction(
                    discussionID: discussionID,
                    action: .toggleParticipation
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishDiscussionAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: updatedDiscussion.uiState.isParticipating
                            ? AppLocalization.text("news.discussion.status.joined")
                            : AppLocalization.text("news.discussion.status.left")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleDiscussionFailure(
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
    private func startDiscussionReplyTask(for discussionID: String) {
        guard canStartDiscussionAction(for: discussionID) else { return }

        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
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
                    let updatedDiscussion = try await self.repository.performDiscussionAction(
                        discussionID: discussionID,
                        action: .addReply
                    )
                    try Task.checkCancellation()

                    let hasMoreQueuedReplies = await MainActor.run {
                        self.applyDiscussionQueuedReplyProgress(
                            updatedDiscussion,
                            discussionID: discussionID
                        )
                    }

                    if !hasMoreQueuedReplies {
                        await MainActor.run {
                            self.finishDiscussionAction(
                                updatedDiscussion,
                                discussionID: discussionID,
                                statusMessage: AppLocalization.text("news.discussion.status.replied")
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleDiscussionFailure(
                    action: .addReply,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Persists a display-mode preference for one discussion card.
    private func startDiscussionDisplayModeTask(
        _ displayMode: DiscussionCardDisplayMode,
        for discussionID: String
    ) {
        guard let currentDiscussion = discussion(withID: discussionID),
              !currentDiscussion.uiState.blocksActions else { return }

        let previousDiscussion = currentDiscussion
        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
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
                let updatedDiscussion = try await self.repository.performDiscussionAction(
                    discussionID: discussionID,
                    action: .setDisplayMode(displayMode)
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishDiscussionAction(updatedDiscussion, discussionID: discussionID, statusMessage: nil)
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleDiscussionFailure(
                    action: .setDisplayMode(displayMode),
                    discussionID: discussionID,
                    previousDiscussion: previousDiscussion,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Starts a targeted refresh for one discussion card without replacing visible content first.
    private func startDiscussionRefreshTask(for discussionID: String) {
        guard canStartDiscussionAction(for: discussionID) else {
            return
        }

        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
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
                let updatedDiscussion = try await self.repository.performDiscussionAction(
                    discussionID: discussionID,
                    action: .refreshContent
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishDiscussionAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: AppLocalization.text("news.discussion.status.refreshed")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleDiscussionFailure(
                    action: .refreshContent,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Starts a simulated long-running discussion update and applies the refreshed card on success.
    private func startDiscussionUpdateTask(for discussionID: String) {
        guard canStartDiscussionAction(for: discussionID) else {
            return
        }

        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
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
                let updatedDiscussion = try await self.repository.performDiscussionAction(
                    discussionID: discussionID,
                    action: .runLongTask
                )
                try Task.checkCancellation()
                await MainActor.run {
                    self.finishDiscussionAction(
                        updatedDiscussion,
                        discussionID: discussionID,
                        statusMessage: AppLocalization.text("news.discussion.status.updated")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await self?.handleDiscussionFailure(
                    action: .runLongTask,
                    discussionID: discussionID,
                    previousDiscussion: nil,
                    error: error
                )
            }
        }, for: discussionID)
    }

    /// Replaces the visible discussion card with the latest persisted snapshot.
    private func finishDiscussionAction(
        _ updatedDiscussion: DiscussionCardModel,
        discussionID: String,
        statusMessage: String?
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        updateDiscussion(discussionID: discussionID) { _ in
            updatedDiscussion.updatingUIState { _ in
                DiscussionCardUIState(
                    isParticipating: updatedDiscussion.uiState.isParticipating,
                    displayMode: updatedDiscussion.uiState.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: statusMessage
                )
            }
        }
    }

    /// Marks one discussion action as failed without destroying its persisted content.
    private func failDiscussionAction(
        discussionID: String,
        message: String
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        updateDiscussion(discussionID: discussionID) { discussion in
            discussion.updatingUIState {
                DiscussionCardUIState(
                    isParticipating: $0.isParticipating,
                    displayMode: $0.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: message
                )
            }
        }
    }

    /// Restores the previous discussion snapshot after a failed optimistic action.
    private func rollbackDiscussion(
        discussionID: String,
        previousDiscussion: DiscussionCardModel?
    ) {
        rollbackDiscussion(
            discussionID: discussionID,
            previousDiscussion: previousDiscussion,
            message: genericCardActionFailureMessage
        )
    }

    /// Restores the previous discussion snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackDiscussion(
        discussionID: String,
        previousDiscussion: DiscussionCardModel?,
        message: String
    ) {
        discussionActionCoordinator.clear(cardID: discussionID)
        guard let previousDiscussion else {
            return
        }

        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case .discussion = $0, $0.id == discussionID else {
                        return $0
                    }
                    return .discussion(
                        previousDiscussion.updatingUIState {
                            DiscussionCardUIState(
                                isParticipating: $0.isParticipating,
                                displayMode: $0.displayMode,
                                pendingOperation: nil,
                                inlineStatusMessage: message
                            )
                        }
                    )
                },
                availability: content.availability
            )
        }
    }

    /// Updates one discussion card inside the currently visible feed content.
    private func updateDiscussion(
        discussionID: String,
        transform: (DiscussionCardModel) -> DiscussionCardModel
    ) {
        updateVisibleContent { content in
            NewsFeedContent(
                cards: content.cards.map {
                    guard case let .discussion(discussion) = $0, discussion.id == discussionID else {
                        return $0
                    }
                    return .discussion(transform(discussion))
                },
                availability: content.availability
            )
        }
    }

    /// Returns the visible discussion snapshot for a given identifier.
    private func discussion(withID discussionID: String) -> DiscussionCardModel? {
        for card in state.content.cards {
            if case let .discussion(discussion) = card, discussion.id == discussionID {
                return discussion
            }
        }

        return nil
    }

    /// Whether a new card-level action can start for the target discussion.
    private func canStartDiscussionAction(for discussionID: String) -> Bool {
        guard let discussion = discussion(withID: discussionID) else {
            return false
        }

        return !discussion.uiState.blocksActions
    }

    /// Evaluates whether one discussion action should start now, queue behind an additive in-flight action, or be ignored.
    private func discussionActionStartDecision(
        for action: DiscussionCardAction,
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
    private func applyDiscussionQueuedReplyProgress(
        _ updatedDiscussion: DiscussionCardModel,
        discussionID: String
    ) -> Bool {
        guard discussionActionCoordinator.consumeQueuedAdditiveAction(for: discussionID) else {
            return false
        }

        updateDiscussion(discussionID: discussionID) { _ in
            updatedDiscussion.updatingUIState { _ in
                DiscussionCardUIState(
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
    private func cancelDiscussionTasks() {
        discussionActionCoordinator.cancelAll()
    }

    /// Resolves the rollback/preserve policy for a failed discussion action and applies it to the visible card.
    private func handleDiscussionFailure(
        action: DiscussionCardAction,
        discussionID: String,
        previousDiscussion: DiscussionCardModel?,
        error: Error
    ) async {
        let policy = await discussionFailurePolicy(for: action, error: error)
        switch policy.resolution {
        case .rollback:
            rollbackDiscussion(
                discussionID: discussionID,
                previousDiscussion: previousDiscussion,
                message: policy.message
            )
        case .preserveVisibleSnapshot:
            failDiscussionAction(discussionID: discussionID, message: policy.message)
        }
    }

    /// Determines how discussion UI should recover from a repository/network failure.
    private func discussionFailurePolicy(
        for action: DiscussionCardAction,
        error: Error
    ) async -> CardActionFailurePolicy {
        let fallbackMessage = await cardActionFailureMessage(for: error, feature: "discussion")
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
        case .missingChannel, .missingPersistedFeed:
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
                        self.state = .empty(Self.emptyContent)
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
        channelsStore.selectedChannelID ?? channelsStore.selectedChannel?.id
    }
}
