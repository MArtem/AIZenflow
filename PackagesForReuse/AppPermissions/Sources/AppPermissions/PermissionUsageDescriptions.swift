import Foundation

public struct PermissionUsageDescriptionRequirement: Codable, Sendable, Equatable {
    public let kind: PermissionKind
    public let infoPlistKey: String
    public let requiredBeforeRequest: Bool

    public init(kind: PermissionKind, infoPlistKey: String, requiredBeforeRequest: Bool = true) {
        self.kind = kind
        self.infoPlistKey = infoPlistKey
        self.requiredBeforeRequest = requiredBeforeRequest
    }
}

/// Info.plist key knowledge without product-specific copy.
public enum PermissionUsageDescriptions {
    public static func requirements(for kind: PermissionKind) -> [PermissionUsageDescriptionRequirement] {
        switch kind {
        case .camera:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSCameraUsageDescription")]
        case .microphone:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSMicrophoneUsageDescription")]
        case .photoLibrary:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSPhotoLibraryUsageDescription")]
        case .photoLibraryAddOnly:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSPhotoLibraryAddUsageDescription")]
        case .locationWhenInUse:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSLocationWhenInUseUsageDescription")]
        case .locationAlways:
            [
                PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSLocationWhenInUseUsageDescription"),
                PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSLocationAlwaysAndWhenInUseUsageDescription")
            ]
        case .contacts:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSContactsUsageDescription")]
        case .calendars:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSCalendarsUsageDescription")]
        case .reminders:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSRemindersUsageDescription")]
        case .trackingTransparency:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSUserTrackingUsageDescription")]
        case .bluetooth:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSBluetoothAlwaysUsageDescription")]
        case .localNetwork:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSLocalNetworkUsageDescription")]
        case .speechRecognition:
            [PermissionUsageDescriptionRequirement(kind: kind, infoPlistKey: "NSSpeechRecognitionUsageDescription")]
        case .notifications:
            []
        default:
            []
        }
    }
}
