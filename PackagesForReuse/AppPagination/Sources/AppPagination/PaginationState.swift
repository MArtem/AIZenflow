import Foundation

public enum PaginationMergePolicy: Codable, Hashable, Sendable {
    case replace
    case append
    case prepend
    case byRequestDirection
}

public struct PaginationState<Item: Sendable>: Sendable {
    public let collectionID: PaginationCollectionID
    public let items: [Item]
    public let nextCursor: PaginationCursor?
    public let previousCursor: PaginationCursor?
    public let nextOffset: ItemOffset
    public let nextPage: PageIndex
    public let hasMoreForward: Bool
    public let hasMoreBackward: Bool
    public let isLoading: Bool
    public let completedLoads: Int

    public init(
        collectionID: PaginationCollectionID,
        items: [Item],
        nextCursor: PaginationCursor?,
        previousCursor: PaginationCursor?,
        nextOffset: ItemOffset,
        nextPage: PageIndex,
        hasMoreForward: Bool,
        hasMoreBackward: Bool,
        isLoading: Bool,
        completedLoads: Int
    ) throws {
        guard completedLoads >= 0 else {
            throw PaginationFailure.invalidIndex(label: "completedLoads", actual: completedLoads)
        }
        self.collectionID = collectionID
        self.items = items
        self.nextCursor = nextCursor
        self.previousCursor = previousCursor
        self.nextOffset = nextOffset
        self.nextPage = nextPage
        self.hasMoreForward = hasMoreForward
        self.hasMoreBackward = hasMoreBackward
        self.isLoading = isLoading
        self.completedLoads = completedLoads
    }

    public static func empty(collectionID: PaginationCollectionID) throws -> PaginationState<Item> {
        try PaginationState(
            collectionID: collectionID,
            items: [],
            nextCursor: nil,
            previousCursor: nil,
            nextOffset: .zero,
            nextPage: .zero,
            hasMoreForward: true,
            hasMoreBackward: false,
            isLoading: false,
            completedLoads: 0
        )
    }

    public func withLoading(_ isLoading: Bool) throws -> PaginationState<Item> {
        try PaginationState(
            collectionID: collectionID,
            items: items,
            nextCursor: nextCursor,
            previousCursor: previousCursor,
            nextOffset: nextOffset,
            nextPage: nextPage,
            hasMoreForward: hasMoreForward,
            hasMoreBackward: hasMoreBackward,
            isLoading: isLoading,
            completedLoads: completedLoads
        )
    }

    public func applying(_ page: PaginationPage<Item>, mergePolicy: PaginationMergePolicy) throws -> PaginationState<Item> {
        let resolvedItems: [Item]
        switch resolvedMergePolicy(for: page.request.direction, configured: mergePolicy) {
        case .replace:
            resolvedItems = page.items
        case .append:
            resolvedItems = items + page.items
        case .prepend:
            resolvedItems = page.items + items
        case .byRequestDirection:
            resolvedItems = items + page.items
        }

        let nextCompletedLoads = completedLoads.addingReportingOverflow(1)
        guard !nextCompletedLoads.overflow else {
            throw PaginationFailure.invalidIndex(label: "completedLoads", actual: completedLoads)
        }

        return try PaginationState(
            collectionID: collectionID,
            items: resolvedItems,
            nextCursor: page.nextCursor,
            previousCursor: page.previousCursor,
            nextOffset: nextOffset.advanced(by: page.items.count),
            nextPage: nextPage.advanced(by: 1),
            hasMoreForward: page.hasMoreForward,
            hasMoreBackward: page.hasMoreBackward,
            isLoading: false,
            completedLoads: nextCompletedLoads.partialValue
        )
    }

    private func resolvedMergePolicy(for direction: PaginationDirection, configured: PaginationMergePolicy) -> PaginationMergePolicy {
        switch configured {
        case .byRequestDirection:
            switch direction {
            case .refresh:
                .replace
            case .next:
                .append
            case .previous:
                .prepend
            }
        case .replace, .append, .prepend:
            configured
        }
    }
}

extension PaginationState: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "PaginationState(collection:\(collectionID),count:\(items.count),nextCursor:\(nextCursor == nil ? "nil" : "<redacted>"),previousCursor:\(previousCursor == nil ? "nil" : "<redacted>"),nextOffset:\(nextOffset.value),nextPage:\(nextPage.value),hasMoreForward:\(hasMoreForward),hasMoreBackward:\(hasMoreBackward),isLoading:\(isLoading),completedLoads:\(completedLoads))"
    }

    public var debugDescription: String { description }
}
