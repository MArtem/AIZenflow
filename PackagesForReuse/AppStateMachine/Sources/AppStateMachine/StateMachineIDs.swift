import Foundation

public struct StateMachineID: SafeStateMachineIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeIdentifierValidator.validate(rawValue, label: "machine")
        self.rawValue = rawValue
    }
}

public struct StateID: SafeStateMachineIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeIdentifierValidator.validate(rawValue, label: "state")
        self.rawValue = rawValue
    }
}

public struct StateEventID: SafeStateMachineIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeIdentifierValidator.validate(rawValue, label: "event")
        self.rawValue = rawValue
    }
}

public struct StateGuardID: SafeStateMachineIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeIdentifierValidator.validate(rawValue, label: "guard")
        self.rawValue = rawValue
    }
}

public struct StateActionID: SafeStateMachineIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeIdentifierValidator.validate(rawValue, label: "action")
        self.rawValue = rawValue
    }
}

extension StateMachineID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StateID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StateEventID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StateGuardID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension StateActionID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
