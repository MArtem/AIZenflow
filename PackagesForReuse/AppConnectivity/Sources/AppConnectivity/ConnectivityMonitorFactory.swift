import Foundation

public enum ConnectivityMonitorFactory {
    /// Returns the native monitor on Apple platforms that expose Network.framework, otherwise a manual fallback.
    public static func makeDefault() -> any ConnectivityMonitoring {
        #if canImport(Network)
        return NetworkPathConnectivityMonitor()
        #else
        return ManualConnectivityMonitor(initialSnapshot: .unknown())
        #endif
    }
}
