import SwiftUI
import TchopBranding
import UIKit

/// Semantic color tokens used across app screens in light and dark modes.
@MainActor
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
    static let warning = dynamicColor(
        light: UIColor(red: 0.86, green: 0.47, blue: 0.11, alpha: 1),
        dark: UIColor(red: 1.00, green: 0.73, blue: 0.34, alpha: 1)
    )

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

    /// Resolves target-specific glass styling for one semantic chrome role.
    static func glassStyle(for role: BrandGlassRole) -> BrandGlassStyle? {
        AppBranding.theme.glass.style(for: role)
    }

    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}

/// Shared spacing tokens used by screens, cards, and shell chrome.
enum AppSpacing {
    static let xxs: CGFloat = 4
    static let xs: CGFloat = 8
    static let sm: CGFloat = 12
    static let md: CGFloat = 16
    static let lg: CGFloat = 20
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 28
    static let xxxl: CGFloat = 32

    static let screenHorizontal: CGFloat = 14
    static let shellHorizontal: CGFloat = 16
    static let cardPadding: CGFloat = 20
    static let cardSection: CGFloat = 18
    static let formSection: CGFloat = 24
    static let featureSection: CGFloat = 24
    static let profileTopInset: CGFloat = 28
    static let loginTopInset: CGFloat = 36
    static let loginBottomInset: CGFloat = 32
    static let shellBottomInset: CGFloat = 120
}

/// Shared corner-radius tokens used across inputs, cards, buttons, and shell chrome.
enum AppRadius {
    static let badge: CGFloat = 6
    static let menuSelection: CGFloat = 14
    static let compactCard: CGFloat = 12
    static let buttonField: CGFloat = 18
    static let prominentButton: CGFloat = 20
    static let quickAction: CGFloat = 22
    static let card: CGFloat = 24
    static let featureHero: CGFloat = 28
}

/// Shared typography tokens used across the app's primary screens.
enum AppTypography {
    static let heroDisplay = Font.system(size: 34, weight: .bold)
    static let featureDisplay = Font.system(size: 30, weight: .bold)
    static let profileDisplay = Font.system(size: 28, weight: .bold)
    static let menuTitle = Font.system(size: 22, weight: .bold)
    static let sectionTitle = Font.system(size: 20, weight: .bold)
    static let cardTitle = Font.system(size: 18, weight: .semibold)
    static let cardTitleBold = Font.system(size: 18, weight: .bold)
    static let actionTitle = Font.system(size: 16, weight: .semibold)
    static let bodyRegular = Font.system(size: 16, weight: .regular)
    static let body = Font.system(size: 15, weight: .medium)
    static let bodySemibold = Font.system(size: 15, weight: .semibold)
    static let detail = Font.system(size: 14, weight: .medium)
    static let detailSemibold = Font.system(size: 14, weight: .semibold)
    static let caption = Font.system(size: 13, weight: .medium)
    static let captionSemibold = Font.system(size: 13, weight: .semibold)
    static let label = Font.system(size: 12, weight: .medium)
    static let labelSemibold = Font.system(size: 12, weight: .semibold)
    static let eyebrow = Font.system(size: 12, weight: .semibold)
    static let eyebrowStrong = Font.system(size: 11, weight: .bold)
    static let microLabel = Font.system(size: 10, weight: .semibold)
    static let channelTitle = Font.system(size: 16, weight: .semibold)
    static let channelSubtitle = Font.system(size: 13, weight: .regular)
    static let shellIcon = Font.system(size: 18, weight: .regular)
    static let shellMenuIcon = Font.system(size: 20, weight: .medium)
    static let fabIcon = Font.system(size: 28, weight: .medium)

    static func featuredHeadline(isExpanded: Bool) -> Font {
        .system(size: isExpanded ? 18 : 16, weight: .bold)
    }

    static func discussionHeadline(isExpanded: Bool) -> Font {
        .system(size: isExpanded ? 16 : 15, weight: .bold)
    }

    static func featuredHeroSymbol(isExpanded: Bool) -> Font {
        .system(size: isExpanded ? 120 : 88)
    }
}
