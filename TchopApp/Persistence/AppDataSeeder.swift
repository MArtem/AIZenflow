import Foundation
import CoreData
import SwiftData
import TchopDatabase

/// Seeds the local persistence backend with the initial app content.
@MainActor
enum AppDataSeeder {
    /// Inserts the default channel record on first launch only.
    static func seedIfNeeded(in databaseManager: any DatabaseManaging) throws {
        let hasPrimaryChannel = try databaseManager.read(
            DatabaseReadOperation(
                swiftData: { context in
                    try context.fetchCount(FetchDescriptor<ChannelRecord>()) > 0
                },
                coreData: { context in
                    try context.count(for: CoreDataChannelEntity.fetchRequest()) > 0
                }
            )
        )

        guard !hasPrimaryChannel else {
            return
        }

        _ = try databaseManager.write(
            DatabaseWriteOperation(
                swiftData: { context in
                    context.insert(
                        ChannelRecord(
                            id: "primary-channel",
                            title: "Tchop",
                            subtitle: "New channel name"
                        )
                    )
                },
                coreData: { context in
                    let entity = CoreDataChannelEntity(context: context)
                    entity.id = "primary-channel"
                    entity.title = "Tchop"
                    entity.subtitle = "New channel name"
                }
            )
        ) as Void
    }
}
