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
    private var loadingTask: Task<Void, Never>?

    /// Creates the feed view model and immediately starts the first load.
    init(repository: any NewsFeedRepository, content: NewsFeedContent? = nil) {
        self.repository = repository
        self.content = content ?? NewsFeedFixtures.fallbackContent
        self.isLoading = false
        self.errorMessage = nil
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
            } catch is CancellationError {
                return
            } catch {
                self.content = NewsFeedFixtures.fallbackContent
                self.errorMessage = "Failed to load feed."
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
                        postedInPrefix: "Posted in ",
                        sourceTitle: "Our Blog",
                        brandTitle: "Tchop",
                        headline: "Parrots help others in need, study\nshows for first time",
                        summary: "Consectetur adipiscing elit. Eget semper at augue amet, facilisis vulputate nec vitae libero. Id scelerisque vestibulum quis faucibus urna sem...",
                        metadataLine: "by Adorlee Querry · two days ago · read time: 2min",
                        translationLabel: "See translation",
                        actions: [
                            ArticleActionItem(
                                id: "like",
                                systemName: "hand.thumbsup.fill",
                                title: "Like"
                            ),
                            ArticleActionItem(
                                id: "comments",
                                systemName: "bubble.left.fill",
                                title: "48 Comments"
                            )
                        ]
                    )
                ),
                .discussion(
                    DiscussionCardModel(
                        id: "discussion-fallback",
                        categoryTitle: "Discussion",
                        headline: "Mattis duis volutpat tincidunt\nhabitant amet in sagittis odio",
                        participants: [
                            DiscussionParticipant(id: "adorlee", initials: "A", isHighlighted: true),
                            DiscussionParticipant(id: "mattis", initials: "M", isHighlighted: false),
                            DiscussionParticipant(id: "sophia", initials: "S", isHighlighted: false)
                        ],
                        joinedText: "+12 joined"
                    )
                )
            ]
        )
    }()
}
