import Foundation

public enum ThermalCondition: String, Codable, Sendable, Equatable, CaseIterable {
    case nominal
    case fair
    case serious
    case critical
    case unavailable
    case unknown
}
