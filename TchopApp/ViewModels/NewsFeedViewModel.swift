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
    private let loadFailureContent: NewsFeedContent
    private let loadFailureMessage: String
    private var loadingTask: Task<Void, Never>?

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
        self.content = initialContent
        self.isLoading = false
        self.errorMessage = nil
        self.loadFailureContent = loadFailureContent
        self.loadFailureMessage = loadFailureMessage
        widgetContentSyncManager.syncFeed(content: self.content)
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
                self.applyLoadedContent(content)
            } catch is CancellationError {
                return
            } catch {
                self.applyLoadFailureState()
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

    /// Cleans up any in-flight resources before release.
    deinit {
        loadingTask?.cancel()
    }

    /// Applies freshly loaded feed content to published state and side effects.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        self.content = content
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    private func applyLoadFailureState() {
        content = loadFailureContent
        errorMessage = loadFailureMessage
        widgetContentSyncManager.syncFeed(content: content)
    }
}
