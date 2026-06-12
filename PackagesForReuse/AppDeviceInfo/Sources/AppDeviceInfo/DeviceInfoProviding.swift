import Foundation

public protocol DeviceModelInfoProviding: Sendable {
    func modelInfo() async -> DeviceModelInfo
}

public protocol OperatingSystemInfoProviding: Sendable {
    func operatingSystemInfo() async -> OperatingSystemInfo
}

public protocol DeviceExecutionEnvironmentProviding: Sendable {
    func executionEnvironment() async -> DeviceExecutionEnvironment
}

public protocol DeviceScreenInfoProviding: Sendable {
    func screenInfo() async -> DeviceScreenInfo
}

public protocol DevicePowerInfoProviding: Sendable {
    func powerInfo() async -> DevicePowerInfo
}

public protocol DeviceMemoryInfoProviding: Sendable {
    func memoryInfo() async -> DeviceMemoryInfo
}

public protocol DeviceInfoProviding: Sendable {
    func snapshot() async -> DeviceInfoSnapshot
}
