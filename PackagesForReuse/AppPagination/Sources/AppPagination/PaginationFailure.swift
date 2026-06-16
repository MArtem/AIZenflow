import Foundation

public enum PaginationFailure: Error, Equatable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    public enum IdentifierReason: Equatable, Sendable {
        case empty
        case tooLong(maximum: Int)
        case containsUnsafeCharacters
    }

    public enum ResponseReason: Equatable, Sendable {
        case emptyPageWithoutEndMarker
        case cursorDidNotAdvance
        case negativeCount
    }

    case invalidIdentifier(label: String, reason: IdentifierReason)
    case invalidPageSize(minimum: Int, maximum: Int, actual: Int)
    case invalidIndex(label: String, actual: Int)
    case invalidResponse(reason: ResponseReason)
    case loadAlreadyInProgress

    public var description: String {
        switch self {
        case .invalidIdentifier(let label, let reason):
            "PaginationFailure.invalidIdentifier(label:\(label),reason:\(reason))"
        case .invalidPageSize(let minimum, let maximum, let actual):
            "PaginationFailure.invalidPageSize(minimum:\(minimum),maximum:\(maximum),actual:\(actual))"
        case .invalidIndex(let label, let actual):
            "PaginationFailure.invalidIndex(label:\(label),actual:\(actual))"
        case .invalidResponse(let reason):
            "PaginationFailure.invalidResponse(reason:\(reason))"
        case .loadAlreadyInProgress:
            "PaginationFailure.loadAlreadyInProgress"
        }
    }

    public var debugDescription: String { description }
}
