import Foundation
import SwiftUI
import UIKit

/// Top-level application tabs shared by the tab bar and side menu.
enum AppTab: String, CaseIterable, Identifiable {
    case news
    case mixes
    case pinned
    case chat
    case profile

    /// Stable identity used by SwiftUI collections.
    var id: String { rawValue }

    /// Human-readable title rendered in the bottom tab bar and menu.
    var title: String {
        switch self {
        case .news: "News"
        case .mixes: "Mixes"
        case .pinned: "Pinned"
        case .chat: "Chat"
        case .profile: "Profile"
        }
    }

    /// Symbol name used by the bottom tab bar.
    var tabIcon: String {
        switch self {
        case .news: "square.grid.2x2.fill"
        case .mixes: "line.3.horizontal.decrease"
        case .pinned: "pin"
        case .chat: "bubble.left"
        case .profile: "person.crop.circle.fill"
        }
    }

    /// Symbol name used by the side menu.
    var menuIcon: String {
        switch self {
        case .news: "newspaper"
        case .mixes: "slider.horizontal.3"
        case .pinned: "pin.fill"
        case .chat: "message"
        case .profile: "person.circle"
        }
    }

    /// Placeholder copy used by stub screens.
    var stubDescription: String {
        switch self {
        case .news: "Latest stories and channel updates."
        case .mixes: "Curated collections and recommended posts."
        case .pinned: "Saved highlights and priority content."
        case .chat: "Direct messages and team conversations."
        case .profile: "Account settings, activity, and preferences."
        }
    }
}

enum AppTheme {
    static let accent = dynamicColor(
        light: UIColor(red: 0.95, green: 0.50, blue: 0.37, alpha: 1),
        dark: UIColor(red: 1.00, green: 0.64, blue: 0.52, alpha: 1)
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

    static let selectionFill = dynamicColor(
        light: UIColor(red: 0.99, green: 0.94, blue: 0.91, alpha: 1),
        dark: UIColor(red: 0.24, green: 0.17, blue: 0.15, alpha: 1)
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

    private static func dynamicColor(light: UIColor, dark: UIColor) -> Color {
        Color(
            uiColor: UIColor { trait in
                trait.userInterfaceStyle == .dark ? dark : light
            }
        )
    }
}
