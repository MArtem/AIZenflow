import SwiftUI
import UIKit

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    /// The shell-level plus button hides once the user has clearly moved away from the top card.
    private static let floatingActionButtonHideThreshold: CGFloat = 30

    @ObservedObject var viewModel: NewsFeedViewModel
    /// Reports whether the list is close enough to the top for the shell-level floating action button to stay visible.
    let onScrollProximityChange: (Bool) -> Void
    let onFeaturedArticleTap: (FeaturedArticleCardModel) -> Void
    /// Card actions stay outside the card view so the screen view model remains the owner of state changes.
    let onFeaturedArticleAction: (FeaturedArticleCardModel, FeaturedArticleCardAction) -> Void
    let onDiscussionTap: (DiscussionCardModel) -> Void
    /// Card actions stay outside the card view so the screen view model remains the owner of state changes.
    let onDiscussionAction: (DiscussionCardModel, DiscussionCardAction) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.md) {
                NewsFeedScrollObserver { verticalOffset in
                    onScrollProximityChange(verticalOffset <= Self.floatingActionButtonHideThreshold)
                }
                .frame(height: 0)

                if let cachedStatusText {
                    Text(cachedStatusText)
                        .font(AppTypography.label)
                        .foregroundStyle(AppTheme.warning.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("news.feed.cached-status")
                }

                if case let .failed(_, errorMessage) = viewModel.state {
                    HStack(alignment: .top, spacing: AppSpacing.sm) {
                        Text(errorMessage)
                            .font(AppTypography.caption)
                            .foregroundStyle(AppTheme.destructive.opacity(0.82))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Button(AppLocalization.text("news.feed.retry")) {
                            viewModel.retry()
                        }
                        .font(AppTypography.captionSemibold)
                        .buttonStyle(.plain)
                        .foregroundStyle(AppTheme.textPrimary)
                        .accessibilityIdentifier("news.feed.retry")
                    }
                }

                if viewModel.state.isEmpty {
                    emptyStateView
                } else {
                    ForEach(viewModel.state.content.cards) { card in
                        switch card {
                        case let .featuredArticle(article):
                            FeaturedArticleCard(
                                article: article,
                                onTap: { onFeaturedArticleTap(article) },
                                onAction: { onFeaturedArticleAction(article, $0) }
                            )
                        case let .discussion(discussion):
                            DiscussionCard(
                                discussion: discussion,
                                onTap: { onDiscussionTap(discussion) },
                                onAction: { onDiscussionAction(discussion, $0) }
                            )
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.top, AppSpacing.md)
            .padding(.bottom, AppSpacing.shellBottomInset)
        }
        .accessibilityIdentifier("news.feed")
        .clipped()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable {
            viewModel.refresh()
        }
    }

    private var cachedStatusText: String? {
        guard case let .cached(lastSyncedAt, reason) = viewModel.state.content.availability else {
            return nil
        }

        let baseText: String
        switch reason {
        case .bootstrap:
            baseText = AppLocalization.text("news.feed.cached.bootstrap")
        case .offline:
            baseText = AppLocalization.text("news.feed.cached.offline")
        }

        guard let lastSyncedAt else {
            return baseText
        }

        let timestampPrefix = AppLocalization.text("news.feed.cached.updatedAt")
        return "\(baseText) \(timestampPrefix): \(lastSyncedAt.formatted(date: .abbreviated, time: .shortened))"
    }

    /// Dedicated empty-state surface for a feed that resolved successfully but currently has no cards.
    private var emptyStateView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(AppLocalization.text("news.feed.empty.title"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text(AppLocalization.text("news.feed.empty.description"))
                .font(AppTypography.detail)
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpacing.xl)
        .accessibilityElement(children: .combine)
    }
}

/// Lightweight UIKit bridge that observes the hosting scroll view's content offset without affecting SwiftUI layout.
@MainActor
private struct NewsFeedScrollObserver: UIViewRepresentable {
    let onOffsetChange: @MainActor (CGFloat) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onOffsetChange: onOffsetChange)
    }

    func makeUIView(context: Context) -> ObserverView {
        let view = ObserverView()
        view.isUserInteractionEnabled = false
        return view
    }

    func updateUIView(_ uiView: ObserverView, context: Context) {
        context.coordinator.onOffsetChange = onOffsetChange
        context.coordinator.attachIfNeeded(to: uiView)
    }

    /// Owns the single KVO observation for the enclosing UIKit scroll view.
    @MainActor
    final class Coordinator {
        var onOffsetChange: @MainActor (CGFloat) -> Void
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?

        init(onOffsetChange: @escaping @MainActor (CGFloat) -> Void) {
            self.onOffsetChange = onOffsetChange
        }

        func attachIfNeeded(to view: UIView) {
            guard let scrollView = enclosingScrollView(from: view) else {
                return
            }

            guard self.scrollView !== scrollView else {
                return
            }

            self.scrollView = scrollView
            // KVO keeps this bridge lightweight and avoids layout-driven approaches such as an
            // outer GeometryReader wrapper around the entire feed.
            self.observation = scrollView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] _, change in
                let verticalOffset = max(0, change.newValue?.y ?? 0)
                MainActor.assumeIsolated {
                    self?.onOffsetChange(verticalOffset)
                }
            }
        }

        /// Walks up the hosting hierarchy until the actual `UIScrollView` is found.
        private func enclosingScrollView(from view: UIView) -> UIScrollView? {
            var currentSuperview: UIView? = view.superview

            while let currentView = currentSuperview {
                if let scrollView = currentView as? UIScrollView {
                    return scrollView
                }
                currentSuperview = currentView.superview
            }

            return nil
        }
    }
}

/// Zero-sized host view used only to discover the surrounding UIKit scroll view.
private final class ObserverView: UIView {}

#if DEBUG
#Preview("News Feed") {
    NewsFeedView(
        viewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        onScrollProximityChange: { _ in },
        onFeaturedArticleTap: { _ in },
        onFeaturedArticleAction: { _, _ in },
        onDiscussionTap: { _ in },
        onDiscussionAction: { _, _ in }
    )
}
#endif
