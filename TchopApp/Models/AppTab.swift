import Foundation

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
