import Foundation

/// Route payload for destinations in the news tab.
struct NewsRoute: Hashable, Identifiable {
    let id: UUID
    let destinationID: String
    let title: String
    let subtitle: String
    let bodyText: String
    let accentLabel: String?

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
struct MixesRoute: Hashable, Identifiable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the pinned tab.
struct PinnedRoute: Hashable, Identifiable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the chat tab.
struct ChatRoute: Hashable, Identifiable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}

/// Route payload for destinations in the profile tab.
struct ProfileRoute: Hashable, Identifiable {
    let id: UUID
    let title: String
    let description: String

    init(id: UUID = UUID(), title: String, description: String) {
        self.id = id
        self.title = title
        self.description = description
    }
}
