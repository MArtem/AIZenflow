import Foundation

/// Route payload for destinations in the news tab.
struct NewsRoute: Hashable, Identifiable, Codable {
    let id: UUID
    let destinationID: String
    let title: String
    let subtitle: String
    let bodyText: String
    let accentLabel: String?

    /// Creates a new NewsRoute instance.
    init(
        id: UUID = UUID(),
        destinationID: String,
        title: String,
        subtitle: String,
        bodyText: String,
        accentLabel: String? = nil
    ) {
        self.id = id
        self.destinationID = destinationID
        self.title = title
        self.subtitle = subtitle
        self.bodyText = bodyText
        self.accentLabel = accentLabel
    }
}

/// Route payload for destinations in the mixes tab.
struct MixesRoute: Hashable, Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String

    /// Creates a new MixesRoute instance.
    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the pinned tab.
struct PinnedRoute: Hashable, Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String

    /// Creates a new PinnedRoute instance.
    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the chat tab.
struct ChatRoute: Hashable, Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String

    /// Creates a new ChatRoute instance.
    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the profile tab.
struct ProfileRoute: Hashable, Identifiable, Codable {
    let id: UUID
    let title: String
    let description: String

    /// Creates a new ProfileRoute instance.
    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}
