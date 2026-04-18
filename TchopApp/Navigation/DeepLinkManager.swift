import Foundation

/// Resolves deep and universal links into coordinator-driven app navigation.
@MainActor
final class DeepLinkManager: DeepLinkManaging {
    private let eventReporter: any NavigationEventReporting

    init(eventReporter: (any NavigationEventReporting)? = nil) {
        self.eventReporter = eventReporter ?? NavigationNoopEventReporter()
    }

    @discardableResult
    func handle(url: URL, coordinator: AppCoordinator) -> Bool {
        let urlString = url.absoluteString
        switch parseIntent(from: url) {
        case .unsupported:
            eventReporter.report(.deepLinkRejected(url: urlString, reason: "unsupported-link"))
            return false
        case let .invalidInAppLink(reason):
            coordinator.selectTab(.news)
            coordinator.newsRouter.popToRoot()
            eventReporter.report(.deepLinkFallback(url: urlString, reason: reason))
            return true
        case let .resolved(intent):
            apply(intent, coordinator: coordinator)
            eventReporter.report(
                .deepLinkHandled(
                    url: urlString,
                    destination: intent.destination.debugName,
                    policy: intent.policy
                )
            )
            return true
        }
    }

    @discardableResult
    func handle(userActivity: NSUserActivity, coordinator: AppCoordinator) -> Bool {
        guard let webpageURL = userActivity.webpageURL else {
            return false
        }

        return handle(url: webpageURL, coordinator: coordinator)
    }

    private func parseIntent(from url: URL) -> DeepLinkParseResult {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return .unsupported
        }

        let normalizedScheme = components.scheme?.lowercased()
        if normalizedScheme == "tchop" {
            return parseCustomSchemeIntent(components: components)
        }

        return parseUniversalLinkIntent(components: components)
    }

    private func parseCustomSchemeIntent(components: URLComponents) -> DeepLinkParseResult {
        guard let host = components.host else {
            return .invalidInAppLink(reason: "missing-host")
        }

        let trailingSegments = components.path
            .split(separator: "/")
            .map(String.init)
        let segments = [host] + trailingSegments
        return buildIntent(pathSegments: segments, queryItems: components.queryItems ?? [])
    }

    private func parseUniversalLinkIntent(components: URLComponents) -> DeepLinkParseResult {
        guard let host = components.host?.lowercased(), host == "example.com" || host == "www.example.com" else {
            return .unsupported
        }

        let pathSegments = components.path
            .split(separator: "/")
            .map(String.init)
        return buildIntent(pathSegments: pathSegments, queryItems: components.queryItems ?? [])
    }

    private func buildIntent(
        pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> DeepLinkParseResult {
        guard let firstSegment = pathSegments.first?.lowercased() else {
            return .invalidInAppLink(reason: "missing-path")
        }

        let transitionPolicy = parseTransitionPolicy(queryItems: queryItems)
        switch firstSegment {
        case "news":
            return buildNewsIntent(
                pathSegments: pathSegments,
                queryItems: queryItems,
                transitionPolicy: transitionPolicy
            )
        case "mixes":
            return buildMixesIntent(queryItems: queryItems, transitionPolicy: transitionPolicy)
        case "pinned":
            return buildPinnedIntent(queryItems: queryItems, transitionPolicy: transitionPolicy)
        case "chat":
            return buildChatIntent(queryItems: queryItems, transitionPolicy: transitionPolicy)
        case "profile":
            return buildProfileIntent(queryItems: queryItems, transitionPolicy: transitionPolicy)
        default:
            return .invalidInAppLink(reason: "unknown-root-segment")
        }
    }

    private func buildNewsIntent(
        pathSegments: [String],
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        guard pathSegments.count > 1 else {
            return .resolved(
                DeepLinkIntent(
                    destination: .tab(.news),
                    policy: .replace
                )
            )
        }

        let secondSegment = pathSegments[1].lowercased()
        if secondSegment == "discussion" {
            guard let title = requiredQueryValue("title", queryItems) else {
                return .invalidInAppLink(reason: "missing-discussion-title")
            }
            let subtitle = queryValue("subtitle", queryItems) ?? "Open discussion"
            let body = queryValue("body", queryItems) ?? "Discussion deep link destination."
            return .resolved(
                DeepLinkIntent(
                    destination: .newsDiscussion(
                        NewsRoute(
                            destinationID: "discussion-details",
                            title: title,
                            subtitle: subtitle,
                            bodyText: body
                        )
                    ),
                    policy: transitionPolicy
                )
            )
        }

        guard secondSegment == "article" else {
            return .invalidInAppLink(reason: "unknown-news-destination")
        }

        guard let title = requiredQueryValue("title", queryItems) else {
            return .invalidInAppLink(reason: "missing-article-title")
        }
        let subtitle = queryValue("subtitle", queryItems) ?? "From deep link"
        let body = queryValue("body", queryItems) ?? "Article deep link destination."
        let accentLabel = queryValue("accent", queryItems)

        return .resolved(
            DeepLinkIntent(
                destination: .newsArticle(
                    NewsRoute(
                        destinationID: "article-details",
                        title: title,
                        subtitle: subtitle,
                        bodyText: body,
                        accentLabel: accentLabel
                    )
                ),
                policy: transitionPolicy
            )
        )
    }

    private func buildMixesIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .resolved(DeepLinkIntent(destination: .tab(.mixes), policy: .replace))
        }

        let description = queryValue("description", queryItems) ?? "Mix detail opened from a deep link."
        return .resolved(
            DeepLinkIntent(
                destination: .mixes(MixesRoute(title: title, description: description)),
                policy: transitionPolicy
            )
        )
    }

    private func buildPinnedIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .resolved(DeepLinkIntent(destination: .tab(.pinned), policy: .replace))
        }

        let description = queryValue("description", queryItems) ?? "Pinned detail opened from a deep link."
        return .resolved(
            DeepLinkIntent(
                destination: .pinned(PinnedRoute(title: title, description: description)),
                policy: transitionPolicy
            )
        )
    }

    private func buildChatIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .resolved(DeepLinkIntent(destination: .tab(.chat), policy: .replace))
        }

        let description = queryValue("description", queryItems) ?? "Chat room opened from a deep link."
        return .resolved(
            DeepLinkIntent(
                destination: .chat(ChatRoute(title: title, description: description)),
                policy: transitionPolicy
            )
        )
    }

    private func buildProfileIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .resolved(DeepLinkIntent(destination: .tab(.profile), policy: .replace))
        }

        let description = queryValue("description", queryItems) ?? "Profile detail opened from a deep link."
        return .resolved(
            DeepLinkIntent(
                destination: .profile(ProfileRoute(title: title, description: description)),
                policy: transitionPolicy
            )
        )
    }

    private func apply(_ intent: DeepLinkIntent, coordinator: AppCoordinator) {
        switch intent.destination {
        case let .tab(tab):
            coordinator.selectTab(tab)
        case let .newsArticle(route):
            coordinator.selectTab(.news)
            coordinator.navigateToNews(route, policy: intent.policy)
        case let .newsDiscussion(route):
            coordinator.selectTab(.news)
            coordinator.navigateToNews(route, policy: intent.policy)
        case let .mixes(route):
            coordinator.selectTab(.mixes)
            coordinator.navigateToMixes(route, policy: intent.policy)
        case let .pinned(route):
            coordinator.selectTab(.pinned)
            coordinator.navigateToPinned(route, policy: intent.policy)
        case let .chat(route):
            coordinator.selectTab(.chat)
            coordinator.navigateToChat(route, policy: intent.policy)
        case let .profile(route):
            coordinator.selectTab(.profile)
            coordinator.navigateToProfile(route, policy: intent.policy)
        }
    }

    private func queryValue(_ name: String, _ items: [URLQueryItem]) -> String? {
        guard let value = items.first(where: { $0.name == name })?.value?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            return nil
        }
        return value
    }

    private func requiredQueryValue(_ name: String, _ items: [URLQueryItem]) -> String? {
        queryValue(name, items)
    }

    private func parseTransitionPolicy(queryItems: [URLQueryItem]) -> NavigationTransitionPolicy {
        guard let rawValue = queryValue("transition", queryItems)?.lowercased() else {
            return .replace
        }

        switch rawValue {
        case "push":
            return .push
        case "root", "poptoroot", "pop_to_root":
            return .popToRoot
        default:
            return .replace
        }
    }
}

private enum DeepLinkParseResult {
    case resolved(DeepLinkIntent)
    case invalidInAppLink(reason: String)
    case unsupported
}

private struct DeepLinkIntent {
    let destination: DeepLinkDestination
    let policy: NavigationTransitionPolicy
}

private enum DeepLinkDestination {
    case tab(AppTab)
    case newsArticle(NewsRoute)
    case newsDiscussion(NewsRoute)
    case mixes(MixesRoute)
    case pinned(PinnedRoute)
    case chat(ChatRoute)
    case profile(ProfileRoute)

    var debugName: String {
        switch self {
        case let .tab(tab):
            return "tab:\(tab.rawValue)"
        case .newsArticle:
            return "news-article"
        case .newsDiscussion:
            return "news-discussion"
        case .mixes:
            return "mixes-detail"
        case .pinned:
            return "pinned-detail"
        case .chat:
            return "chat-detail"
        case .profile:
            return "profile-detail"
        }
    }
}
