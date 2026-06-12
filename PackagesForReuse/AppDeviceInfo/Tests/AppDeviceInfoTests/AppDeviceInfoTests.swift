import XCTest
@testable import AppDeviceInfo

final class AppDeviceInfoTests: XCTestCase {
    func testStaticProviderReturnsSnapshot() async {
        let snapshot = makeSnapshot()
        let provider = StaticDeviceInfoProvider(snapshot: snapshot)

        let result = await provider.snapshot()

        XCTAssertEqual(result, snapshot)
    }

    func testDiagnosticsIsPrivacySafeSummary() {
        let snapshot = makeSnapshot()

        let diagnostics = DeviceInfoDiagnostics(snapshot: snapshot)

        XCTAssertEqual(diagnostics.platform, .iOS)
        XCTAssertEqual(diagnostics.family, .phone)
        XCTAssertEqual(diagnostics.executionEnvironment, .simulator)
        XCTAssertEqual(diagnostics.osMajorVersion, 17)
        XCTAssertEqual(diagnostics.isLowPowerModeEnabled, false)
        XCTAssertEqual(diagnostics.thermalCondition, .nominal)
        XCTAssertTrue(diagnostics.hasScreenInfo)
        XCTAssertTrue(diagnostics.hasPhysicalMemoryInfo)
    }

    func testProcessExecutionEnvironmentDetectsPreview() async {
        let provider = ProcessExecutionEnvironmentProvider(
            environment: ["XCODE_RUNNING_FOR_PREVIEWS": "1"],
            arguments: []
        )

        let result = await provider.executionEnvironment()

        XCTAssertEqual(result, .preview)
    }

    func testProcessExecutionEnvironmentDetectsUnitTestWithoutPathContract() async {
        let provider = ProcessExecutionEnvironmentProvider(
            environment: ["XCTestConfigurationFilePath": "AppDeviceInfoTests.xctestconfiguration"],
            arguments: []
        )

        let result = await provider.executionEnvironment()

        XCTAssertEqual(result, .unitTest)
    }

    func testProcessExecutionEnvironmentDetectsSimulator() async {
        let provider = ProcessExecutionEnvironmentProvider(
            environment: ["SIMULATOR_DEVICE_NAME": "iPhone"],
            arguments: []
        )

        let result = await provider.executionEnvironment()

        XCTAssertEqual(result, .simulator)
    }

    func testDeviceFamilyDefaults() {
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .iOS), .phone)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .iPadOS), .tablet)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .macOS), .desktop)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .tvOS), .television)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .watchOS), .watch)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .visionOS), .spatial)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .linux), .server)
        XCTAssertEqual(DeviceFamily.defaultFamily(for: .unknown), .unknown)
    }

    func testModelInfoNormalizesEmptyStrings() {
        let model = DeviceModelInfo(identifier: "", family: .unknown, architecture: "")

        XCTAssertEqual(model.identifier, "unknown")
        XCTAssertEqual(model.architecture, "unknown")
    }

    func testOperatingSystemInfoNormalizesEmptyValues() {
        let info = OperatingSystemInfo(
            platform: .iOS,
            name: "",
            versionString: "",
            majorVersion: 0,
            minorVersion: 0,
            patchVersion: 0
        )

        XCTAssertEqual(info.name, "iOS")
        XCTAssertEqual(info.versionString, "unknown")
    }

    func testDefaultProviderReturnsCoherentSnapshot() async {
        let provider = DefaultDeviceInfoProvider(
            modelProvider: StaticDeviceModelInfoProvider(DeviceModelInfo(identifier: "iPhone16,1", family: .phone, architecture: "arm64")),
            operatingSystemProvider: StaticOperatingSystemInfoProvider(OperatingSystemInfo(platform: .iOS, name: "iOS", versionString: "17.0.0", majorVersion: 17, minorVersion: 0, patchVersion: 0)),
            executionEnvironmentProvider: StaticExecutionEnvironmentProvider(.simulator),
            screenProvider: StaticScreenInfoProvider(DeviceScreenInfo(widthPoints: 390, heightPoints: 844, scale: 3)),
            powerProvider: StaticPowerInfoProvider(DevicePowerInfo(isLowPowerModeEnabled: false, thermalCondition: .nominal)),
            memoryProvider: StaticMemoryInfoProvider(DeviceMemoryInfo(physicalMemoryBytes: 8_589_934_592))
        )

        let snapshot = await provider.snapshot()

        XCTAssertEqual(snapshot.model.identifier, "iPhone16,1")
        XCTAssertEqual(snapshot.operatingSystem.majorVersion, 17)
        XCTAssertEqual(snapshot.executionEnvironment, .simulator)
        XCTAssertEqual(snapshot.screen.scale, 3)
        XCTAssertEqual(snapshot.power.thermalCondition, .nominal)
        XCTAssertEqual(snapshot.memory.physicalMemoryBytes, 8_589_934_592)
    }

    func testSnapshotIsCodable() throws {
        let snapshot = makeSnapshot()

        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(DeviceInfoSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
    }

    func testDiagnosticsIsCodable() throws {
        let diagnostics = DeviceInfoDiagnostics(snapshot: makeSnapshot())

        let data = try JSONEncoder().encode(diagnostics)
        let decoded = try JSONDecoder().decode(DeviceInfoDiagnostics.self, from: data)

        XCTAssertEqual(decoded, diagnostics)
    }

    func testProcessProvidersReturnNonEmptyPortableValues() async {
        let model = await ProcessDeviceModelInfoProvider(platform: .linux).modelInfo()
        let os = await ProcessOperatingSystemInfoProvider(platform: .linux).operatingSystemInfo()
        let memory = await ProcessMemoryInfoProvider().memoryInfo()

        XCTAssertFalse(model.identifier.isEmpty)
        XCTAssertFalse(model.architecture.isEmpty)
        XCTAssertEqual(os.platform, .linux)
        XCTAssertFalse(os.versionString.isEmpty)
        XCTAssertNotNil(memory.physicalMemoryBytes)
    }
}

private func makeSnapshot() -> DeviceInfoSnapshot {
    DeviceInfoSnapshot(
        model: DeviceModelInfo(identifier: "iPhone16,1", family: .phone, architecture: "arm64"),
        operatingSystem: OperatingSystemInfo(platform: .iOS, name: "iOS", versionString: "17.0.0", majorVersion: 17, minorVersion: 0, patchVersion: 0),
        executionEnvironment: .simulator,
        screen: DeviceScreenInfo(widthPoints: 390, heightPoints: 844, scale: 3),
        power: DevicePowerInfo(isLowPowerModeEnabled: false, thermalCondition: .nominal),
        memory: DeviceMemoryInfo(physicalMemoryBytes: 8_589_934_592)
    )
}
