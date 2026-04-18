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
    static let classicFloatingActionButtonShadowLight = platformColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 0.35)
    static let classicFloatingActionButtonShadowDark = platformColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 0.40)

    static let oceanPrimaryAccentLight = platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 1)
    static let oceanPrimaryAccentDark = platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 1)
    static let oceanFloatingActionButtonShadowLight = platformColor(red: 0.09, green: 0.49, blue: 0.73, alpha: 0.35)
    static let oceanFloatingActionButtonShadowDark = platformColor(red: 0.34, green: 0.76, blue: 0.92, alpha: 0.42)

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
