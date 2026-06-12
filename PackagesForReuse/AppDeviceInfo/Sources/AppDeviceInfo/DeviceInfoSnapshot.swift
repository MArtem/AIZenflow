import Foundation

/// Full local device/runtime snapshot.
///
/// Raw snapshots can be fingerprintable. Keep them local unless the host app has an explicit
/// privacy-reviewed reason to export them; use `DeviceInfoDiagnostics` for telemetry-safe summaries.
public struct DeviceInfoSnapshot: Codable, Sendable, Equatable {
    public let model: DeviceModelInfo
    public let operatingSystem: OperatingSystemInfo
    public let executionEnvironment: DeviceExecutionEnvironment
    public let screen: DeviceScreenInfo
    public let power: DevicePowerInfo
    public let memory: DeviceMemoryInfo

    public init(
        model: DeviceModelInfo,
        operatingSystem: OperatingSystemInfo,
        executionEnvironment: DeviceExecutionEnvironment,
        screen: DeviceScreenInfo,
        power: DevicePowerInfo,
        memory: DeviceMemoryInfo
    ) {
        self.model = model
        self.operatingSystem = operatingSystem
        self.executionEnvironment = executionEnvironment
        self.screen = screen
        self.power = power
        self.memory = memory
    }
}
