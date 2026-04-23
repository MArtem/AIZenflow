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
            toggleLike(for: articleID)
        case let .setDisplayMode(displayMode):
            setDisplayMode(displayMode, for: articleID)
        case .refreshContent:
            startRefreshContentTask(for: articleID)
        case .runLongTask:
            startLongUpdateTask(for: articleID)
        case .openComments:
            return
        }
    }

    /// Cancels the current feed refresh and clears the loading state.
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        cancelFeaturedArticleTasks()

        if case let .loading(content) = state {
            state = .loaded(content)
        }
    }

    /// Cleans up any in-flight resources before release.
    deinit {
        loadingTask?.cancel()
        cancelFeaturedArticleTasks()
    }

    /// Applies freshly loaded feed content to published state and side effects.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        cancelFeaturedArticleTasks()
        state = .loaded(content)
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    private func applyLoadFailureState() {
        cancelFeaturedArticleTasks()
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

    /// Applies a display-mode change without touching persistence-backed article content.
    private func setDisplayMode(
        _ displayMode: FeaturedArticleCardDisplayMode,
        for articleID: String
    ) {
        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: displayMode,
                    pendingOperation: $0.pendingOperation,
                    inlineStatusMessage: nil
                )
            }
        }
    }

    /// Performs a lightweight optimistic like toggle with inline progress feedback.
    private func toggleLike(for articleID: String) {
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

        featuredArticleTasks[articleID]?.cancel()
        featuredArticleTasks[articleID] = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(450))
                try Task.checkCancellation()
                await self?.finishLikeToggle(for: articleID)
            } catch is CancellationError {
                return
            } catch {
                await self?.rollbackFeaturedArticle(articleID: articleID, previousArticle: previousArticle)
            }
        }
    }

    /// Starts a simulated card refresh with a card-scoped inline loader.
    private func startRefreshContentTask(for articleID: String) {
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

        featuredArticleTasks[articleID]?.cancel()
        featuredArticleTasks[articleID] = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(1))
                try Task.checkCancellation()
                await self?.finishRefreshContent(for: articleID)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    /// Starts a simulated long-running article update with inline loading state.
    private func startLongUpdateTask(for articleID: String) {
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

        featuredArticleTasks[articleID]?.cancel()
        featuredArticleTasks[articleID] = Task { [weak self] in
            do {
                try await Task.sleep(for: .seconds(2))
                try Task.checkCancellation()
                await self?.finishLongUpdate(for: articleID)
            } catch is CancellationError {
                return
            } catch {
                return
            }
        }
    }

    /// Applies final state after a lightweight like interaction completes.
    private func finishLikeToggle(for articleID: String) {
        featuredArticleTasks[articleID] = nil
        updateFeaturedArticle(articleID: articleID) { article in
            article.updatingUIState {
                FeaturedArticleCardUIState(
                    isLiked: $0.isLiked,
                    displayMode: $0.displayMode,
                    pendingOperation: nil,
                    inlineStatusMessage: $0.isLiked
                        ? AppLocalization.text("news.featured.status.liked", fallback: "Reaction saved.")
                        : AppLocalization.text("news.featured.status.unliked", fallback: "Reaction removed.")
                )
            }
        }
    }

    /// Applies refreshed article text after a card-level refresh operation finishes.
    private func finishRefreshContent(for articleID: String) {
        featuredArticleTasks[articleID] = nil
        updateFeaturedArticle(articleID: articleID) { article in
            article
                .updatingContent(
                    metadataLine: AppLocalization.text(
                        "news.featured.refresh.metadata",
                        fallback: "refreshed just now"
                    )
                )
                .updatingUIState {
                    FeaturedArticleCardUIState(
                        isLiked: $0.isLiked,
                        displayMode: $0.displayMode,
                        pendingOperation: nil,
                        inlineStatusMessage: AppLocalization.text(
                            "news.featured.status.refreshed",
                            fallback: "Card refreshed."
                        )
                    )
                }
        }
    }

    /// Applies a simulated full-content replacement after a longer article update task finishes.
    private func finishLongUpdate(for articleID: String) {
        featuredArticleTasks[articleID] = nil
        updateFeaturedArticle(articleID: articleID) { article in
            article
                .updatingContent(
                    headline: AppLocalization.text(
                        "news.featured.updated.headline",
                        fallback: "Updated article version ready for review"
                    ),
                    summary: AppLocalization.text(
                        "news.featured.updated.summary",
                        fallback: "This card now shows a rebuilt content snapshot to simulate a long-running article update finishing directly inside the feed."
                    ),
                    metadataLine: AppLocalization.text(
                        "news.featured.updated.metadata",
                        fallback: "system update completed just now"
                    )
                )
                .updatingUIState {
                    FeaturedArticleCardUIState(
                        isLiked: $0.isLiked,
                        displayMode: $0.displayMode,
                        pendingOperation: nil,
                        inlineStatusMessage: AppLocalization.text(
                            "news.featured.status.updated",
                            fallback: "Article updated."
                        )
                    )
                }
        }
    }

    /// Restores the previous article snapshot after a failed optimistic action.
    private func rollbackFeaturedArticle(
        articleID: String,
        previousArticle: FeaturedArticleCardModel?
    ) {
        featuredArticleTasks[articleID] = nil
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
                                inlineStatusMessage: AppLocalization.text(
                                    "news.featured.status.failed",
                                    fallback: "Unable to complete this action right now."
                                )
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

    /// Cancels all active card-level tasks and clears the registry.
    private func cancelFeaturedArticleTasks() {
        for task in featuredArticleTasks.values {
            task.cancel()
        }
        featuredArticleTasks.removeAll()
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
