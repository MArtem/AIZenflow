import Foundation

public struct ValidationSetID: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let identifier: SafeValidationIdentifier

    public init(_ value: String) throws {
        self.identifier = try SafeValidationIdentifier(value)
    }

    public var value: String { identifier.value }
    public var description: String { "ValidationSetID(redacted)" }
    public var debugDescription: String { description }
}

public struct ValidationValueID: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let identifier: SafeValidationIdentifier

    public init(_ value: String) throws {
        self.identifier = try SafeValidationIdentifier(value)
    }

    public var value: String { identifier.value }
    public var description: String { "ValidationValueID(redacted)" }
    public var debugDescription: String { description }
}

public struct ValidationRuleID: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let identifier: SafeValidationIdentifier

    public init(_ value: String) throws {
        self.identifier = try SafeValidationIdentifier(value)
    }

    public var value: String { identifier.value }
    public var description: String { "ValidationRuleID(redacted)" }
    public var debugDescription: String { description }
}

public struct ValidationCode: Hashable, Codable, Sendable, CustomStringConvertible, CustomDebugStringConvertible {
    private let identifier: SafeValidationIdentifier

    public init(_ value: String) throws {
        self.identifier = try SafeValidationIdentifier(value)
    }

    public var value: String { identifier.value }
    public var description: String { "ValidationCode(redacted)" }
    public var debugDescription: String { description }
}
