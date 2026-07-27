import Foundation

public struct DevicePowerInfo: Codable, Sendable, Equatable {
    public let isLowPowerModeEnabled: Bool?
    public let thermalCondition: ThermalCondition

    public init(
        isLowPowerModeEnabled: Bool?,
        thermalCondition: ThermalCondition
    ) {
        self.isLowPowerModeEnabled = isLowPowerModeEnabled
        self.thermalCondition = thermalCondition
    }
}
