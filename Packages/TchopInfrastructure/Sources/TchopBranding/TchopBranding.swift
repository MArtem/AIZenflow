import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
private typealias PlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
private typealias PlatformColor = NSColor
#endif

/// Shared semantic brand variants resolved from target configuration.
public enum BrandVariant: String, CaseIterable, Codable {
    case classic
    case ocean
}

/// Shared info-dictionary keys used to resolve target branding at runtime.
public enum BrandThemeInfoKey {
    public static let variant = "TchopBrandVariant"
}

/// Semantic color palette that can drive target-specific UI tokens.
public struct BrandTheme {
    public let variant: BrandVariant
    public let primaryAccent: Color
    public let floatingActionButtonFill: Color
    public let floatingActionButtonShadow: Color

    public init(
        variant: BrandVariant,
        primaryAccent: Color,
        floatingActionButtonFill: Color,
        floatingActionButtonShadow: Color
    ) {
        self.variant = variant
        self.primaryAccent = primaryAccent
        self.floatingActionButtonFill = floatingActionButtonFill
        self.floatingActionButtonShadow = floatingActionButtonShadow
    }
}

/// Contract for anything that can resolve the active target theme.
public protocol BrandThemeManaging {
    var activeTheme: BrandTheme { get }
}

/// Reads the active brand variant from target metadata and exposes semantic tokens.
public final class InfoDictionaryBrandThemeManager: BrandThemeManaging {
    private let infoDictionary: [String: Any]

    public convenience init(bundle: Bundle) {
        self.init(infoDictionary: bundle.infoDictionary ?? [:])
    }

    public init(infoDictionary: [String: Any]) {
        self.infoDictionary = infoDictionary
    }

    public var activeTheme: BrandTheme {
        Self.theme(for: activeVariant)
    }

    public var activeVariant: BrandVariant {
        guard let rawValue = infoDictionary[BrandThemeInfoKey.variant] as? String,
              let variant = BrandVariant(rawValue: rawValue) else {
            return .classic
        }

        return variant
    }

    public static func theme(for variant: BrandVariant) -> BrandTheme {
        switch variant {
        case .classic:
            return BrandTheme(
                variant: .classic,
                primaryAccent: dynamicColor(
                    light: platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 1),
                    dark: platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 1)
                ),
                floatingActionButtonFill: dynamicColor(
                    light: platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 1),
                    dark: platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 1)
                ),
                floatingActionButtonShadow: dynamicColor(
                    light: platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 0.35),
                    dark: platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 0.40)
                )
            )
        case .ocean:
            return BrandTheme(
                variant: .ocean,
                primaryAccent: dynamicColor(
                    light: platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 1),
                    dark: platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 1)
                ),
                floatingActionButtonFill: dynamicColor(
                    light: platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 1),
                    dark: platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 1)
                ),
                floatingActionButtonShadow: dynamicColor(
                    light: platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 0.35),
                    dark: platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 0.42)
                )
            )
        }
    }

    private static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> PlatformColor {
        #if canImport(UIKit)
        PlatformColor(red: red, green: green, blue: blue, alpha: alpha)
        #elseif canImport(AppKit)
        PlatformColor(
            calibratedRed: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
        #endif
    }

    private static func dynamicColor(light: PlatformColor, dark: PlatformColor) -> Color {
        #if canImport(UIKit)
        Color(
            uiColor: PlatformColor { trait in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        )
        #elseif canImport(AppKit)
        Color(
            nsColor: PlatformColor(name: nil) { appearance in
                appearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua ? dark : light
            }
        )
        #endif
    }
}
