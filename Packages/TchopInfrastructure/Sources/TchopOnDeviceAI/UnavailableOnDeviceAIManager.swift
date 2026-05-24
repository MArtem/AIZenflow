import Foundation

/// Deterministic unavailable implementation used when on-device AI is unsupported or disabled.
public struct UnavailableOnDeviceAIManager: OnDeviceAIManaging, Sendable {
    private let reason: OnDeviceAIUnavailableReason

    public init(reason: OnDeviceAIUnavailableReason = .unsupportedOS) {
        self.reason = reason
    }

        /// Always reports the configured unavailable reason.
public func translationAvailability(for localeIdentifier: String?) -> OnDeviceAIAvailability {
        .unavailable(reason)
    }

        /// Always throws the configured unavailable reason.
public func translate(_ request: OnDeviceTranslationRequest) async throws -> OnDeviceTranslationResult {
        throw OnDeviceAIError.unavailable(reason)
    }
}
