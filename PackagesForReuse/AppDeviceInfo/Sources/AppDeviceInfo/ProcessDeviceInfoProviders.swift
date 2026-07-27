import Foundation

public struct ProcessDeviceModelInfoProvider: DeviceModelInfoProviding {
    private let platform: DevicePlatform

    public init(platform: DevicePlatform = .current) {
        self.platform = platform
    }

    public func modelInfo() async -> DeviceModelInfo {
        let family = DeviceFamily.defaultFamily(for: platform)
        return DeviceModelInfo(
            identifier: SystemIdentifier.machineIdentifier(),
            family: family,
            architecture: SystemIdentifier.architectureIdentifier()
        )
    }
}

public struct ProcessOperatingSystemInfoProvider: OperatingSystemInfoProviding {
    private let platform: DevicePlatform

    public init(platform: DevicePlatform = .current) {
        self.platform = platform
    }

    public func operatingSystemInfo() async -> OperatingSystemInfo {
        let version = ProcessInfo.processInfo.operatingSystemVersion
        let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
        return OperatingSystemInfo(
            platform: platform,
            name: platform.rawValue,
            versionString: versionString,
            majorVersion: version.majorVersion,
            minorVersion: version.minorVersion,
            patchVersion: version.patchVersion
        )
    }
}

public struct ProcessExecutionEnvironmentProvider: DeviceExecutionEnvironmentProviding {
    private let environment: [String: String]
    private let arguments: [String]

    public init(
        environment: [String: String] = ProcessInfo.processInfo.environment,
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) {
        self.environment = environment
        self.arguments = arguments
    }

    public func executionEnvironment() async -> DeviceExecutionEnvironment {
        if environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1" {
            return .preview
        }

        if environment["XCTestConfigurationFilePath"] != nil ||
            environment["XCTestBundlePath"] != nil ||
            arguments.contains(where: { $0.hasSuffix(".xctest") || $0.contains("xctestconfiguration") }) {
            return .unitTest
        }

        if environment["SIMULATOR_DEVICE_NAME"] != nil ||
            environment["SIMULATOR_UDID"] != nil ||
            environment["SIMULATOR_MODEL_IDENTIFIER"] != nil {
            return .simulator
        }

        #if targetEnvironment(simulator)
        return .simulator
        #else
        return .physicalDevice
        #endif
    }
}

public struct ProcessPowerInfoProvider: DevicePowerInfoProviding {
    public init() {}

    public func powerInfo() async -> DevicePowerInfo {
        DevicePowerInfo(
            isLowPowerModeEnabled: currentLowPowerModeState(),
            thermalCondition: currentThermalCondition()
        )
    }

    private func currentLowPowerModeState() -> Bool? {
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS)
        return ProcessInfo.processInfo.isLowPowerModeEnabled
        #else
        return nil
        #endif
    }

    private func currentThermalCondition() -> ThermalCondition {
        #if os(iOS) || os(macOS) || os(tvOS) || os(watchOS) || os(visionOS)
        switch ProcessInfo.processInfo.thermalState {
        case .nominal:
            return .nominal
        case .fair:
            return .fair
        case .serious:
            return .serious
        case .critical:
            return .critical
        @unknown default:
            return .unknown
        }
        #else
        return .unavailable
        #endif
    }
}

public struct ProcessMemoryInfoProvider: DeviceMemoryInfoProviding {
    public init() {}

    public func memoryInfo() async -> DeviceMemoryInfo {
        DeviceMemoryInfo(physicalMemoryBytes: ProcessInfo.processInfo.physicalMemory)
    }
}

public struct UnavailableScreenInfoProvider: DeviceScreenInfoProviding {
    public init() {}

    public func screenInfo() async -> DeviceScreenInfo {
        .unavailable
    }
}
