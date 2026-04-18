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

/// Static fixture factory for feature-tab placeholder content.
enum FeatureTabFixtures {
    static let mixes = FeatureTabContent(
        title: AppLocalization.text("feature.mixes.title", fallback: "Mixes"),
        subtitle: AppLocalization.text("feature.mixes.subtitle", fallback: "Curated collections for fast catch-up"),
        summary: AppLocalization.text(
            "feature.mixes.summary",
            fallback: "Group related stories into focused streams so readers can move through product updates, market context, and team posts without losing the channel rhythm."
        ),
        quickActions: [
            FeatureQuickAction(
                id: "daily-briefing",
                title: AppLocalization.text("feature.mixes.quickAction.dailyBriefing.title", fallback: "Daily Briefing"),
                caption: AppLocalization.text("feature.mixes.quickAction.dailyBriefing.caption", fallback: "6 stories"),
                systemImageName: "sun.max.fill"
            ),
            FeatureQuickAction(
                id: "launch-watch",
                title: AppLocalization.text("feature.mixes.quickAction.launchWatch.title", fallback: "Launch Watch"),
                caption: AppLocalization.text("feature.mixes.quickAction.launchWatch.caption", fallback: "3 updates"),
                systemImageName: "sparkles"
            ),
            FeatureQuickAction(
                id: "community-picks",
                title: AppLocalization.text("feature.mixes.quickAction.communityPicks.title", fallback: "Community Picks"),
                caption: AppLocalization.text("feature.mixes.quickAction.communityPicks.caption", fallback: "12 saves"),
                systemImageName: "person.3.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "featured-mixes",
                title: AppLocalization.text("feature.mixes.section.featured.title", fallback: "Featured mixes"),
                items: [
                    FeatureTabItem(
                        id: "mix-product",
                        eyebrow: AppLocalization.text("feature.mixes.item.product.eyebrow", fallback: "Editorial"),
                        title: AppLocalization.text("feature.mixes.item.product.title", fallback: "Product rollout recap"),
                        summary: AppLocalization.text(
                            "feature.mixes.item.product.summary",
                            fallback: "A tight sequence of release notes, design rationale, and support talking points for the current launch window."
                        ),
                        metadata: AppLocalization.text("feature.mixes.item.product.metadata", fallback: "Updated 18 min ago")
                    ),
                    FeatureTabItem(
                        id: "mix-leadership",
                        eyebrow: AppLocalization.text("feature.mixes.item.leadership.eyebrow", fallback: "Leadership"),
                        title: AppLocalization.text("feature.mixes.item.leadership.title", fallback: "Weekly leadership digest"),
                        summary: AppLocalization.text(
                            "feature.mixes.item.leadership.summary",
                            fallback: "High-signal internal posts bundled into one stream for stakeholders who only need the decision-level view."
                        ),
                        metadata: AppLocalization.text("feature.mixes.item.leadership.metadata", fallback: "4 contributors")
                    )
                ]
            ),
            FeatureTabSection(
                id: "recently-followed",
                title: AppLocalization.text("feature.mixes.section.recentlyFollowed.title", fallback: "Recently followed"),
                items: [
                    FeatureTabItem(
                        id: "mix-partners",
                        eyebrow: AppLocalization.text("feature.mixes.item.partners.eyebrow", fallback: "Go-to-market"),
                        title: AppLocalization.text("feature.mixes.item.partners.title", fallback: "Partner enablement"),
                        summary: AppLocalization.text(
                            "feature.mixes.item.partners.summary",
                            fallback: "Sales assets, objection handling, and announcement follow-ups organized for field teams."
                        ),
                        metadata: AppLocalization.text("feature.mixes.item.partners.metadata", fallback: "Ready to share")
                    ),
                    FeatureTabItem(
                        id: "mix-customer-voice",
                        eyebrow: AppLocalization.text("feature.mixes.item.customerVoice.eyebrow", fallback: "Research"),
                        title: AppLocalization.text("feature.mixes.item.customerVoice.title", fallback: "Customer voice highlights"),
                        summary: AppLocalization.text(
                            "feature.mixes.item.customerVoice.summary",
                            fallback: "Quotes, surveys, and qualitative feedback that help the team validate what is resonating after release."
                        ),
                        metadata: AppLocalization.text("feature.mixes.item.customerVoice.metadata", fallback: "New comments today")
                    )
                ]
            )
        ]
    )

    static let pinned = FeatureTabContent(
        title: AppLocalization.text("feature.pinned.title", fallback: "Pinned"),
        subtitle: AppLocalization.text("feature.pinned.subtitle", fallback: "High-priority content kept close"),
        summary: AppLocalization.text(
            "feature.pinned.summary",
            fallback: "Use pinned items as a lightweight operating surface for the material that should survive the feed: launch posts, team references, and threads worth revisiting."
        ),
        quickActions: [
            FeatureQuickAction(
                id: "must-read",
                title: AppLocalization.text("feature.pinned.quickAction.mustRead.title", fallback: "Must Read"),
                caption: AppLocalization.text("feature.pinned.quickAction.mustRead.caption", fallback: "4 items"),
                systemImageName: "pin.circle.fill"
            ),
            FeatureQuickAction(
                id: "team-docs",
                title: AppLocalization.text("feature.pinned.quickAction.teamDocs.title", fallback: "Team Docs"),
                caption: AppLocalization.text("feature.pinned.quickAction.teamDocs.caption", fallback: "9 references"),
                systemImageName: "doc.text.fill"
            ),
            FeatureQuickAction(
                id: "watch-later",
                title: AppLocalization.text("feature.pinned.quickAction.watchLater.title", fallback: "Watch Later"),
                caption: AppLocalization.text("feature.pinned.quickAction.watchLater.caption", fallback: "2 videos"),
                systemImageName: "play.rectangle.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "recent-pins",
                title: AppLocalization.text("feature.pinned.section.recent.title", fallback: "Recent pins"),
                items: [
                    FeatureTabItem(
                        id: "pin-launch",
                        eyebrow: AppLocalization.text("feature.pinned.item.launch.eyebrow", fallback: "Launch"),
                        title: AppLocalization.text("feature.pinned.item.launch.title", fallback: "Launch checklist"),
                        summary: AppLocalization.text(
                            "feature.pinned.item.launch.summary",
                            fallback: "Operational sequence for announcement, support readiness, and channel moderation during the release day push."
                        ),
                        metadata: AppLocalization.text("feature.pinned.item.launch.metadata", fallback: "Pinned by Ops")
                    ),
                    FeatureTabItem(
                        id: "pin-brand",
                        eyebrow: AppLocalization.text("feature.pinned.item.brand.eyebrow", fallback: "Reference"),
                        title: AppLocalization.text("feature.pinned.item.brand.title", fallback: "Brand system notes"),
                        summary: AppLocalization.text(
                            "feature.pinned.item.brand.summary",
                            fallback: "Messaging guardrails, visual references, and approved language collected in one stable place."
                        ),
                        metadata: AppLocalization.text("feature.pinned.item.brand.metadata", fallback: "Edited yesterday")
                    )
                ]
            ),
            FeatureTabSection(
                id: "for-review",
                title: AppLocalization.text("feature.pinned.section.review.title", fallback: "For review"),
                items: [
                    FeatureTabItem(
                        id: "pin-risk",
                        eyebrow: AppLocalization.text("feature.pinned.item.risk.eyebrow", fallback: "Escalation"),
                        title: AppLocalization.text("feature.pinned.item.risk.title", fallback: "Risk log snapshot"),
                        summary: AppLocalization.text(
                            "feature.pinned.item.risk.summary",
                            fallback: "A concise rollup of outstanding product and communication risks that should stay visible until closed."
                        ),
                        metadata: AppLocalization.text("feature.pinned.item.risk.metadata", fallback: "Needs owner update")
                    ),
                    FeatureTabItem(
                        id: "pin-faq",
                        eyebrow: AppLocalization.text("feature.pinned.item.faq.eyebrow", fallback: "Support"),
                        title: AppLocalization.text("feature.pinned.item.faq.title", fallback: "Customer FAQ draft"),
                        summary: AppLocalization.text(
                            "feature.pinned.item.faq.summary",
                            fallback: "Working draft that captures the highest-volume questions expected from rollout messaging and onboarding."
                        ),
                        metadata: AppLocalization.text("feature.pinned.item.faq.metadata", fallback: "Awaiting approval")
                    )
                ]
            )
        ]
    )

    static let chat = FeatureTabContent(
        title: AppLocalization.text("feature.chat.title", fallback: "Chat"),
        subtitle: AppLocalization.text("feature.chat.subtitle", fallback: "Focused conversations around the feed"),
        summary: AppLocalization.text(
            "feature.chat.summary",
            fallback: "Treat chat as the short-loop collaboration layer: team rooms for execution, announcement threads for signal, and direct message follow-ups when something needs a decision."
        ),
        quickActions: [
            FeatureQuickAction(
                id: "launch-room",
                title: AppLocalization.text("feature.chat.quickAction.launchRoom.title", fallback: "Launch Room"),
                caption: AppLocalization.text("feature.chat.quickAction.launchRoom.caption", fallback: "8 online"),
                systemImageName: "bubble.left.and.bubble.right.fill"
            ),
            FeatureQuickAction(
                id: "design-review",
                title: AppLocalization.text("feature.chat.quickAction.designReview.title", fallback: "Design Review"),
                caption: AppLocalization.text("feature.chat.quickAction.designReview.caption", fallback: "2 unread"),
                systemImageName: "paintpalette.fill"
            ),
            FeatureQuickAction(
                id: "support-desk",
                title: AppLocalization.text("feature.chat.quickAction.supportDesk.title", fallback: "Support Desk"),
                caption: AppLocalization.text("feature.chat.quickAction.supportDesk.caption", fallback: "Live"),
                systemImageName: "person.crop.circle.badge.questionmark"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "active-rooms",
                title: AppLocalization.text("feature.chat.section.activeRooms.title", fallback: "Active rooms"),
                items: [
                    FeatureTabItem(
                        id: "chat-release",
                        eyebrow: AppLocalization.text("feature.chat.item.release.eyebrow", fallback: "Coordination"),
                        title: AppLocalization.text("feature.chat.item.release.title", fallback: "Release war room"),
                        summary: AppLocalization.text(
                            "feature.chat.item.release.summary",
                            fallback: "Fast-moving decisions, incident triage, and owner handoffs during the current release cycle."
                        ),
                        metadata: AppLocalization.text("feature.chat.item.release.metadata", fallback: "5 unread messages")
                    ),
                    FeatureTabItem(
                        id: "chat-editorial",
                        eyebrow: AppLocalization.text("feature.chat.item.storyPlanning.eyebrow", fallback: "Editorial"),
                        title: AppLocalization.text("feature.chat.item.storyPlanning.title", fallback: "Story planning"),
                        summary: AppLocalization.text(
                            "feature.chat.item.storyPlanning.summary",
                            fallback: "Writers and editors aligning on headlines, sequencing, and which stories should land in the next mix."
                        ),
                        metadata: AppLocalization.text("feature.chat.item.storyPlanning.metadata", fallback: "Updated just now")
                    )
                ]
            ),
            FeatureTabSection(
                id: "follow-ups",
                title: AppLocalization.text("feature.chat.section.followUps.title", fallback: "Follow-ups"),
                items: [
                    FeatureTabItem(
                        id: "chat-customer",
                        eyebrow: AppLocalization.text("feature.chat.item.enterprisePilot.eyebrow", fallback: "Customer success"),
                        title: AppLocalization.text("feature.chat.item.enterprisePilot.title", fallback: "Enterprise pilot feedback"),
                        summary: AppLocalization.text(
                            "feature.chat.item.enterprisePilot.summary",
                            fallback: "Thread collecting rollout friction, onboarding blockers, and the asks that should be reflected back into pinned guidance."
                        ),
                        metadata: AppLocalization.text("feature.chat.item.enterprisePilot.metadata", fallback: "Owner: Alice")
                    ),
                    FeatureTabItem(
                        id: "chat-platform",
                        eyebrow: AppLocalization.text("feature.chat.item.infrastructureSync.eyebrow", fallback: "Engineering"),
                        title: AppLocalization.text("feature.chat.item.infrastructureSync.title", fallback: "Infrastructure sync"),
                        summary: AppLocalization.text(
                            "feature.chat.item.infrastructureSync.summary",
                            fallback: "Weekly checkpoint for mobile, backend, and support dependencies tied to feed delivery and reliability."
                        ),
                        metadata: AppLocalization.text("feature.chat.item.infrastructureSync.metadata", fallback: "Next update tomorrow")
                    )
                ]
            )
        ]
    )
}
