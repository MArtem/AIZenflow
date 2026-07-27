import Foundation

public struct UploadFailure: Error, Equatable, Sendable, Codable, CustomStringConvertible {
    public enum Code: String, Equatable, Sendable, Codable {
        case invalidIdentifier
        case invalidURL
        case invalidName
        case invalidMediaType
        case invalidPayload
        case payloadTooLarge
        case responseTooLarge
        case transportUnavailable
        case invalidResponse
        case fileSystemUnavailable
        case fileReadFailed
        case encodingFailed
        case retryLimitExceeded
    }

    public enum Operation: String, Equatable, Sendable, Codable {
        case validation
        case fileSystem
        case encoding
        case transport
        case retry
    }

    public let code: Code
    public let operation: Operation

    public init(_ code: Code, operation: Operation) {
        self.code = code
        self.operation = operation
    }

    public var description: String {
        "UploadFailure(code: \(code.rawValue), operation: \(operation.rawValue))"
    }
}
