import Foundation
import SwiftData
import TchopDatabase

/// Repository used by app composition to resolve locally available channels.
@MainActor
protocol AppContentRepository {
    /// Fetches all locally available channels for the active runtime.
    func fetchAvailableChannels() throws -> [AppChannel]
}

/// Persists locally created feed cards in the app SwiftData store.
@MainActor
struct FeedCardRepository: FeedCardPersisting {
    private let databaseManager: any DatabaseManaging

    init(databaseManager: any DatabaseManaging) {
        self.databaseManager = databaseManager

        precondition(
            databaseManager.backendKind == .swiftData,
            "FeedCardRepository expects SwiftData runtime backend."
        )
    }

    func loadCards() throws -> [FeedCard] {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let records = try context.fetch(FetchDescriptor<FeedCardRecord>())
                    .sorted(by: { $0.createdAt > $1.createdAt })
                return try records.map(Self.decodeCard)
            })
        )
    }

    func saveCards(_ cards: [FeedCard]) throws {
        guard !cards.isEmpty else {
            return
        }

        try databaseManager.write(
            DatabaseWriteOperation(swiftData: { context in
                let existingRecords = try context.fetch(FetchDescriptor<FeedCardRecord>())

                for card in cards {
                    let payloadData = try JSONEncoder().encode(card)

                    if let existingRecord = existingRecords.first(where: { $0.id == card.id }) {
                        Self.apply(card, payloadData: payloadData, to: existingRecord)
                    } else {
                        context.insert(Self.makeRecord(from: card, payloadData: payloadData))
                    }
                }
            })
        ) as Void
    }

    private static func decodeCard(from record: FeedCardRecord) throws -> FeedCard {
        try JSONDecoder().decode(FeedCard.self, from: record.payloadData)
    }

    private static func makeRecord(
        from card: FeedCard,
        payloadData: Data
    ) -> FeedCardRecord {
        FeedCardRecord(
            id: card.id,
            channelID: card.channelID,
            kindRawValue: card.kind.rawValue,
            createdAt: card.createdAt,
            payloadData: payloadData
        )
    }

    private static func apply(
        _ card: FeedCard,
        payloadData: Data,
        to record: FeedCardRecord
    ) {
        record.channelID = card.channelID
        record.kindRawValue = card.kind.rawValue
        record.createdAt = card.createdAt
        record.payloadData = payloadData
    }
}

/// Default app content repository for local channel persistence.
@MainActor
final class DefaultAppContentRepository: AppContentRepository {
    private let databaseManager: any DatabaseManaging

    /// Creates a new DefaultAppContentRepository instance.
    init(databaseManager: any DatabaseManaging) {
        self.databaseManager = databaseManager

        // Active runtime policy is SwiftData-only.
        precondition(
            databaseManager.backendKind == .swiftData,
            "DefaultAppContentRepository expects SwiftData runtime backend."
        )
    }

    /// Fetches channel data from local persistence.
    func fetchAvailableChannels() throws -> [AppChannel] {
        let channels = try fetchSwiftDataChannels()
        guard !channels.isEmpty else {
            throw RepositoryError.missingChannel
        }

        return channels
    }

    /// Fetches channels through the SwiftData backend.
    private func fetchSwiftDataChannels() throws -> [AppChannel] {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                let descriptor = FetchDescriptor<ChannelRecord>()
                return try context.fetch(descriptor).map(AppContentMapper.mapChannel)
            })
        )
    }
}

enum RepositoryError: Error {
    case missingChannel
    case unsupportedFeedCardPersistence
}

private enum AppContentMapper {
    static func mapChannel(_ channel: ChannelRecord) -> AppChannel {
        AppChannel(
            id: channel.id,
            title: channel.title,
            subtitle: channel.subtitle
        )
    }
}
