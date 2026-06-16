import XCTest
@testable import AppPagination

final class AppPaginationTests: XCTestCase {
    func testSafeIdentifiersRejectUnsafeValues() throws {
        XCTAssertThrowsError(try PaginationCollectionID(""))
        XCTAssertThrowsError(try PaginationCollectionID("feed/../../x"))
        let id = try PaginationCollectionID("news.feed")
        XCTAssertEqual(id.rawValue, "news.feed")
        XCTAssertFalse(id.description.contains("news.feed"))
    }

    func testPageSizeAndIndexesValidateBounds() throws {
        XCTAssertThrowsError(try PageSize(0))
        XCTAssertThrowsError(try PageSize(501))
        XCTAssertThrowsError(try PageIndex(-1))
        XCTAssertThrowsError(try ItemOffset(-1))
        XCTAssertEqual(try PageSize(25).value, 25)
    }

    func testLoadPlannerCreatesOffsetNextRequest() throws {
        let collection = try PaginationCollectionID("articles")
        let state = try PaginationState<Int>.empty(collectionID: collection)
        let plan = PaginationLoadPlanner.next(state: state, pageSize: try PageSize(20), mode: .offset)

        guard case .request(let request) = plan else {
            XCTFail("Expected request")
            return
        }

        XCTAssertEqual(request.collectionID, collection)
        XCTAssertEqual(request.direction, .next)
        XCTAssertEqual(request.pageSize.value, 20)
        XCTAssertEqual(request.position, .offset(.zero))
    }

    func testStateAppliesRefreshAndAppendPages() throws {
        let collection = try PaginationCollectionID("articles")
        let request = PaginationRequest(
            collectionID: collection,
            direction: .refresh,
            pageSize: try PageSize(2),
            position: .page(.zero)
        )
        let page = try PaginationPage(
            items: [1, 2],
            request: request,
            nextCursor: try PaginationCursor("c2"),
            previousCursor: nil,
            hasMoreForward: true,
            hasMoreBackward: false
        )
        let state = try PaginationState<Int>.empty(collectionID: collection)
        let refreshed = try state.applying(page, mergePolicy: .byRequestDirection)

        XCTAssertEqual(refreshed.items, [1, 2])
        XCTAssertEqual(refreshed.nextOffset.value, 2)
        XCTAssertEqual(refreshed.nextPage.value, 1)
        XCTAssertEqual(refreshed.completedLoads, 1)

        let nextRequest = PaginationRequest(
            collectionID: collection,
            direction: .next,
            pageSize: try PageSize(2),
            position: .cursor(after: try PaginationCursor("c2"), before: nil)
        )
        let nextPage = try PaginationPage(
            items: [3, 4],
            request: nextRequest,
            nextCursor: try PaginationCursor("c4"),
            previousCursor: try PaginationCursor("c2"),
            hasMoreForward: false,
            hasMoreBackward: true
        )
        let appended = try refreshed.applying(nextPage, mergePolicy: .byRequestDirection)
        XCTAssertEqual(appended.items, [1, 2, 3, 4])
        XCTAssertFalse(appended.hasMoreForward)
    }

    func testUniqueMergerPreservesFirstOccurrence() {
        struct Row: Sendable, Equatable {
            let id: Int
            let title: String
        }

        let existing = [Row(id: 1, title: "A"), Row(id: 2, title: "B")]
        let incoming = [Row(id: 2, title: "B2"), Row(id: 3, title: "C")]
        let merged = PaginationMerger.appendUnique(existing: existing, incoming: incoming) { row in
            row.id
        }

        XCTAssertEqual(merged.map(\.id), [1, 2, 3])
        XCTAssertEqual(merged[1].title, "B")
    }

    func testPaginatorLoadsNextPageThroughBoundaries() async throws {
        let collection = try PaginationCollectionID("articles")
        let loader = OffsetNumberLoader()
        let store = InMemoryPaginationStateStore<Int>()
        let paginator = AppPaginator(
            collectionID: collection,
            pageSize: try PageSize(3),
            mode: .offset,
            loader: loader,
            store: store
        )

        let first = try await paginator.loadNext()
        XCTAssertEqual(first.items, [0, 1, 2])
        XCTAssertTrue(first.hasMoreForward)

        let second = try await paginator.loadNext()
        XCTAssertEqual(second.items, [0, 1, 2, 3, 4, 5])
    }

    func testFailedLoadClearsLoadingState() async throws {
        let collection = try PaginationCollectionID("articles")
        let store = InMemoryPaginationStateStore<Int>()
        let paginator = AppPaginator(
            collectionID: collection,
            pageSize: try PageSize(3),
            mode: .offset,
            loader: FailingPageLoader(),
            store: store
        )

        do {
            _ = try await paginator.loadNext()
            XCTFail("Expected load failure")
        } catch let error as TestPaginationLoadFailure {
            XCTAssertEqual(error, .failed)
        }

        let state = try await paginator.currentState()
        XCTAssertFalse(state.isLoading)
    }

    func testPreviousCursorMustAdvance() throws {
        let collection = try PaginationCollectionID("articles")
        let cursor = try PaginationCursor("cursor-1")
        let request = PaginationRequest(
            collectionID: collection,
            direction: .previous,
            pageSize: try PageSize(2),
            position: .cursor(after: nil, before: cursor)
        )

        XCTAssertThrowsError(
            try PaginationPage(
                items: [1, 2],
                request: request,
                nextCursor: nil,
                previousCursor: cursor,
                hasMoreForward: true,
                hasMoreBackward: true
            )
        )
    }

    func testIndexAdvancementRejectsOverflow() throws {
        let page = try PageIndex(Int.max)
        let offset = try ItemOffset(Int.max)

        XCTAssertThrowsError(try page.advanced(by: 1))
        XCTAssertThrowsError(try offset.advanced(by: 1))
    }

    func testCompletedLoadsRejectsOverflow() throws {
        let collection = try PaginationCollectionID("articles")
        let request = PaginationRequest(
            collectionID: collection,
            direction: .next,
            pageSize: try PageSize(1),
            position: .offset(.zero)
        )
        let page = try PaginationPage(
            items: [1],
            request: request,
            nextCursor: nil,
            previousCursor: nil,
            hasMoreForward: false,
            hasMoreBackward: false
        )
        let state = try PaginationState<Int>(
            collectionID: collection,
            items: [],
            nextCursor: nil,
            previousCursor: nil,
            nextOffset: .zero,
            nextPage: .zero,
            hasMoreForward: true,
            hasMoreBackward: false,
            isLoading: false,
            completedLoads: Int.max
        )

        XCTAssertThrowsError(try state.applying(page, mergePolicy: .append))
    }

    func testDescriptionsRedactCursors() throws {
        let collection = try PaginationCollectionID("private.feed")
        let request = PaginationRequest(
            collectionID: collection,
            direction: .next,
            pageSize: try PageSize(10),
            position: .cursor(after: try PaginationCursor("cursor-value"), before: nil)
        )
        let page = try PaginationPage(
            items: [1],
            request: request,
            nextCursor: try PaginationCursor("next-value"),
            previousCursor: nil,
            hasMoreForward: true,
            hasMoreBackward: false
        )

        XCTAssertFalse(request.description.contains("private.feed"))
        XCTAssertFalse(request.description.contains("cursor-value"))
        XCTAssertFalse(page.description.contains("next-value"))
    }
}

private struct OffsetNumberLoader: PaginationPageLoader {
    func loadPage(_ request: PaginationRequest) async throws -> PaginationPage<Int> {
        let start: Int
        switch request.position {
        case .offset(let offset):
            start = offset.value
        case .cursor, .page:
            start = 0
        }
        let end = start + request.pageSize.value
        return try PaginationPage(
            items: Array(start..<end),
            request: request,
            nextCursor: nil,
            previousCursor: nil,
            hasMoreForward: end < 9,
            hasMoreBackward: start > 0
        )
    }
}


private enum TestPaginationLoadFailure: Error, Equatable {
    case failed
}

private struct FailingPageLoader: PaginationPageLoader {
    func loadPage(_ request: PaginationRequest) async throws -> PaginationPage<Int> {
        throw TestPaginationLoadFailure.failed
    }
}
