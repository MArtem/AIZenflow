import Foundation
import CoreData
import SwiftData
import AppDatabase

/// Seeds the local persistence backend with the initial app content.
@MainActor
enum AppDataSeeder {
    private static let seededChannels: [AppChannel] = [
        .product,
        .community,
        .leadership
    ]

    /// Inserts the default channels on first launch only.
    static func seedIfNeeded(in databaseManager: any DatabaseManaging) throws {
        precondition(
            databaseManager.backendKind == .swiftData,
            "AppDataSeeder expects SwiftData runtime backend."
        )

        try seedChannelIfNeeded(in: databaseManager)
    }

    /// Inserts the default channel record only when it is still missing.
    private static func seedChannelIfNeeded(in databaseManager: any DatabaseManaging) throws {
        let hasPrimaryChannel = try fetchHasPrimaryChannel(in: databaseManager)

        guard !hasPrimaryChannel else {
            return
        }

        if #available(iOS 17, *) {
            _ = try databaseManager.write(
                DatabaseWriteOperation(swiftData: { context in
                    for channel in seededChannels {
                        context.insert(
                            ChannelRecord(
                                id: channel.id,
                                title: channel.title,
                                subtitle: channel.subtitle
                            )
                        )
                    }
                })
            ) as Void
            return
        }

        try writeLegacyCoreDataChannels(in: databaseManager)
    }

    @available(iOS 17, *)
    private static func fetchHasPrimaryChannel(in databaseManager: any DatabaseManaging) throws -> Bool {
        try databaseManager.read(
            DatabaseReadOperation(swiftData: { context in
                try context.fetchCount(FetchDescriptor<ChannelRecord>()) > 0
            })
        )
    }

    /// Legacy Core Data fallback is kept as rollback-only code.
    private static func writeLegacyCoreDataChannels(in databaseManager: any DatabaseManaging) throws {
        _ = try databaseManager.write(
            DatabaseWriteOperation(coreData: { context in
                for channel in seededChannels {
                    let entity = CoreDataChannelEntity(context: context)
                    entity.id = channel.id
                    entity.title = channel.title
                    entity.subtitle = channel.subtitle
                }
            })
        ) as Void
    }
}
