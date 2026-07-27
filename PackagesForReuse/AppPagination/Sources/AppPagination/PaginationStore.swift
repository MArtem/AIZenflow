import Foundation

public protocol PaginationStateStore<Item>: Sendable {
    associatedtype Item: Sendable

    func loadState(collectionID: PaginationCollectionID) async throws -> PaginationState<Item>?
    func saveState(_ state: PaginationState<Item>) async throws
    func resetState(collectionID: PaginationCollectionID) async throws
}

public actor InMemoryPaginationStateStore<Item: Sendable>: PaginationStateStore {
    private var states: [PaginationCollectionID: PaginationState<Item>] = [:]

    public init() {}

    public func loadState(collectionID: PaginationCollectionID) async throws -> PaginationState<Item>? {
        states[collectionID]
    }

    public func saveState(_ state: PaginationState<Item>) async throws {
        states[state.collectionID] = state
    }

    public func resetState(collectionID: PaginationCollectionID) async throws {
        states.removeValue(forKey: collectionID)
    }
}
