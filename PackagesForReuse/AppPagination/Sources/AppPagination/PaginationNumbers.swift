import Foundation

public struct PageSize: Codable, Hashable, Sendable, Comparable, CustomStringConvertible {
    public static let defaultMinimum = 1
    public static let defaultMaximum = 500

    public let value: Int

    public init(_ value: Int, minimum: Int = Self.defaultMinimum, maximum: Int = Self.defaultMaximum) throws {
        guard value >= minimum, value <= maximum else {
            throw PaginationFailure.invalidPageSize(minimum: minimum, maximum: maximum, actual: value)
        }
        self.value = value
    }

    public static func < (lhs: PageSize, rhs: PageSize) -> Bool {
        lhs.value < rhs.value
    }

    public var description: String { "PageSize(\(value))" }
}

public struct PageIndex: Codable, Hashable, Sendable, Comparable, CustomStringConvertible {
    public static let zero = PageIndex(unchecked: 0)

    public let value: Int

    private init(unchecked value: Int) {
        self.value = value
    }

    public init(_ value: Int, label: String = "page") throws {
        guard value >= 0 else {
            throw PaginationFailure.invalidIndex(label: label, actual: value)
        }
        self.value = value
    }

    public func advanced(by distance: Int) throws -> PageIndex {
        let advanced = value.addingReportingOverflow(distance)
        guard !advanced.overflow else {
            throw PaginationFailure.invalidIndex(label: "page", actual: value)
        }
        return try PageIndex(advanced.partialValue)
    }

    public static func < (lhs: PageIndex, rhs: PageIndex) -> Bool {
        lhs.value < rhs.value
    }

    public var description: String { "PageIndex(\(value))" }
}

public struct ItemOffset: Codable, Hashable, Sendable, Comparable, CustomStringConvertible {
    public static let zero = ItemOffset(unchecked: 0)

    public let value: Int

    private init(unchecked value: Int) {
        self.value = value
    }

    public init(_ value: Int) throws {
        guard value >= 0 else {
            throw PaginationFailure.invalidIndex(label: "offset", actual: value)
        }
        self.value = value
    }

    public func advanced(by distance: Int) throws -> ItemOffset {
        let advanced = value.addingReportingOverflow(distance)
        guard !advanced.overflow else {
            throw PaginationFailure.invalidIndex(label: "offset", actual: value)
        }
        return try ItemOffset(advanced.partialValue)
    }

    public static func < (lhs: ItemOffset, rhs: ItemOffset) -> Bool {
        lhs.value < rhs.value
    }

    public var description: String { "ItemOffset(\(value))" }
}
