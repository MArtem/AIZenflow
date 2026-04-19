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

    /// Creates a new BrandTheme instance.
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

    /// Creates a new InfoDictionaryBrandThemeManager instance.
    public convenience init(bundle: Bundle) {
        self.init(infoDictionary: bundle.infoDictionary ?? [:])
    }

    /// Creates a new InfoDictionaryBrandThemeManager instance.
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
                    light: BrandColorTokens.classicPrimaryAccentLight,
                    dark: BrandColorTokens.classicPrimaryAccentDark
                ),
                floatingActionButtonFill: dynamicColor(
                    light: BrandColorTokens.classicPrimaryAccentLight,
                    dark: BrandColorTokens.classicPrimaryAccentDark
                ),
                floatingActionButtonShadow: dynamicColor(
                    light: BrandColorTokens.classicFloatingActionButtonShadowLight,
                    dark: BrandColorTokens.classicFloatingActionButtonShadowDark
                )
            )
        case .ocean:
            return BrandTheme(
                variant: .ocean,
                primaryAccent: dynamicColor(
                    light: BrandColorTokens.oceanPrimaryAccentLight,
                    dark: BrandColorTokens.oceanPrimaryAccentDark
                ),
                floatingActionButtonFill: dynamicColor(
                    light: BrandColorTokens.oceanPrimaryAccentLight,
                    dark: BrandColorTokens.oceanPrimaryAccentDark
                ),
                floatingActionButtonShadow: dynamicColor(
                    light: BrandColorTokens.oceanFloatingActionButtonShadowLight,
                    dark: BrandColorTokens.oceanFloatingActionButtonShadowDark
                )
            )
        }
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
