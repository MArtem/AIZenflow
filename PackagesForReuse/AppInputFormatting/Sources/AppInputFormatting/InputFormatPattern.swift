public struct InputFormatPattern: Sendable, Hashable, Codable, CustomStringConvertible, CustomDebugStringConvertible {
    public let value: String
    public let marker: String

    public init(_ value: String, marker: String = "#") throws {
        guard !value.isEmpty, value.count <= 128 else {
            throw InputFormattingFailure.invalidPattern
        }
        guard value.contains(marker) else {
            throw InputFormattingFailure.invalidPattern
        }
        guard marker.count == 1, marker.first?.isWhitespace == false else {
            throw InputFormattingFailure.invalidPattern
        }
        self.value = value
        self.marker = marker
    }

    public var description: String {
        "InputFormatPattern(redacted,length:\(value.count))"
    }

    public var debugDescription: String { description }
}
