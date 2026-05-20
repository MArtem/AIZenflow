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

    private let channelsStore: ChannelsStore
    private let widgetContentSyncManager: any WidgetContentSyncing
    private let errorManager: any AppErrorManaging
    private let localFeedCardStore: LocalFeedCardStore
    private let sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager?
    private let onDeviceAIManager: any OnDeviceAIManaging
    private let cardTranslationStore: CardTranslationStore

    /// Creates the feed view model for local-created feed cards.
    init(
        channelsStore: ChannelsStore,
        widgetContentSyncManager: any WidgetContentSyncing,
        errorManager: any AppErrorManaging,
        localFeedCardStore: LocalFeedCardStore,
        sharedLocalFeedCardSyncManager: SharedLocalFeedCardSyncManager? = nil,
        onDeviceAIManager: any OnDeviceAIManaging = OnDeviceAIManagerFactory.makeDefaultManager(),
        cardTranslationStore: CardTranslationStore = CardTranslationStore()
    ) {
        self.channelsStore = channelsStore
        self.widgetContentSyncManager = widgetContentSyncManager
        self.errorManager = errorManager
        self.localFeedCardStore = localFeedCardStore
        self.sharedLocalFeedCardSyncManager = sharedLocalFeedCardSyncManager
        self.onDeviceAIManager = onDeviceAIManager
        self.cardTranslationStore = cardTranslationStore
        self.state = .empty(Self.emptyContent)
        widgetContentSyncManager.syncFeed(content: Self.emptyContent)
    }

    /// Current feed content shown by the news screen.
    var content: NewsFeedContent {
        state.content
    }

    /// Feed content visible after applying the current channel-local search query.
    var visibleContent: NewsFeedContent {
        let localCards = localFeedCardStore.cards(for: currentChannelID)
        return NewsFeedContent(
            cards: filteredCards(from: localCards, query: searchQuery),
            availability: .live
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

    func translatedLocalFeedCard(_ card: LocalFeedCardModel) -> LocalFeedCardModel {
        card.translated(using: cardTranslationStore.snapshot(for: card.id))
    }

    func toggleLocalCardLike(cardID: String) {
        updateLocalCard(cardID: cardID) { card in
            card.replacingInteractionState(isLiked: !card.isLiked)
        }
    }

    func incrementLocalCardComments(cardID: String) {
        updateLocalCard(cardID: cardID) { card in
            card.replacingInteractionState(commentsCount: card.commentsCount + 1)
        }
    }

    func setLocalCardDisplayMode(cardID: String, displayMode: LocalFeedCardDisplayMode) {
        updateLocalCard(cardID: cardID) { card in
            card.replacingInteractionState(displayMode: displayMode)
        }
    }

    private func updateLocalCard(
        cardID: String,
        transform: (LocalFeedCardModel) -> LocalFeedCardModel
    ) {
        localFeedCardStore.updatePersistedCard(id: cardID, transform: transform)
        handleLocalChannelCardsChanged()
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
            _ = await errorManager.presentableError(
                from: error,
                context: AppErrorContext(
                    operation: "translateCard",
                    feature: "newsFeed"
                )
            )
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
            !localFeedCardStore.cards(for: currentChannelID).isEmpty
    }

    /// Starts a user-driven refresh when no feed request is already running.
    /// Online refresh goes through the API path; offline refresh keeps the stored snapshot and updates the UI source metadata.
    func refresh() {
        syncSharedLocalCardsIfNeeded()
        handleLocalChannelCardsChanged()
    }

    /// Retries feed loading only after a visible failed state.
    func retry() {
        handleLocalChannelCardsChanged()
    }

    /// Opens or closes the current-channel search UI.
    func toggleSearchPresentation() {
        isSearchPresented.toggle()
        if !isSearchPresented {
            searchQuery = ""
        }
    }

    /// Re-resolves local cards for a newly selected channel.
    func handleSelectedChannelChange() {
        searchQuery = ""
        isSearchPresented = false

        guard currentChannelID != nil else {
            setEmptyState()
            return
        }
        handleLocalChannelCardsChanged()
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
