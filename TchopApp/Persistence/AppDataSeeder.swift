import Foundation
import CoreData
import SwiftData
import TchopDatabase

/// Seeds the local persistence backend with the initial app content.
@MainActor
enum AppDataSeeder {
    /// Inserts the default channel and the initial feed snapshot on first launch only.
    static func seedIfNeeded(in databaseManager: any DatabaseManaging) throws {
        try seedChannelIfNeeded(in: databaseManager)
        try seedFeedIfNeeded(in: databaseManager)
    }

    /// Inserts the default channel record only when it is still missing.
    private static func seedChannelIfNeeded(in databaseManager: any DatabaseManaging) throws {
        let hasPrimaryChannel: Bool
        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                hasPrimaryChannel = try databaseManager.read(
                    DatabaseReadOperation(swiftData: { context in
                        try context.fetchCount(FetchDescriptor<ChannelRecord>()) > 0
                    })
                )
            } else {
                hasPrimaryChannel = try databaseManager.read(
                    DatabaseReadOperation(coreData: { context in
                        try context.count(for: CoreDataChannelEntity.fetchRequest()) > 0
                    })
                )
            }
        case .coreData:
            hasPrimaryChannel = try databaseManager.read(
                DatabaseReadOperation(coreData: { context in
                    try context.count(for: CoreDataChannelEntity.fetchRequest()) > 0
                })
            )
        }

        guard !hasPrimaryChannel else {
            return
        }

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                _ = try databaseManager.write(
                    DatabaseWriteOperation(swiftData: { context in
                        context.insert(
                            ChannelRecord(
                                id: "primary-channel",
                                title: AppLocalization.text("channel.default.title", fallback: "Tchop"),
                                subtitle: AppLocalization.text("channel.default.subtitle", fallback: "New channel name")
                            )
                        )
                    })
                ) as Void
            } else {
                _ = try databaseManager.write(
                    DatabaseWriteOperation(coreData: { context in
                        let entity = CoreDataChannelEntity(context: context)
                        entity.id = "primary-channel"
                        entity.title = AppLocalization.text("channel.default.title", fallback: "Tchop")
                        entity.subtitle = AppLocalization.text("channel.default.subtitle", fallback: "New channel name")
                    })
                ) as Void
            }
        case .coreData:
            _ = try databaseManager.write(
                DatabaseWriteOperation(coreData: { context in
                    let entity = CoreDataChannelEntity(context: context)
                    entity.id = "primary-channel"
                    entity.title = AppLocalization.text("channel.default.title", fallback: "Tchop")
                    entity.subtitle = AppLocalization.text("channel.default.subtitle", fallback: "New channel name")
                })
            ) as Void
        }
    }

    /// Inserts the initial persisted feed snapshot only when the feed store is still empty.
    private static func seedFeedIfNeeded(in databaseManager: any DatabaseManaging) throws {
        let hasPersistedFeedCards: Bool

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                hasPersistedFeedCards = try databaseManager.read(
                    DatabaseReadOperation(swiftData: { context in
                        try context.fetchCount(FetchDescriptor<FeedCardRecord>()) > 0
                    })
                )
            } else {
                hasPersistedFeedCards = try databaseManager.read(
                    DatabaseReadOperation(coreData: { context in
                        try context.count(for: CoreDataFeedCardEntity.fetchRequest()) > 0
                    })
                )
            }
        case .coreData:
            hasPersistedFeedCards = try databaseManager.read(
                DatabaseReadOperation(coreData: { context in
                    try context.count(for: CoreDataFeedCardEntity.fetchRequest()) > 0
                })
            )
        }

        guard !hasPersistedFeedCards else {
            return
        }

        let feedResponse = try FeedAPIStubFactory.loadFeedResponse()
        let syncedAt = Date()
        let payloads = try feedResponse.cards.enumerated().map { index, card in
            try makeFeedSeedPayload(card, sortOrder: index, syncedAt: syncedAt)
        }

        switch databaseManager.backendKind {
        case .swiftData:
            if #available(iOS 17, *) {
                _ = try databaseManager.write(
                    DatabaseWriteOperation(swiftData: { context in
                        for payload in payloads {
                            context.insert(makeFeedCardRecord(from: payload))
                        }
                    })
                ) as Void
            } else {
                try seedCoreDataFeedCards(payloads, in: databaseManager)
            }
        case .coreData:
            try seedCoreDataFeedCards(payloads, in: databaseManager)
        }
    }

    /// Persists feed seed payloads into the Core Data backend.
    private static func seedCoreDataFeedCards(
        _ payloads: [FeedSeedPayload],
        in databaseManager: any DatabaseManaging
    ) throws {
        _ = try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                for payload in payloads {
                    let entity = CoreDataFeedCardEntity(context: context)
                    apply(payload, to: entity)
                }
            })
        ) as Void
    }

    /// Backend-agnostic payload used to seed the first persisted feed snapshot.
    ///
    /// The seeder builds this once from the bundled JSON contract and then writes the same
    /// values into either SwiftData or Core Data so both backends start from identical content.
    private struct FeedSeedPayload {
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
        let articleStateData: Data?
        let categoryTitle: String?
        let participantsData: Data?
        let joinedText: String?
        let discussionStateData: Data?
    }

    /// Maps one decoded feed card into the backend-agnostic seed payload.
    private static func makeFeedSeedPayload(
        _ card: FeedCardDTO,
        sortOrder: Int,
        syncedAt: Date
    ) throws -> FeedSeedPayload {
        switch card {
        case let .featuredArticle(article):
            return FeedSeedPayload(
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
                            kind: $0.kind,
                            systemName: $0.systemName,
                            title: $0.title
                        )
                    }
                ),
                articleStateData: try JSONEncoder().encode(
                    FeedCardArticleStatePayload(
                        isLiked: article.localState.isLiked,
                        commentCount: article.localState.commentCount,
                        displayModeRawValue: article.localState.displayMode.rawValue
                    )
                ),
                categoryTitle: nil,
                participantsData: nil,
                joinedText: nil,
                discussionStateData: nil
            )
        case let .discussion(discussion):
            return FeedSeedPayload(
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
                joinedText: "+\(discussion.localState.joinedCount) joined",
                discussionStateData: try JSONEncoder().encode(
                    FeedCardDiscussionStatePayload(
                        isParticipating: discussion.localState.isParticipating,
                        replyCount: discussion.localState.replyCount,
                        joinedCount: discussion.localState.joinedCount,
                        displayModeRawValue: discussion.localState.displayMode.rawValue
                    )
                )
            )
        }
    }

    @available(iOS 17, *)
    private static func makeFeedCardRecord(from payload: FeedSeedPayload) -> FeedCardRecord {
        FeedCardRecord(
            id: payload.id,
            kind: payload.kind,
            sortOrder: payload.sortOrder,
            remoteUpdatedAt: payload.remoteUpdatedAt,
            syncedAt: payload.syncedAt,
            publishedAt: payload.publishedAt,
            postedInPrefix: payload.postedInPrefix,
            sourceTitle: payload.sourceTitle,
            brandTitle: payload.brandTitle,
            headline: payload.headline,
            summary: payload.summary,
            metadataLine: payload.metadataLine,
            translationLabel: payload.translationLabel,
            articleActionsData: payload.articleActionsData,
            articleStateData: payload.articleStateData,
            categoryTitle: payload.categoryTitle,
            participantsData: payload.participantsData,
            joinedText: payload.joinedText,
            discussionStateData: payload.discussionStateData
        )
    }

    private static func apply(_ payload: FeedSeedPayload, to entity: CoreDataFeedCardEntity) {
        entity.id = payload.id
        entity.kindRawValue = payload.kind.rawValue
        entity.sortOrder = Int64(payload.sortOrder)
        entity.remoteUpdatedAt = payload.remoteUpdatedAt
        entity.syncedAt = payload.syncedAt
        entity.publishedAt = payload.publishedAt
        entity.postedInPrefix = payload.postedInPrefix
        entity.sourceTitle = payload.sourceTitle
        entity.brandTitle = payload.brandTitle
        entity.headline = payload.headline
        entity.summary = payload.summary
        entity.metadataLine = payload.metadataLine
        entity.translationLabel = payload.translationLabel
        entity.articleActionsData = payload.articleActionsData
        entity.articleStateData = payload.articleStateData
        entity.categoryTitle = payload.categoryTitle
        entity.participantsData = payload.participantsData
        entity.joinedText = payload.joinedText
        entity.discussionStateData = payload.discussionStateData
    }
}
