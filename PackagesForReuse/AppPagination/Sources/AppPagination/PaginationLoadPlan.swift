import Foundation

public enum PaginationLoadPlan: Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    case request(PaginationRequest)
    case noLoad(reason: NoLoadReason)

    public enum NoLoadReason: Sendable, Equatable {
        case alreadyLoading
        case reachedForwardEnd
        case reachedBackwardEnd
    }

    public var description: String {
        switch self {
        case .request(let request):
            "PaginationLoadPlan.request(\(request))"
        case .noLoad(let reason):
            "PaginationLoadPlan.noLoad(reason:\(reason))"
        }
    }

    public var debugDescription: String { description }
}

public enum PaginationLoadPlanner {
    public static func refresh<Item: Sendable>(
        state: PaginationState<Item>,
        pageSize: PageSize,
        position: PaginationPosition
    ) -> PaginationLoadPlan {
        if state.isLoading {
            return .noLoad(reason: .alreadyLoading)
        }
        return .request(.refresh(collectionID: state.collectionID, pageSize: pageSize, position: position))
    }

    public static func next<Item: Sendable>(
        state: PaginationState<Item>,
        pageSize: PageSize,
        mode: PaginationMode
    ) -> PaginationLoadPlan {
        if state.isLoading {
            return .noLoad(reason: .alreadyLoading)
        }
        guard state.hasMoreForward else {
            return .noLoad(reason: .reachedForwardEnd)
        }
        return .request(PaginationRequest(
            collectionID: state.collectionID,
            direction: .next,
            pageSize: pageSize,
            position: positionForNext(state: state, mode: mode)
        ))
    }

    public static func previous<Item: Sendable>(
        state: PaginationState<Item>,
        pageSize: PageSize,
        mode: PaginationMode
    ) -> PaginationLoadPlan {
        if state.isLoading {
            return .noLoad(reason: .alreadyLoading)
        }
        guard state.hasMoreBackward else {
            return .noLoad(reason: .reachedBackwardEnd)
        }
        return .request(PaginationRequest(
            collectionID: state.collectionID,
            direction: .previous,
            pageSize: pageSize,
            position: positionForPrevious(state: state, mode: mode)
        ))
    }

    private static func positionForNext<Item: Sendable>(state: PaginationState<Item>, mode: PaginationMode) -> PaginationPosition {
        switch mode {
        case .cursor:
            .cursor(after: state.nextCursor, before: nil)
        case .offset:
            .offset(state.nextOffset)
        case .page:
            .page(state.nextPage)
        }
    }

    private static func positionForPrevious<Item: Sendable>(state: PaginationState<Item>, mode: PaginationMode) -> PaginationPosition {
        switch mode {
        case .cursor:
            .cursor(after: nil, before: state.previousCursor)
        case .offset:
            .offset(.zero)
        case .page:
            .page(.zero)
        }
    }
}

public enum PaginationMode: Codable, Hashable, Sendable {
    case cursor
    case offset
    case page
}
