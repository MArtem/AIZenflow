import SwiftUI
import UIKit

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    private static let floatingActionButtonHideThreshold: CGFloat = 30

    @ObservedObject var viewModel: NewsFeedViewModel
    /// Reports whether the list is close enough to the top for the shell-level floating action button to stay visible.
    let onScrollProximityChange: (Bool) -> Void
    let onFeaturedArticleTap: (FeaturedArticleCardModel) -> Void
    let onFeaturedArticleAction: (FeaturedArticleCardModel, FeaturedArticleCardAction) -> Void
    let onDiscussionTap: (DiscussionCardModel) -> Void
    let onDiscussionAction: (DiscussionCardModel, DiscussionCardAction) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: 16) {
                if let cachedStatusText {
                    Text(cachedStatusText)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(.orange.opacity(0.92))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .accessibilityIdentifier("news.feed.cached-status")
                }

                if case let .failed(_, errorMessage) = viewModel.state {
                    HStack(alignment: .top, spacing: 12) {
                        Text(errorMessage)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundStyle(.red.opacity(0.82))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .fixedSize(horizontal: false, vertical: true)

                        Button("Retry") {
                            viewModel.retry()
                        }
                        .font(.system(size: 13, weight: .semibold))
                        .buttonStyle(.plain)
                        .foregroundStyle(.primary)
                        .accessibilityIdentifier("news.feed.retry")
                    }
                }

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
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .padding(.horizontal, 14)
            .padding(.top, 16)
            .padding(.bottom, 120)
        }
        .background(
            NewsFeedScrollObserver { verticalOffset in
                onScrollProximityChange(verticalOffset <= Self.floatingActionButtonHideThreshold)
            }
        )
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
            baseText = AppLocalization.text(
                "news.feed.cached.bootstrap",
                fallback: "Showing saved feed."
            )
        case .offline:
            baseText = AppLocalization.text(
                "news.feed.cached.offline",
                fallback: "Offline mode. Showing saved feed."
            )
        }

        guard let lastSyncedAt else {
            return baseText
        }

        let timestampPrefix = AppLocalization.text(
            "news.feed.cached.updatedAt",
            fallback: "Last updated"
        )
        return "\(baseText) \(timestampPrefix): \(Self.cachedStatusDateFormatter.string(from: lastSyncedAt))"
    }

    private static let cachedStatusDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

/// Lightweight UIKit bridge that observes the hosting scroll view's content offset without affecting SwiftUI layout.
private struct NewsFeedScrollObserver: UIViewRepresentable {
    let onOffsetChange: (CGFloat) -> Void

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

    final class Coordinator {
        var onOffsetChange: (CGFloat) -> Void
        private weak var scrollView: UIScrollView?
        private var observation: NSKeyValueObservation?

        init(onOffsetChange: @escaping (CGFloat) -> Void) {
            self.onOffsetChange = onOffsetChange
        }

        func attachIfNeeded(to view: UIView) {
            DispatchQueue.main.async { [weak self, weak view] in
                guard let self, let view else {
                    return
                }

                guard let scrollView = self.enclosingScrollView(from: view) else {
                    return
                }

                guard self.scrollView !== scrollView else {
                    return
                }

                self.scrollView = scrollView
                self.observation = scrollView.observe(\.contentOffset, options: [.initial, .new]) { [weak self] scrollView, _ in
                    self?.onOffsetChange(max(0, scrollView.contentOffset.y))
                }
            }
        }

        private func enclosingScrollView(from view: UIView) -> UIScrollView? {
            var currentSuperview = view.superview

            while let currentSuperview {
                if let scrollView = currentSuperview as? UIScrollView {
                    return scrollView
                }
                currentSuperview = currentSuperview.superview
            }

            return nil
        }
    }
}

private final class ObserverView: UIView {}
