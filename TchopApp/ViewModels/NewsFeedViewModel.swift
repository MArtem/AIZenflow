import Foundation

/// View model responsible for loading and exposing the home feed state.
@MainActor
final class NewsFeedViewModel: ObservableObject {
    /// Current feed content shown by the news screen.
    @Published private(set) var content: NewsFeedContent

    /// Whether a feed refresh is currently running.
    @Published private(set) var isLoading: Bool

    /// User-facing error message shown when a refresh fails.
    @Published private(set) var errorMessage: String?

    private let repository: any NewsFeedRepository
    private let widgetContentSyncManager: any WidgetContentSyncing
    private var loadingTask: Task<Void, Never>?

    /// Creates the feed view model and immediately starts the first load.
    init(
        repository: any NewsFeedRepository,
        widgetContentSyncManager: (any WidgetContentSyncing)? = nil,
        content: NewsFeedContent? = nil
    ) {
        self.repository = repository
        let resolvedWidgetContentSyncManager = widgetContentSyncManager ?? NoopWidgetContentSyncManager()
        self.widgetContentSyncManager = resolvedWidgetContentSyncManager
        self.content = content ?? NewsFeedFixtures.fallbackContent
        self.isLoading = false
        self.errorMessage = nil
        resolvedWidgetContentSyncManager.syncFeed(content: self.content)
        reload()
    }

    /// Reloads the news feed, cancelling any in-flight request first.
    func reload() {
        loadingTask?.cancel()
        isLoading = true
        errorMessage = nil

        loadingTask = Task { [weak self] in
            guard let self else {
                return
            }

            do {
                let content = try await repository.fetchNewsFeedContent()
                guard !Task.isCancelled else {
                    return
                }
                self.content = content
                self.widgetContentSyncManager.syncFeed(content: content)
            } catch is CancellationError {
                return
            } catch {
                self.content = NewsFeedFixtures.fallbackContent
                self.errorMessage = AppLocalization.text("news.error.loadFailed", fallback: "Failed to load feed.")
                self.widgetContentSyncManager.syncFeed(content: self.content)
            }

            self.isLoading = false
        }
    }

    /// Cancels the current feed refresh and clears the loading state.
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil
        isLoading = false
    }

    deinit {
        loadingTask?.cancel()
    }
}

private enum NewsFeedFixtures {
    static let fallbackContent: NewsFeedContent = {
        NewsFeedContent(
            cards: [
                .featuredArticle(
                    FeaturedArticleCardModel(
                        id: "featured-article-fallback",
                        postedInPrefix: AppLocalization.text("news.fallback.postedInPrefix", fallback: "Posted in "),
                        sourceTitle: AppLocalization.text("news.fallback.sourceTitle", fallback: "Our Blog"),
                        brandTitle: AppLocalization.text("news.fallback.brandTitle", fallback: "Tchop"),
                        headline: AppLocalization.text("news.fallback.headline", fallback: "Parrots help others in need, study\nshows for first time"),
                        summary: AppLocalization.text("news.fallback.summary", fallback: "Consectetur adipiscing elit. Eget semper at augue amet, facilisis vulputate nec vitae libero. Id scelerisque vestibulum quis faucibus urna sem..."),
                        metadataLine: AppLocalization.text("news.fallback.metadataLine", fallback: "by Adorlee Querry · two days ago · read time: 2min"),
                        translationLabel: AppLocalization.text("news.fallback.translationLabel", fallback: "See translation"),
                        actions: [
                            ArticleActionItem(
                                id: "like",
                                systemName: "hand.thumbsup.fill",
                                title: AppLocalization.text("news.fallback.action.like", fallback: "Like")
                            ),
                            ArticleActionItem(
                                id: "comments",
                                systemName: "bubble.left.fill",
                                title: AppLocalization.text("news.fallback.action.comments", fallback: "48 Comments")
                            )
                        ]
                    )
                ),
                .discussion(
                    DiscussionCardModel(
                        id: "discussion-fallback",
                        categoryTitle: AppLocalization.text("news.fallback.discussion.category", fallback: "Discussion"),
                        headline: AppLocalization.text("news.fallback.discussion.headline", fallback: "Mattis duis volutpat tincidunt\nhabitant amet in sagittis odio"),
                        participants: [
                            DiscussionParticipant(id: "adorlee", initials: "A", isHighlighted: true),
                            DiscussionParticipant(id: "mattis", initials: "M", isHighlighted: false),
                            DiscussionParticipant(id: "sophia", initials: "S", isHighlighted: false)
                        ],
                        joinedText: AppLocalization.text("news.fallback.discussion.joinedText", fallback: "+12 joined")
                    )
                )
            ]
        )
    }()
}
