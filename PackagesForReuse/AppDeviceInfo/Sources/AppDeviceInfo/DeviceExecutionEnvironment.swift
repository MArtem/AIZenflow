import Foundation

public enum DeviceExecutionEnvironment: String, Codable, Sendable, Equatable, CaseIterable {
    case physicalDevice
    case simulator
    case preview
    case unitTest
    case unknown
}
