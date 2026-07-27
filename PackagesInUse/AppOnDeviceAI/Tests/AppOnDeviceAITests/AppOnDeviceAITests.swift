import Testing
@testable import AppOnDeviceAI

/// Verifies on-device AI availability and unavailable-manager behavior.
struct AppOnDeviceAITests {
    @Test
    func unavailableManagerReportsUnavailableAvailability() async throws {
        let manager = UnavailableOnDeviceAIManager(reason: .unsupportedOS)

        let availability = manager.translationAvailability(for: nil)

        #expect(availability == .unavailable(.unsupportedOS))
    }

    @Test
    func unavailableManagerThrowsUnavailableError() async throws {
        let manager = UnavailableOnDeviceAIManager(reason: .unsupportedOS)
        let request = OnDeviceTranslationRequest(
            targetLanguage: OnDeviceLanguage(localeIdentifier: "de"),
            segments: [
                OnDeviceTranslationSegment(id: "headline", text: "Hello")
            ]
        )

        await #expect(throws: OnDeviceAIError.unavailable(.unsupportedOS)) {
            _ = try await manager.translate(request)
        }
    }
}
