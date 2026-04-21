import Foundation
import TchopNavigation

/// Resolves deep and universal links into coordinator-driven app navigation.
@MainActor
final class DeepLinkManager: DeepLinkManaging {
    private let eventReporter: any NavigationEventReporting
    private lazy var routeDefinitions: [DeepLinkRouteDefinition] = makeRouteDefinitions()

    /// Builds the declarative routing table for supported deep-link roots.
    private func makeRouteDefinitions() -> [DeepLinkRouteDefinition] {
        [
            DeepLinkRouteDefinition(rootSegment: "news") { [self] pathSegments, queryItems, transitionPolicy in
                return self.buildNewsIntent(
                    pathSegments: pathSegments,
                    queryItems: queryItems,
                    transitionPolicy: transitionPolicy
                )
            },
            DeepLinkRouteDefinition(rootSegment: "mixes") { [self] _, queryItems, transitionPolicy in
                return self.buildMixesIntent(
                    queryItems: queryItems,
                    transitionPolicy: transitionPolicy
                )
            },
            DeepLinkRouteDefinition(rootSegment: "pinned") { [self] _, queryItems, transitionPolicy in
                return self.buildPinnedIntent(
                    queryItems: queryItems,
                    transitionPolicy: transitionPolicy
                )
            },
            DeepLinkRouteDefinition(rootSegment: "chat") { [self] _, queryItems, transitionPolicy in
                return self.buildChatIntent(
                    queryItems: queryItems,
                    transitionPolicy: transitionPolicy
                )
            },
            DeepLinkRouteDefinition(rootSegment: "profile") { [self] _, queryItems, transitionPolicy in
                return self.buildProfileIntent(
                    queryItems: queryItems,
                    transitionPolicy: transitionPolicy
                )
            }
        ]
    }

    /// Creates a new DeepLinkManager instance.
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
            coordinator.showTabRoot(.news)
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

    /// Parses intent.
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

    /// Parses custom scheme intent.
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

    /// Parses universal link intent.
    private func parseUniversalLinkIntent(components: URLComponents) -> DeepLinkParseResult {
        guard let host = components.host?.lowercased(), host == "example.com" || host == "www.example.com" else {
            return .unsupported
        }

        let pathSegments = components.path
            .split(separator: "/")
            .map(String.init)
        return buildIntent(pathSegments: pathSegments, queryItems: components.queryItems ?? [])
    }

    /// Builds intent.
    private func buildIntent(
        pathSegments: [String],
        queryItems: [URLQueryItem]
    ) -> DeepLinkParseResult {
        guard let firstSegment = pathSegments.first?.lowercased() else {
            return .invalidInAppLink(reason: "missing-path")
        }

        let transitionPolicy = parseTransitionPolicy(queryItems: queryItems)
        guard let routeDefinition = routeDefinitions.first(where: { $0.rootSegment == firstSegment }) else {
            return .invalidInAppLink(reason: "unknown-root-segment")
        }

        return routeDefinition.resolve(pathSegments, queryItems, transitionPolicy)
    }

    /// Builds news intent.
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
            return buildNewsDetailIntent(
                queryItems: queryItems,
                transitionPolicy: transitionPolicy,
                missingTitleReason: "missing-discussion-title",
                destinationID: "discussion-details",
                subtitleLocalizationKey: "deeplink.news.discussion.subtitle",
                subtitleFallback: "Open discussion",
                bodyLocalizationKey: "deeplink.news.discussion.body",
                bodyFallback: "Discussion deep link destination.",
                makeDestination: DeepLinkDestination.newsDiscussion
            )
        }

        guard secondSegment == "article" else {
            return .invalidInAppLink(reason: "unknown-news-destination")
        }

        return buildNewsDetailIntent(
            queryItems: queryItems,
            transitionPolicy: transitionPolicy,
            missingTitleReason: "missing-article-title",
            destinationID: "article-details",
            subtitleLocalizationKey: "deeplink.news.article.subtitle",
            subtitleFallback: "From deep link",
            bodyLocalizationKey: "deeplink.news.article.body",
            bodyFallback: "Article deep link destination.",
            makeDestination: DeepLinkDestination.newsArticle
        )
    }

    /// Builds article/discussion detail intents that share the same NewsRoute shape.
    private func buildNewsDetailIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy,
        missingTitleReason: String,
        destinationID: String,
        subtitleLocalizationKey: String,
        subtitleFallback: String,
        bodyLocalizationKey: String,
        bodyFallback: String,
        makeDestination: (NewsRoute) -> DeepLinkDestination
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .invalidInAppLink(reason: missingTitleReason)
        }

        let subtitle = queryValue("subtitle", queryItems) ?? AppLocalization.text(
            subtitleLocalizationKey,
            fallback: subtitleFallback
        )
        let body = queryValue("body", queryItems) ?? AppLocalization.text(
            bodyLocalizationKey,
            fallback: bodyFallback
        )
        let accentLabel = queryValue("accent", queryItems)

        return .resolved(
            DeepLinkIntent(
                destination: makeDestination(
                    NewsRoute(
                        destinationID: destinationID,
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

    /// Builds mixes intent.
    private func buildMixesIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        buildTabOrDetailIntent(
            tab: .mixes,
            queryItems: queryItems,
            transitionPolicy: transitionPolicy,
            makeDetail: { title, description in
                .mixes(MixesRoute(title: title, description: description))
            },
            descriptionLocalizationKey: "deeplink.mixes.description",
            descriptionFallback: "Mix detail opened from a deep link."
        )
    }

    /// Builds pinned intent.
    private func buildPinnedIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        buildTabOrDetailIntent(
            tab: .pinned,
            queryItems: queryItems,
            transitionPolicy: transitionPolicy,
            makeDetail: { title, description in
                .pinned(PinnedRoute(title: title, description: description))
            },
            descriptionLocalizationKey: "deeplink.pinned.description",
            descriptionFallback: "Pinned detail opened from a deep link."
        )
    }

    /// Builds chat intent.
    private func buildChatIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        buildTabOrDetailIntent(
            tab: .chat,
            queryItems: queryItems,
            transitionPolicy: transitionPolicy,
            makeDetail: { title, description in
                .chat(ChatRoute(title: title, description: description))
            },
            descriptionLocalizationKey: "deeplink.chat.description",
            descriptionFallback: "Chat room opened from a deep link."
        )
    }

    /// Builds profile intent.
    private func buildProfileIntent(
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        buildTabOrDetailIntent(
            tab: .profile,
            queryItems: queryItems,
            transitionPolicy: transitionPolicy,
            makeDetail: { title, description in
                .profile(ProfileRoute(title: title, description: description))
            },
            descriptionLocalizationKey: "deeplink.profile.description",
            descriptionFallback: "Profile detail opened from a deep link."
        )
    }

    /// Builds a root-tab intent when no title is provided, otherwise builds the requested detail destination.
    private func buildTabOrDetailIntent(
        tab: AppTab,
        queryItems: [URLQueryItem],
        transitionPolicy: NavigationTransitionPolicy,
        makeDetail: (String, String) -> DeepLinkDestination,
        descriptionLocalizationKey: String,
        descriptionFallback: String
    ) -> DeepLinkParseResult {
        guard let title = queryValue("title", queryItems) else {
            return .resolved(DeepLinkIntent(destination: .tab(tab), policy: .replace))
        }

        let description = queryValue("description", queryItems) ?? AppLocalization.text(
            descriptionLocalizationKey,
            fallback: descriptionFallback
        )

        return .resolved(
            DeepLinkIntent(
                destination: makeDetail(title, description),
                policy: transitionPolicy
            )
        )
    }

    /// Applies the resolved destination to the coordinator with the correct tab selection behavior.
    private func apply(_ intent: DeepLinkIntent, coordinator: AppCoordinator) {
        switch intent.destination {
        case let .tab(tab):
            coordinator.showTabRoot(tab)
        case let .newsArticle(route):
            applyNewsDestination(route, coordinator: coordinator, policy: intent.policy)
        case let .newsDiscussion(route):
            applyNewsDestination(route, coordinator: coordinator, policy: intent.policy)
        case let .mixes(route):
            applyTabDestination(.mixes, coordinator: coordinator) {
                coordinator.navigateToMixes(route, policy: intent.policy)
            }
        case let .pinned(route):
            applyTabDestination(.pinned, coordinator: coordinator) {
                coordinator.navigateToPinned(route, policy: intent.policy)
            }
        case let .chat(route):
            applyTabDestination(.chat, coordinator: coordinator) {
                coordinator.navigateToChat(route, policy: intent.policy)
            }
        case let .profile(route):
            applyTabDestination(.profile, coordinator: coordinator) {
                coordinator.navigateToProfile(route, policy: intent.policy)
            }
        }
    }

    /// Applies a news route because both article and discussion destinations share the same tab navigation API.
    private func applyNewsDestination(
        _ route: NewsRoute,
        coordinator: AppCoordinator,
        policy: NavigationTransitionPolicy
    ) {
        applyTabDestination(.news, coordinator: coordinator) {
            coordinator.navigateToNews(route, policy: policy)
        }
    }

    /// Selects the required tab before running the destination-specific navigation action.
    private func applyTabDestination(
        _ tab: AppTab,
        coordinator: AppCoordinator,
        navigate: () -> Void
    ) {
        coordinator.selectTab(tab)
        navigate()
    }

    /// Returns a trimmed query-item value when present and non-empty.
    private func queryValue(_ name: String, _ items: [URLQueryItem]) -> String? {
        guard
            let value = items.first(where: { $0.name == name })?.value?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !value.isEmpty
        else {
            return nil
        }
        return value
    }

    /// Parses transition policy.
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

/// Declarative definition for a supported deep-link root segment.
private struct DeepLinkRouteDefinition {
    let rootSegment: String
    private let resolver: @MainActor ([String], [URLQueryItem], NavigationTransitionPolicy) -> DeepLinkParseResult

    /// Creates a new DeepLinkRouteDefinition instance.
    init(
        rootSegment: String,
        resolver: @escaping @MainActor ([String], [URLQueryItem], NavigationTransitionPolicy) -> DeepLinkParseResult
    ) {
        self.rootSegment = rootSegment
        self.resolver = resolver
    }

    /// Resolves the incoming path and query items into a parse result.
    @MainActor
    func resolve(
        _ pathSegments: [String],
        _ queryItems: [URLQueryItem],
        _ transitionPolicy: NavigationTransitionPolicy
    ) -> DeepLinkParseResult {
        resolver(pathSegments, queryItems, transitionPolicy)
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
