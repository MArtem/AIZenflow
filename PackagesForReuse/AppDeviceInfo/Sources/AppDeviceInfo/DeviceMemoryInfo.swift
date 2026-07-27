import Foundation

public struct DeviceMemoryInfo: Codable, Sendable, Equatable {
    public let physicalMemoryBytes: UInt64?

    public init(physicalMemoryBytes: UInt64?) {
        self.physicalMemoryBytes = physicalMemoryBytes
    }
}
