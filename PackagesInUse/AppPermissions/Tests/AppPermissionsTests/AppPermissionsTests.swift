import XCTest
@testable import AppPermissions

final class AppPermissionsTests: XCTestCase {
    func testPermissionKindIsExtensibleAndCodable() throws {
        let custom: PermissionKind = "custom_sensor"
        XCTAssertEqual(custom.rawValue, "custom_sensor")
        let data = try JSONEncoder().encode(custom)
        let decoded = try JSONDecoder().decode(PermissionKind.self, from: data)
        XCTAssertEqual(decoded, custom)
    }

    func testBuiltInPermissionKindsUseStableRawValues() {
        XCTAssertEqual(PermissionKind.camera.rawValue, "camera")
        XCTAssertEqual(PermissionKind.photoLibrary.rawValue, "photo_library")
        XCTAssertEqual(PermissionKind.locationWhenInUse.rawValue, "location_when_in_use")
        XCTAssertEqual(PermissionKind.trackingTransparency.rawValue, "tracking_transparency")
    }

    func testPermissionStateAccessSemantics() {
        XCTAssertTrue(PermissionState.authorized.grantsAccess)
        XCTAssertTrue(PermissionState.limited.grantsAccess)
        XCTAssertTrue(PermissionState.provisional.grantsAccess)
        XCTAssertFalse(PermissionState.denied.grantsAccess)
        XCTAssertTrue(PermissionState.notDetermined.canPromptUser)
        XCTAssertTrue(PermissionState.denied.usuallyRequiresSettingsRedirect)
    }

    func testSnapshotDefaultsAreDerivedFromState() {
        let notDetermined = PermissionSnapshot(kind: .camera, state: .notDetermined)
        XCTAssertTrue(notDetermined.canRequestInApp)
        XCTAssertFalse(notDetermined.requiresSettingsRedirect)

        let denied = PermissionSnapshot(kind: .camera, state: .denied)
        XCTAssertFalse(denied.canRequestInApp)
        XCTAssertTrue(denied.requiresSettingsRedirect)
    }

    func testDiagnosticSnapshotIsPrivacySafe() {
        let snapshot = PermissionSnapshot(kind: .contacts, state: .restricted)
        let diagnostic = PermissionDiagnosticSnapshot(snapshot: snapshot)
        XCTAssertEqual(diagnostic.kind, .contacts)
        XCTAssertEqual(diagnostic.stateCode, "restricted")
        XCTAssertFalse(diagnostic.grantsAccess)
    }

    func testManualManagerReturnsDefaultStateForSupportedKind() async {
        let manager = ManualPermissionManager(supportedKinds: [.camera], defaultState: .notDetermined)
        let state = await manager.state(for: .camera)
        XCTAssertEqual(state, .notDetermined)
    }

    func testManualManagerReturnsUnavailableForUnsupportedKind() async {
        let manager = ManualPermissionManager(supportedKinds: [.camera], defaultState: .notDetermined)
        let state = await manager.state(for: .microphone)
        XCTAssertEqual(state, .unavailable)
    }

    func testManualManagerDefaultRequestAuthorizesNotDeterminedPermission() async throws {
        let manager = ManualPermissionManager(supportedKinds: [.camera], defaultState: .notDetermined)
        let outcome = try await manager.request(.camera)
        XCTAssertEqual(outcome.state, .authorized)
        XCTAssertTrue(outcome.didPromptUser)
        let storedState = await manager.state(for: .camera)
        XCTAssertEqual(storedState, .authorized)
    }

    func testManualManagerUsesConfiguredRequestOutcome() async throws {
        let denied = PermissionRequestOutcome(kind: .camera, state: .denied, didPromptUser: true)
        let manager = ManualPermissionManager(
            supportedKinds: [.camera],
            defaultState: .notDetermined,
            requestOutcomes: [.camera: denied]
        )
        let outcome = try await manager.request(.camera)
        XCTAssertEqual(outcome.state, .denied)
        XCTAssertTrue(outcome.didPromptUser)
        let storedState = await manager.state(for: .camera)
        XCTAssertEqual(storedState, .denied)
    }

    func testManualManagerAllowsStateMutation() async {
        let manager = ManualPermissionManager(supportedKinds: [.camera], defaultState: .notDetermined)
        await manager.setState(.restricted, for: .camera)
        let storedState = await manager.state(for: .camera)
        XCTAssertEqual(storedState, .restricted)
    }

    func testManualManagerThrowsForUnsupportedRequest() async {
        let manager = ManualPermissionManager(supportedKinds: [.camera])
        do {
            _ = try await manager.request(.microphone)
            XCTFail("Expected unsupported kind error")
        } catch let error as PermissionError {
            XCTAssertEqual(error, .unsupportedKind(.microphone))
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testStaticManagerReturnsConfiguredState() async {
        let manager = StaticPermissionManager(states: [.camera: .authorized])
        let storedState = await manager.state(for: .camera)
        XCTAssertEqual(storedState, .authorized)
    }

    func testStaticManagerThrowsDeniedForDeniedRequest() async {
        let manager = StaticPermissionManager(states: [.camera: .denied])
        do {
            _ = try await manager.request(.camera)
            XCTFail("Expected denied error")
        } catch let error as PermissionError {
            XCTAssertEqual(error, .denied(.camera, state: .denied))
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testCompositeManagerRoutesToProvider() async throws {
        let camera = ManualPermissionManager(supportedKinds: [.camera], states: [.camera: .authorized])
        let microphone = ManualPermissionManager(supportedKinds: [.microphone], states: [.microphone: .denied])
        let composite = CompositePermissionManager(providers: [camera, microphone])

        let cameraState = await composite.state(for: .camera)
        let microphoneState = await composite.state(for: .microphone)
        XCTAssertEqual(cameraState, .authorized)
        XCTAssertEqual(microphoneState, .denied)
    }

    func testCompositeManagerThrowsUnsupportedForMissingProvider() async {
        let composite = CompositePermissionManager(providers: [])
        do {
            _ = try await composite.request(.camera)
            XCTFail("Expected unsupported kind error")
        } catch let error as PermissionError {
            XCTAssertEqual(error, .unsupportedKind(.camera))
        } catch {
            XCTFail("Unexpected error")
        }
    }

    func testSnapshotExtensionReturnsSnapshot() async {
        let manager = StaticPermissionManager(states: [.camera: .authorized])
        let snapshot = await manager.snapshot(for: .camera)
        XCTAssertEqual(snapshot.kind, .camera)
        XCTAssertEqual(snapshot.state, .authorized)
    }

    func testSnapshotsExtensionPreservesOrder() async {
        let manager = StaticPermissionManager(states: [.camera: .authorized, .microphone: .denied])
        let snapshots = await manager.snapshots(for: [.microphone, .camera])
        XCTAssertEqual(snapshots.map(\.kind), [.microphone, .camera])
        XCTAssertEqual(snapshots.map(\.state), [.denied, .authorized])
    }

    func testUsageDescriptionRequirements() {
        XCTAssertEqual(
            PermissionUsageDescriptions.requirements(for: .camera).map(\.infoPlistKey),
            ["NSCameraUsageDescription"]
        )
        XCTAssertEqual(
            PermissionUsageDescriptions.requirements(for: .locationAlways).map(\.infoPlistKey),
            ["NSLocationWhenInUseUsageDescription", "NSLocationAlwaysAndWhenInUseUsageDescription"]
        )
        XCTAssertTrue(PermissionUsageDescriptions.requirements(for: .notifications).isEmpty)
    }

    func testReadinessEvaluator() {
        let evaluator = PermissionReadinessEvaluator()
        XCTAssertEqual(evaluator.decision(for: PermissionSnapshot(kind: .camera, state: .authorized)), .available)
        XCTAssertEqual(evaluator.decision(for: PermissionSnapshot(kind: .camera, state: .notDetermined)), .shouldRequestInApp)
        XCTAssertEqual(evaluator.decision(for: PermissionSnapshot(kind: .camera, state: .denied)), .redirectToSettings)
        XCTAssertEqual(evaluator.decision(for: PermissionSnapshot(kind: .camera, state: .unavailable)), .unavailable)
    }

    func testRequestPolicy() {
        let policy = PermissionRequestPolicy(allowsInAppRequest: false)
        let snapshot = PermissionSnapshot(kind: .camera, state: .notDetermined)
        XCTAssertFalse(policy.canRequest(snapshot: snapshot))
    }

    func testPermissionErrorDescriptionsAreStableCodes() {
        XCTAssertEqual(
            PermissionError.platformRequestFailed(kind: .camera, code: "camera_failed").description,
            "permission_platform_request_failed:camera:camera_failed"
        )
        XCTAssertFalse(PermissionError.unavailable(.camera).description.contains("Optional"))
    }
}

extension AppPermissionsTests {
    func testUsageDescriptionCheckerThrowsForMissingRequiredPrivacyString() {
        let checker = PermissionUsageDescriptionChecker { _ in nil }

        XCTAssertThrowsError(try checker.validateUsageDescriptions(for: .camera)) { error in
            XCTAssertEqual(
                error as? PermissionError,
                .missingUsageDescription(kind: .camera, key: "NSCameraUsageDescription")
            )
        }
    }

    func testUsageDescriptionCheckerAllowsProvidedPrivacyString() {
        let checker = PermissionUsageDescriptionChecker { key in
            key == "NSCameraUsageDescription" ? "Camera is required." : nil
        }

        XCTAssertNoThrow(try checker.validateUsageDescriptions(for: .camera))
    }

    func testUsageDescriptionCheckerDoesNotRequireNotificationString() {
        let checker = PermissionUsageDescriptionChecker { _ in nil }
        XCTAssertNoThrow(try checker.validateUsageDescriptions(for: .notifications))
    }
}
