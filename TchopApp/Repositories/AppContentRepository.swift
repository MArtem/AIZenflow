import Foundation
import CoreData
import Network
import SwiftData
import TchopDatabase

/// Repository interface for fixed channel header information.
@MainActor
protocol ChannelInfoRepository {
    /// Fetches channel metadata used by the pinned top bar.
    func fetchChannelInfo() throws -> ChannelHeaderInfo
}

/// Repository interface for the news feed timeline.
@MainActor
protocol NewsFeedRepository {
    /// Returns the current persisted feed snapshot if one is already available locally.
    func currentNewsFeedContent() throws -> NewsFeedContent?

    /// Refreshes feed content from the API, syncs persistence, and returns the resulting snapshot.
    func refreshNewsFeedContent() async throws -> NewsFeedContent
}

/// Lightweight app-local reachability check used by the feed repository.
protocol NetworkAvailabilityChecking {
    /// Whether the app currently has a usable internet path.
    var isInternetAvailable: Bool { get }
}

/// Combined repository used by the shell to resolve both channel and feed content.
protocol AppContentRepository: ChannelInfoRepository, NewsFeedRepository {}

/// Default app content repository that combines local persistence and API data.
@MainActor
final class DefaultAppContentRepository: AppContentRepository {
    private let databaseManager: any DatabaseManaging
    private let feedAPIManager: any FeedAPIManaging
    private let networkAvailabilityChecker: any NetworkAvailabilityChecking

    /// Creates a new DefaultAppContentRepository instance.
    init(
        databaseManager: any DatabaseManaging,
        feedAPIManager: any FeedAPIManaging,
        networkAvailabilityChecker: any NetworkAvailabilityChecking
    ) {
        self.databaseManager = databaseManager
        self.feedAPIManager = feedAPIManager
        self.networkAvailabilityChecker = networkAvailabilityChecker
    }

    /// Fetches channel data from local persistence.
    func fetchChannelInfo() throws -> ChannelHeaderInfo {
        try requireChannelInfo(fetchChannelInfoFromCurrentBackend())
    }

    /// Returns the current persisted feed snapshot if one is already available locally.
    func currentNewsFeedContent() throws -> NewsFeedContent? {
        let content = try fetchPersistedNewsFeedContent(cacheReason: .bootstrap)
        return content.cards.isEmpty ? nil : content
    }

    /// Refreshes feed cards from the feed API, syncs persistence, and rereads the stored snapshot.
    func refreshNewsFeedContent() async throws -> NewsFeedContent {
        guard networkAvailabilityChecker.isInternetAvailable else {
            if let persistedContent = try currentNewsFeedContent() {
                return persistedContent.withCacheReason(.offline)
            }

            throw RepositoryError.missingPersistedFeed
        }

        let response = try await feedAPIManager.fetchFeed()
        try syncPersistedFeedContent(with: response)
        return try fetchPersistedNewsFeedContent(cacheReason: nil)
    }

    /// Resolves channel info using the currently selected persistence backend.
    private func fetchChannelInfoFromCurrentBackend() throws -> ChannelHeaderInfo? {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataChannelInfo()
            }

            return try fetchCoreDataChannelInfo()
        case .coreData:
            return try fetchCoreDataChannelInfo()
        }
    }

    /// Converts an optional channel result into a repository-level success or error.
    private func requireChannelInfo(_ channel: ChannelHeaderInfo?) throws -> ChannelHeaderInfo {
        guard let channel else {
            throw RepositoryError.missingChannel
        }

        return channel
    }

    @available(iOS 17, *)
    /// Fetches channel info through the SwiftData backend.
    private func fetchSwiftDataChannelInfo() throws -> ChannelHeaderInfo? {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let descriptor = FetchDescriptor<ChannelRecord>()
                return try context.fetch(descriptor).first.map(AppContentMapper.mapChannelInfo)
            })
        )
    }

    /// Fetches channel info through the Core Data backend.
    private func fetchCoreDataChannelInfo() throws -> ChannelHeaderInfo? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataChannelFetchRequest()
                return try context.fetch(request).first.map(AppContentMapper.mapChannelInfo)
            })
        )
    }

    /// Builds a single-record Core Data request for channel metadata.
    private static func makeCoreDataChannelFetchRequest() -> NSFetchRequest<CoreDataChannelEntity> {
        let request = CoreDataChannelEntity.fetchRequest()
        request.fetchLimit = 1
        return request
    }

    /// Fetches the current persisted feed snapshot using the selected backend.
    private func fetchPersistedNewsFeedContent(
        cacheReason: NewsFeedCacheReason?
    ) throws -> NewsFeedContent {
        let snapshot = try fetchPersistedFeedSnapshotFromCurrentBackend()
        return NewsFeedContent(
            cards: snapshot.cards,
            availability: makeFeedAvailability(
                lastSyncedAt: snapshot.lastSyncedAt,
                cacheReason: cacheReason
            )
        )
    }

    /// Reads persisted feed cards from the selected backend and maps them into presentation models.
    private func fetchPersistedFeedSnapshotFromCurrentBackend() throws -> PersistedNewsFeedSnapshot {
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                return try fetchSwiftDataFeedSnapshot()
            }

            return try fetchCoreDataFeedSnapshot()
        case .coreData:
            return try fetchCoreDataFeedSnapshot()
        }
    }

    /// Synchronizes the full persisted feed snapshot with the latest API response.
    private func syncPersistedFeedContent(with response: FeedResponseDTO) throws {
        let syncedAt = Date()
        let snapshots = try AppContentPersistenceMapper.makeFeedCardSnapshots(
            from: response,
            syncedAt: syncedAt
        )

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                try syncSwiftDataFeedCards(with: snapshots)
            } else {
                try syncCoreDataFeedCards(with: snapshots)
            }
        case .coreData:
            try syncCoreDataFeedCards(with: snapshots)
        }
    }

    @available(iOS 17, *)
    /// Fetches persisted feed cards through the SwiftData backend.
    private func fetchSwiftDataFeedSnapshot() throws -> PersistedNewsFeedSnapshot {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let descriptor = FetchDescriptor<FeedCardRecord>(
                    sortBy: [SortDescriptor(\.sortOrder, order: .forward)]
                )
                let records = try context.fetch(descriptor)
                return PersistedNewsFeedSnapshot(
                    cards: records.compactMap(AppContentMapper.mapFeedCard),
                    lastSyncedAt: records.first?.syncedAt
                )
            })
        )
    }

    /// Fetches persisted feed cards through the Core Data backend.
    private func fetchCoreDataFeedSnapshot() throws -> PersistedNewsFeedSnapshot {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest()
                let records = try context.fetch(request)
                return PersistedNewsFeedSnapshot(
                    cards: records.compactMap(AppContentMapper.mapFeedCard),
                    lastSyncedAt: records.first?.syncedAt
                )
            })
        )
    }

    /// Derives visible feed availability from the current source path.
    private func makeFeedAvailability(
        lastSyncedAt: Date?,
        cacheReason: NewsFeedCacheReason?
    ) -> NewsFeedAvailability {
        guard let cacheReason else {
            return .live
        }

        return .cached(lastSyncedAt: lastSyncedAt, reason: cacheReason)
    }

    @available(iOS 17, *)
    /// Performs full-snapshot upsert/delete sync of feed cards in SwiftData.
    private func syncSwiftDataFeedCards(
        with snapshots: [FeedCardPersistenceSnapshot]
    ) throws {
        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                let descriptor = FetchDescriptor<FeedCardRecord>()
                let existingRecords = try context.fetch(descriptor)
                let snapshotsByID = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.id, $0) })

                for record in existingRecords where snapshotsByID[record.id] == nil {
                    context.delete(record)
                }

                for snapshot in snapshots {
                    if let existingRecord = existingRecords.first(where: { $0.id == snapshot.id }) {
                        AppContentPersistenceMapper.apply(snapshot, to: existingRecord)
                    } else {
                        context.insert(AppContentPersistenceMapper.makeFeedCardRecord(from: snapshot))
                    }
                }
            })
        ) as Void
    }

    /// Performs full-snapshot upsert/delete sync of feed cards in Core Data.
    private func syncCoreDataFeedCards(
        with snapshots: [FeedCardPersistenceSnapshot]
    ) throws {
        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest()
                let existingRecords = try context.fetch(request)
                let snapshotsByID = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.id, $0) })

                for record in existingRecords where snapshotsByID[record.id] == nil {
                    context.delete(record)
                }

                for snapshot in snapshots {
                    if let existingRecord = existingRecords.first(where: { $0.id == snapshot.id }) {
                        AppContentPersistenceMapper.apply(snapshot, to: existingRecord)
                    } else {
                        let record = CoreDataFeedCardEntity(context: context)
                        AppContentPersistenceMapper.apply(snapshot, to: record)
                    }
                }
            })
        ) as Void
    }

    /// Builds an ordered Core Data request for persisted feed cards.
    private static func makeCoreDataFeedCardFetchRequest() -> NSFetchRequest<CoreDataFeedCardEntity> {
        let request = CoreDataFeedCardEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ]
        return request
    }
}

private enum RepositoryError: Error {
    case missingChannel
    case missingPersistedFeed
}

private struct PersistedNewsFeedSnapshot {
    let cards: [NewsFeedCard]
    let lastSyncedAt: Date?
}

/// Minimal network availability monitor for choosing between remote and persisted feed paths.
final class NetworkAvailabilityMonitor: NetworkAvailabilityChecking {
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "app.network-availability-monitor")
    private let stateQueue = DispatchQueue(label: "app.network-availability-state")
    private var hasSatisfiedPath = false

    /// Whether the app currently has a usable internet path.
    var isInternetAvailable: Bool {
        stateQueue.sync { hasSatisfiedPath }
    }

    init() {
        monitor.pathUpdateHandler = { [weak self] path in
            self?.stateQueue.async {
                self?.hasSatisfiedPath = path.status == .satisfied
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }
}

private struct FeedCardPersistenceSnapshot {
    let id: String
    let kind: FeedCardRecordKind
    let sortOrder: Int
    let remoteUpdatedAt: Date
    let syncedAt: Date
    let publishedAt: Date?
    let postedInPrefix: String?
    let sourceTitle: String?
    let brandTitle: String?
    let headline: String
    let summary: String?
    let metadataLine: String?
    let translationLabel: String?
    let articleActionsData: Data?
    let categoryTitle: String?
    let participantsData: Data?
    let joinedText: String?
}

private enum AppContentPersistenceMapper {
    static func makeFeedCardSnapshots(
        from response: FeedResponseDTO,
        syncedAt: Date
    ) throws -> [FeedCardPersistenceSnapshot] {
        try response.cards.enumerated().map { index, card in
            try makeFeedCardSnapshot(card, sortOrder: index, syncedAt: syncedAt)
        }
    }

    @available(iOS 17, *)
    static func makeFeedCardRecord(from snapshot: FeedCardPersistenceSnapshot) -> FeedCardRecord {
        FeedCardRecord(
            id: snapshot.id,
            kind: snapshot.kind,
            sortOrder: snapshot.sortOrder,
            remoteUpdatedAt: snapshot.remoteUpdatedAt,
            syncedAt: snapshot.syncedAt,
            publishedAt: snapshot.publishedAt,
            postedInPrefix: snapshot.postedInPrefix,
            sourceTitle: snapshot.sourceTitle,
            brandTitle: snapshot.brandTitle,
            headline: snapshot.headline,
            summary: snapshot.summary,
            metadataLine: snapshot.metadataLine,
            translationLabel: snapshot.translationLabel,
            articleActionsData: snapshot.articleActionsData,
            categoryTitle: snapshot.categoryTitle,
            participantsData: snapshot.participantsData,
            joinedText: snapshot.joinedText
        )
    }

    @available(iOS 17, *)
    static func apply(_ snapshot: FeedCardPersistenceSnapshot, to record: FeedCardRecord) {
        record.kindRawValue = snapshot.kind.rawValue
        record.sortOrder = snapshot.sortOrder
        record.remoteUpdatedAt = snapshot.remoteUpdatedAt
        record.syncedAt = snapshot.syncedAt
        record.publishedAt = snapshot.publishedAt
        record.postedInPrefix = snapshot.postedInPrefix
        record.sourceTitle = snapshot.sourceTitle
        record.brandTitle = snapshot.brandTitle
        record.headline = snapshot.headline
        record.summary = snapshot.summary
        record.metadataLine = snapshot.metadataLine
        record.translationLabel = snapshot.translationLabel
        record.articleActionsData = snapshot.articleActionsData
        record.categoryTitle = snapshot.categoryTitle
        record.participantsData = snapshot.participantsData
        record.joinedText = snapshot.joinedText
    }

    static func apply(_ snapshot: FeedCardPersistenceSnapshot, to record: CoreDataFeedCardEntity) {
        record.id = snapshot.id
        record.kindRawValue = snapshot.kind.rawValue
        record.sortOrder = Int64(snapshot.sortOrder)
        record.remoteUpdatedAt = snapshot.remoteUpdatedAt
        record.syncedAt = snapshot.syncedAt
        record.publishedAt = snapshot.publishedAt
        record.postedInPrefix = snapshot.postedInPrefix
        record.sourceTitle = snapshot.sourceTitle
        record.brandTitle = snapshot.brandTitle
        record.headline = snapshot.headline
        record.summary = snapshot.summary
        record.metadataLine = snapshot.metadataLine
        record.translationLabel = snapshot.translationLabel
        record.articleActionsData = snapshot.articleActionsData
        record.categoryTitle = snapshot.categoryTitle
        record.participantsData = snapshot.participantsData
        record.joinedText = snapshot.joinedText
    }

    private static func makeFeedCardSnapshot(
        _ card: FeedCardDTO,
        sortOrder: Int,
        syncedAt: Date
    ) throws -> FeedCardPersistenceSnapshot {
        switch card {
        case let .featuredArticle(article):
            return FeedCardPersistenceSnapshot(
                id: article.id,
                kind: .featuredArticle,
                sortOrder: sortOrder,
                remoteUpdatedAt: article.remoteUpdatedAt,
                syncedAt: syncedAt,
                publishedAt: article.publishedAt,
                postedInPrefix: article.postedInPrefix,
                sourceTitle: article.sourceTitle,
                brandTitle: article.brandTitle,
                headline: article.headline,
                summary: article.summary,
                metadataLine: article.metadataLine,
                translationLabel: article.translationLabel,
                articleActionsData: try JSONEncoder().encode(
                    article.actions.map {
                        FeedCardActionPayload(
                            id: $0.id,
                            systemName: $0.systemName,
                            title: $0.title
                        )
                    }
                ),
                categoryTitle: nil,
                participantsData: nil,
                joinedText: nil
            )
        case let .discussion(discussion):
            return FeedCardPersistenceSnapshot(
                id: discussion.id,
                kind: .discussion,
                sortOrder: sortOrder,
                remoteUpdatedAt: discussion.remoteUpdatedAt,
                syncedAt: syncedAt,
                publishedAt: discussion.publishedAt,
                postedInPrefix: nil,
                sourceTitle: nil,
                brandTitle: nil,
                headline: discussion.headline,
                summary: nil,
                metadataLine: nil,
                translationLabel: nil,
                articleActionsData: nil,
                categoryTitle: discussion.categoryTitle,
                participantsData: try JSONEncoder().encode(
                    discussion.participants.map {
                        FeedCardParticipantPayload(
                            id: $0.id,
                            initials: $0.initials,
                            isHighlighted: $0.isHighlighted
                        )
                    }
                ),
                joinedText: discussion.joinedText
            )
        }
    }
}

private enum AppContentMapper {
    static func mapFeedContent(from response: FeedResponseDTO) -> NewsFeedContent {
        NewsFeedContent(
            cards: response.cards.map(mapFeedCard),
            availability: .live
        )
    }

    static func mapFeedCard(_ card: FeedCardDTO) -> NewsFeedCard {
        switch card {
        case let .featuredArticle(article):
            return .featuredArticle(mapFeaturedArticle(article))
        case let .discussion(discussion):
            return .discussion(mapDiscussion(discussion))
        }
    }

    static func mapFeaturedArticle(_ article: FeaturedArticleDTO) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: article.id,
            postedInPrefix: article.postedInPrefix,
            sourceTitle: article.sourceTitle,
            brandTitle: article.brandTitle,
            headline: article.headline,
            summary: article.summary,
            metadataLine: article.metadataLine,
            translationLabel: article.translationLabel,
            actions: article.actions.map(mapArticleAction)
        )
    }

    static func mapArticleAction(_ action: ArticleActionDTO) -> ArticleActionItem {
        ArticleActionItem(
            id: action.id,
            systemName: action.systemName,
            title: action.title
        )
    }

    static func mapDiscussion(_ discussion: DiscussionDTO) -> DiscussionCardModel {
        DiscussionCardModel(
            id: discussion.id,
            categoryTitle: discussion.categoryTitle,
            headline: discussion.headline,
            participants: discussion.participants.map(mapDiscussionParticipant),
            joinedText: discussion.joinedText
        )
    }

    static func mapDiscussionParticipant(_ participant: DiscussionParticipantDTO) -> DiscussionParticipant {
        DiscussionParticipant(
            id: participant.id,
            initials: participant.initials,
            isHighlighted: participant.isHighlighted
        )
    }

    @available(iOS 17, *)
    static func mapFeedCard(_ record: FeedCardRecord) -> NewsFeedCard? {
        guard let kind = record.kind else {
            return nil
        }

        switch kind {
        case .featuredArticle:
            return .featuredArticle(mapFeaturedArticle(record))
        case .discussion:
            return .discussion(mapDiscussion(record))
        }
    }

    static func mapFeedCard(_ record: CoreDataFeedCardEntity) -> NewsFeedCard? {
        guard let kind = FeedCardRecordKind(rawValue: record.kindRawValue) else {
            return nil
        }

        switch kind {
        case .featuredArticle:
            return .featuredArticle(mapFeaturedArticle(record))
        case .discussion:
            return .discussion(mapDiscussion(record))
        }
    }

    @available(iOS 17, *)
    static func mapFeaturedArticle(_ record: FeedCardRecord) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: record.id,
            postedInPrefix: record.postedInPrefix ?? "",
            sourceTitle: record.sourceTitle ?? "",
            brandTitle: record.brandTitle ?? "",
            headline: record.headline,
            summary: record.summary ?? "",
            metadataLine: record.metadataLine ?? "",
            translationLabel: record.translationLabel ?? "",
            actions: decodeArticleActions(from: record.articleActionsData)
        )
    }

    static func mapFeaturedArticle(_ record: CoreDataFeedCardEntity) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: record.id,
            postedInPrefix: record.postedInPrefix ?? "",
            sourceTitle: record.sourceTitle ?? "",
            brandTitle: record.brandTitle ?? "",
            headline: record.headline,
            summary: record.summary ?? "",
            metadataLine: record.metadataLine ?? "",
            translationLabel: record.translationLabel ?? "",
            actions: decodeArticleActions(from: record.articleActionsData)
        )
    }

    @available(iOS 17, *)
    static func mapDiscussion(_ record: FeedCardRecord) -> DiscussionCardModel {
        DiscussionCardModel(
            id: record.id,
            categoryTitle: record.categoryTitle ?? "",
            headline: record.headline,
            participants: decodeDiscussionParticipants(from: record.participantsData),
            joinedText: record.joinedText ?? ""
        )
    }

    static func mapDiscussion(_ record: CoreDataFeedCardEntity) -> DiscussionCardModel {
        DiscussionCardModel(
            id: record.id,
            categoryTitle: record.categoryTitle ?? "",
            headline: record.headline,
            participants: decodeDiscussionParticipants(from: record.participantsData),
            joinedText: record.joinedText ?? ""
        )
    }

    static func decodeArticleActions(from data: Data?) -> [ArticleActionItem] {
        guard
            let data,
            let payload = try? JSONDecoder().decode([FeedCardActionPayload].self, from: data)
        else {
            return []
        }

        return payload.map {
            ArticleActionItem(
                id: $0.id,
                systemName: $0.systemName,
                title: $0.title
            )
        }
    }

    static func decodeDiscussionParticipants(from data: Data?) -> [DiscussionParticipant] {
        guard
            let data,
            let payload = try? JSONDecoder().decode([FeedCardParticipantPayload].self, from: data)
        else {
            return []
        }

        return payload.map {
            DiscussionParticipant(
                id: $0.id,
                initials: $0.initials,
                isHighlighted: $0.isHighlighted
            )
        }
    }

    @available(iOS 17, *)
    static func mapChannelInfo(_ channel: ChannelRecord) -> ChannelHeaderInfo {
        ChannelHeaderInfo(title: channel.title, subtitle: channel.subtitle)
    }

    static func mapChannelInfo(_ channel: CoreDataChannelEntity) -> ChannelHeaderInfo {
        ChannelHeaderInfo(title: channel.title, subtitle: channel.subtitle)
    }
}

private extension NewsFeedContent {
    func withCacheReason(_ reason: NewsFeedCacheReason) -> NewsFeedContent {
        guard case let .cached(lastSyncedAt, _) = availability else {
            return self
        }

        return NewsFeedContent(
            cards: cards,
            availability: .cached(lastSyncedAt: lastSyncedAt, reason: reason)
        )
    }
}
