import Foundation

public protocol PaginationPageLoader<Item>: Sendable {
    associatedtype Item: Sendable

    func loadPage(_ request: PaginationRequest) async throws -> PaginationPage<Item>
}
