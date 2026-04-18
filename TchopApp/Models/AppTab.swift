import Foundation

/// Top-level application tabs shared by the tab bar and side menu.
enum AppTab: String, CaseIterable, Identifiable, Codable {
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
        case .news:
            AppLocalization.text("tab.news.title", fallback: "News")
        case .mixes:
            AppLocalization.text("tab.mixes.title", fallback: "Mixes")
        case .pinned:
            AppLocalization.text("tab.pinned.title", fallback: "Pinned")
        case .chat:
            AppLocalization.text("tab.chat.title", fallback: "Chat")
        case .profile:
            AppLocalization.text("tab.profile.title", fallback: "Profile")
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
        case .news:
            AppLocalization.text("tab.news.stubDescription", fallback: "Latest stories and channel updates.")
        case .mixes:
            AppLocalization.text("tab.mixes.stubDescription", fallback: "Curated collections and recommended posts.")
        case .pinned:
            AppLocalization.text("tab.pinned.stubDescription", fallback: "Saved highlights and priority content.")
        case .chat:
            AppLocalization.text("tab.chat.stubDescription", fallback: "Direct messages and team conversations.")
        case .profile:
            AppLocalization.text("tab.profile.stubDescription", fallback: "Account settings, activity, and preferences.")
        }
    }
}
