import Foundation

public struct DownloadFailure: Error, Equatable, Sendable, Codable, CustomStringConvertible {
    public enum Code: String, Equatable, Sendable, Codable {
        case invalidIdentifier
        case invalidURL
        case invalidFileName
        case invalidDestination
        case invalidResponse
        case responseTooLarge
        case transportUnavailable
        case fileSystemUnavailable
        case writeFailed
        case moveFailed
        case cleanupFailed
    }

    public enum Operation: String, Equatable, Sendable, Codable {
        case validation
        case transport
        case fileSystem
        case cleanup
    }

    public let code: Code
    public let operation: Operation

    public init(_ code: Code, operation: Operation) {
        self.code = code
        self.operation = operation
    }

    public var description: String {
        "DownloadFailure(code: \(code.rawValue), operation: \(operation.rawValue))"
    }
}
