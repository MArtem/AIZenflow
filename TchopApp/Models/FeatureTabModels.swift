import Foundation

/// Shared content model for scaffolded feature tabs.
struct FeatureTabContent: Equatable {
    let title: String
    let subtitle: String
    let summary: String
    let quickActions: [FeatureQuickAction]
    let sections: [FeatureTabSection]
}

/// Quick action item shown in a feature tab header block.
struct FeatureQuickAction: Identifiable, Equatable {
    let id: String
    let title: String
    let caption: String
    let systemImageName: String
}

/// Section containing grouped items in a feature tab list.
struct FeatureTabSection: Identifiable, Equatable {
    let id: String
    let title: String
    let items: [FeatureTabItem]
}

/// Leaf row model rendered inside feature tab sections.
struct FeatureTabItem: Identifiable, Equatable {
    let id: String
    let eyebrow: String
    let title: String
    let summary: String
    let metadata: String
}

/// Static placeholder content for feature tabs not yet connected to backend data.
enum FeatureTabFixtures {
    static let mixes = FeatureTabContent(
        title: AppLocalization.text("feature.mixes.title"),
        subtitle: AppLocalization.text("feature.mixes.subtitle"),
        summary: AppLocalization.text("feature.mixes.summary"),
        quickActions: [
            FeatureQuickAction(
                id: "daily-briefing",
                title: AppLocalization.text("feature.mixes.quickAction.dailyBriefing.title"),
                caption: AppLocalization.text("feature.mixes.quickAction.dailyBriefing.caption"),
                systemImageName: "sun.max.fill"
            ),
            FeatureQuickAction(
                id: "launch-watch",
                title: AppLocalization.text("feature.mixes.quickAction.launchWatch.title"),
                caption: AppLocalization.text("feature.mixes.quickAction.launchWatch.caption"),
                systemImageName: "sparkles"
            ),
            FeatureQuickAction(
                id: "community-picks",
                title: AppLocalization.text("feature.mixes.quickAction.communityPicks.title"),
                caption: AppLocalization.text("feature.mixes.quickAction.communityPicks.caption"),
                systemImageName: "person.3.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "featured-mixes",
                title: AppLocalization.text("feature.mixes.section.featured.title"),
                items: [
                    FeatureTabItem(
                        id: "mix-product",
                        eyebrow: AppLocalization.text("feature.mixes.item.product.eyebrow"),
                        title: AppLocalization.text("feature.mixes.item.product.title"),
                        summary: AppLocalization.text("feature.mixes.item.product.summary"),
                        metadata: AppLocalization.text("feature.mixes.item.product.metadata")
                    ),
                    FeatureTabItem(
                        id: "mix-leadership",
                        eyebrow: AppLocalization.text("feature.mixes.item.leadership.eyebrow"),
                        title: AppLocalization.text("feature.mixes.item.leadership.title"),
                        summary: AppLocalization.text("feature.mixes.item.leadership.summary"),
                        metadata: AppLocalization.text("feature.mixes.item.leadership.metadata")
                    )
                ]
            ),
            FeatureTabSection(
                id: "recently-followed",
                title: AppLocalization.text("feature.mixes.section.recentlyFollowed.title"),
                items: [
                    FeatureTabItem(
                        id: "mix-partners",
                        eyebrow: AppLocalization.text("feature.mixes.item.partners.eyebrow"),
                        title: AppLocalization.text("feature.mixes.item.partners.title"),
                        summary: AppLocalization.text("feature.mixes.item.partners.summary"),
                        metadata: AppLocalization.text("feature.mixes.item.partners.metadata")
                    ),
                    FeatureTabItem(
                        id: "mix-customer-voice",
                        eyebrow: AppLocalization.text("feature.mixes.item.customerVoice.eyebrow"),
                        title: AppLocalization.text("feature.mixes.item.customerVoice.title"),
                        summary: AppLocalization.text("feature.mixes.item.customerVoice.summary"),
                        metadata: AppLocalization.text("feature.mixes.item.customerVoice.metadata")
                    )
                ]
            )
        ]
    )

    static let pinned = FeatureTabContent(
        title: AppLocalization.text("feature.pinned.title"),
        subtitle: AppLocalization.text("feature.pinned.subtitle"),
        summary: AppLocalization.text("feature.pinned.summary"),
        quickActions: [
            FeatureQuickAction(
                id: "must-read",
                title: AppLocalization.text("feature.pinned.quickAction.mustRead.title"),
                caption: AppLocalization.text("feature.pinned.quickAction.mustRead.caption"),
                systemImageName: "pin.circle.fill"
            ),
            FeatureQuickAction(
                id: "team-docs",
                title: AppLocalization.text("feature.pinned.quickAction.teamDocs.title"),
                caption: AppLocalization.text("feature.pinned.quickAction.teamDocs.caption"),
                systemImageName: "doc.text.fill"
            ),
            FeatureQuickAction(
                id: "watch-later",
                title: AppLocalization.text("feature.pinned.quickAction.watchLater.title"),
                caption: AppLocalization.text("feature.pinned.quickAction.watchLater.caption"),
                systemImageName: "play.rectangle.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "recent-pins",
                title: AppLocalization.text("feature.pinned.section.recent.title"),
                items: [
                    FeatureTabItem(
                        id: "pin-launch",
                        eyebrow: AppLocalization.text("feature.pinned.item.launch.eyebrow"),
                        title: AppLocalization.text("feature.pinned.item.launch.title"),
                        summary: AppLocalization.text("feature.pinned.item.launch.summary"),
                        metadata: AppLocalization.text("feature.pinned.item.launch.metadata")
                    ),
                    FeatureTabItem(
                        id: "pin-brand",
                        eyebrow: AppLocalization.text("feature.pinned.item.brand.eyebrow"),
                        title: AppLocalization.text("feature.pinned.item.brand.title"),
                        summary: AppLocalization.text("feature.pinned.item.brand.summary"),
                        metadata: AppLocalization.text("feature.pinned.item.brand.metadata")
                    )
                ]
            ),
            FeatureTabSection(
                id: "for-review",
                title: AppLocalization.text("feature.pinned.section.review.title"),
                items: [
                    FeatureTabItem(
                        id: "pin-risk",
                        eyebrow: AppLocalization.text("feature.pinned.item.risk.eyebrow"),
                        title: AppLocalization.text("feature.pinned.item.risk.title"),
                        summary: AppLocalization.text("feature.pinned.item.risk.summary"),
                        metadata: AppLocalization.text("feature.pinned.item.risk.metadata")
                    ),
                    FeatureTabItem(
                        id: "pin-faq",
                        eyebrow: AppLocalization.text("feature.pinned.item.faq.eyebrow"),
                        title: AppLocalization.text("feature.pinned.item.faq.title"),
                        summary: AppLocalization.text("feature.pinned.item.faq.summary"),
                        metadata: AppLocalization.text("feature.pinned.item.faq.metadata")
                    )
                ]
            )
        ]
    )

    static let chat = FeatureTabContent(
        title: AppLocalization.text("feature.chat.title"),
        subtitle: AppLocalization.text("feature.chat.subtitle"),
        summary: AppLocalization.text("feature.chat.summary"),
        quickActions: [
            FeatureQuickAction(
                id: "launch-room",
                title: AppLocalization.text("feature.chat.quickAction.launchRoom.title"),
                caption: AppLocalization.text("feature.chat.quickAction.launchRoom.caption"),
                systemImageName: "bubble.left.and.bubble.right.fill"
            ),
            FeatureQuickAction(
                id: "design-review",
                title: AppLocalization.text("feature.chat.quickAction.designReview.title"),
                caption: AppLocalization.text("feature.chat.quickAction.designReview.caption"),
                systemImageName: "paintpalette.fill"
            ),
            FeatureQuickAction(
                id: "support-desk",
                title: AppLocalization.text("feature.chat.quickAction.supportDesk.title"),
                caption: AppLocalization.text("feature.chat.quickAction.supportDesk.caption"),
                systemImageName: "person.crop.circle.badge.questionmark"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "active-rooms",
                title: AppLocalization.text("feature.chat.section.activeRooms.title"),
                items: [
                    FeatureTabItem(
                        id: "chat-release",
                        eyebrow: AppLocalization.text("feature.chat.item.release.eyebrow"),
                        title: AppLocalization.text("feature.chat.item.release.title"),
                        summary: AppLocalization.text("feature.chat.item.release.summary"),
                        metadata: AppLocalization.text("feature.chat.item.release.metadata")
                    ),
                    FeatureTabItem(
                        id: "chat-editorial",
                        eyebrow: AppLocalization.text("feature.chat.item.storyPlanning.eyebrow"),
                        title: AppLocalization.text("feature.chat.item.storyPlanning.title"),
                        summary: AppLocalization.text("feature.chat.item.storyPlanning.summary"),
                        metadata: AppLocalization.text("feature.chat.item.storyPlanning.metadata")
                    )
                ]
            ),
            FeatureTabSection(
                id: "follow-ups",
                title: AppLocalization.text("feature.chat.section.followUps.title"),
                items: [
                    FeatureTabItem(
                        id: "chat-customer",
                        eyebrow: AppLocalization.text("feature.chat.item.enterprisePilot.eyebrow"),
                        title: AppLocalization.text("feature.chat.item.enterprisePilot.title"),
                        summary: AppLocalization.text("feature.chat.item.enterprisePilot.summary"),
                        metadata: AppLocalization.text("feature.chat.item.enterprisePilot.metadata")
                    ),
                    FeatureTabItem(
                        id: "chat-platform",
                        eyebrow: AppLocalization.text("feature.chat.item.infrastructureSync.eyebrow"),
                        title: AppLocalization.text("feature.chat.item.infrastructureSync.title"),
                        summary: AppLocalization.text("feature.chat.item.infrastructureSync.summary"),
                        metadata: AppLocalization.text("feature.chat.item.infrastructureSync.metadata")
                    )
                ]
            )
        ]
    )
}
