import Foundation

public enum PaginationMerger {
    public static func appendUnique<Item: Sendable, ID: Hashable & Sendable>(
        existing: [Item],
        incoming: [Item],
        identify: @Sendable (Item) -> ID
    ) -> [Item] {
        var seen = Set<ID>()
        var result: [Item] = []
        result.reserveCapacity(existing.count + incoming.count)

        for item in existing {
            let id = identify(item)
            if seen.insert(id).inserted {
                result.append(item)
            }
        }

        for item in incoming {
            let id = identify(item)
            if seen.insert(id).inserted {
                result.append(item)
            }
        }

        return result
    }

    public static func prependUnique<Item: Sendable, ID: Hashable & Sendable>(
        existing: [Item],
        incoming: [Item],
        identify: @Sendable (Item) -> ID
    ) -> [Item] {
        appendUnique(existing: incoming, incoming: existing, identify: identify)
    }
}
