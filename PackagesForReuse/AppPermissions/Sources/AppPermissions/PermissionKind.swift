import Foundation

/// An app-independent permission identifier.
///
/// `PermissionKind` is a struct instead of a closed enum so host apps can add
/// their own custom permission-like capabilities without forking the package.
public struct PermissionKind: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral, CustomStringConvertible {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    public var description: String { rawValue }
}

public extension PermissionKind {
    static let camera = PermissionKind("camera")
    static let microphone = PermissionKind("microphone")
    static let photoLibrary = PermissionKind("photo_library")
    static let photoLibraryAddOnly = PermissionKind("photo_library_add_only")
    static let locationWhenInUse = PermissionKind("location_when_in_use")
    static let locationAlways = PermissionKind("location_always")
    static let notifications = PermissionKind("notifications")
    static let contacts = PermissionKind("contacts")
    static let calendars = PermissionKind("calendars")
    static let reminders = PermissionKind("reminders")
    static let trackingTransparency = PermissionKind("tracking_transparency")
    static let bluetooth = PermissionKind("bluetooth")
    static let localNetwork = PermissionKind("local_network")
    static let speechRecognition = PermissionKind("speech_recognition")
}
