import Foundation

/// Resolves deep and universal links into coordinator-driven app navigation.
@MainActor
final class DeepLinkManager: DeepLinkManaging {
    @discardableResult
    func handle(url: URL, coordinator: AppCoordinator) -> Bool {
        guard let destination = parseDestination(from: url) else {
            return false
        }

        apply(destination, coordinator: coordinator)
        return true
    }

    @discardableResult
    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool {
        guard let webpageURL = userActivity.webpageURL else {
            return false
        }

        return handle(url: webpageURL, coordinator: coordinator)
    }

    private func parseDestination(from url: URL) -> DeepLinkDestination? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return nil
        }

        let normalizedScheme = components.scheme?.lowercased()
        if normalizedScheme == "tchop" {
            return parseCustomSchemeDestination(components: components)
        }

        return parseUniversalLinkDestination(components: components)
    }

    private func parseCustomSchemeDestination(components: URLComponents) -> DeepLinkDestination? {
        guard let host = components.host else {
            return nil
        }

        let trailingSegments = components.path
            .split(separator: "/")
            .map(String.init)
        let segments = [host] + trailingSegments
        return buildDestination(pathSegments: segments, queryItems: components.queryItems ?? [])
    }

    private func parseUniversalLinkDestination(components: URLComponents) -> DeepLinkDestination? {
        let pathSegments = components.path
            .split(separator: "/")
            .map(String.init)
        return buildDestination(pathSegments: pathSegments, queryItems: components.queryItems ?? [])
    }

    private func buildDestination(
        pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> DeepLinkDestination? {
        guard let firstSegment = pathSegments.first?.lowercased() else {
            return nil
        }

        switch firstSegment {
        case "news":
            return buildNewsDestination(pathSegments: pathSegments, queryItems: queryItems)
        case "mixes":
            return buildMixesDestination(queryItems: queryItems)
        case "pinned":
            return buildPinnedDestination(queryItems: queryItems)
        case "chat":
            return buildChatDestination(queryItems: queryItems)
        case "profile":
            return buildProfileDestination(queryItems: queryItems)
        default:
            return nil
        }
    }

    private func buildNewsDestination(
        pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> DeepLinkDestination {
        guard pathSegments.count > 1 else {
            return .tab(.news)
        }

        let secondSegment = pathSegments[1].lowercased()
        if secondSegment == "discussion" {
            let title = queryValue("title", queryItems) ?? "Discussion"
            let subtitle = queryValue("subtitle", queryItems) ?? "Open discussion"
            let body = queryValue("body", queryItems) ?? "Discussion deep link destination."
            return .newsDiscussion(
                NewsRoute(
                    destinationID: "discussion-details",
                    title: title,
                    subtitle: subtitle,
                    bodyText: body
                )
            )
        }

        let title = queryValue("title", queryItems) ?? "Article"
        let subtitle = queryValue("subtitle", queryItems) ?? "From deep link"
        let body = queryValue("body", queryItems) ?? "Article deep link destination."
        let accentLabel = queryValue("accent", queryItems)

        return .newsArticle(
            NewsRoute(
                destinationID: "article-details",
                title: title,
                subtitle: subtitle,
                bodyText: body,
                accentLabel: accentLabel
            )
        )
    }

    private func buildMixesDestination(queryItems: [URLQueryItem]) -> DeepLinkDestination {
        guard let title = queryValue("title", queryItems) else {
            return .tab(.mixes)
        }

        let description = queryValue("description", queryItems) ?? "Mix detail opened from a deep link."
        return .mixes(MixesRoute(title: title, description: description))
    }

    private func buildPinnedDestination(queryItems: [URLQueryItem]) -> DeepLinkDestination {
        guard let title = queryValue("title", queryItems) else {
            return .tab(.pinned)
        }

        let description = queryValue("description", queryItems) ?? "Pinned detail opened from a deep link."
        return .pinned(PinnedRoute(title: title, description: description))
    }

    private func buildChatDestination(queryItems: [URLQueryItem]) -> DeepLinkDestination {
        guard let title = queryValue("title", queryItems) else {
            return .tab(.chat)
        }

        let description = queryValue("description", queryItems) ?? "Chat room opened from a deep link."
        return .chat(ChatRoute(title: title, description: description))
    }

    private func buildProfileDestination(queryItems: [URLQueryItem]) -> DeepLinkDestination {
        guard let title = queryValue("title", queryItems) else {
            return .tab(.profile)
        }

        let description = queryValue("description", queryItems) ?? "Profile detail opened from a deep link."
        return .profile(ProfileRoute(title: title, description: description))
    }

    private func apply(_ destination: DeepLinkDestination, coordinator: AppCoordinator) {
        switch destination {
        case let .tab(tab):
            coordinator.selectTab(tab)
        case let .newsArticle(route):
            coordinator.selectTab(.news)
            coordinator.newsRouter.replacePath(with: [route])
        case let .newsDiscussion(route):
            coordinator.selectTab(.news)
            coordinator.newsRouter.replacePath(with: [route])
        case let .mixes(route):
            coordinator.selectTab(.mixes)
            coordinator.mixesRouter.replacePath(with: [route])
        case let .pinned(route):
            coordinator.selectTab(.pinned)
            coordinator.pinnedRouter.replacePath(with: [route])
        case let .chat(route):
            coordinator.selectTab(.chat)
            coordinator.chatRouter.replacePath(with: [route])
        case let .profile(route):
            coordinator.selectTab(.profile)
            coordinator.profileRouter.replacePath(with: [route])
        }
    }

    private func queryValue(_ name: String, _ items: [URLQueryItem]) -> String? {
        items.first(where: { $0.name == name })?.value
    }
}

private enum DeepLinkDestination {
    case tab(AppTab)
    case newsArticle(NewsRoute)
    case newsDiscussion(NewsRoute)
    case mixes(MixesRoute)
    case pinned(PinnedRoute)
    case chat(ChatRoute)
    case profile(ProfileRoute)
}
