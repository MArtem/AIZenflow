import Foundation

public struct FormID: SafeFormIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeFormIdentifierValidator.validate(rawValue, label: "form")
        self.rawValue = rawValue
    }
}

public struct FormFieldID: SafeFormIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeFormIdentifierValidator.validate(rawValue, label: "field")
        self.rawValue = rawValue
    }
}

public struct FormValidationRuleID: SafeFormIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeFormIdentifierValidator.validate(rawValue, label: "rule")
        self.rawValue = rawValue
    }
}

public struct FormValidationCode: SafeFormIdentifier {
    public let rawValue: String

    public init(_ rawValue: String) throws {
        try SafeFormIdentifierValidator.validate(rawValue, label: "code")
        self.rawValue = rawValue
    }
}

extension FormID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension FormFieldID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension FormValidationRuleID {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}

extension FormValidationCode {
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        try self.init(try container.decode(String.self))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(rawValue)
    }
}
