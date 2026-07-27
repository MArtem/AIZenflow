import Foundation

/// Privacy-safe summary derived from a full device snapshot.
public struct DeviceInfoDiagnostics: Codable, Sendable, Equatable {
    public let platform: DevicePlatform
    public let family: DeviceFamily
    public let executionEnvironment: DeviceExecutionEnvironment
    public let osMajorVersion: Int
    public let isLowPowerModeEnabled: Bool?
    public let thermalCondition: ThermalCondition
    public let hasScreenInfo: Bool
    public let hasPhysicalMemoryInfo: Bool

    public init(snapshot: DeviceInfoSnapshot) {
        self.platform = snapshot.operatingSystem.platform
        self.family = snapshot.model.family
        self.executionEnvironment = snapshot.executionEnvironment
        self.osMajorVersion = snapshot.operatingSystem.majorVersion
        self.isLowPowerModeEnabled = snapshot.power.isLowPowerModeEnabled
        self.thermalCondition = snapshot.power.thermalCondition
        self.hasScreenInfo = snapshot.screen.widthPoints != nil || snapshot.screen.heightPoints != nil || snapshot.screen.scale != nil
        self.hasPhysicalMemoryInfo = snapshot.memory.physicalMemoryBytes != nil
    }

    public init(
        platform: DevicePlatform,
        family: DeviceFamily,
        executionEnvironment: DeviceExecutionEnvironment,
        osMajorVersion: Int,
        isLowPowerModeEnabled: Bool?,
        thermalCondition: ThermalCondition,
        hasScreenInfo: Bool,
        hasPhysicalMemoryInfo: Bool
    ) {
        self.platform = platform
        self.family = family
        self.executionEnvironment = executionEnvironment
        self.osMajorVersion = osMajorVersion
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
        self.thermalCondition = thermalCondition
        self.hasScreenInfo = hasScreenInfo
        self.hasPhysicalMemoryInfo = hasPhysicalMemoryInfo
    }
}
