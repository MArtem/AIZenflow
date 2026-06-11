import Foundation
import Observation
import os

private let newsFeedPerformanceLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier ?? "com.example.TchopApp",
    category: "FeedPerformance"
)

private enum NewsFeedPerformanceSignpost {
    static func beginVisibleContentRefresh(
        channelID: String?,
        searchQuery: String
    ) -> OSSignpostID {
        let signpostID = OSSignpostID(log: newsFeedPerformanceLog)
        os_signpost(
            .begin,
            log: newsFeedPerformanceLog,
            name: "FeedVisibleContentRefresh",
            signpostID: signpostID,
            "%{public}s %{public}s",
            channelID ?? "nil",
            searchQuery.isEmpty ? "empty-search" : "search"
        )
        return signpostID
    }

    static func endVisibleContentRefresh(
        _ signpostID: OSSignpostID,
        visibleCount: Int
    ) {
        os_signpost(
            .end,
            log: newsFeedPerformanceLog,
            name: "FeedVisibleContentRefresh",
            signpostID: signpostID,
            "visibleCount=%{public}d",
            visibleCount
        )
    }
}

@MainActor
/// Main-actor persistence helper for feed-stage translation snapshots.
///
/// Ownership:
/// Owned by `NewsFeedViewModel`; snapshots are small UserDefaults-backed presentation artifacts,
/// not the source of truth for feed card content.
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

/// User/product events accepted by `NewsFeedViewModel`.
///
/// Purpose:
/// Keeps the SwiftUI layer on user intent terms instead of exposing implementation
/// details such as repository/store mutation helpers.
///
/// External usage:
/// `NewsFeedView` and shell composition should prefer sending actions through this
/// contract. Direct methods remain only where another owner needs a narrower
/// lifecycle-specific call, such as selected-channel changes from the shell.
enum NewsFeedAction {
    case refreshRequested
    case retryTapped
    case searchPresentationToggled
    case selectedChannelChanged
    case channelCardsChanged
    case cardLikeTapped(cardID: String)
    case cardCommentsTapped(cardID: String)
    case cardDisplayModeChanged(cardID: String, displayMode: FeedCardDisplayMode)
    case cardOriginalTextRequested(cardID: String)
    case cardTranslationRequested(card: NewsFeedCard, targetLanguage: OnDeviceLanguage)
}

/// Snapshot consumed by `NewsFeedView` for one SwiftUI body pass.
///
/// Purpose:
/// Groups screen-level presentation inputs so the View reads one stable snapshot
/// instead of reaching into several independent `NewsFeedViewModel` properties.
///
/// Invariant:
/// This type must stay cheap to construct. Expensive search/filter/media work belongs
/// in `NewsFeedViewModel.refreshVisibleContent()` or dedicated media loaders.
struct NewsFeedScreenState: Equatable {
    let visibleContent: NewsFeedContent
    let cardStates: [NewsFeedCardViewState]
    let contentPresentation: NewsFeedContentPresentation
    let hasVisibleCards: Bool
    let isSearchPresented: Bool
    let showsNoSearchResults: Bool
}

/// Top-level presentation choice for the feed content area.
///
/// Purpose:
/// Keeps empty/search-empty/card-list branching in the view-model snapshot so
/// `NewsFeedView` can keep its lazy list structure explicit without owning
/// content-state decisions.
enum NewsFeedContentPresentation: Equatable {
    case empty
    case noSearchResults
    case cards([NewsFeedCardViewState])
}

/// Lightweight presentation state for one feed card row.
///
/// Purpose:
/// Starts separating SwiftUI rendering decisions from source-neutral feed-card runtime data
/// without rewriting the existing media/text card renderers in one risky pass.
struct NewsFeedCardViewState: Identifiable, Equatable {
    let id: String
    let sourceCard: NewsFeedCard
    let renderedCard: NewsFeedCard
    let route: NewsRoute
    let actionState: NewsFeedCardActionViewState
    let translation: NewsFeedCardTranslationViewState?
    let accessibilityLabel: String
}

/// Presentation state for the shared feed-card footer actions.
struct NewsFeedCardActionViewState: Equatable {
    let isLiked: Bool
    let commentsCount: Int
    let commentsText: String
    let displayMode: FeedCardDisplayMode
}

/// Presentation state for feed-card translation controls.
struct NewsFeedCardTranslationViewState: Equatable {
    let title: String
    let isInFlight: Bool
    let tapBehavior: NewsFeedCardTranslationTapBehavior
}

/// Product-level behavior for tapping the translation control.
///
/// Purpose:
/// Keeps one-vs-many-language and translated-vs-original decisions out of
/// `NewsFeedView`; the view only performs the required UI effect.
enum NewsFeedCardTranslationTapBehavior: Equatable {
    case restoreOriginal(cardID: String)
    case startTranslation(card: NewsFeedCard, targetLanguage: OnDeviceLanguage)
    case chooseLanguage(card: NewsFeedCard, languages: [OnDeviceLanguage])
}

/// View model responsible for loading and exposing the home feed state.
@MainActor
@Observable
/// Main-actor state owner for the news feed screen.
///
/// Responsibilities:
/// - derives the visible feed snapshot for the selected channel/search query;
/// - handles card interactions and translation actions;
/// - keeps expensive filtering out of SwiftUI row rendering paths.
///
/// Ownership:
/// Created by app composition for the news tab runtime.
final class NewsFeedViewModel {
    /// Explicit screen state used by the news feed UI.
    private(set) var state: NewsFeedState
    /// Feed content visible after applying current channel and search state.
    private(set) var visibleContent = NewsFeedContent(cards: [], availability: .live)
    private var hasCardsInCurrentChannel = false

    /// Current free-text search query applied to cards from the selected channel only.
    var searchQuery: String = "" {
        didSet {
            refreshVisibleContent()
        }
    }

    /// Whether the search field for the current channel is currently visible.
    private(set) var isSearchPresented: Bool = false
    private var translatingCardIDs: Set<String> = []

    private let channelsStore: ChannelsStore
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let errorManager: any AppErrorManaging
    private let feedCardStore: FeedCardStore
    private let sharedFeedCardSyncManager: SharedFeedCardSyncManager?
    private let onDeviceAIManager: any OnDeviceAIManaging
    private let cardTranslationStore: CardTranslationStore
    private var asynchronousActionTask: Task<Void, Never>?

    /// Creates the feed view model for local-created feed cards.
    init(
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        feedCardStore: FeedCardStore,
        sharedFeedCardSyncManager: SharedFeedCardSyncManager? = nil,
        onDeviceAIManager: any OnDeviceAIManaging = OnDeviceAIManagerFactory.makeDefaultManager(),
        cardTranslationStore: CardTranslationStore = CardTranslationStore()
    ) {
        self.channelsStore = channelsStore
        self.widgetContentSyncManager = widgetContentSyncManager
        self.errorManager = errorManager
        self.feedCardStore = feedCardStore
        self.sharedFeedCardSyncManager = sharedFeedCardSyncManager
        self.onDeviceAIManager = onDeviceAIManager
        self.cardTranslationStore = cardTranslationStore
        self.state = .empty(Self.emptyContent)
        refreshVisibleContent()
        widgetContentSyncManager.syncFeed(content: visibleContent)
    }

    /// Current feed content shown by the news screen.
    var content: NewsFeedContent {
        state.content
    }

    /// Current screen-level presentation snapshot for `NewsFeedView`.
    var screenState: NewsFeedScreenState {
        let cardStates = visibleContent.cards.map(makeCardViewState)
        let showsNoSearchResults = showsNoSearchResults

        return NewsFeedScreenState(
            visibleContent: visibleContent,
            cardStates: cardStates,
            contentPresentation: Self.makeContentPresentation(
                cardStates: cardStates,
                showsNoSearchResults: showsNoSearchResults
            ),
            hasVisibleCards: !cardStates.isEmpty,
            isSearchPresented: isSearchPresented,
            showsNoSearchResults: showsNoSearchResults
        )
    }

    /// Handles synchronous feed actions from SwiftUI and shell composition.
    func send(_ action: NewsFeedAction) {
        switch action {
        case .refreshRequested:
            runAsynchronousAction { viewModel in
                await viewModel.refresh()
            }

        case .retryTapped:
            retry()

        case .searchPresentationToggled:
            toggleSearchPresentation()

        case .selectedChannelChanged:
            handleSelectedChannelChange()

        case .channelCardsChanged:
            handleChannelCardsChanged()

        case let .cardLikeTapped(cardID):
            toggleFeedCardLike(cardID: cardID)

        case let .cardCommentsTapped(cardID):
            incrementFeedCardComments(cardID: cardID)

        case let .cardDisplayModeChanged(cardID, displayMode):
            setFeedCardDisplayMode(cardID: cardID, displayMode: displayMode)

        case let .cardOriginalTextRequested(cardID):
            restoreOriginalCardText(cardID: cardID)

        case let .cardTranslationRequested(card, targetLanguage):
            runAsynchronousAction { viewModel in
                await viewModel.performTranslation(for: card, targetLanguage: targetLanguage)
            }
        }
    }

    /// Handles feed actions whose caller needs to await lifecycle-bound work.
    func sendAndWait(_ action: NewsFeedAction) async {
        switch action {
        case .refreshRequested:
            await refresh()

        case let .cardTranslationRequested(card, targetLanguage):
            await performTranslation(for: card, targetLanguage: targetLanguage)

        default:
            send(action)
        }
    }

    private func runAsynchronousAction(
        _ operation: @escaping @MainActor (NewsFeedViewModel) async -> Void
    ) {
        asynchronousActionTask?.cancel()
        asynchronousActionTask = Task { @MainActor [weak self] in
            guard let self else {
                return
            }

            await operation(self)
        }
    }

    private func makeCardViewState(for card: NewsFeedCard) -> NewsFeedCardViewState {
        let feedCard = card.feedCard
        let translatedCard = translatedFeedCard(feedCard)
        let translationTapBehavior = makeTranslationTapBehavior(for: card)
        let translation: NewsFeedCardTranslationViewState? = translationTapBehavior.map { tapBehavior in
            NewsFeedCardTranslationViewState(
                title: translationActionTitle(for: card.id),
                isInFlight: isTranslationInFlight(card.id),
                tapBehavior: tapBehavior
            )
        }

        return NewsFeedCardViewState(
            id: card.id,
            sourceCard: card,
            renderedCard: translatedCard.newsFeedCard,
            route: feedCard.detailRoute,
            actionState: NewsFeedCardActionViewState(
                isLiked: translatedCard.isLiked,
                commentsCount: translatedCard.commentsCount,
                commentsText: "\(translatedCard.commentsCount) " +
                    AppLocalization.text("news.photo.action.comments"),
                displayMode: translatedCard.displayMode
            ),
            translation: translation,
            accessibilityLabel: translatedCard.serviceHeadline
        )
    }

    private static func makeContentPresentation(
        cardStates: [NewsFeedCardViewState],
        showsNoSearchResults: Bool
    ) -> NewsFeedContentPresentation {
        if showsNoSearchResults {
            return .noSearchResults
        }

        if cardStates.isEmpty {
            return .empty
        }

        return .cards(cardStates)
    }

    private func makeTranslationTapBehavior(for card: NewsFeedCard) -> NewsFeedCardTranslationTapBehavior? {
        if isCardTranslated(card.id) {
            return .restoreOriginal(cardID: card.id)
        }

        guard AppLocalization.supportedLocaleIdentifiers.count > 1 else {
            return nil
        }

        let targetLanguages = translationTargetLanguages(for: card)
        guard !targetLanguages.isEmpty else {
            return nil
        }

        if targetLanguages.count == 1, let targetLanguage = targetLanguages.first {
            return .startTranslation(card: card, targetLanguage: targetLanguage)
        }

        return .chooseLanguage(card: card, languages: targetLanguages)
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

    func translatedFeedCard(_ card: FeedCard) -> FeedCard {
        card.translated(using: cardTranslationStore.snapshot(for: card.id))
    }

    private func toggleFeedCardLike(cardID: String) {
        updateFeedCard(cardID: cardID) { card in
            card.replacingInteractionState(isLiked: !card.isLiked)
        }
    }

    private func incrementFeedCardComments(cardID: String) {
        updateFeedCard(cardID: cardID) { card in
            card.replacingInteractionState(commentsCount: card.commentsCount + 1)
        }
    }

    private func setFeedCardDisplayMode(cardID: String, displayMode: FeedCardDisplayMode) {
        updateFeedCard(cardID: cardID) { card in
            card.replacingInteractionState(displayMode: displayMode)
        }
    }

    private func updateFeedCard(
        cardID: String,
        transform: (FeedCard) -> FeedCard
    ) {
        feedCardStore.updatePersistedCard(id: cardID, transform: transform)
        handleChannelCardsChanged()
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

    private func translateCard(
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
        refreshVisibleContent()
    }

    private func performTranslation(
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
            _ = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "translateCard",
                    feature: "newsFeed"
                )
            )
        }
    }

    private func restoreOriginalCardText(cardID: String) {
        cardTranslationStore.remove(cardID: cardID)
        refreshVisibleContent()
    }

    private func handleChannelCardsChanged() {
        refreshVisibleContent()
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
            hasCardsInCurrentChannel
    }

    /// Starts a user-driven refresh when no feed request is already running.
    /// Online refresh goes through the API path; offline refresh keeps the stored snapshot and updates the UI source metadata.
    private func refresh() async {
        await syncSharedFeedCardsIfNeeded()
        handleChannelCardsChanged()
    }

    /// Retries feed loading only after a visible failed state.
    private func retry() {
        handleChannelCardsChanged()
    }

    /// Opens or closes the current-channel search UI.
    private func toggleSearchPresentation() {
        isSearchPresented.toggle()
        if !isSearchPresented {
            searchQuery = ""
        }
    }

    /// Re-resolves feed cards for a newly selected channel.
    private func handleSelectedChannelChange() {
        searchQuery = ""
        isSearchPresented = false

        guard currentChannelID != nil else {
            setEmptyState()
            return
        }
        handleChannelCardsChanged()
    }

    private func syncSharedFeedCardsIfNeeded() async {
        guard let sharedFeedCardSyncManager else {
            return
        }

        do {
            let importedCount = try await sharedFeedCardSyncManager.syncPendingCards(into: feedCardStore)
            guard importedCount > 0 else {
                return
            }

            handleChannelCardsChanged()
        } catch {
            _ = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "syncSharedFeedCards",
                    feature: "newsFeed"
                )
            )
        }
    }

    private func setEmptyState() {
        hasCardsInCurrentChannel = false
        visibleContent = Self.emptyContent
        state = .empty(Self.emptyContent)
    }

    private func refreshVisibleContent() {
        let signpostID = NewsFeedPerformanceSignpost.beginVisibleContentRefresh(
            channelID: currentChannelID,
            searchQuery: searchQuery
        )
        let channelCards = feedCardStore.cards(for: currentChannelID)
        hasCardsInCurrentChannel = !channelCards.isEmpty
        visibleContent = NewsFeedContent(
            cards: filteredCards(from: channelCards, query: searchQuery),
            availability: .live
        )
        state = Self.resolvedState(for: visibleContent)
        NewsFeedPerformanceSignpost.endVisibleContentRefresh(
            signpostID,
            visibleCount: visibleContent.cards.count
        )
    }

    /// Maps local feed content into the explicit feed state used by the screen.
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

    /// Currently selected channel identifier used for feed queries.
    private var currentChannelID: String? {
        channelsStore.selectionSnapshot.selectedChannelID ?? channelsStore.selectionSnapshot.selectedChannel?.id
    }
}

private extension NewsFeedCard {
    /// Source-neutral published feed card behind the current feed-row wrapper.
    var feedCard: FeedCard {
        switch self {
        case let .photo(content):
            switch content {
            case let .card(card):
                return card
            }
        case let .text(content):
            switch content {
            case let .card(card):
                return card
            }
        case let .video(content):
            switch content {
            case let .card(card):
                return card
            }
        case let .audio(content):
            switch content {
            case let .card(card):
                return card
            }
        case let .pdf(content):
            switch content {
            case let .card(card):
                return card
            }
        }
    }
}
