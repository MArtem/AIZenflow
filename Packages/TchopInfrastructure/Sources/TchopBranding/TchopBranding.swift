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

/// Extensible semantic key used to look up target-specific glass styling for chrome elements.
public struct BrandGlassRole: RawRepresentable, Hashable, Codable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    /// Creates a new BrandGlassRole instance.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    /// Creates a new BrandGlassRole instance from a string literal.
    public init(stringLiteral value: StringLiteralType) {
        self.init(rawValue: value)
    }

    public static let floatingActionButton = BrandGlassRole(rawValue: "shell.floatingActionButton")
}

/// Target-specific tint and stroke tokens for one glass-backed semantic element.
public struct BrandGlassStyle {
    public let tint: Color?
    public let stroke: Color?

    /// Creates a new BrandGlassStyle instance.
    public init(tint: Color?, stroke: Color? = nil) {
        self.tint = tint
        self.stroke = stroke
    }
}

/// Catalog of target-specific glass styles keyed by semantic roles rather than individual view implementations.
public struct BrandGlassTheme {
    private let stylesByRole: [BrandGlassRole: BrandGlassStyle]

    /// Creates a new BrandGlassTheme instance.
    public init(stylesByRole: [BrandGlassRole: BrandGlassStyle] = [:]) {
        self.stylesByRole = stylesByRole
    }

    /// Resolves a glass style for the provided semantic role.
    public func style(for role: BrandGlassRole) -> BrandGlassStyle? {
        stylesByRole[role]
    }
}

/// Semantic color palette that can drive target-specific UI tokens.
public struct BrandTheme {
    public let variant: BrandVariant
    public let button: BrandButtonTheme
    public let badge: BrandBadgeTheme
    public let tab: BrandTabTheme
    public let card: BrandCardTheme
    public let navigation: BrandNavigationTheme
    public let status: BrandStatusTheme
    public let glass: BrandGlassTheme

    /// Creates a new BrandTheme instance.
    public init(
        variant: BrandVariant,
        button: BrandButtonTheme,
        badge: BrandBadgeTheme,
        tab: BrandTabTheme,
        card: BrandCardTheme,
        navigation: BrandNavigationTheme,
        status: BrandStatusTheme,
        glass: BrandGlassTheme = BrandGlassTheme()
    ) {
        self.variant = variant
        self.button = button
        self.badge = badge
        self.tab = tab
        self.card = card
        self.navigation = navigation
        self.status = status
        self.glass = glass
    }

    /// Backward-compatible alias for the primary accent token.
    public var primaryAccent: Color {
        button.primaryFill
    }

    /// Backward-compatible alias for the floating action button fill token.
    public var floatingActionButtonFill: Color {
        button.floatingActionFill
    }

    /// Backward-compatible alias for the floating action button shadow token.
    public var floatingActionButtonShadow: Color {
        button.floatingActionShadow
    }
}

/// Semantic brand tokens for button-style elements.
public struct BrandButtonTheme {
    public let primaryFill: Color
    public let primaryForeground: Color
    public let floatingActionFill: Color
    public let floatingActionShadow: Color

    /// Creates a new BrandButtonTheme instance.
    public init(
        primaryFill: Color,
        primaryForeground: Color,
        floatingActionFill: Color,
        floatingActionShadow: Color
    ) {
        self.primaryFill = primaryFill
        self.primaryForeground = primaryForeground
        self.floatingActionFill = floatingActionFill
        self.floatingActionShadow = floatingActionShadow
    }
}

/// Semantic brand tokens for badge-like highlights and pills.
public struct BrandBadgeTheme {
    public let accentFill: Color
    public let accentForeground: Color

    /// Creates a new BrandBadgeTheme instance.
    public init(accentFill: Color, accentForeground: Color) {
        self.accentFill = accentFill
        self.accentForeground = accentForeground
    }
}

/// Semantic brand tokens for tab selection and emphasis.
public struct BrandTabTheme {
    public let selectedIcon: Color
    public let selectedIndicator: Color

    /// Creates a new BrandTabTheme instance.
    public init(selectedIcon: Color, selectedIndicator: Color) {
        self.selectedIcon = selectedIcon
        self.selectedIndicator = selectedIndicator
    }
}

/// Semantic brand tokens for cards and highlighted content blocks.
public struct BrandCardTheme {
    public let highlightedBorder: Color
    public let highlightedAccent: Color

    /// Creates a new BrandCardTheme instance.
    public init(highlightedBorder: Color, highlightedAccent: Color) {
        self.highlightedBorder = highlightedBorder
        self.highlightedAccent = highlightedAccent
    }
}

/// Semantic brand tokens for navigation chrome and active destinations.
public struct BrandNavigationTheme {
    public let activeTint: Color
    public let activeBackground: Color

    /// Creates a new BrandNavigationTheme instance.
    public init(activeTint: Color, activeBackground: Color) {
        self.activeTint = activeTint
        self.activeBackground = activeBackground
    }
}

/// Semantic brand tokens for common status states.
public struct BrandStatusTheme {
    public let success: Color
    public let destructive: Color

    /// Creates a new BrandStatusTheme instance.
    public init(success: Color, destructive: Color) {
        self.success = success
        self.destructive = destructive
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

    /// Resolves the semantic brand token set for one active variant.
    public static func theme(for variant: BrandVariant) -> BrandTheme {
        switch variant {
        case .classic:
            return BrandTheme(
                variant: .classic,
                button: BrandButtonTheme(
                    primaryFill: dynamicColor(
                        light: BrandColorTokens.classicPrimaryAccentLight,
                        dark: BrandColorTokens.classicPrimaryAccentDark
                    ),
                    primaryForeground: dynamicColor(
                        light: BrandColorTokens.classicPrimaryForegroundLight,
                        dark: BrandColorTokens.classicPrimaryForegroundDark
                    ),
                    floatingActionFill: dynamicColor(
                        light: BrandColorTokens.classicPrimaryAccentLight,
                        dark: BrandColorTokens.classicPrimaryAccentDark
                    ),
                    floatingActionShadow: dynamicColor(
                        light: BrandColorTokens.classicFloatingActionButtonShadowLight,
                        dark: BrandColorTokens.classicFloatingActionButtonShadowDark
                    )
                ),
                badge: BrandBadgeTheme(
                    accentFill: dynamicColor(
                        light: BrandColorTokens.classicBadgeFillLight,
                        dark: BrandColorTokens.classicBadgeFillDark
                    ),
                    accentForeground: dynamicColor(
                        light: BrandColorTokens.classicPrimaryForegroundLight,
                        dark: BrandColorTokens.classicPrimaryForegroundDark
                    )
                ),
                tab: BrandTabTheme(
                    selectedIcon: dynamicColor(
                        light: BrandColorTokens.classicPrimaryAccentLight,
                        dark: BrandColorTokens.classicPrimaryAccentDark
                    ),
                    selectedIndicator: dynamicColor(
                        light: BrandColorTokens.classicTabIndicatorLight,
                        dark: BrandColorTokens.classicTabIndicatorDark
                    )
                ),
                card: BrandCardTheme(
                    highlightedBorder: dynamicColor(
                        light: BrandColorTokens.classicCardHighlightBorderLight,
                        dark: BrandColorTokens.classicCardHighlightBorderDark
                    ),
                    highlightedAccent: dynamicColor(
                        light: BrandColorTokens.classicPrimaryAccentLight,
                        dark: BrandColorTokens.classicPrimaryAccentDark
                    )
                ),
                navigation: BrandNavigationTheme(
                    activeTint: dynamicColor(
                        light: BrandColorTokens.classicPrimaryAccentLight,
                        dark: BrandColorTokens.classicPrimaryAccentDark
                    ),
                    activeBackground: dynamicColor(
                        light: BrandColorTokens.classicNavigationBackgroundLight,
                        dark: BrandColorTokens.classicNavigationBackgroundDark
                    )
                ),
                status: BrandStatusTheme(
                    success: dynamicColor(
                        light: BrandColorTokens.classicSuccessLight,
                        dark: BrandColorTokens.classicSuccessDark
                    ),
                    destructive: dynamicColor(
                        light: BrandColorTokens.classicDestructiveLight,
                        dark: BrandColorTokens.classicDestructiveDark
                    )
                ),
                glass: BrandGlassTheme(
                    stylesByRole: [
                        .floatingActionButton: BrandGlassStyle(
                            tint: dynamicColor(
                                light: BrandColorTokens.classicPrimaryAccentLight,
                                dark: BrandColorTokens.classicPrimaryAccentDark
                            )
                        )
                    ]
                )
            )
        case .ocean:
            return BrandTheme(
                variant: .ocean,
                button: BrandButtonTheme(
                    primaryFill: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryAccentLight,
                        dark: BrandColorTokens.oceanPrimaryAccentDark
                    ),
                    primaryForeground: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryForegroundLight,
                        dark: BrandColorTokens.oceanPrimaryForegroundDark
                    ),
                    floatingActionFill: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryAccentLight,
                        dark: BrandColorTokens.oceanPrimaryAccentDark
                    ),
                    floatingActionShadow: dynamicColor(
                        light: BrandColorTokens.oceanFloatingActionButtonShadowLight,
                        dark: BrandColorTokens.oceanFloatingActionButtonShadowDark
                    )
                ),
                badge: BrandBadgeTheme(
                    accentFill: dynamicColor(
                        light: BrandColorTokens.oceanBadgeFillLight,
                        dark: BrandColorTokens.oceanBadgeFillDark
                    ),
                    accentForeground: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryForegroundLight,
                        dark: BrandColorTokens.oceanPrimaryForegroundDark
                    )
                ),
                tab: BrandTabTheme(
                    selectedIcon: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryAccentLight,
                        dark: BrandColorTokens.oceanPrimaryAccentDark
                    ),
                    selectedIndicator: dynamicColor(
                        light: BrandColorTokens.oceanTabIndicatorLight,
                        dark: BrandColorTokens.oceanTabIndicatorDark
                    )
                ),
                card: BrandCardTheme(
                    highlightedBorder: dynamicColor(
                        light: BrandColorTokens.oceanCardHighlightBorderLight,
                        dark: BrandColorTokens.oceanCardHighlightBorderDark
                    ),
                    highlightedAccent: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryAccentLight,
                        dark: BrandColorTokens.oceanPrimaryAccentDark
                    )
                ),
                navigation: BrandNavigationTheme(
                    activeTint: dynamicColor(
                        light: BrandColorTokens.oceanPrimaryAccentLight,
                        dark: BrandColorTokens.oceanPrimaryAccentDark
                    ),
                    activeBackground: dynamicColor(
                        light: BrandColorTokens.oceanNavigationBackgroundLight,
                        dark: BrandColorTokens.oceanNavigationBackgroundDark
                    )
                ),
                status: BrandStatusTheme(
                    success: dynamicColor(
                        light: BrandColorTokens.oceanSuccessLight,
                        dark: BrandColorTokens.oceanSuccessDark
                    ),
                    destructive: dynamicColor(
                        light: BrandColorTokens.oceanDestructiveLight,
                        dark: BrandColorTokens.oceanDestructiveDark
                    )
                ),
                glass: BrandGlassTheme(
                    stylesByRole: [
                        .floatingActionButton: BrandGlassStyle(
                            tint: dynamicColor(
                                light: BrandColorTokens.oceanPrimaryAccentLight,
                                dark: BrandColorTokens.oceanPrimaryAccentDark
                            )
                        )
                    ]
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
