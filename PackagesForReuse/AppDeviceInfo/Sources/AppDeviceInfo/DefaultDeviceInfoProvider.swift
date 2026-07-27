import Foundation

public struct DefaultDeviceInfoProvider: DeviceInfoProviding {
    private let modelProvider: any DeviceModelInfoProviding
    private let operatingSystemProvider: any OperatingSystemInfoProviding
    private let executionEnvironmentProvider: any DeviceExecutionEnvironmentProviding
    private let screenProvider: any DeviceScreenInfoProviding
    private let powerProvider: any DevicePowerInfoProviding
    private let memoryProvider: any DeviceMemoryInfoProviding

    public init(
        modelProvider: any DeviceModelInfoProviding = ProcessDeviceModelInfoProvider(),
        operatingSystemProvider: any OperatingSystemInfoProviding = ProcessOperatingSystemInfoProvider(),
        executionEnvironmentProvider: any DeviceExecutionEnvironmentProviding = ProcessExecutionEnvironmentProvider(),
        screenProvider: any DeviceScreenInfoProviding = UnavailableScreenInfoProvider(),
        powerProvider: any DevicePowerInfoProviding = ProcessPowerInfoProvider(),
        memoryProvider: any DeviceMemoryInfoProviding = ProcessMemoryInfoProvider()
    ) {
        self.modelProvider = modelProvider
        self.operatingSystemProvider = operatingSystemProvider
        self.executionEnvironmentProvider = executionEnvironmentProvider
        self.screenProvider = screenProvider
        self.powerProvider = powerProvider
        self.memoryProvider = memoryProvider
    }

    public func snapshot() async -> DeviceInfoSnapshot {
        async let model = modelProvider.modelInfo()
        async let operatingSystem = operatingSystemProvider.operatingSystemInfo()
        async let environment = executionEnvironmentProvider.executionEnvironment()
        async let screen = screenProvider.screenInfo()
        async let power = powerProvider.powerInfo()
        async let memory = memoryProvider.memoryInfo()

        return await DeviceInfoSnapshot(
            model: model,
            operatingSystem: operatingSystem,
            executionEnvironment: environment,
            screen: screen,
            power: power,
            memory: memory
        )
    }
}
