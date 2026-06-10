import Foundation

public protocol FeatureFlagBucketing: Sendable {
    func bucket(key: FeatureFlagKey, identifier: String) -> Double
}

/// Stable FNV-1a based bucketer returning values in `0..<100`.
public struct StableFeatureFlagBucketer: FeatureFlagBucketing {
    public init() {}

    public func bucket(key: FeatureFlagKey, identifier: String) -> Double {
        let input = "\(key.rawValue):\(identifier)"
        var hash: UInt64 = 14695981039346656037
        for byte in input.utf8 {
            hash ^= UInt64(byte)
            hash &*= 1099511628211
        }
        let normalized = hash % 10_000
        return Double(normalized) / 100.0
    }
}
