import Foundation
import CoreData
import Network
import SwiftData
import TchopDatabase

/// Repository interface for channel snapshots available to the current app runtime.
@MainActor
protocol ChannelsRepository {
    /// Fetches all locally available channels for the active runtime.
    func fetchAvailableChannels() throws -> [AppChannel]
}

/// Repository interface for the news feed timeline.
@MainActor
protocol NewsFeedRepository {
    /// Returns the current persisted feed snapshot if one is already available locally.
    func currentNewsFeedContent(channelID: String) throws -> NewsFeedContent?

    /// Refreshes feed content from the API when online, otherwise returns the current persisted snapshot marked as offline.
    func refreshNewsFeedContent(channelID: String) async throws -> NewsFeedContent

    /// Persists one featured article card action and returns the updated card snapshot.
    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) async throws -> FeaturedArticleCardModel

    /// Persists one discussion card action and returns the updated card snapshot.
    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction
    ) async throws -> DiscussionCardModel
}

/// Lightweight app-local reachability check used by the feed repository.
protocol NetworkAvailabilityChecking: Sendable {
    /// Whether the app currently has a usable internet path.
    func isInternetAvailable() async -> Bool
}

/// Combined repository used by the shell to resolve both channels and feed content.
protocol AppContentRepository: ChannelsRepository, NewsFeedRepository {}

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

        // Active runtime policy is SwiftData-only. Legacy CoreData branches below are preserved
        // for rollback and migration safety, but are not expected to execute in the current app.
        precondition(
            databaseManager.backendKind == .swiftData,
            "DefaultAppContentRepository expects SwiftData runtime backend."
        )
    }

    /// Fetches channel data from local persistence.
    func fetchAvailableChannels() throws -> [AppChannel] {
        let channels = try fetchChannelsFromCurrentBackend()
        guard !channels.isEmpty else {
            throw RepositoryError.missingChannel
        }

        return channels
    }

    /// Returns the current persisted feed snapshot if one is already available locally.
    func currentNewsFeedContent(channelID: String) throws -> NewsFeedContent? {
        let content = try fetchPersistedNewsFeedContent(
            channelID: channelID,
            cacheReason: .bootstrap
        )
        return content.cards.isEmpty ? nil : content
    }

    /// Refreshes feed cards from the feed API when online, or keeps the persisted snapshot visible when offline.
    ///
    /// The repository always returns a storage-backed snapshot. Even after a successful fetch,
    /// the API response is first synchronized into persistence and only then mapped back into
    /// presentation models.
    func refreshNewsFeedContent(channelID: String) async throws -> NewsFeedContent {
        let networkAvailabilityChecker = self.networkAvailabilityChecker
        let feedAPIManager = self.feedAPIManager

        guard await networkAvailabilityChecker.isInternetAvailable() else {
            if let persistedContent = try currentNewsFeedContent(channelID: channelID) {
                return persistedContent.withCacheReason(.offline)
            }

            throw RepositoryError.missingPersistedFeed
        }

        let response = try await feedAPIManager.fetchFeed(channelID: channelID)
        try await syncPersistedFeedContent(with: response, channelID: channelID)
        return try fetchPersistedNewsFeedContent(channelID: channelID, cacheReason: nil)
    }

    func performFeaturedArticleAction(
        articleID: String,
        action: FeaturedArticleCardAction
    ) async throws -> FeaturedArticleCardModel {
        let networkAvailabilityChecker = self.networkAvailabilityChecker

        guard await networkAvailabilityChecker.isInternetAvailable() else {
            throw RepositoryError.offlineCardAction
        }

        let currentArticle = try requirePersistedFeaturedArticle(articleID: articleID)
        let localStore = try makeFeaturedArticleActionSyncLocalStore(
            article: currentArticle,
            action: action
        )
        let engine = SyncEngine(
            localStore: localStore,
            remoteClient: FeedActionRemoteSyncClient(feedAPIManager: feedAPIManager),
            statusStore: SyncStatusStore(),
            scope: "featured-article-\(articleID)"
        )

        await engine.sync(reason: .localMutation)
        return try requirePersistedFeaturedArticle(articleID: articleID)
    }

    func performDiscussionAction(
        discussionID: String,
        action: DiscussionCardAction
    ) async throws -> DiscussionCardModel {
        let networkAvailabilityChecker = self.networkAvailabilityChecker

        guard await networkAvailabilityChecker.isInternetAvailable() else {
            throw RepositoryError.offlineCardAction
        }

        let currentDiscussion = try requirePersistedDiscussion(discussionID: discussionID)
        let localStore = try makeDiscussionActionSyncLocalStore(
            discussion: currentDiscussion,
            action: action
        )
        let engine = SyncEngine(
            localStore: localStore,
            remoteClient: FeedActionRemoteSyncClient(feedAPIManager: feedAPIManager),
            statusStore: SyncStatusStore(),
            scope: "discussion-\(discussionID)"
        )

        await engine.sync(reason: .localMutation)
        return try requirePersistedDiscussion(discussionID: discussionID)
    }

    private func makeFeaturedArticleActionSyncLocalStore(
        article: FeaturedArticleCardModel,
        action: FeaturedArticleCardAction
    ) throws -> FeedPersistenceSyncLocalStore {
        let payload = FeaturedArticleActionMutationPayload(
            channelID: article.channelID,
            articleID: article.id,
            actionKind: featuredArticleActionKind(action),
            displayModeRawValue: featuredArticleDisplayModeRawValue(action),
            isLiked: article.uiState.isLiked
        )
        let envelope = FeedActionMutationEnvelope(
            kind: .featuredArticle,
            payloadData: try JSONEncoder().encode(payload)
        )
        let mutation = SyncMutation(
            entityType: "feedCard",
            entityID: article.id,
            operation: .update,
            baseServerRevision: try persistedSortOrder(for: article.id),
            payloadData: try JSONEncoder().encode(envelope)
        )

        return FeedPersistenceSyncLocalStore(
            databaseManager: databaseManager,
            channelID: article.channelID,
            queuedMutations: [mutation]
        )
    }

    private func makeDiscussionActionSyncLocalStore(
        discussion: DiscussionCardModel,
        action: DiscussionCardAction
    ) throws -> FeedPersistenceSyncLocalStore {
        let payload = DiscussionActionMutationPayload(
            channelID: discussion.channelID,
            discussionID: discussion.id,
            actionKind: discussionActionKind(action),
            displayModeRawValue: discussionDisplayModeRawValue(action),
            isParticipating: discussion.uiState.isParticipating
        )
        let envelope = FeedActionMutationEnvelope(
            kind: .discussion,
            payloadData: try JSONEncoder().encode(payload)
        )
        let mutation = SyncMutation(
            entityType: "feedCard",
            entityID: discussion.id,
            operation: .update,
            baseServerRevision: try persistedSortOrder(for: discussion.id),
            payloadData: try JSONEncoder().encode(envelope)
        )

        return FeedPersistenceSyncLocalStore(
            databaseManager: databaseManager,
            channelID: discussion.channelID,
            queuedMutations: [mutation]
        )
    }

    /// Resolves channels using the currently selected persistence backend.
    private func fetchChannelsFromCurrentBackend() throws -> [AppChannel] {
        if #available(iOS 17, *) {
            return try fetchSwiftDataChannels()
        }

        return try fetchCoreDataChannels()
    }

    @available(iOS 17, *)
    /// Fetches channels through the SwiftData backend.
    private func fetchSwiftDataChannels() throws -> [AppChannel] {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let descriptor = FetchDescriptor<ChannelRecord>()
                return try context.fetch(descriptor).map(AppContentMapper.mapChannel)
            })
        )
    }

    /// Fetches channels through the Core Data backend.
    private func fetchCoreDataChannels() throws -> [AppChannel] {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataChannelFetchRequest()
                return try context.fetch(request).map(AppContentMapper.mapChannel)
            })
        )
    }

    /// Builds a single-record Core Data request for channel metadata.
    private static func makeCoreDataChannelFetchRequest() -> NSFetchRequest<CoreDataChannelEntity> {
        let request = CoreDataChannelEntity.fetchRequest()
        request.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]
        return request
    }

    /// Fetches the current persisted feed snapshot using the selected backend.
    private func fetchPersistedNewsFeedContent(
        channelID: String,
        cacheReason: NewsFeedCacheReason?
    ) throws -> NewsFeedContent {
        let snapshot = try fetchPersistedFeedSnapshotFromCurrentBackend(channelID: channelID)
        return NewsFeedContent(
            cards: snapshot.cards,
            availability: makeFeedAvailability(
                lastSyncedAt: snapshot.lastSyncedAt,
                cacheReason: cacheReason
            )
        )
    }

    /// Reads persisted feed cards from the selected backend and maps them into presentation models.
    private func fetchPersistedFeedSnapshotFromCurrentBackend(
        channelID: String
    ) throws -> PersistedNewsFeedSnapshot {
        if #available(iOS 17, *) {
            return try fetchSwiftDataFeedSnapshot(channelID: channelID)
        }

        return try fetchCoreDataFeedSnapshot(channelID: channelID)
    }

    /// Synchronizes the full persisted feed snapshot with the latest API response.
    ///
    /// Feed refresh still behaves like a full snapshot replacement, but persisted per-card local
    /// state is carried forward so card actions do not disappear when the stub feed is refreshed.
    private func syncPersistedFeedContent(
        with response: FeedResponseDTO,
        channelID: String
    ) async throws {
        let syncedAt = Date()
        let persistedStates = try fetchPersistedCardStateMap(channelID: channelID)
        let existingCardIDs = Set(
            try fetchPersistedFeedSnapshotFromCurrentBackend(channelID: channelID).cards.map(\.id)
        )
        let localStore = FeedPersistenceSyncLocalStore(
            databaseManager: databaseManager,
            channelID: channelID
        )
        let remoteClient = FeedRemoteSyncClient(
            response: response,
            channelID: channelID,
            syncedAt: syncedAt,
            persistedStates: persistedStates,
            existingCardIDs: existingCardIDs
        )
        let statusStore = SyncStatusStore()
        let engine = SyncEngine(
            localStore: localStore,
            remoteClient: remoteClient,
            statusStore: statusStore,
            scope: "feed-\(channelID)"
        )

        await engine.sync(reason: .manual)
    }

    /// Returns persisted card-local-state blobs keyed by card identifier.
    ///
    /// This payload is intentionally separate from the API DTOs so local preferences such as
    /// liked state or display mode can survive a full feed re-sync.
    private func fetchPersistedCardStateMap(
        channelID: String
    ) throws -> [String: PersistedCardStateSnapshot] {
        if #available(iOS 17, *) {
            return try databaseManager.read(
                DatabaseReadOperation(swiftData: { context in
                    let descriptor = FetchDescriptor<FeedCardRecord>()
                    return Dictionary(
                        uniqueKeysWithValues: try context.fetch(descriptor)
                            .filter { $0.channelID == channelID }
                            .map {
                            (
                                $0.id,
                                PersistedCardStateSnapshot(
                                    articleStateData: $0.articleStateData,
                                    discussionStateData: $0.discussionStateData
                                )
                            )
                        }
                    )
                })
            )
        }

        return try fetchCoreDataCardStateMap(channelID: channelID)
    }

    /// Returns persisted card-local-state blobs from the Core Data backend.
    private func fetchCoreDataCardStateMap(
        channelID: String
    ) throws -> [String: PersistedCardStateSnapshot] {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest(channelID: channelID)
                return Dictionary(
                    uniqueKeysWithValues: try context.fetch(request).map {
                        (
                            $0.id,
                            PersistedCardStateSnapshot(
                                articleStateData: $0.articleStateData,
                                discussionStateData: $0.discussionStateData
                            )
                        )
                    }
                )
            })
        )
    }

    @available(iOS 17, *)
    /// Fetches persisted feed cards through the SwiftData backend.
    private func fetchSwiftDataFeedSnapshot(channelID: String) throws -> PersistedNewsFeedSnapshot {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let records = try Self.fetchAllSwiftDataFeedCardRecords(in: context)
                    .filter { $0.channelID == channelID }
                    .sorted(by: { $0.sortOrder < $1.sortOrder })
                return PersistedNewsFeedSnapshot(
                    cards: records.compactMap(AppContentMapper.mapFeedCard),
                    lastSyncedAt: records.first?.syncedAt
                )
            })
        )
    }

    /// Fetches persisted feed cards through the Core Data backend.
    private func fetchCoreDataFeedSnapshot(channelID: String) throws -> PersistedNewsFeedSnapshot {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest(channelID: channelID)
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
        with snapshots: [FeedCardPersistenceSnapshot],
        channelID: String
    ) throws {
        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                let descriptor = FetchDescriptor<FeedCardRecord>()
                let existingRecords = try context.fetch(descriptor).filter { record in
                    return record.channelID == channelID
                }
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
        with snapshots: [FeedCardPersistenceSnapshot],
        channelID: String
    ) throws {
        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest(channelID: channelID)
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

    /// Persists one updated featured article snapshot while keeping feed ordering stable.
    private func persistFeaturedArticle(
        _ article: FeaturedArticleDTO,
        articleID: String,
        state: FeedCardArticleStatePayload
    ) throws {
        // The remote DTO may only describe content. Persisted card state is merged separately so
        // one successful action does not wipe unrelated fields such as like/comment/display mode.
        let currentArticle = try requirePersistedFeaturedArticle(articleID: articleID)
        let sortOrder = try persistedSortOrder(for: articleID)
        let snapshot = try AppContentPersistenceMapper.makeFeaturedArticleSnapshot(
            article,
            channelID: currentArticle.channelID,
            sortOrder: sortOrder,
            syncedAt: Date(),
            persistedState: PersistedCardStateSnapshot(
                articleStateData: try JSONEncoder().encode(state),
                discussionStateData: nil
            )
        )
        try upsertFeedCard(snapshot)
    }

    /// Persists one updated discussion snapshot while keeping feed ordering stable.
    private func persistDiscussion(
        _ discussion: DiscussionDTO,
        discussionID: String,
        state: FeedCardDiscussionStatePayload
    ) throws {
        let currentDiscussion = try requirePersistedDiscussion(discussionID: discussionID)
        let sortOrder = try persistedSortOrder(for: discussionID)
        let snapshot = try AppContentPersistenceMapper.makeDiscussionSnapshot(
            discussion,
            channelID: currentDiscussion.channelID,
            sortOrder: sortOrder,
            syncedAt: Date(),
            persistedState: PersistedCardStateSnapshot(
                articleStateData: nil,
                discussionStateData: try JSONEncoder().encode(state)
            )
        )
        try upsertFeedCard(snapshot)
    }

    /// Builds the persisted featured article state that should survive one successful card action.
    private func mergedFeaturedArticleState(
        from currentArticle: FeaturedArticleCardModel,
        action: FeaturedArticleCardAction
    ) -> FeedCardArticleStatePayload {
        switch action {
        case .toggleLike:
            return FeedCardArticleStatePayload(
                isLiked: !currentArticle.uiState.isLiked,
                commentCount: currentArticle.commentCount,
                displayModeRawValue: currentArticle.uiState.displayMode.rawValue
            )
        case .addComment:
            return FeedCardArticleStatePayload(
                isLiked: currentArticle.uiState.isLiked,
                commentCount: currentArticle.commentCount + 1,
                displayModeRawValue: currentArticle.uiState.displayMode.rawValue
            )
        case let .setDisplayMode(displayMode):
            return FeedCardArticleStatePayload(
                isLiked: currentArticle.uiState.isLiked,
                commentCount: currentArticle.commentCount,
                displayModeRawValue: displayMode.rawValue
            )
        case .refreshContent, .runLongTask:
            return FeedCardArticleStatePayload(
                isLiked: currentArticle.uiState.isLiked,
                commentCount: currentArticle.commentCount,
                displayModeRawValue: currentArticle.uiState.displayMode.rawValue
            )
        }
    }

    /// Builds the persisted discussion state that should survive one successful card action.
    private func mergedDiscussionState(
        from currentDiscussion: DiscussionCardModel,
        action: DiscussionCardAction
    ) -> FeedCardDiscussionStatePayload {
        switch action {
        case .toggleParticipation:
            let isParticipating = !currentDiscussion.uiState.isParticipating
            let joinedDelta = isParticipating == currentDiscussion.uiState.isParticipating ? 0 : (isParticipating ? 1 : -1)
            return FeedCardDiscussionStatePayload(
                isParticipating: isParticipating,
                replyCount: currentDiscussion.replyCount,
                joinedCount: max(0, currentDiscussion.joinedCount + joinedDelta),
                displayModeRawValue: currentDiscussion.uiState.displayMode.rawValue
            )
        case .addReply:
            return FeedCardDiscussionStatePayload(
                isParticipating: currentDiscussion.uiState.isParticipating,
                replyCount: currentDiscussion.replyCount + 1,
                joinedCount: currentDiscussion.joinedCount,
                displayModeRawValue: currentDiscussion.uiState.displayMode.rawValue
            )
        case let .setDisplayMode(displayMode):
            return FeedCardDiscussionStatePayload(
                isParticipating: currentDiscussion.uiState.isParticipating,
                replyCount: currentDiscussion.replyCount,
                joinedCount: currentDiscussion.joinedCount,
                displayModeRawValue: displayMode.rawValue
            )
        case .refreshContent, .runLongTask:
            return FeedCardDiscussionStatePayload(
                isParticipating: currentDiscussion.uiState.isParticipating,
                replyCount: currentDiscussion.replyCount,
                joinedCount: currentDiscussion.joinedCount,
                displayModeRawValue: currentDiscussion.uiState.displayMode.rawValue
            )
        }
    }

    /// Upserts one feed-card snapshot in the active backend.
    private func upsertFeedCard(_ snapshot: FeedCardPersistenceSnapshot) throws {
        if #available(iOS 17, *) {
            try databaseManager.write(
                DatabaseWriteOperation(swiftData: { context in
                    let descriptor = FetchDescriptor<FeedCardRecord>()
                    if let existingRecord = try context.fetch(descriptor).first(where: { $0.id == snapshot.id }) {
                        AppContentPersistenceMapper.apply(snapshot, to: existingRecord)
                    } else {
                        context.insert(AppContentPersistenceMapper.makeFeedCardRecord(from: snapshot))
                    }
                })
            ) as Void
            return
        }

        try upsertCoreDataFeedCard(snapshot)
    }

    /// Upserts one feed-card snapshot in the Core Data backend.
    private func upsertCoreDataFeedCard(_ snapshot: FeedCardPersistenceSnapshot) throws {
        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest(channelID: snapshot.channelID)
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", snapshot.id)
                if let existingRecord = try context.fetch(request).first {
                    AppContentPersistenceMapper.apply(snapshot, to: existingRecord)
                } else {
                    let record = CoreDataFeedCardEntity(context: context)
                    AppContentPersistenceMapper.apply(snapshot, to: record)
                }
            })
        ) as Void
    }

    /// Returns the persisted sort order for one card identifier.
    private func persistedSortOrder(for cardID: String) throws -> Int {
        if #available(iOS 17, *) {
            return try databaseManager.read(
                DatabaseReadOperation(swiftData: { context in
                    let descriptor = FetchDescriptor<FeedCardRecord>()
                    guard let record = try context.fetch(descriptor).first(where: { $0.id == cardID }) else {
                        throw RepositoryError.missingPersistedFeedCard
                    }
                    return record.sortOrder
                })
            )
        }

        return try persistedCoreDataSortOrder(for: cardID)
    }

    /// Returns the persisted sort order for one Core Data feed card.
    private func persistedCoreDataSortOrder(for cardID: String) throws -> Int {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", cardID)
                guard let record = try context.fetch(request).first else {
                    throw RepositoryError.missingPersistedFeedCard
                }
                return Int(record.sortOrder)
            })
        )
    }

    /// Returns one persisted featured article card or throws when the snapshot is missing.
    private func requirePersistedFeaturedArticle(articleID: String) throws -> FeaturedArticleCardModel {
        guard let article = try persistedFeaturedArticle(articleID: articleID) else {
            throw RepositoryError.missingPersistedFeedCard
        }

        return article
    }

    /// Returns one persisted discussion card or throws when the snapshot is missing.
    private func requirePersistedDiscussion(discussionID: String) throws -> DiscussionCardModel {
        guard let discussion = try persistedDiscussion(discussionID: discussionID) else {
            throw RepositoryError.missingPersistedFeedCard
        }

        return discussion
    }

    /// Reads one persisted featured article card from the active backend.
    private func persistedFeaturedArticle(articleID: String) throws -> FeaturedArticleCardModel? {
        if #available(iOS 17, *) {
            return try databaseManager.read(
                DatabaseReadOperation(swiftData: { context in
                    let descriptor = FetchDescriptor<FeedCardRecord>()
                    return try context.fetch(descriptor)
                        .first(where: { $0.id == articleID })
                        .map(AppContentMapper.mapFeaturedArticle)
                })
            )
        }

        return try persistedCoreDataFeaturedArticle(articleID: articleID)
    }

    /// Reads one persisted featured article card from Core Data.
    private func persistedCoreDataFeaturedArticle(articleID: String) throws -> FeaturedArticleCardModel? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", articleID)
                return try context.fetch(request).first.map(AppContentMapper.mapFeaturedArticle)
            })
        )
    }

    /// Reads one persisted discussion card from the active backend.
    private func persistedDiscussion(discussionID: String) throws -> DiscussionCardModel? {
        if #available(iOS 17, *) {
            return try databaseManager.read(
                DatabaseReadOperation(swiftData: { context in
                    let descriptor = FetchDescriptor<FeedCardRecord>()
                    return try context.fetch(descriptor)
                        .first(where: { $0.id == discussionID })
                        .map(AppContentMapper.mapDiscussion)
                })
            )
        }

        return try persistedCoreDataDiscussion(discussionID: discussionID)
    }

    /// Reads one persisted discussion card from Core Data.
    private func persistedCoreDataDiscussion(discussionID: String) throws -> DiscussionCardModel? {
        try databaseManager.read(
            DatabaseReadOperation(coreData: { context in
                let request = Self.makeCoreDataFeedCardFetchRequest()
                request.fetchLimit = 1
                request.predicate = NSPredicate(format: "id == %@", discussionID)
                return try context.fetch(request).first.map(AppContentMapper.mapDiscussion)
            })
        )
    }

    /// Builds an ordered Core Data request for persisted feed cards.
    fileprivate static func makeCoreDataFeedCardFetchRequest(
        channelID: String? = nil
    ) -> NSFetchRequest<CoreDataFeedCardEntity> {
        let request = CoreDataFeedCardEntity.fetchRequest()
        if let channelID {
            request.predicate = NSPredicate(format: "channelID == %@", channelID)
        }
        request.sortDescriptors = [
            NSSortDescriptor(key: "sortOrder", ascending: true)
        ]
        return request
    }
}

enum RepositoryError: Error {
    case missingChannel
    case missingPersistedFeed
    case missingPersistedFeedCard
    case offlineCardAction
    case unsupportedCardAction
}

private struct PersistedNewsFeedSnapshot {
    let cards: [NewsFeedCard]
    let lastSyncedAt: Date?
}

/// Carries only the state blobs that must survive a later full feed snapshot replacement.
private struct PersistedCardStateSnapshot {
    let articleStateData: Data?
    let discussionStateData: Data?
}

/// Minimal network availability monitor for choosing between remote and persisted feed paths.
final class NetworkAvailabilityMonitor: NetworkAvailabilityChecking {
    private let monitor = NWPathMonitor()
    /// NWPathMonitor still requires a dispatch queue for its system callback delivery API.
    private let monitorQueue = DispatchQueue(label: "app.network-availability-monitor")
    private let state = NetworkAvailabilityState()

    /// Whether the app currently has a usable internet path.
    func isInternetAvailable() async -> Bool {
        await state.isInternetAvailable
    }

    init() {
        monitor.pathUpdateHandler = { [state] path in
            Task {
                await state.setInternetAvailable(path.status == .satisfied)
            }
        }
        monitor.start(queue: monitorQueue)
    }

    deinit {
        monitor.cancel()
    }
}

/// Actor-backed reachability state used by `NetworkAvailabilityMonitor`.
private actor NetworkAvailabilityState {
    private var hasSatisfiedPath = false

    /// Whether the latest known network path is usable.
    var isInternetAvailable: Bool {
        hasSatisfiedPath
    }

    /// Applies one path-status update from the system monitor.
    func setInternetAvailable(_ isInternetAvailable: Bool) {
        hasSatisfiedPath = isInternetAvailable
    }
}

extension DefaultAppContentRepository {
    @available(iOS 17, *)
    /// Fetches the full SwiftData feed-card set for local repository sorting and filtering.
    ///
    /// This avoids Swift 6 strict-concurrency warnings from key-path-based `SortDescriptor`
    /// creation on mutable reference-model records while keeping the repository logic explicit.
    fileprivate static func fetchAllSwiftDataFeedCardRecords(
        in context: ModelContext
    ) throws -> [FeedCardRecord] {
        try context.fetch(FetchDescriptor<FeedCardRecord>())
    }
}

extension NetworkAvailabilityMonitor: @unchecked Sendable {}

private struct FeedCardPersistenceSnapshot: Codable {
    let id: String
    let channelID: String
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
    let articleStateData: Data?
    let categoryTitle: String?
    let participantsData: Data?
    let joinedText: String?
    let discussionStateData: Data?
}

private struct FeedCardSyncEnvelope: Codable {
    let snapshot: FeedCardPersistenceSnapshot
}

private enum FeedActionMutationKind: String, Codable {
    case featuredArticle
    case discussion
}

private struct FeaturedArticleActionMutationPayload: Codable {
    let channelID: String
    let articleID: String
    let actionKind: String
    let displayModeRawValue: String?
    let isLiked: Bool
}

private struct DiscussionActionMutationPayload: Codable {
    let channelID: String
    let discussionID: String
    let actionKind: String
    let displayModeRawValue: String?
    let isParticipating: Bool
}

private struct FeedActionMutationEnvelope: Codable {
    let kind: FeedActionMutationKind
    let payloadData: Data
}

@MainActor
private final class FeedPersistenceSyncLocalStore: SyncLocalStore, @unchecked Sendable {
    private let databaseManager: any DatabaseManaging
    private let channelID: String
    private var cursor: SyncCursor?
    private var queuedMutations: [SyncMutation]

    init(
        databaseManager: any DatabaseManaging,
        channelID: String,
        queuedMutations: [SyncMutation] = []
    ) {
        self.databaseManager = databaseManager
        self.channelID = channelID
        self.queuedMutations = queuedMutations
    }

    func pendingMutations(limit: Int) async throws -> [SyncMutation] {
        Array(queuedMutations.prefix(limit))
    }

    func pendingMutationsCount() async throws -> Int {
        queuedMutations.count
    }

    func unresolvedConflictsCount() async throws -> Int {
        0
    }

    func markMutationsAsSynced(_ mutationIDs: [UUID]) async throws {
        let ids = Set(mutationIDs)
        queuedMutations.removeAll { ids.contains($0.id) }
    }

    func markMutationAsFailed(_ mutationID: UUID, reason: String) async throws {}

    func saveConflict(_ conflict: SyncConflict) async throws {}

    func markConflictResolved(_ conflictID: UUID, resolution: ConflictResolution) async throws {}

    func loadCursor(scope: String) async throws -> SyncCursor? {
        cursor
    }

    func saveRemoteChanges(_ changes: [RemoteChange], nextCursor: SyncCursor?) async throws {
        let decoder = JSONDecoder()
        var snapshotsByID: [String: FeedCardPersistenceSnapshot] = [:]
        var deletedCardIDs: Set<String> = []

        for change in changes {
            switch change.kind {
            case .created, .updated:
                guard let payloadData = change.payloadData else {
                    continue
                }

                let envelope = try decoder.decode(FeedCardSyncEnvelope.self, from: payloadData)
                snapshotsByID[envelope.snapshot.id] = envelope.snapshot
            case .deleted:
                deletedCardIDs.insert(change.entityID)
            }
        }

        let snapshots = snapshotsByID.values.sorted(by: { $0.sortOrder < $1.sortOrder })
        try applySnapshots(snapshots, deletedCardIDs: deletedCardIDs)
        cursor = nextCursor
    }

    func applyResolution(_ resolution: ConflictResolution) async throws {}

    private func applySnapshots(
        _ snapshots: [FeedCardPersistenceSnapshot],
        deletedCardIDs: Set<String>
    ) throws {
        if #available(iOS 17, *) {
            try databaseManager.write(
                DatabaseWriteOperation(swiftData: { context in
                    let existingRecords = try DefaultAppContentRepository.fetchAllSwiftDataFeedCardRecords(in: context)
                        .filter { $0.channelID == self.channelID }
                    let snapshotsByID = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.id, $0) })

                    for record in existingRecords
                    where snapshotsByID[record.id] == nil || deletedCardIDs.contains(record.id) {
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
            return
        }

        try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                let request = DefaultAppContentRepository.makeCoreDataFeedCardFetchRequest(channelID: self.channelID)
                let existingRecords = try context.fetch(request)
                let snapshotsByID = Dictionary(uniqueKeysWithValues: snapshots.map { ($0.id, $0) })

                for record in existingRecords
                where snapshotsByID[record.id] == nil || deletedCardIDs.contains(record.id) {
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
}

private struct FeedRemoteSyncClient: SyncRemoteClient, Sendable {
    private let response: FeedResponseDTO
    private let channelID: String
    private let syncedAt: Date
    private let persistedStates: [String: PersistedCardStateSnapshot]
    private let existingCardIDs: Set<String>

    init(
        response: FeedResponseDTO,
        channelID: String,
        syncedAt: Date,
        persistedStates: [String: PersistedCardStateSnapshot],
        existingCardIDs: Set<String>
    ) {
        self.response = response
        self.channelID = channelID
        self.syncedAt = syncedAt
        self.persistedStates = persistedStates
        self.existingCardIDs = existingCardIDs
    }

    func push(_ request: PushRequest) async throws -> PushResponse {
        PushResponse(results: [])
    }

    func pull(_ request: PullRequest) async throws -> PullResponse {
        let snapshots = try AppContentPersistenceMapper.makeFeedCardSnapshots(
            from: response,
            channelID: channelID,
            syncedAt: syncedAt,
            persistedStates: persistedStates
        )
        let encoder = JSONEncoder()
        let liveCardIDs = Set(snapshots.map(\.id))

        let updatedChanges = try snapshots.map { snapshot in
            RemoteChange(
                entityType: "feedCard",
                entityID: snapshot.id,
                kind: .updated,
                serverRevision: snapshot.sortOrder,
                serverUpdatedAt: snapshot.remoteUpdatedAt,
                payloadData: try encoder.encode(FeedCardSyncEnvelope(snapshot: snapshot))
            )
        }
        let deletedChanges = existingCardIDs.subtracting(liveCardIDs).map { deletedID in
            RemoteChange(
                entityType: "feedCard",
                entityID: deletedID,
                kind: .deleted,
                serverRevision: nil,
                serverUpdatedAt: syncedAt
            )
        }

        return PullResponse(
            changes: updatedChanges + deletedChanges,
            nextCursor: SyncCursor(scope: request.cursor?.scope ?? "feed-\(channelID)", value: syncedAt.ISO8601Format()),
            hasMore: false,
            serverTime: syncedAt
        )
    }
}

private actor FeedActionRemoteSyncClient: SyncRemoteClient {
    private let feedAPIManager: any FeedAPIManaging
    private var pendingChanges: [RemoteChange] = []

    init(feedAPIManager: any FeedAPIManaging) {
        self.feedAPIManager = feedAPIManager
    }

    func push(_ request: PushRequest) async throws -> PushResponse {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        var results: [MutationPushResult] = []

        for mutation in request.mutations {
            guard let payloadData = mutation.payloadData else {
                results.append(.rejected(mutationID: mutation.id, reason: "Missing mutation payload."))
                continue
            }

            let envelope = try decoder.decode(FeedActionMutationEnvelope.self, from: payloadData)

            switch envelope.kind {
            case .featuredArticle:
                let payload = try decoder.decode(FeaturedArticleActionMutationPayload.self, from: envelope.payloadData)
                let action = try payload.makeAction()
                let article = try await feedAPIManager.performFeaturedArticleAction(
                    channelID: payload.channelID,
                    articleID: payload.articleID,
                    action: action,
                    context: FeaturedArticleActionContext(
                        isLiked: payload.isLiked,
                        displayMode: try payload.makeDisplayMode()
                    )
                )
                let snapshot = try AppContentPersistenceMapper.makeFeaturedArticleSnapshot(
                    article,
                    channelID: payload.channelID,
                    sortOrder: mutation.baseServerRevision ?? 0,
                    syncedAt: Date()
                )
                pendingChanges.append(
                    RemoteChange(
                        entityType: "feedCard",
                        entityID: snapshot.id,
                        kind: .updated,
                        serverRevision: snapshot.sortOrder,
                        serverUpdatedAt: snapshot.remoteUpdatedAt,
                        payloadData: try encoder.encode(FeedCardSyncEnvelope(snapshot: snapshot))
                    )
                )
                results.append(
                    .accepted(
                        mutationID: mutation.id,
                        entityID: snapshot.id,
                        serverRevision: snapshot.sortOrder,
                        serverUpdatedAt: snapshot.remoteUpdatedAt
                    )
                )

            case .discussion:
                let payload = try decoder.decode(DiscussionActionMutationPayload.self, from: envelope.payloadData)
                let action = try payload.makeAction()
                let discussion = try await feedAPIManager.performDiscussionAction(
                    channelID: payload.channelID,
                    discussionID: payload.discussionID,
                    action: action,
                    context: DiscussionActionContext(
                        isParticipating: payload.isParticipating,
                        displayMode: try payload.makeDisplayMode()
                    )
                )
                let snapshot = try AppContentPersistenceMapper.makeDiscussionSnapshot(
                    discussion,
                    channelID: payload.channelID,
                    sortOrder: mutation.baseServerRevision ?? 0,
                    syncedAt: Date()
                )
                pendingChanges.append(
                    RemoteChange(
                        entityType: "feedCard",
                        entityID: snapshot.id,
                        kind: .updated,
                        serverRevision: snapshot.sortOrder,
                        serverUpdatedAt: snapshot.remoteUpdatedAt,
                        payloadData: try encoder.encode(FeedCardSyncEnvelope(snapshot: snapshot))
                    )
                )
                results.append(
                    .accepted(
                        mutationID: mutation.id,
                        entityID: snapshot.id,
                        serverRevision: snapshot.sortOrder,
                        serverUpdatedAt: snapshot.remoteUpdatedAt
                    )
                )
            }
        }

        return PushResponse(results: results)
    }

    func pull(_ request: PullRequest) async throws -> PullResponse {
        let changes = pendingChanges
        pendingChanges = []
        return PullResponse(
            changes: changes,
            nextCursor: SyncCursor(scope: request.cursor?.scope ?? "feed-actions", value: UUID().uuidString),
            hasMore: false,
            serverTime: Date()
        )
    }
}

/// Converts between remote DTOs, storage snapshots, and backend-specific persistence records.
private enum AppContentPersistenceMapper {
    static func makeFeedCardSnapshots(
        from response: FeedResponseDTO,
        channelID: String,
        syncedAt: Date,
        persistedStates: [String: PersistedCardStateSnapshot]
    ) throws -> [FeedCardPersistenceSnapshot] {
        try response.cards.enumerated().map { index, card in
            let persistedCardID = makeScopedCardID(rawID: card.id, channelID: channelID)
            return try makeFeedCardSnapshot(
                card,
                channelID: channelID,
                sortOrder: index,
                syncedAt: syncedAt,
                persistedState: persistedStates[persistedCardID]
            )
        }
    }

    @available(iOS 17, *)
    static func makeFeedCardRecord(from snapshot: FeedCardPersistenceSnapshot) -> FeedCardRecord {
        FeedCardRecord(
            id: snapshot.id,
            channelID: snapshot.channelID,
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
            articleStateData: snapshot.articleStateData,
            categoryTitle: snapshot.categoryTitle,
            participantsData: snapshot.participantsData,
            joinedText: snapshot.joinedText,
            discussionStateData: snapshot.discussionStateData
        )
    }

    @available(iOS 17, *)
    static func apply(_ snapshot: FeedCardPersistenceSnapshot, to record: FeedCardRecord) {
        record.channelID = snapshot.channelID
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
        record.articleStateData = snapshot.articleStateData
        record.categoryTitle = snapshot.categoryTitle
        record.participantsData = snapshot.participantsData
        record.joinedText = snapshot.joinedText
        record.discussionStateData = snapshot.discussionStateData
    }

    static func apply(_ snapshot: FeedCardPersistenceSnapshot, to record: CoreDataFeedCardEntity) {
        record.id = snapshot.id
        record.channelID = snapshot.channelID
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
        record.articleStateData = snapshot.articleStateData
        record.categoryTitle = snapshot.categoryTitle
        record.participantsData = snapshot.participantsData
        record.joinedText = snapshot.joinedText
        record.discussionStateData = snapshot.discussionStateData
    }

    private static func makeFeedCardSnapshot(
        _ card: FeedCardDTO,
        channelID: String,
        sortOrder: Int,
        syncedAt: Date,
        persistedState: PersistedCardStateSnapshot?
    ) throws -> FeedCardPersistenceSnapshot {
        switch card {
        case let .featuredArticle(article):
            return try makeFeaturedArticleSnapshot(
                article,
                channelID: channelID,
                sortOrder: sortOrder,
                syncedAt: syncedAt,
                persistedState: persistedState
            )
        case let .discussion(discussion):
            return try makeDiscussionSnapshot(
                discussion,
                channelID: channelID,
                sortOrder: sortOrder,
                syncedAt: syncedAt,
                persistedState: persistedState
            )
        }
    }

    static func makeFeaturedArticleSnapshot(
        _ article: FeaturedArticleDTO,
        channelID: String,
        sortOrder: Int,
        syncedAt: Date,
        persistedState: PersistedCardStateSnapshot? = nil
    ) throws -> FeedCardPersistenceSnapshot {
        // Carry forward the previous interaction-state blob unless the caller explicitly provides a
        // freshly merged state for this write.
        let articleStateData: Data
        if let persistedArticleStateData = persistedState?.articleStateData {
            articleStateData = persistedArticleStateData
        } else {
            articleStateData = try JSONEncoder().encode(
                FeedCardArticleStatePayload(
                    isLiked: article.localState.isLiked,
                    commentCount: article.localState.commentCount,
                    displayModeRawValue: article.localState.displayMode.rawValue
                )
            )
        }

        return FeedCardPersistenceSnapshot(
            id: makeScopedCardID(rawID: article.id, channelID: channelID),
            channelID: channelID,
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
                        kind: $0.kind,
                        systemName: $0.systemName,
                        title: $0.title
                    )
                }
            ),
            articleStateData: articleStateData,
            categoryTitle: nil,
            participantsData: nil,
            joinedText: nil,
            discussionStateData: nil
        )
    }

    static func makeDiscussionSnapshot(
        _ discussion: DiscussionDTO,
        channelID: String,
        sortOrder: Int,
        syncedAt: Date,
        persistedState: PersistedCardStateSnapshot? = nil
    ) throws -> FeedCardPersistenceSnapshot {
        // Discussion interaction state is preserved the same way so replies, participation, and
        // display-mode choices survive future remote feed refreshes.
        let discussionStateData: Data
        if let persistedDiscussionStateData = persistedState?.discussionStateData {
            discussionStateData = persistedDiscussionStateData
        } else {
            discussionStateData = try JSONEncoder().encode(
                FeedCardDiscussionStatePayload(
                    isParticipating: discussion.localState.isParticipating,
                    replyCount: discussion.localState.replyCount,
                    joinedCount: discussion.localState.joinedCount,
                    displayModeRawValue: discussion.localState.displayMode.rawValue
                )
            )
        }
        let joinedCount = ((try? JSONDecoder().decode(FeedCardDiscussionStatePayload.self, from: discussionStateData))?.joinedCount)
            ?? discussion.localState.joinedCount

        return FeedCardPersistenceSnapshot(
            id: makeScopedCardID(rawID: discussion.id, channelID: channelID),
            channelID: channelID,
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
            articleStateData: nil,
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
            joinedText: "+\(joinedCount) joined",
            discussionStateData: discussionStateData
        )
    }

    /// Builds a persisted card identifier that stays unique across channels while preserving the raw remote id.
    private static func makeScopedCardID(rawID: String, channelID: String) -> String {
        "\(channelID)-\(rawID)"
    }
}

private extension FeaturedArticleActionMutationPayload {
    func makeAction() throws -> FeaturedArticleCardAction {
        switch actionKind {
        case "toggleLike":
            return .toggleLike
        case "addComment":
            return .addComment
        case "setDisplayMode":
            return .setDisplayMode(try makeDisplayMode())
        case "refreshContent":
            return .refreshContent
        case "runLongTask":
            return .runLongTask
        default:
            throw RepositoryError.unsupportedCardAction
        }
    }

    func makeDisplayMode() throws -> FeaturedArticleCardDisplayMode {
        guard let displayModeRawValue,
              let displayMode = FeaturedArticleCardDisplayMode(rawValue: displayModeRawValue) else {
            return .expanded
        }

        return displayMode
    }
}

private extension DiscussionActionMutationPayload {
    func makeAction() throws -> DiscussionCardAction {
        switch actionKind {
        case "toggleParticipation":
            return .toggleParticipation
        case "addReply":
            return .addReply
        case "setDisplayMode":
            return .setDisplayMode(try makeDisplayMode())
        case "refreshContent":
            return .refreshContent
        case "runLongTask":
            return .runLongTask
        default:
            throw RepositoryError.unsupportedCardAction
        }
    }

    func makeDisplayMode() throws -> DiscussionCardDisplayMode {
        guard let displayModeRawValue,
              let displayMode = DiscussionCardDisplayMode(rawValue: displayModeRawValue) else {
            return .expanded
        }

        return displayMode
    }
}

private func featuredArticleActionKind(_ action: FeaturedArticleCardAction) -> String {
    switch action {
    case .toggleLike:
        return "toggleLike"
    case .addComment:
        return "addComment"
    case .setDisplayMode:
        return "setDisplayMode"
    case .refreshContent:
        return "refreshContent"
    case .runLongTask:
        return "runLongTask"
    }
}

private func featuredArticleDisplayModeRawValue(_ action: FeaturedArticleCardAction) -> String? {
    guard case let .setDisplayMode(displayMode) = action else {
        return nil
    }

    return displayMode.rawValue
}

private func discussionActionKind(_ action: DiscussionCardAction) -> String {
    switch action {
    case .toggleParticipation:
        return "toggleParticipation"
    case .addReply:
        return "addReply"
    case .setDisplayMode:
        return "setDisplayMode"
    case .refreshContent:
        return "refreshContent"
    case .runLongTask:
        return "runLongTask"
    }
}

private func discussionDisplayModeRawValue(_ action: DiscussionCardAction) -> String? {
    guard case let .setDisplayMode(displayMode) = action else {
        return nil
    }

    return displayMode.rawValue
}

private enum AppContentMapper {
    static func mapFeedContent(from response: FeedResponseDTO) -> NewsFeedContent {
        NewsFeedContent(
            cards: response.cards.map { mapFeedCard($0) },
            availability: .live
        )
    }

    static func mapFeedCard(
        _ card: FeedCardDTO,
        channelID: String = AppChannel.defaultChannel.id
    ) -> NewsFeedCard {
        switch card {
        case let .featuredArticle(article):
            return .featuredArticle(mapFeaturedArticle(article, channelID: channelID))
        case let .discussion(discussion):
            return .discussion(mapDiscussion(discussion, channelID: channelID))
        }
    }

    static func mapFeaturedArticle(
        _ article: FeaturedArticleDTO,
        channelID: String = AppChannel.defaultChannel.id
    ) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: article.id,
            channelID: channelID,
            postedInPrefix: article.postedInPrefix,
            sourceTitle: article.sourceTitle,
            brandTitle: article.brandTitle,
            headline: article.headline,
            summary: article.summary,
            metadataLine: article.metadataLine,
            translationLabel: article.translationLabel,
            commentCount: article.localState.commentCount,
            actions: article.actions.map(mapArticleAction),
            uiState: FeaturedArticleCardUIState(
                isLiked: article.localState.isLiked,
                displayMode: article.localState.displayMode,
                pendingOperation: nil,
                inlineStatusMessage: nil
            )
        )
    }

    static func mapArticleAction(_ action: ArticleActionDTO) -> ArticleActionItem {
        ArticleActionItem(
            id: action.id,
            kind: action.kind,
            systemName: action.systemName,
            title: action.title
        )
    }

    static func mapDiscussion(
        _ discussion: DiscussionDTO,
        channelID: String = AppChannel.defaultChannel.id
    ) -> DiscussionCardModel {
        DiscussionCardModel(
            id: discussion.id,
            channelID: channelID,
            categoryTitle: discussion.categoryTitle,
            headline: discussion.headline,
            participants: discussion.participants.map(mapDiscussionParticipant),
            replyCount: discussion.localState.replyCount,
            joinedCount: discussion.localState.joinedCount,
            uiState: DiscussionCardUIState(
                isParticipating: discussion.localState.isParticipating,
                displayMode: discussion.localState.displayMode,
                pendingOperation: nil,
                inlineStatusMessage: nil
            )
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
            channelID: record.channelID,
            postedInPrefix: record.postedInPrefix ?? "",
            sourceTitle: record.sourceTitle ?? "",
            brandTitle: record.brandTitle ?? "",
            headline: record.headline,
            summary: record.summary ?? "",
            metadataLine: record.metadataLine ?? "",
            translationLabel: record.translationLabel ?? "",
            commentCount: decodeFeaturedArticleState(from: record.articleStateData).commentCount,
            actions: decodeArticleActions(from: record.articleActionsData),
            uiState: decodeFeaturedArticleUIState(from: record.articleStateData)
        )
    }

    static func mapFeaturedArticle(_ record: CoreDataFeedCardEntity) -> FeaturedArticleCardModel {
        FeaturedArticleCardModel(
            id: record.id,
            channelID: record.channelID,
            postedInPrefix: record.postedInPrefix ?? "",
            sourceTitle: record.sourceTitle ?? "",
            brandTitle: record.brandTitle ?? "",
            headline: record.headline,
            summary: record.summary ?? "",
            metadataLine: record.metadataLine ?? "",
            translationLabel: record.translationLabel ?? "",
            commentCount: decodeFeaturedArticleState(from: record.articleStateData).commentCount,
            actions: decodeArticleActions(from: record.articleActionsData),
            uiState: decodeFeaturedArticleUIState(from: record.articleStateData)
        )
    }

    @available(iOS 17, *)
    static func mapDiscussion(_ record: FeedCardRecord) -> DiscussionCardModel {
        DiscussionCardModel(
            id: record.id,
            channelID: record.channelID,
            categoryTitle: record.categoryTitle ?? "",
            headline: record.headline,
            participants: decodeDiscussionParticipants(from: record.participantsData),
            replyCount: decodeDiscussionState(from: record.discussionStateData).replyCount,
            joinedCount: decodeDiscussionState(from: record.discussionStateData).joinedCount,
            uiState: decodeDiscussionUIState(from: record.discussionStateData)
        )
    }

    static func mapDiscussion(_ record: CoreDataFeedCardEntity) -> DiscussionCardModel {
        DiscussionCardModel(
            id: record.id,
            channelID: record.channelID,
            categoryTitle: record.categoryTitle ?? "",
            headline: record.headline,
            participants: decodeDiscussionParticipants(from: record.participantsData),
            replyCount: decodeDiscussionState(from: record.discussionStateData).replyCount,
            joinedCount: decodeDiscussionState(from: record.discussionStateData).joinedCount,
            uiState: decodeDiscussionUIState(from: record.discussionStateData)
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
                kind: $0.kind,
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

    static func decodeFeaturedArticleUIState(from data: Data?) -> FeaturedArticleCardUIState {
        let state = decodeFeaturedArticleState(from: data)
        return FeaturedArticleCardUIState(
            isLiked: state.isLiked,
            displayMode: FeaturedArticleCardDisplayMode(rawValue: state.displayModeRawValue) ?? .expanded,
            pendingOperation: nil,
            inlineStatusMessage: nil
        )
    }

    static func decodeFeaturedArticleState(from data: Data?) -> FeedCardArticleStatePayload {
        guard
            let data,
            let payload = try? JSONDecoder().decode(FeedCardArticleStatePayload.self, from: data)
        else {
            return FeedCardArticleStatePayload(
                isLiked: false,
                commentCount: 0,
                displayModeRawValue: FeaturedArticleCardDisplayMode.expanded.rawValue
            )
        }

        return payload
    }

    static func decodeDiscussionUIState(from data: Data?) -> DiscussionCardUIState {
        let state = decodeDiscussionState(from: data)
        return DiscussionCardUIState(
            isParticipating: state.isParticipating,
            displayMode: DiscussionCardDisplayMode(rawValue: state.displayModeRawValue) ?? .expanded,
            pendingOperation: nil,
            inlineStatusMessage: nil
        )
    }

    static func decodeDiscussionState(from data: Data?) -> FeedCardDiscussionStatePayload {
        guard
            let data,
            let payload = try? JSONDecoder().decode(FeedCardDiscussionStatePayload.self, from: data)
        else {
            return FeedCardDiscussionStatePayload(
                isParticipating: false,
                replyCount: 0,
                joinedCount: 0,
                displayModeRawValue: DiscussionCardDisplayMode.expanded.rawValue
            )
        }

        return payload
    }

    @available(iOS 17, *)
    static func mapChannel(_ channel: ChannelRecord) -> AppChannel {
        AppChannel(
            id: channel.id,
            title: channel.title,
            subtitle: channel.subtitle
        )
    }

    static func mapChannel(_ channel: CoreDataChannelEntity) -> AppChannel {
        AppChannel(
            id: channel.id,
            title: channel.title,
            subtitle: channel.subtitle
        )
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
