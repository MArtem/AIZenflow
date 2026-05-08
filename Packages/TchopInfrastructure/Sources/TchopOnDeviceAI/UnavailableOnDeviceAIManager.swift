import Foundation

public struct UnavailableOnDeviceAIManager: OnDeviceAIManaging, Sendable {
    private let reason: OnDeviceAIUnavailableReason

    public init(reason: OnDeviceAIUnavailableReason = .unsupportedOS) {
        self.reason = reason
    }

    public func translationAvailability(for localeIdentifier: String?) -> OnDeviceAIAvailability {
        .unavailable(reason)
    }

    public func translate(_ request: OnDeviceTranslationRequest) async throws -> OnDeviceTranslationResult {
        throw OnDeviceAIError.unavailable(reason)
    }
}
