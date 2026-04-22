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

    /// Cancels the current feed refresh and clears the loading state.
    func cancelLoading() {
        loadingTask?.cancel()
        loadingTask = nil

        if case let .loading(content) = state {
            state = .loaded(content)
        }
    }

    /// Cleans up any in-flight resources before release.
    deinit {
        loadingTask?.cancel()
    }

    /// Applies freshly loaded feed content to published state and side effects.
    private func applyLoadedContent(_ content: NewsFeedContent) {
        state = .loaded(content)
        widgetContentSyncManager.syncFeed(content: content)
    }

    /// Applies the configured fallback state after a failed feed load.
    private func applyLoadFailureState() {
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
