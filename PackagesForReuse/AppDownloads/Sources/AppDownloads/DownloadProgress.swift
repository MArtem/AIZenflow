import Foundation

public struct DownloadProgress: Equatable, Sendable, Codable {
    public let receivedBytes: Int64
    public let expectedBytes: Int64?

    public init(receivedBytes: Int64, expectedBytes: Int64?) {
        self.receivedBytes = max(0, receivedBytes)
        if let expectedBytes, expectedBytes > 0 {
            self.expectedBytes = expectedBytes
        } else {
            self.expectedBytes = nil
        }
    }

    public var fractionCompleted: Double? {
        guard let expectedBytes, expectedBytes > 0 else { return nil }
        return min(1, Double(receivedBytes) / Double(expectedBytes))
    }
}

public enum DownloadState: Equatable, Sendable, Codable {
    case queued
    case running(DownloadProgress)
    case finished(DownloadReceipt)
    case failed(DownloadFailure)
}
