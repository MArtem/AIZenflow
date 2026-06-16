import Foundation

public actor AppPaginator<Item: Sendable, Loader: PaginationPageLoader, Store: PaginationStateStore> where Loader.Item == Item, Store.Item == Item {
    private let collectionID: PaginationCollectionID
    private let pageSize: PageSize
    private let mode: PaginationMode
    private let mergePolicy: PaginationMergePolicy
    private let loader: Loader
    private let store: Store

    public init(
        collectionID: PaginationCollectionID,
        pageSize: PageSize,
        mode: PaginationMode,
        mergePolicy: PaginationMergePolicy = .byRequestDirection,
        loader: Loader,
        store: Store
    ) {
        self.collectionID = collectionID
        self.pageSize = pageSize
        self.mode = mode
        self.mergePolicy = mergePolicy
        self.loader = loader
        self.store = store
    }

    public func currentState() async throws -> PaginationState<Item> {
        if let state = try await store.loadState(collectionID: collectionID) {
            return state
        }
        let empty = try PaginationState<Item>.empty(collectionID: collectionID)
        try await store.saveState(empty)
        return empty
    }

    @discardableResult
    public func refresh(position: PaginationPosition) async throws -> PaginationState<Item> {
        var state = try await currentState()
        let plan = PaginationLoadPlanner.refresh(state: state, pageSize: pageSize, position: position)
        guard case .request(let request) = plan else {
            throw PaginationFailure.loadAlreadyInProgress
        }
        state = try state.withLoading(true)
        try await store.saveState(state)
        do {
            let page = try await loader.loadPage(request)
            let newState = try state.applying(page, mergePolicy: .replace)
            try await store.saveState(newState)
            return newState
        } catch {
            await clearLoadingBestEffort(from: state)
            throw error
        }
    }

    @discardableResult
    public func loadNext() async throws -> PaginationState<Item> {
        var state = try await currentState()
        let plan = PaginationLoadPlanner.next(state: state, pageSize: pageSize, mode: mode)
        guard case .request(let request) = plan else {
            return state
        }
        state = try state.withLoading(true)
        try await store.saveState(state)
        do {
            let page = try await loader.loadPage(request)
            let newState = try state.applying(page, mergePolicy: mergePolicy)
            try await store.saveState(newState)
            return newState
        } catch {
            await clearLoadingBestEffort(from: state)
            throw error
        }
    }

    @discardableResult
    public func loadPrevious() async throws -> PaginationState<Item> {
        var state = try await currentState()
        let plan = PaginationLoadPlanner.previous(state: state, pageSize: pageSize, mode: mode)
        guard case .request(let request) = plan else {
            return state
        }
        state = try state.withLoading(true)
        try await store.saveState(state)
        do {
            let page = try await loader.loadPage(request)
            let newState = try state.applying(page, mergePolicy: mergePolicy)
            try await store.saveState(newState)
            return newState
        } catch {
            await clearLoadingBestEffort(from: state)
            throw error
        }
    }

    public func reset() async throws {
        try await store.resetState(collectionID: collectionID)
    }

    private func clearLoadingBestEffort(from state: PaginationState<Item>) async {
        do {
            let nonLoadingState = try state.withLoading(false)
            try await store.saveState(nonLoadingState)
        } catch {
            // Preserve the original loader/merge/save failure for the caller.
        }
    }
}
