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
        title: "Mixes",
        subtitle: "Curated collections for fast catch-up",
        summary: "Group related stories into focused streams so readers can move through product updates, market context, and team posts without losing the channel rhythm.",
        quickActions: [
            FeatureQuickAction(
                id: "daily-briefing",
                title: "Daily Briefing",
                caption: "6 stories",
                systemImageName: "sun.max.fill"
            ),
            FeatureQuickAction(
                id: "launch-watch",
                title: "Launch Watch",
                caption: "3 updates",
                systemImageName: "sparkles"
            ),
            FeatureQuickAction(
                id: "community-picks",
                title: "Community Picks",
                caption: "12 saves",
                systemImageName: "person.3.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "featured-mixes",
                title: "Featured mixes",
                items: [
                    FeatureTabItem(
                        id: "mix-product",
                        eyebrow: "Editorial",
                        title: "Product rollout recap",
                        summary: "A tight sequence of release notes, design rationale, and support talking points for the current launch window.",
                        metadata: "Updated 18 min ago"
                    ),
                    FeatureTabItem(
                        id: "mix-leadership",
                        eyebrow: "Leadership",
                        title: "Weekly leadership digest",
                        summary: "High-signal internal posts bundled into one stream for stakeholders who only need the decision-level view.",
                        metadata: "4 contributors"
                    )
                ]
            ),
            FeatureTabSection(
                id: "recently-followed",
                title: "Recently followed",
                items: [
                    FeatureTabItem(
                        id: "mix-partners",
                        eyebrow: "Go-to-market",
                        title: "Partner enablement",
                        summary: "Sales assets, objection handling, and announcement follow-ups organized for field teams.",
                        metadata: "Ready to share"
                    ),
                    FeatureTabItem(
                        id: "mix-customer-voice",
                        eyebrow: "Research",
                        title: "Customer voice highlights",
                        summary: "Quotes, surveys, and qualitative feedback that help the team validate what is resonating after release.",
                        metadata: "New comments today"
                    )
                ]
            )
        ]
    )

    static let pinned = FeatureTabContent(
        title: "Pinned",
        subtitle: "High-priority content kept close",
        summary: "Use pinned items as a lightweight operating surface for the material that should survive the feed: launch posts, team references, and threads worth revisiting.",
        quickActions: [
            FeatureQuickAction(
                id: "must-read",
                title: "Must Read",
                caption: "4 items",
                systemImageName: "pin.circle.fill"
            ),
            FeatureQuickAction(
                id: "team-docs",
                title: "Team Docs",
                caption: "9 references",
                systemImageName: "doc.text.fill"
            ),
            FeatureQuickAction(
                id: "watch-later",
                title: "Watch Later",
                caption: "2 videos",
                systemImageName: "play.rectangle.fill"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "recent-pins",
                title: "Recent pins",
                items: [
                    FeatureTabItem(
                        id: "pin-launch",
                        eyebrow: "Launch",
                        title: "Launch checklist",
                        summary: "Operational sequence for announcement, support readiness, and channel moderation during the release day push.",
                        metadata: "Pinned by Ops"
                    ),
                    FeatureTabItem(
                        id: "pin-brand",
                        eyebrow: "Reference",
                        title: "Brand system notes",
                        summary: "Messaging guardrails, visual references, and approved language collected in one stable place.",
                        metadata: "Edited yesterday"
                    )
                ]
            ),
            FeatureTabSection(
                id: "for-review",
                title: "For review",
                items: [
                    FeatureTabItem(
                        id: "pin-risk",
                        eyebrow: "Escalation",
                        title: "Risk log snapshot",
                        summary: "A concise rollup of outstanding product and communication risks that should stay visible until closed.",
                        metadata: "Needs owner update"
                    ),
                    FeatureTabItem(
                        id: "pin-faq",
                        eyebrow: "Support",
                        title: "Customer FAQ draft",
                        summary: "Working draft that captures the highest-volume questions expected from rollout messaging and onboarding.",
                        metadata: "Awaiting approval"
                    )
                ]
            )
        ]
    )

    static let chat = FeatureTabContent(
        title: "Chat",
        subtitle: "Focused conversations around the feed",
        summary: "Treat chat as the short-loop collaboration layer: team rooms for execution, announcement threads for signal, and direct message follow-ups when something needs a decision.",
        quickActions: [
            FeatureQuickAction(
                id: "launch-room",
                title: "Launch Room",
                caption: "8 online",
                systemImageName: "bubble.left.and.bubble.right.fill"
            ),
            FeatureQuickAction(
                id: "design-review",
                title: "Design Review",
                caption: "2 unread",
                systemImageName: "paintpalette.fill"
            ),
            FeatureQuickAction(
                id: "support-desk",
                title: "Support Desk",
                caption: "Live",
                systemImageName: "person.crop.circle.badge.questionmark"
            )
        ],
        sections: [
            FeatureTabSection(
                id: "active-rooms",
                title: "Active rooms",
                items: [
                    FeatureTabItem(
                        id: "chat-release",
                        eyebrow: "Coordination",
                        title: "Release war room",
                        summary: "Fast-moving decisions, incident triage, and owner handoffs during the current release cycle.",
                        metadata: "5 unread messages"
                    ),
                    FeatureTabItem(
                        id: "chat-editorial",
                        eyebrow: "Editorial",
                        title: "Story planning",
                        summary: "Writers and editors aligning on headlines, sequencing, and which stories should land in the next mix.",
                        metadata: "Updated just now"
                    )
                ]
            ),
            FeatureTabSection(
                id: "follow-ups",
                title: "Follow-ups",
                items: [
                    FeatureTabItem(
                        id: "chat-customer",
                        eyebrow: "Customer success",
                        title: "Enterprise pilot feedback",
                        summary: "Thread collecting rollout friction, onboarding blockers, and the asks that should be reflected back into pinned guidance.",
                        metadata: "Owner: Alice"
                    ),
                    FeatureTabItem(
                        id: "chat-platform",
                        eyebrow: "Engineering",
                        title: "Infrastructure sync",
                        summary: "Weekly checkpoint for mobile, backend, and support dependencies tied to feed delivery and reliability.",
                        metadata: "Next update tomorrow"
                    )
                ]
            )
        ]
    )
}
