public struct InputFieldID: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let storage: SafeInputIdentifier

    public init(_ value: String) throws {
        self.storage = try SafeInputIdentifier(value)
    }

    public var value: String { storage.value }

    public var description: String {
        "InputFieldID(redacted,length:\(value.count))"
    }

    public var debugDescription: String { description }
}

public struct InputFormatterID: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let storage: SafeInputIdentifier

    public init(_ value: String) throws {
        self.storage = try SafeInputIdentifier(value)
    }

    public var value: String { storage.value }

    public var description: String {
        "InputFormatterID(redacted,length:\(value.count))"
    }

    public var debugDescription: String { description }
}
