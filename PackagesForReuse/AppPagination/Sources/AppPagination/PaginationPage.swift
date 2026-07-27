import Foundation

public struct PaginationPage<Item: Sendable>: Sendable {
    public let items: [Item]
    public let request: PaginationRequest
    public let nextCursor: PaginationCursor?
    public let previousCursor: PaginationCursor?
    public let hasMoreForward: Bool
    public let hasMoreBackward: Bool

    public init(
        items: [Item],
        request: PaginationRequest,
        nextCursor: PaginationCursor?,
        previousCursor: PaginationCursor?,
        hasMoreForward: Bool,
        hasMoreBackward: Bool
    ) throws {
        if items.isEmpty && hasMoreForward && nextCursor == nil {
            throw PaginationFailure.invalidResponse(reason: .emptyPageWithoutEndMarker)
        }
        if case .cursor(let after, _) = request.position, let after, let nextCursor, after == nextCursor {
            throw PaginationFailure.invalidResponse(reason: .cursorDidNotAdvance)
        }
        if case .cursor(_, let before) = request.position, let before, let previousCursor, before == previousCursor {
            throw PaginationFailure.invalidResponse(reason: .cursorDidNotAdvance)
        }
        self.items = items
        self.request = request
        self.nextCursor = nextCursor
        self.previousCursor = previousCursor
        self.hasMoreForward = hasMoreForward
        self.hasMoreBackward = hasMoreBackward
    }
}

extension PaginationPage: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        "PaginationPage(count:\(items.count),nextCursor:\(nextCursor == nil ? "nil" : "<redacted>"),previousCursor:\(previousCursor == nil ? "nil" : "<redacted>"),hasMoreForward:\(hasMoreForward),hasMoreBackward:\(hasMoreBackward))"
    }

    public var debugDescription: String { description }
}
