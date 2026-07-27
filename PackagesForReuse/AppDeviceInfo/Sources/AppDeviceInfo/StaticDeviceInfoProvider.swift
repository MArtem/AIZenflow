import Foundation

public struct StaticDeviceInfoProvider: DeviceInfoProviding {
    private let storedSnapshot: DeviceInfoSnapshot

    public init(snapshot: DeviceInfoSnapshot) {
        self.storedSnapshot = snapshot
    }

    public func snapshot() async -> DeviceInfoSnapshot {
        storedSnapshot
    }
}

public struct StaticDeviceModelInfoProvider: DeviceModelInfoProviding {
    private let value: DeviceModelInfo

    public init(_ value: DeviceModelInfo) {
        self.value = value
    }

    public func modelInfo() async -> DeviceModelInfo {
        value
    }
}

public struct StaticOperatingSystemInfoProvider: OperatingSystemInfoProviding {
    private let value: OperatingSystemInfo

    public init(_ value: OperatingSystemInfo) {
        self.value = value
    }

    public func operatingSystemInfo() async -> OperatingSystemInfo {
        value
    }
}

public struct StaticExecutionEnvironmentProvider: DeviceExecutionEnvironmentProviding {
    private let value: DeviceExecutionEnvironment

    public init(_ value: DeviceExecutionEnvironment) {
        self.value = value
    }

    public func executionEnvironment() async -> DeviceExecutionEnvironment {
        value
    }
}

public struct StaticScreenInfoProvider: DeviceScreenInfoProviding {
    private let value: DeviceScreenInfo

    public init(_ value: DeviceScreenInfo) {
        self.value = value
    }

    public func screenInfo() async -> DeviceScreenInfo {
        value
    }
}

public struct StaticPowerInfoProvider: DevicePowerInfoProviding {
    private let value: DevicePowerInfo

    public init(_ value: DevicePowerInfo) {
        self.value = value
    }

    public func powerInfo() async -> DevicePowerInfo {
        value
    }
}

public struct StaticMemoryInfoProvider: DeviceMemoryInfoProviding {
    private let value: DeviceMemoryInfo

    public init(_ value: DeviceMemoryInfo) {
        self.value = value
    }

    public func memoryInfo() async -> DeviceMemoryInfo {
        value
    }
}
