import SwiftUI

#if canImport(UIKit)
import UIKit
typealias BrandPlatformColor = UIColor
#elseif canImport(AppKit)
import AppKit
typealias BrandPlatformColor = NSColor
#endif

/// Centralized raw palette values for each supported brand variant.
enum BrandColorTokens {
    static let classicPrimaryAccentLight = platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 1)
    static let classicPrimaryAccentDark = platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 1)
    static let classicPrimaryForegroundLight = platformColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1)
    static let classicPrimaryForegroundDark = platformColor(red: 0.15, green: 0.11, blue: 0.10, alpha: 1)
    static let classicFloatingActionButtonShadowLight = platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 0.35)
    static let classicFloatingActionButtonShadowDark = platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 0.40)
    static let classicBadgeFillLight = platformColor(red: 0.99, green: 0.91, blue: 0.85, alpha: 1)
    static let classicBadgeFillDark = platformColor(red: 0.35, green: 0.22, blue: 0.18, alpha: 1)
    static let classicTabIndicatorLight = platformColor(red: 0.99, green: 0.94, blue: 0.91, alpha: 1)
    static let classicTabIndicatorDark = platformColor(red: 0.29, green: 0.18, blue: 0.15, alpha: 1)
    static let classicCardHighlightBorderLight = platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 0.22)
    static let classicCardHighlightBorderDark = platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 0.30)
    static let classicNavigationBackgroundLight = platformColor(red: 0.99, green: 0.94, blue: 0.91, alpha: 1)
    static let classicNavigationBackgroundDark = platformColor(red: 0.25, green: 0.16, blue: 0.14, alpha: 1)
    static let classicSuccessLight = platformColor(red: 0.20, green: 0.67, blue: 0.42, alpha: 1)
    static let classicSuccessDark = platformColor(red: 0.33, green: 0.83, blue: 0.56, alpha: 1)
    static let classicDestructiveLight = platformColor(red: 0.84, green: 0.24, blue: 0.24, alpha: 1)
    static let classicDestructiveDark = platformColor(red: 1.00, green: 0.45, blue: 0.45, alpha: 1)

    static let oceanPrimaryAccentLight = platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 1)
    static let oceanPrimaryAccentDark = platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 1)
    static let oceanPrimaryForegroundLight = platformColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1)
    static let oceanPrimaryForegroundDark = platformColor(red: 0.07, green: 0.15, blue: 0.20, alpha: 1)
    static let oceanFloatingActionButtonShadowLight = platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 0.35)
    static let oceanFloatingActionButtonShadowDark = platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 0.42)
    static let oceanBadgeFillLight = platformColor(red: 0.86, green: 0.95, blue: 0.99, alpha: 1)
    static let oceanBadgeFillDark = platformColor(red: 0.13, green: 0.27, blue: 0.34, alpha: 1)
    static let oceanTabIndicatorLight = platformColor(red: 0.89, green: 0.96, blue: 0.99, alpha: 1)
    static let oceanTabIndicatorDark = platformColor(red: 0.14, green: 0.28, blue: 0.36, alpha: 1)
    static let oceanCardHighlightBorderLight = platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 0.22)
    static let oceanCardHighlightBorderDark = platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 0.30)
    static let oceanNavigationBackgroundLight = platformColor(red: 0.89, green: 0.96, blue: 0.99, alpha: 1)
    static let oceanNavigationBackgroundDark = platformColor(red: 0.12, green: 0.24, blue: 0.31, alpha: 1)
    static let oceanSuccessLight = platformColor(red: 0.16, green: 0.68, blue: 0.54, alpha: 1)
    static let oceanSuccessDark = platformColor(red: 0.31, green: 0.85, blue: 0.69, alpha: 1)
    static let oceanDestructiveLight = platformColor(red: 0.82, green: 0.28, blue: 0.33, alpha: 1)
    static let oceanDestructiveDark = platformColor(red: 0.98, green: 0.47, blue: 0.53, alpha: 1)

    private static func platformColor(red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) -> BrandPlatformColor {
        #if canImport(UIKit)
        BrandPlatformColor(red: red, green: green, blue: blue, alpha: alpha)
        #elseif canImport(AppKit)
        BrandPlatformColor(
            calibratedRed: red,
            green: green,
            blue: blue,
            alpha: alpha
        )
        #endif
    }
}
