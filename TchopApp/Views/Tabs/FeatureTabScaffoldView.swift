import SwiftUI

/// Shared scaffold for non-news tabs with list sections and quick actions.
struct FeatureTabScaffoldView: View {
    let content: FeatureTabContent
    let onQuickActionTap: (FeatureQuickAction) -> Void
    let onItemTap: (FeatureTabItem) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 12) {
                    Text(content.subtitle.uppercased())
                        .font(.system(size: 12, weight: .semibold))
                        .tracking(0.8)
                        .foregroundStyle(AppTheme.accent)

                    Text(content.title)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(content.summary)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundStyle(AppTheme.textSecondary)
                        .lineSpacing(3)
                }
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppTheme.surfacePrimary.opacity(0.95))
                .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 12, y: 6)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(content.quickActions) { action in
                            Button(action: { onQuickActionTap(action) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    Image(systemName: action.systemImageName)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(AppTheme.accent)

                                    Text(action.title)
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text(action.caption)
                                        .font(.system(size: 13, weight: .medium))
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                .padding(16)
                                .frame(width: 150, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                                .shadow(color: AppTheme.shadow.opacity(0.35), radius: 10, y: 4)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.horizontal, 2)
                }

                ForEach(content.sections) { section in
                    VStack(alignment: .leading, spacing: 14) {
                        Text(section.title)
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(AppTheme.textPrimary)

                        ForEach(section.items) { item in
                            Button(action: { onItemTap(item) }) {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(alignment: .top) {
                                        Text(item.eyebrow.uppercased())
                                            .font(.system(size: 11, weight: .bold))
                                            .tracking(0.8)
                                            .foregroundStyle(AppTheme.accent)

                                        Spacer(minLength: 12)

                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(AppTheme.iconSecondary)
                                    }

                                    Text(item.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundStyle(AppTheme.textPrimary)

                                    Text(item.summary)
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .lineSpacing(2)

                                    Text(item.metadata)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(AppTheme.textTertiary)
                                }
                                .padding(18)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(AppTheme.surfacePrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .shadow(color: AppTheme.shadow.opacity(0.3), radius: 10, y: 5)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}
