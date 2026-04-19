import SwiftUI
import TchopBranding
import UIKit

/// Semantic color tokens used across app screens in light and dark modes.
enum AppTheme {
    static let accent = AppBranding.theme.button.primaryFill
    static let accentOnColor = AppBranding.theme.button.primaryForeground
    static let floatingActionButtonFill = AppBranding.theme.button.floatingActionFill
    static let floatingActionButtonShadow = AppBranding.theme.button.floatingActionShadow
    static let selectionFill = AppBranding.theme.navigation.activeBackground
    static let navigationActiveTint = AppBranding.theme.navigation.activeTint
    static let badgeAccentFill = AppBranding.theme.badge.accentFill
    static let badgeAccentForeground = AppBranding.theme.badge.accentForeground
    static let cardHighlightBorder = AppBranding.theme.card.highlightedBorder
    static let success = AppBranding.theme.status.success
    static let destructive = AppBranding.theme.status.destructive

    static let canvasBackground = dynamicColor(
        light: UIColor(red: 0.97, green: 0.96, blue: 0.94, alpha: 1),
        dark: UIColor(red: 0.08, green: 0.09, blue: 0.12, alpha: 1)
    )

    static let surfacePrimary = dynamicColor(
        light: .white,
        dark: UIColor(red: 0.13, green: 0.14, blue: 0.18, alpha: 1)
    )

    static let surfaceSecondary = dynamicColor(
        light: UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),
        dark: UIColor(red: 0.19, green: 0.20, blue: 0.25, alpha: 1)
    )

    static let menuSurface = dynamicColor(
        light: UIColor(red: 0.98, green: 0.97, blue: 0.95, alpha: 1),
        dark: UIColor(red: 0.10, green: 0.11, blue: 0.15, alpha: 1)
    )

    static let textPrimary = dynamicColor(
        light: UIColor(red: 0.24, green: 0.25, blue: 0.36, alpha: 1),
        dark: UIColor(red: 0.92, green: 0.93, blue: 0.97, alpha: 1)
    )

    static let textSecondary = dynamicColor(
        light: UIColor(red: 0.35, green: 0.36, blue: 0.44, alpha: 1),
        dark: UIColor(red: 0.76, green: 0.78, blue: 0.84, alpha: 1)
    )

    static let textTertiary = dynamicColor(
        light: UIColor(red: 0.52, green: 0.53, blue: 0.60, alpha: 1),
        dark: UIColor(red: 0.63, green: 0.65, blue: 0.72, alpha: 1)
    )

    static let iconPrimary = textPrimary
    static let iconSecondary = textTertiary

    static let borderSubtle = dynamicColor(
        light: UIColor.black.withAlphaComponent(0.08),
        dark: UIColor.white.withAlphaComponent(0.14)
    )

    static let shadow = dynamicColor(
        light: UIColor.black.withAlphaComponent(0.10),
        dark: UIColor.black.withAlphaComponent(0.35)
    )

    static let discussionCardSurface = dynamicColor(
        light: UIColor(red: 0.28, green: 0.27, blue: 0.39, alpha: 1),
        dark: UIColor(red: 0.33, green: 0.32, blue: 0.46, alpha: 1)
    )

    static let discussionTextPrimary = dynamicColor(
        light: UIColor.white,
        dark: UIColor(red: 0.96, green: 0.96, blue: 0.99, alpha: 1)
    )

    static let discussionTextSecondary = dynamicColor(
        light: UIColor.white.withAlphaComponent(0.82),
        dark: UIColor(red: 0.86, green: 0.87, blue: 0.93, alpha: 1)
    )

    static let discussionParticipantFill = dynamicColor(
        light: UIColor.white.withAlphaComponent(0.85),
        dark: UIColor(red: 0.78, green: 0.80, blue: 0.88, alpha: 1)
    )

    static let discussionParticipantText = dynamicColor(
        light: UIColor(red: 0.28, green: 0.29, blue: 0.40, alpha: 1),
        dark: UIColor(red: 0.17, green: 0.18, blue: 0.27, alpha: 1)
    )

    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
