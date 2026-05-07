import Observation
import SwiftUI
import UIKit

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    /// The shell-level plus button hides once the user has clearly moved away from the top card.
    private static let floatingActionButtonHideThreshold: CGFloat = 30

    @Bindable var viewModel: NewsFeedViewModel
    /// Reports whether the list is close enough to the top for the shell-level floating action button to stay visible.
    let onScrollProximityChange: (Bool) -> Void
    let onPhotoTap: (PhotoCardModel) -> Void
    /// Card actions stay outside the card view so the screen view model remains the owner of state changes.
    let onPhotoAction: (PhotoCardModel, PhotoCardAction) -> Void
    let onTextTap: (TextCardModel) -> Void
    /// Card actions stay outside the card view so the screen view model remains the owner of state changes.
    let onTextAction: (TextCardModel, TextCardAction) -> Void

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            LazyVStack(spacing: AppSpacing.md) {
                NewsFeedScrollObserver { verticalOffset in
                    onScrollProximityChange(verticalOffset <= Self.floatingActionButtonHideThreshold)
                }
                .frame(height: 0)

                if viewModel.isSearchPresented {
                    searchField
                }

                if viewModel.state.isEmpty {
                    emptyStateView
                } else if viewModel.showsNoSearchResults {
                    searchEmptyStateView
                } else {
                    ForEach(viewModel.visibleContent.cards) { card in
                        switch card {
                        case let .photo(photoCard):
                            photoCardView(photoCard)
                        case let .text(textCard):
                            textCardView(textCard)
                        case let .video(card):
                            ChannelCardPlaceholderView(card: card)
                        case let .audio(card):
                            ChannelCardPlaceholderView(card: card)
                        case let .pdf(card):
                            ChannelCardPlaceholderView(card: card)
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

    /// Search field bound to the current selected channel feed only.
    private var searchField: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.textTertiary)

            TextField(
                AppLocalization.text("news.feed.search.placeholder"),
                text: $viewModel.searchQuery
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)

            if !viewModel.searchQuery.isEmpty {
                Button(action: { viewModel.searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(AppLocalization.text("news.feed.search.clear"))
            }
        }
        .font(AppTypography.detail)
        .foregroundStyle(AppTheme.textPrimary)
        .padding(.horizontal, AppSpacing.md)
        .padding(.vertical, AppSpacing.sm)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
        .accessibilityIdentifier("news.feed.search")
    }

    /// No-results state shown when the current channel contains cards but none match the search query.
    private var searchEmptyStateView: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(AppLocalization.text("news.feed.search.empty.title"))
                .font(AppTypography.cardTitle)
                .foregroundStyle(AppTheme.textPrimary)

            Text(AppLocalization.text("news.feed.search.empty.description"))
                .font(AppTypography.detail)
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, AppSpacing.xl)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private func photoCardView(_ content: NewsFeedPhotoCardContent) -> some View {
        switch content {
        case let .remote(card):
            PhotoCardView(
                photo: card,
                onTap: { onPhotoTap(card) },
                onAction: { onPhotoAction(card, $0) }
            )
        case let .local(card):
            ChannelCardPlaceholderView(card: card)
        }
    }

    @ViewBuilder
    private func textCardView(_ content: NewsFeedTextCardContent) -> some View {
        switch content {
        case let .remote(card):
            TextCardView(
                text: card,
                onTap: { onTextTap(card) },
                onAction: { onTextAction(card, $0) }
            )
        case let .local(card):
            ChannelCardPlaceholderView(card: card)
        }
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

private struct ChannelCardPlaceholderView: View {
    let card: ChannelCardContent

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let media = card.media {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppTheme.surfaceSecondary)
                    .frame(height: media.kind == .photo ? 220 : 180)
                    .overlay {
                        VStack(spacing: AppSpacing.xs) {
                            Image(systemName: mediaIconName(media))
                                .font(.system(size: 28, weight: .semibold))
                                .foregroundStyle(AppTheme.textSecondary)

                            Text(media.displayTitle)
                                .font(AppTypography.cardTitle)
                                .foregroundStyle(AppTheme.textSecondary)
                        }
                    }
            }

            ForEach(card.orderedTextContent) { textContent in
                Text(textContent.text)
                    .font(font(for: textContent.kind))
                    .foregroundStyle(color(for: textContent.kind))
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private func font(for kind: ChannelCardTextFieldKind) -> Font {
        switch kind {
        case .text:
            return AppTypography.bodyRegular
        case .headline:
            return AppTypography.cardTitleBold
        case .subheadline:
            return AppTypography.bodySemibold
        case .source:
            return AppTypography.captionSemibold
        }
    }

    private func color(for kind: ChannelCardTextFieldKind) -> Color {
        switch kind {
        case .text, .headline:
            return AppTheme.textPrimary
        case .subheadline:
            return AppTheme.textSecondary
        case .source:
            return AppTheme.accent
        }
    }

    private func mediaIconName(_ media: ChannelCardMediaContent) -> String {
        switch media.kind {
        case .photo:
            return "photo.on.rectangle.angled"
        case .video:
            return "video"
        case .audio:
            return "waveform"
        case .pdf:
            return "doc.richtext"
        }
    }
}

#if DEBUG
#Preview("News Feed") {
    NewsFeedView(
        viewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        onScrollProximityChange: { _ in },
        onPhotoTap: { _ in },
        onPhotoAction: { _, _ in },
        onTextTap: { _ in },
        onTextAction: { _, _ in }
    )
}
#endif
