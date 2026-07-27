import XCTest
@testable import AppEnvironment

final class AppEnvironmentTests: XCTestCase {
    func testEnvironmentKindDefaultsToProductionWhenMissing() {
        XCTAssertEqual(EnvironmentKind(rawValue: nil), .production)
    }

    func testEnvironmentKindParsesCommonAliases() {
        XCTAssertEqual(EnvironmentKind(rawValue: "dev"), .development)
        XCTAssertEqual(EnvironmentKind(rawValue: " DEVELOPMENT "), .development)
        XCTAssertEqual(EnvironmentKind(rawValue: "qa"), .staging)
        XCTAssertEqual(EnvironmentKind(rawValue: "stage"), .staging)
        XCTAssertEqual(EnvironmentKind(rawValue: "prod"), .production)
        XCTAssertEqual(EnvironmentKind(rawValue: "release"), .production)
    }

    func testEnvironmentKindKeepsCustomValueAsStableCode() {
        let kind = EnvironmentKind(rawValue: " Client QA ")
        XCTAssertEqual(kind, .custom("client-qa"))
        XCTAssertEqual(kind.stableCode, "custom.client-qa")
    }

    func testBuildInfoCleansEmptyValuesAndFormatsVersion() {
        let info = AppBuildInfo(
            bundleIdentifier: "  ",
            displayName: " Example ",
            version: "1.2.3",
            buildNumber: " 45 ",
            buildConfiguration: .release
        )

        XCTAssertNil(info.bundleIdentifier)
        XCTAssertEqual(info.displayName, "Example")
        XCTAssertEqual(info.versionDisplay, "1.2.3 (45)")
    }

    func testRuntimeFlagsAutomation() {
        let flags = AppRuntimeFlags(
            isDebugBuild: true,
            isSimulator: false,
            isRunningTests: false,
            isUITesting: true,
            isPreview: false,
            processName: "HostApp"
        )

        XCTAssertTrue(flags.isAutomation)
        XCTAssertEqual(flags.processName, "HostApp")
    }

    func testStaticEnvironmentProviderReturnsSnapshot() async {
        let snapshot = makeSnapshot(kind: .development)
        let provider = StaticEnvironmentProvider(snapshot)

        let result = await provider.snapshot()

        XCTAssertEqual(result, snapshot)
    }

    func testDefaultProviderComposesInjectedProviders() async {
        let date = Date(timeIntervalSince1970: 1_700_000_000)
        let provider = DefaultAppEnvironmentProvider(
            environmentKind: .staging,
            buildInfoProvider: StaticAppBuildInfoProvider(makeBuildInfo()),
            runtimeFlagsProvider: StaticRuntimeFlagsProvider(makeFlags(isPreview: true)),
            localeContextProvider: StaticLocaleContextProvider(makeLocale()),
            dateProvider: { date }
        )

        let snapshot = await provider.snapshot()

        XCTAssertEqual(snapshot.kind, .staging)
        XCTAssertEqual(snapshot.buildInfo.versionDisplay, "1.0 (10)")
        XCTAssertTrue(snapshot.runtimeFlags.isPreview)
        XCTAssertEqual(snapshot.localeContext.localeIdentifier, "en_US")
        XCTAssertEqual(snapshot.generatedAt, date)
    }

    func testDefaultProviderReadsEnvironmentVariableFromInjectedEnvironment() async {
        let provider = DefaultAppEnvironmentProvider(
            environmentVariableName: "SDK_ENV",
            processEnvironment: ["SDK_ENV": "staging"],
            buildInfoProvider: StaticAppBuildInfoProvider(makeBuildInfo()),
            runtimeFlagsProvider: StaticRuntimeFlagsProvider(makeFlags()),
            localeContextProvider: StaticLocaleContextProvider(makeLocale()),
            dateProvider: { Date(timeIntervalSince1970: 0) }
        )

        let snapshot = await provider.snapshot()

        XCTAssertEqual(snapshot.kind, .staging)
    }

    func testProcessRuntimeFlagsStaticHelperMatchesProviderSemantics() {
        let flags = ProcessRuntimeFlagsProvider.makeRuntimeFlags(
            environment: [
                "XCTestConfigurationFilePath": "/worktree/test.xctestconfiguration",
                "XCODE_RUNNING_FOR_PREVIEWS": "1",
                "UI_TESTING": "1"
            ],
            arguments: [],
            processName: "StaticHost",
            buildConfiguration: .debug
        )

        XCTAssertTrue(flags.isDebugBuild)
        XCTAssertTrue(flags.isRunningTests)
        XCTAssertTrue(flags.isUITesting)
        XCTAssertTrue(flags.isPreview)
        XCTAssertEqual(flags.processName, "StaticHost")
    }

    func testProcessRuntimeFlagsProviderDetectsTestingPreviewAndUITesting() async {
        let provider = ProcessRuntimeFlagsProvider(
            environment: [
                "XCTestConfigurationFilePath": "/worktree/test.xctestconfiguration",
                "XCODE_RUNNING_FOR_PREVIEWS": "1",
                "UI_TESTING": "1"
            ],
            arguments: [],
            processName: "UnitTestHost",
            buildConfiguration: .debug
        )

        let flags = await provider.runtimeFlags()

        XCTAssertTrue(flags.isDebugBuild)
        XCTAssertTrue(flags.isRunningTests)
        XCTAssertTrue(flags.isUITesting)
        XCTAssertTrue(flags.isPreview)
        XCTAssertTrue(flags.isAutomation)
        XCTAssertEqual(flags.processName, "UnitTestHost")
    }

    func testDiagnosticsArePrivacySafeSubset() {
        let snapshot = makeSnapshot(kind: .production)
        let diagnostics = AppEnvironmentDiagnostics(snapshot: snapshot)

        XCTAssertEqual(diagnostics.environmentCode, "production")
        XCTAssertEqual(diagnostics.versionDisplay, "1.0 (10)")
        XCTAssertEqual(diagnostics.localeIdentifier, "en_US")
        XCTAssertEqual(diagnostics.timeZoneIdentifier, "Europe/Kyiv")
    }

    func testSnapshotDescriptionDoesNotDumpProcessNameOrBundleIdentifier() {
        let snapshot = AppEnvironmentSnapshot(
            kind: .production,
            buildInfo: AppBuildInfo(
                bundleIdentifier: "com.example.secret.internal",
                displayName: "Secret Host",
                version: "1.0",
                buildNumber: "1",
                buildConfiguration: .release
            ),
            runtimeFlags: AppRuntimeFlags(
                isDebugBuild: false,
                isSimulator: false,
                processName: "SecretProcess"
            ),
            localeContext: makeLocale(),
            generatedAt: Date(timeIntervalSince1970: 0)
        )

        let description = snapshot.description

        XCTAssertFalse(description.contains("com.example.secret.internal"))
        XCTAssertFalse(description.contains("SecretProcess"))
        XCTAssertFalse(description.contains("Secret Host"))
    }

    func testCurrentLocaleProviderReturnsNonEmptyPrimitiveValues() async {
        let provider = CurrentLocaleContextProvider()

        let context = await provider.localeContext()

        XCTAssertFalse(context.localeIdentifier.isEmpty)
        XCTAssertFalse(context.timeZoneIdentifier.isEmpty)
        XCTAssertFalse(context.calendarIdentifier.isEmpty)
    }

    func testCodableRoundTrip() throws {
        let snapshot = makeSnapshot(kind: .custom("internal"))
        let data = try JSONEncoder().encode(snapshot)
        let decoded = try JSONDecoder().decode(AppEnvironmentSnapshot.self, from: data)

        XCTAssertEqual(decoded, snapshot)
    }

    func testRuntimeFlagsDescriptionDoesNotDumpProcessName() {
        let flags = AppRuntimeFlags(
            isDebugBuild: true,
            isSimulator: true,
            isRunningTests: true,
            processName: "SensitiveProcessName"
        )

        XCTAssertFalse(flags.description.contains("SensitiveProcessName"))
    }

    private func makeSnapshot(kind: EnvironmentKind) -> AppEnvironmentSnapshot {
        AppEnvironmentSnapshot(
            kind: kind,
            buildInfo: makeBuildInfo(),
            runtimeFlags: makeFlags(),
            localeContext: makeLocale(),
            generatedAt: Date(timeIntervalSince1970: 123)
        )
    }

    private func makeBuildInfo() -> AppBuildInfo {
        AppBuildInfo(
            bundleIdentifier: "com.example.app",
            displayName: "Example",
            version: "1.0",
            buildNumber: "10",
            buildConfiguration: .debug
        )
    }

    private func makeFlags(isPreview: Bool = false) -> AppRuntimeFlags {
        AppRuntimeFlags(
            isDebugBuild: true,
            isSimulator: true,
            isRunningTests: true,
            isUITesting: false,
            isPreview: isPreview,
            processName: "TestHost"
        )
    }

    private func makeLocale() -> AppLocaleContext {
        AppLocaleContext(
            localeIdentifier: "en_US",
            languageCode: "en",
            regionCode: "US",
            timeZoneIdentifier: "Europe/Kyiv",
            calendarIdentifier: "gregorian"
        )
    }
}
