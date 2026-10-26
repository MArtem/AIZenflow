import Foundation
import Observation
import os
import SwiftData
import Testing
@testable import AIFieldbook

struct LocalSearchTests {
    @Test @MainActor
    func localSearchRespectsCombinedCriteria() async throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let repository = FieldbookRepository(context: container.mainContext)
        let firstWorkspace = try repository.createWorkspace(name: "First")
        let secondWorkspace = try repository.createWorkspace(name: "Second")
        let firstNote = try repository.createTextNote(
            workspaceID: firstWorkspace, title: "Needle Alpha", body: "First body"
        )
        let secondNote = try repository.createTextNote(
            workspaceID: secondWorkspace, title: "Beta", body: "Needle in body"
        )
        let tag = try repository.createTag(name: "Pinned")
        try repository.setTagAssignment(itemID: firstNote, tagID: tag, isAssigned: true)
        let index = FieldbookSearchIndex(modelContainer: container)

        let empty = try await index.search(criteria: .init(
            query: "  ", workspaceID: nil, kind: nil, tagID: nil
        ))
        #expect(empty.isEmpty)
        let all = try await index.search(criteria: .init(
            query: "Needle", workspaceID: nil, kind: nil, tagID: nil
        ))
        #expect(Set(all.map(\.id)) == Set([firstNote, secondNote]))
        let scoped = try await index.search(criteria: .init(
            query: "Needle", workspaceID: firstWorkspace, kind: .textNote, tagID: tag
        ))
        #expect(scoped.map(\.id) == [firstNote])
        let otherWorkspace = try await index.search(criteria: .init(
            query: "Needle", workspaceID: secondWorkspace, kind: nil, tagID: tag
        ))
        #expect(otherWorkspace.isEmpty)
        let otherKind = try await index.search(criteria: .init(
            query: "Needle", workspaceID: firstWorkspace, kind: .image, tagID: nil
        ))
        #expect(otherKind.isEmpty)
        let bodyMatch = try await index.search(criteria: .init(
            query: "in body", workspaceID: secondWorkspace, kind: .textNote, tagID: nil
        ))
        #expect(bodyMatch.map(\.id) == [secondNote])
    }

    @Test(.timeLimit(.minutes(1))) @MainActor
    func searchCapsMatchingResultsAfterTextFiltering() async throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let repository = FieldbookRepository(context: container.mainContext)
        let workspace = try repository.createWorkspace(name: "Bounded search")
        var matchingIDs: Set<UUID> = []
        for number in 0..<105 {
            let id = try repository.createTextNote(
                workspaceID: workspace, title: "Needle \(number)", body: "Matching"
            )
            matchingIDs.insert(id)
        }
        // Newer nonmatching rows must not consume a limit applied before text filtering.
        for number in 0..<105 {
            _ = try repository.createTextNote(
                workspaceID: workspace, title: "Other \(number)", body: "Unrelated"
            )
        }
        let index = FieldbookSearchIndex(modelContainer: container)
        let results = try await index.search(criteria: .init(
            query: "Needle", workspaceID: workspace, kind: .textNote, tagID: nil
        ))

        #expect(results.count == 100)
        #expect(Set(results.map(\.id)).count == 100)
        #expect(Set(results.map(\.id)).isSubset(of: matchingIDs))
    }

    @Test(.timeLimit(.minutes(1))) @MainActor
    func failedSearchRetriesWithTheSameCriteria() async throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let repository = FieldbookRepository(context: container.mainContext)
        let workspace = try repository.createWorkspace(name: "Retry")
        let note = try repository.createTextNote(
            workspaceID: workspace, title: "Needle", body: "Saved note"
        )
        let criteria = FieldbookSearchCriteria(
            query: "Needle", workspaceID: workspace, kind: nil, tagID: nil
        )
        let realResults = try await FieldbookSearchIndex(modelContainer: container).search(criteria: criteria)
        let service = ControlledFieldbookSearch()
        let model = SearchViewModel(repository: repository, searchIndex: service)
        let (events, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let observer = SearchStateObserver(model: model, continuation: continuation)
        defer { observer.finish(); model.disappeared() }
        observer.observe()
        var states = events.makeAsyncIterator()
        var requests = service.requests.makeAsyncIterator()
        model.appeared()
        model.workspaceSelectionChanged(workspace)
        model.queryChanged("Needle")
        let first = try #require(await requests.next())
        #expect(first.criteria == criteria)
        #expect(await service.fail(first.id))
        while await states.next() != nil {
            if case .failure = model.state { break }
        }
        guard case let .failure(form, message) = model.state else {
            Issue.record("Search failure must not become empty success")
            return
        }
        #expect(form.query == "Needle")
        #expect(form.selectedWorkspaceID == workspace)
        #expect(!message.isEmpty)
        #expect(model.state.rows.isEmpty)

        model.retryTapped()
        let retry = try #require(await requests.next())
        #expect(retry.criteria == criteria)
        #expect(retry.id != first.id)
        if case .searching = model.state {
            // The request remains controlled until the explicit success below.
        } else {
            Issue.record("Retry must publish searching before completion")
        }
        #expect(await service.succeed(retry.id, results: realResults))
        while await states.next() != nil {
            if case .results = model.state { break }
        }
        #expect(model.state.rows.map(\.id) == [note])
        #expect(model.state.form.query == "Needle")
        #expect(model.state.form.selectedWorkspaceID == workspace)
    }

    @Test(.timeLimit(.minutes(1))) @MainActor
    func cancelledSearchCannotOverwriteSameCriteriaRetryWithLateFailure() async throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let repository = FieldbookRepository(context: container.mainContext)
        let workspace = try repository.createWorkspace(name: "Late failure")
        let note = try repository.createTextNote(workspaceID: workspace, title: "Needle", body: "Saved")
        let criteria = FieldbookSearchCriteria(query: "Needle", workspaceID: nil, kind: nil, tagID: nil)
        let rows = try await FieldbookSearchIndex(modelContainer: container).search(criteria: criteria)
        let service = ControlledFieldbookSearch()
        var requests = service.requests.makeAsyncIterator()
        let model = SearchViewModel(repository: repository, searchIndex: service)
        defer { model.disappeared() }
        model.appeared()
        model.queryChanged("Needle")
        let obsoleteRequest = try #require(await requests.next())
        let obsoleteCompletion = try #require(model.searchCompletionSnapshot())
        model.disappeared()
        model.appeared()
        let currentRequest = try #require(await requests.next())
        let currentCompletion = try #require(model.searchCompletionSnapshot())
        #expect(currentRequest.criteria == obsoleteRequest.criteria)
        #expect(await service.succeed(currentRequest.id, results: rows))
        await currentCompletion()
        #expect(model.state.rows.map(\.id) == [note])

        // The provider deliberately ignores cancellation and delivers a generic late error.
        #expect(await service.fail(obsoleteRequest.id))
        await obsoleteCompletion()
        guard case .results = model.state else {
            Issue.record("Cancelled obsolete failure replaced the successful same-criteria search")
            return
        }
        #expect(model.state.rows.map(\.id) == [note])
        #expect(model.state.form.query == "Needle")
    }

    @Test(.timeLimit(.minutes(1))) @MainActor
    func searchStateFollowsLatestCriteria() async throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let repository = FieldbookRepository(context: container.mainContext)
        let firstWorkspace = try repository.createWorkspace(name: "First")
        let secondWorkspace = try repository.createWorkspace(name: "Second")
        _ = try repository.createTextNote(workspaceID: firstWorkspace, title: "Alpha", body: "A")
        let beta = try repository.createTextNote(workspaceID: secondWorkspace, title: "Beta", body: "B")
        let model = SearchViewModel(
            repository: repository, searchIndex: FieldbookSearchIndex(modelContainer: container)
        )
        let (events, continuation) = AsyncStream<Void>.makeStream(bufferingPolicy: .bufferingNewest(1))
        let observer = SearchStateObserver(model: model, continuation: continuation)
        defer { observer.finish() }
        observer.observe()
        var iterator = events.makeAsyncIterator()

        model.appeared()
        model.queryChanged("Alpha")
        model.queryChanged("Beta")
        while await iterator.next() != nil {
            if case .results = model.state { break }
        }
        #expect(model.state.form.query == "Beta")
        #expect(model.state.rows.map(\.id) == [beta])

        model.queryChanged("Alpha")
        model.clearTapped()
        guard case let .criteria(form) = model.state else {
            Issue.record("Clear must immediately restore criteria state")
            return
        }
        #expect(!form.hasActiveCriteria)
        #expect(model.state.rows.isEmpty)

        model.queryChanged("Beta")
        model.disappeared()
        model.appeared()
        while await iterator.next() != nil {
            if case .results = model.state { break }
        }
        #expect(model.state.form.query == "Beta")
        #expect(model.state.rows.map(\.id) == [beta])

        model.workspaceSelectionChanged(firstWorkspace)
        while await iterator.next() != nil {
            if case .empty = model.state { break }
        }
        #expect(model.state.form.selectedWorkspaceID == firstWorkspace)
        #expect(model.state.rows.isEmpty)
        model.workspaceSelectionChanged(secondWorkspace)
        while await iterator.next() != nil {
            if case .results = model.state { break }
        }
        #expect(model.state.form.selectedWorkspaceID == secondWorkspace)
        #expect(model.state.rows.map(\.id) == [beta])
    }

    @Test @MainActor
    func workspaceCacheLookupDoesNotInvalidateObservation() throws {
        let schema = Schema(AIFieldbookSchemaV3.models)
        let container = try ModelContainer(
            for: schema,
            configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)]
        )
        let composition = AppComposition(container: container)
        let id = try composition.repository.createWorkspace(name: "Cache observation fixture")
        let first = composition.workspaceDetailModel(id: id)
        let invalidations = OSAllocatedUnfairLock(initialState: 0)
        var observed: WorkspaceDetailViewModel?
        withObservationTracking {
            observed = composition.workspaceDetailModel(id: id)
        } onChange: {
            invalidations.withLock { $0 += 1 }
        }
        let next = composition.workspaceDetailModel(id: id)
        #expect(first === observed)
        #expect(first === next)
        #expect(invalidations.withLock { $0 } == 0,
                "Operational LRU lookup invalidates the destination that reads it")
    }

}


@MainActor
private final class SearchStateObserver {
    private let model: SearchViewModel
    private let continuation: AsyncStream<Void>.Continuation
    private var active = true

    init(model: SearchViewModel, continuation: AsyncStream<Void>.Continuation) {
        self.model = model
        self.continuation = continuation
    }

    func observe() {
        guard active else { return }
        withObservationTracking {
            _ = model.state
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in self?.observe() }
        }
        continuation.yield(())
    }

    func finish() {
        active = false
        continuation.finish()
    }
}

private actor ControlledFieldbookSearch: FieldbookSearching {
    struct Request: Sendable {
        let id: Int
        let criteria: FieldbookSearchCriteria
    }

    nonisolated let requests: AsyncStream<Request>
    private let continuation: AsyncStream<Request>.Continuation
    private var nextID = 0
    private var pending: [Int: CheckedContinuation<[KnowledgeItemSummary], any Error>] = [:]

    init() {
        (requests, continuation) = AsyncStream<Request>.makeStream()
    }

    func search(criteria: FieldbookSearchCriteria) async throws -> [KnowledgeItemSummary] {
        nextID += 1
        let id = nextID
        return try await withCheckedThrowingContinuation { pendingResult in
            pending[id] = pendingResult
            continuation.yield(Request(id: id, criteria: criteria))
        }
    }

    func fail(_ id: Int) -> Bool {
        guard let result = pending.removeValue(forKey: id) else { return false }
        result.resume(throwing: FixtureError.unavailable)
        return true
    }

    func succeed(_ id: Int, results: [KnowledgeItemSummary]) -> Bool {
        guard let result = pending.removeValue(forKey: id) else { return false }
        result.resume(returning: results)
        return true
    }

    private enum FixtureError: Error { case unavailable }
}
