import Foundation

public enum SystemPermissionManagerFactory {
    /// Creates a best-effort system manager for the current platform.
    ///
    /// On platforms where no native permission framework is available, this returns
    /// a static unavailable manager. Host apps may still compose custom providers.
    public static func makeDefault() -> any PermissionManaging {
        #if canImport(AVFoundation) || canImport(UserNotifications) || canImport(Photos) || canImport(Contacts) || canImport(AppTrackingTransparency) || canImport(CoreLocation)
        return CompositePermissionManager(providers: SystemPermissionProviders.defaultProviders())
        #else
        return StaticPermissionManager(defaultState: .unavailable)
        #endif
    }
}

public enum SystemPermissionProviders {
    public static func defaultProviders() -> [any PermissionProviding] {
        var providers: [any PermissionProviding] = []
        #if canImport(AVFoundation)
        providers.append(AVFoundationPermissionProvider())
        #endif
        #if canImport(UserNotifications)
        providers.append(UserNotificationPermissionProvider())
        #endif
        #if canImport(Photos)
        providers.append(PhotoLibraryPermissionProvider())
        #endif
        #if canImport(Contacts)
        providers.append(ContactsPermissionProvider())
        #endif
        #if canImport(AppTrackingTransparency)
        providers.append(TrackingTransparencyPermissionProvider())
        #endif
        #if canImport(CoreLocation)
        providers.append(CoreLocationPermissionProvider())
        #endif
        return providers
    }
}
