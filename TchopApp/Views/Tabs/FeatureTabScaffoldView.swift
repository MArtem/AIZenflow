import SwiftUI

/// Shared scaffold for non-news tabs with list sections and quick actions.
struct FeatureTabScaffoldView: View {
    let content: FeatureTabContent
    let onQuickActionTap: (FeatureQuickAction) -> Void
    let onItemTap: (FeatureTabItem) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.featureSection) {
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    Text(content.subtitle.uppercased())
                        .font(AppTypography.eyebrow)
                        .tracking(0.8)
                        .foregroundStyle(AppTheme.accent)

                    Text(content.title)
                        .font(AppTypography.featureDisplay)
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(content.summary)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(3)
                }
                .padding(AppSpacing.cardPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surfacePrimary.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.featureHero, style: .continuous))
                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 12, y: 6)
                .accessibilityElement(children: .combine)
                .accessibilityAddTraits(.isHeader)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: AppSpacing.sm) {
                        ForEach(content.quickActions) { action in
                            Button(action: { onQuickActionTap(action) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: action.systemImageName)
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(AppTheme.accent)
                                        .accessibilityHidden(true)

                                    Text(action.title)
                                        .font(AppTypography.actionTitle)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text(action.caption)
                                        .font(AppTypography.caption)
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                .padding(AppSpacing.md)
                                .frame(width: 150, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.quickAction, style: .continuous))
                                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 4)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityHint(AppLocalization.text("accessibility.feature.quickActionHint"))
                        }
                    }
                    .padding(.horizontal, 2)
                }

                ForEach(content.sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(section.title)
                            .font(AppTypography.sectionTitle)
                            .foregroundStyle(AppTheme.textPrimary)

                        ForEach(section.items) { item in
                            Button(action: { onItemTap(item) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top) {
                                        Text(item.eyebrow.uppercased())
                                            .font(AppTypography.eyebrowStrong)
                                            .tracking(0.8)
                                            .foregroundStyle(AppTheme.accent)

                                        Spacer(minLength: AppSpacing.sm)

                                        Image(systemName: "chevron.right")
                                            .font(AppTypography.labelSemibold)
                                            .foregroundStyle(AppTheme.iconSecondary)
                                            .accessibilityHidden(true)
                                    }

                                    Text(item.title)
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text(item.summary)
                                        .font(AppTypography.detail)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineSpacing(2)

                                    Text(item.metadata)
                                        .font(AppTypography.labelSemibold)
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                .padding(AppSpacing.cardSection)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
                                .shadow(color: AppTheme.shadow.opacity(0.3), radius: 10, y: 5)
                            }
                            .buttonStyle(.plain)
                            .accessibilityElement(children: .combine)
                            .accessibilityHint(AppLocalization.text("accessibility.feature.itemHint"))
                        }
                    }
                }
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.shellBottomInset)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG
#Preview("Feature Scaffold") {
    FeatureTabScaffoldView(
        content: FeatureTabFixtures.mixes,
        onQuickActionTap: { _ in },
        onItemTap: { _ in }
    )
}
#endif
