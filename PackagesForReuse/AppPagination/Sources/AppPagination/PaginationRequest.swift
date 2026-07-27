import Foundation

public enum PaginationDirection: Codable, Hashable, Sendable {
    case refresh
    case next
    case previous
}

public enum PaginationPosition: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case cursor(after: PaginationCursor?, before: PaginationCursor?)
    case offset(ItemOffset)
    case page(PageIndex)

    public var description: String {
        switch self {
        case .cursor(let after, let before):
            "PaginationPosition.cursor(after:\(redactedPresence(after)),before:\(redactedPresence(before)))"
        case .offset(let offset):
            "PaginationPosition.offset(\(offset.value))"
        case .page(let page):
            "PaginationPosition.page(\(page.value))"
        }
    }

    public var debugDescription: String { description }

    private func redactedPresence(_ cursor: PaginationCursor?) -> String {
        cursor == nil ? "nil" : "<redacted>"
    }
}

public struct PaginationRequest: Codable, Hashable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public let collectionID: PaginationCollectionID
    public let direction: PaginationDirection
    public let pageSize: PageSize
    public let position: PaginationPosition

    public init(
        collectionID: PaginationCollectionID,
        direction: PaginationDirection,
        pageSize: PageSize,
        position: PaginationPosition
    ) {
        self.collectionID = collectionID
        self.direction = direction
        self.pageSize = pageSize
        self.position = position
    }

    public static func refresh(
        collectionID: PaginationCollectionID,
        pageSize: PageSize,
        position: PaginationPosition
    ) -> PaginationRequest {
        PaginationRequest(collectionID: collectionID, direction: .refresh, pageSize: pageSize, position: position)
    }

    public var description: String {
        "PaginationRequest(collection:\(collectionID),direction:\(direction),size:\(pageSize.value),position:\(position))"
    }

    public var debugDescription: String { description }
}
