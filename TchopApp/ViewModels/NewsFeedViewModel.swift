import Foundation

/// Explicit runtime state for the news feed screen.
enum NewsFeedState: Equatable {
    case loading(NewsFeedContent)
    case loaded(NewsFeedContent)
    case failed(content: NewsFeedContent, message: String)

    /// Feed content currently available to the UI.
    var content: NewsFeedContent {
        switch self {
        case let .loading(content):
            return content
        case let .loaded(content):
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

/// View model responsible for loading and exposing the home feed state.
@MainActor
final class NewsFeedViewModel: ObservableObject {
    /// Explicit screen state used by the news feed UI.
    @Published private(set) var state: NewsFeedState

    private let repository: any NewsFeedRepository
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let loadFailureContent: NewsFeedContent
    private let loadFailureMessage: String
    private var loadingTask: Task<Void, Never>?
    private var featuredArticleTasks: [String: Task<Void, Never>] = [:]
    private var discussionTasks: [String: Task<Void, Never>] = [:]
    private var queuedFeaturedArticleComments: [String: Int] = [:]
    private var queuedDiscussionReplies: [String: Int] = [:]

    /// Creates the feed view model and immediately starts the first load.
    init(
        repository: any NewsFeedRepository,
        widgetContentSyncManager: any WidgetContentSyncing,
        initialContent: NewsFeedContent,
        loadFailureContent: NewsFeedContent,
        loadFailureMessage: String
    ) {
        self.repository = repository
        self.widgetContentSyncManager = widgetContentSyncManager
        self.state = .loaded(initialContent)
        self.loadFailureContent = loadFailureContent
        self.loadFailureMessage = loadFailureMessage
        widgetContentSyncManager.syncFeed(content: initialContent)
        load(using: .initial)
    }

    /// Current feed content shown by the news screen.
    var content: NewsFeedContent {
        state.content
    }

    /// Whether a feed refresh is currently running.
    var isLoading: Bool {
        state.isLoading
    }

    /// User-facing error message shown when a refresh fails.
    var errorMessage: String? {
        state.errorMessage
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

    /// Handles a user intent emitted by a featured article card in the visible feed.
    func handleFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) {
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
            state = .loaded(content)
        }
    }

    /// Cleans up any in-flight resources before release.
    deinit {
        loadingTask?.cancel()
        for task in featuredArticleTasks.values {
            task.cancel()
        }
        for task in discussionTasks.values {
            task.cancel()
        }
    }

    /// Applies freshly loaded feed content to published state and side effects.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        cancelFeaturedArticleTasks()
        cancelDiscussionTasks()
        state = .loaded(content)
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    private func applyLoadFailureState() {
        cancelFeaturedArticleTasks()
        cancelDiscussionTasks()
        state = .failed(content: loadFailureContent, message: loadFailureMessage)
        widgetContentSyncManager.syncFeed(content: loadFailureContent)
    }

    /// Applies load policy guards and starts a new request when the transition is allowed.
    private func load(using policy: NewsFeedLoadPolicy) {
        guard shouldStartLoad(for: policy) else {
            return
        }

        if case .initial = policy {
            loadingTask?.cancel()
        }

        state = .loading(content)
        loadingTask = makeLoadingTask()
    }

    /// Starts an optimistic like toggle and then persists the new state through the repository path.
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

        featuredArticleTasks[articleID] = Task { [weak self] in
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
                            ? AppLocalization.text("news.featured.status.liked", fallback: "Reaction saved.")
                            : AppLocalization.text("news.featured.status.unliked", fallback: "Reaction removed.")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleFeaturedArticleFailure(
                        action: .toggleLike,
                        articleID: articleID,
                        previousArticle: previousArticle,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a comment creation task for one featured article.
    private func startFeaturedArticleCommentTask(for articleID: String) {
        if enqueueQueuedFeaturedArticleComment(for: articleID) {
            return
        }

        guard canStartFeaturedArticleAction(for: articleID) else {
            return
        }

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

        featuredArticleTasks[articleID] = Task { [weak self] in
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
                                statusMessage: AppLocalization.text(
                                    "news.featured.status.commented",
                                    fallback: "Comment added."
                                )
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleFeaturedArticleFailure(
                        action: .addComment,
                        articleID: articleID,
                        previousArticle: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Persists a new display mode for one featured article.
    private func startFeaturedArticleDisplayModeTask(
        _ displayMode: FeaturedArticleCardDisplayMode,
        for articleID: String
    ) {
        guard canStartFeaturedArticleAction(for: articleID) else {
            return
        }

        let previousArticle = featuredArticle(withID: articleID)
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

        featuredArticleTasks[articleID] = Task { [weak self] in
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
                await MainActor.run {
                    self?.handleFeaturedArticleFailure(
                        action: .setDisplayMode(displayMode),
                        articleID: articleID,
                        previousArticle: previousArticle,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a refresh task for one featured article.
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

        featuredArticleTasks[articleID] = Task { [weak self] in
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
                        statusMessage: AppLocalization.text(
                            "news.featured.status.refreshed",
                            fallback: "Card refreshed."
                        )
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleFeaturedArticleFailure(
                        action: .refreshContent,
                        articleID: articleID,
                        previousArticle: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a longer update task for one featured article.
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

        featuredArticleTasks[articleID] = Task { [weak self] in
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
                        statusMessage: AppLocalization.text(
                            "news.featured.status.updated",
                            fallback: "Article updated."
                        )
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleFeaturedArticleFailure(
                        action: .runLongTask,
                        articleID: articleID,
                        previousArticle: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Replaces the visible featured article with the latest persisted snapshot.
    private func finishFeaturedArticleAction(
        _ updatedArticle: FeaturedArticleCardModel,
        articleID: String,
        statusMessage: String?
    ) {
        featuredArticleTasks[articleID] = nil
        queuedFeaturedArticleComments[articleID] = nil
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
        featuredArticleTasks[articleID] = nil
        queuedFeaturedArticleComments[articleID] = nil
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
            message: AppLocalization.text(
                "news.featured.status.failed",
                fallback: "Unable to complete this action right now."
            )
        )
    }

    /// Restores the previous article snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackFeaturedArticle(
        articleID: String,
        previousArticle: FeaturedArticleCardModel?,
        message: String
    ) {
        featuredArticleTasks[articleID] = nil
        queuedFeaturedArticleComments[articleID] = nil
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
        case let .loaded(content):
            let updatedContent = transform(content)
            state = .loaded(updatedContent)
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

    /// Adds one queued comment request while the visible card is already posting a comment.
    private func enqueueQueuedFeaturedArticleComment(for articleID: String) -> Bool {
        guard let article = featuredArticle(withID: articleID),
              article.uiState.pendingOperation == .addingComment else {
            return false
        }

        queuedFeaturedArticleComments[articleID, default: 0] += 1
        return true
    }

    /// Applies one successful intermediate comment result and returns whether another queued request should continue immediately.
    private func applyFeaturedArticleQueuedCommentProgress(
        _ updatedArticle: FeaturedArticleCardModel,
        articleID: String
    ) -> Bool {
        let remainingQueuedComments = queuedFeaturedArticleComments[articleID] ?? 0
        guard remainingQueuedComments > 0 else {
            queuedFeaturedArticleComments[articleID] = nil
            return false
        }

        queuedFeaturedArticleComments[articleID] = remainingQueuedComments - 1
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
        for task in featuredArticleTasks.values {
            task.cancel()
        }
        featuredArticleTasks.removeAll()
        queuedFeaturedArticleComments.removeAll()
    }

    /// Resolves the rollback/preserve policy for a failed featured article action and applies it to the visible card.
    private func handleFeaturedArticleFailure(
        action: FeaturedArticleCardAction,
        articleID: String,
        previousArticle: FeaturedArticleCardModel?,
        error: Error
    ) {
        let policy = featuredArticleFailurePolicy(for: action, error: error)
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
    ) -> CardActionFailurePolicy {
        let fallbackMessage = cardActionFailureMessage(for: error)
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

        discussionTasks[discussionID] = Task { [weak self] in
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
                            ? AppLocalization.text("news.discussion.status.joined", fallback: "Joined discussion.")
                            : AppLocalization.text("news.discussion.status.left", fallback: "Participation removed.")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleDiscussionFailure(
                        action: .toggleParticipation,
                        discussionID: discussionID,
                        previousDiscussion: previousDiscussion,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a reply creation task for one discussion card.
    private func startDiscussionReplyTask(for discussionID: String) {
        if enqueueQueuedDiscussionReply(for: discussionID) {
            return
        }

        guard canStartDiscussionAction(for: discussionID) else {
            return
        }

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

        discussionTasks[discussionID] = Task { [weak self] in
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
                                statusMessage: AppLocalization.text("news.discussion.status.replied", fallback: "Reply added.")
                            )
                        }
                        return
                    }
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleDiscussionFailure(
                        action: .addReply,
                        discussionID: discussionID,
                        previousDiscussion: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Persists a new display mode for one discussion card.
    private func startDiscussionDisplayModeTask(
        _ displayMode: DiscussionCardDisplayMode,
        for discussionID: String
    ) {
        guard canStartDiscussionAction(for: discussionID) else {
            return
        }

        let previousDiscussion = discussion(withID: discussionID)
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

        discussionTasks[discussionID] = Task { [weak self] in
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
                await MainActor.run {
                    self?.handleDiscussionFailure(
                        action: .setDisplayMode(displayMode),
                        discussionID: discussionID,
                        previousDiscussion: previousDiscussion,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a refresh task for one discussion card.
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

        discussionTasks[discussionID] = Task { [weak self] in
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
                        statusMessage: AppLocalization.text("news.discussion.status.refreshed", fallback: "Discussion refreshed.")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleDiscussionFailure(
                        action: .refreshContent,
                        discussionID: discussionID,
                        previousDiscussion: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Starts a longer update task for one discussion card.
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

        discussionTasks[discussionID] = Task { [weak self] in
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
                        statusMessage: AppLocalization.text("news.discussion.status.updated", fallback: "Discussion updated.")
                    )
                }
            } catch is CancellationError {
                return
            } catch {
                await MainActor.run {
                    self?.handleDiscussionFailure(
                        action: .runLongTask,
                        discussionID: discussionID,
                        previousDiscussion: nil,
                        error: error
                    )
                }
            }
        }
    }

    /// Replaces the visible discussion card with the latest persisted snapshot.
    private func finishDiscussionAction(
        _ updatedDiscussion: DiscussionCardModel,
        discussionID: String,
        statusMessage: String?
    ) {
        discussionTasks[discussionID] = nil
        queuedDiscussionReplies[discussionID] = nil
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
        discussionTasks[discussionID] = nil
        queuedDiscussionReplies[discussionID] = nil
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
            message: AppLocalization.text(
                "news.discussion.status.failed",
                fallback: "Unable to complete this action right now."
            )
        )
    }

    /// Restores the previous discussion snapshot after a failed optimistic action and shows the supplied status message.
    private func rollbackDiscussion(
        discussionID: String,
        previousDiscussion: DiscussionCardModel?,
        message: String
    ) {
        discussionTasks[discussionID] = nil
        queuedDiscussionReplies[discussionID] = nil
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

    /// Adds one queued reply request while the visible discussion card is already posting a reply.
    private func enqueueQueuedDiscussionReply(for discussionID: String) -> Bool {
        guard let discussion = discussion(withID: discussionID),
              discussion.uiState.pendingOperation == .addingReply else {
            return false
        }

        queuedDiscussionReplies[discussionID, default: 0] += 1
        return true
    }

    /// Applies one successful intermediate reply result and returns whether another queued request should continue immediately.
    private func applyDiscussionQueuedReplyProgress(
        _ updatedDiscussion: DiscussionCardModel,
        discussionID: String
    ) -> Bool {
        let remainingQueuedReplies = queuedDiscussionReplies[discussionID] ?? 0
        guard remainingQueuedReplies > 0 else {
            queuedDiscussionReplies[discussionID] = nil
            return false
        }

        queuedDiscussionReplies[discussionID] = remainingQueuedReplies - 1
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
        for task in discussionTasks.values {
            task.cancel()
        }
        discussionTasks.removeAll()
        queuedDiscussionReplies.removeAll()
    }

    /// Resolves the rollback/preserve policy for a failed discussion action and applies it to the visible card.
    private func handleDiscussionFailure(
        action: DiscussionCardAction,
        discussionID: String,
        previousDiscussion: DiscussionCardModel?,
        error: Error
    ) {
        let policy = discussionFailurePolicy(for: action, error: error)
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
    ) -> CardActionFailurePolicy {
        let fallbackMessage = cardActionFailureMessage(for: error)
        switch action {
        case .toggleParticipation, .setDisplayMode:
            return CardActionFailurePolicy(resolution: .rollback, message: fallbackMessage)
        case .addReply, .refreshContent, .runLongTask:
            return CardActionFailurePolicy(resolution: .preserveVisibleSnapshot, message: fallbackMessage)
        }
    }

    /// Maps repository/network failures into stable user-facing card status text.
    private func cardActionFailureMessage(for error: Error) -> String {
        guard let repositoryError = error as? RepositoryError else {
            return AppLocalization.text(
                "news.card.status.failed",
                fallback: "Unable to complete this action right now."
            )
        }

        switch repositoryError {
        case .offlineCardAction:
            return AppLocalization.text(
                "news.card.status.offline",
                fallback: "You're offline. Showing saved state."
            )
        case .missingPersistedFeedCard:
            return AppLocalization.text(
                "news.card.status.stale",
                fallback: "Card is out of sync. Refresh the feed."
            )
        case .missingChannel, .missingPersistedFeed:
            return AppLocalization.text(
                "news.card.status.failed",
                fallback: "Unable to complete this action right now."
            )
        }
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
                let content = try await repository.refreshNewsFeedContent()
                guard !Task.isCancelled else {
                    return
                }
                self.applyLoadedContent(content)
            } catch is CancellationError {
                return
            } catch {
                self.applyLoadFailureState()
            }
        }
    }
}
