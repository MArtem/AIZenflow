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
                            VideoCardView(content: card)
                        case let .audio(card):
                            AudioCardView(content: card)
                        case let .pdf(card):
                            PDFCardView(content: card)
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
            LocalPhotoCardView(card: card)
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
            LocalTextCardView(card: card)
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

private struct LocalTextCardView: View {
    let card: LocalFeedCardModel

    var body: some View {
        LocalFeedCardContainer(card: card, mediaHeight: nil) {
            EmptyView()
        }
    }
}

private struct LocalPhotoCardView: View {
    let card: LocalFeedCardModel

    var body: some View {
        LocalFeedCardContainer(card: card, mediaHeight: 220) {
            if case let .photos(items)? = card.mediaContent {
                LocalPhotoMediaPreview(items: items)
            }
        }
    }
}

private struct VideoCardView: View {
    let content: NewsFeedVideoCardContent

    var body: some View {
        switch content {
        case let .local(card):
            LocalFeedCardContainer(card: card, mediaHeight: fileMediaPreviewHeight(for: card)) {
                if let media = card.mediaContent, case let .file(file) = media {
                    LocalVideoMediaView(file: file)
                }
            }
        }
    }

    private func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 180 : 260
    }
}

private struct AudioCardView: View {
    let content: NewsFeedAudioCardContent

    var body: some View {
        switch content {
        case let .local(card):
            LocalFeedCardContainer(card: card, mediaHeight: fileMediaPreviewHeight(for: card)) {
                if let media = card.mediaContent, case let .file(file) = media {
                    LocalAudioMediaView(file: file)
                }
            }
        }
    }

    private func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 180 : 260
    }
}

private struct PDFCardView: View {
    let content: NewsFeedPDFCardContent

    var body: some View {
        switch content {
        case let .local(card):
            LocalFeedCardContainer(card: card, mediaHeight: fileMediaPreviewHeight(for: card)) {
                if let media = card.mediaContent, case let .file(file) = media {
                    LocalPDFMediaView(file: file)
                }
            }
        }
    }

    private func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 180 : 260
    }
}

private struct LocalFeedCardContainer<MediaBody: View>: View {
    @Environment(\.openURL) private var openURL

    let card: LocalFeedCardModel
    let mediaHeight: CGFloat?
    let mediaBody: MediaBody

    init(
        card: LocalFeedCardModel,
        mediaHeight: CGFloat?,
        @ViewBuilder mediaBody: () -> MediaBody
    ) {
        self.card = card
        self.mediaHeight = mediaHeight
        self.mediaBody = mediaBody()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.sm) {
            if let mediaHeight {
                RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                    .fill(AppTheme.surfaceSecondary)
                    .frame(height: mediaHeight)
                    .overlay { mediaBody }
            }

            ForEach(card.orderedTextContent) { textContent in
                if textContent.kind == .source, let sourceURL = sourceURL {
                    Button(action: { openURL(sourceURL) }) {
                        Text(textContent.text)
                            .font(font(for: textContent.kind))
                            .foregroundStyle(color(for: textContent.kind))
                            .fixedSize(horizontal: false, vertical: true)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                } else {
                    Text(textContent.text)
                        .font(font(for: textContent.kind))
                        .foregroundStyle(color(for: textContent.kind))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
    }

    private var sourceURL: URL? {
        guard let resourceURLString = card.sourceContent?.resourceURLString else {
            return nil
        }

        return URL(string: resourceURLString)
    }

    private func font(for kind: LocalFeedTextFieldKind) -> Font {
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

    private func color(for kind: LocalFeedTextFieldKind) -> Color {
        switch kind {
        case .text, .headline:
            return AppTheme.textPrimary
        case .subheadline:
            return AppTheme.textSecondary
        case .source:
            return AppTheme.accent
        }
    }
}

private struct LocalPhotoMediaPreview: View {
    let items: [LocalFeedPhotoItem]

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(AppTheme.surfacePrimary)
                        .frame(width: 152, height: 188)
                        .overlay {
                            VStack(spacing: AppSpacing.xs) {
                                Image(systemName: "photo")
                                    .font(.system(size: 26, weight: .semibold))
                                    .foregroundStyle(AppTheme.textSecondary)

                                if let caption = item.caption, !caption.isEmpty {
                                    Text(caption)
                                        .font(AppTypography.captionSemibold)
                                        .foregroundStyle(AppTheme.textSecondary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.sm)
                                }

                                if let copyright = item.copyright, !copyright.isEmpty {
                                    Text(copyright)
                                        .font(AppTypography.label)
                                        .foregroundStyle(AppTheme.textTertiary)
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.sm)
                                }
                            }
                            .padding(AppSpacing.sm)
                        }
                }
            }
        }
    }
}

private struct LocalVideoMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            FeedMediaKindBadge(title: "Video")
            FeedMediaHeroIcon(systemName: "play.rectangle.fill")
            FeedMediaTitleBlock(file: file)
            FeedMediaTeaserBlock(teaserImage: file.teaserImage)
        }
    }
}

private struct LocalAudioMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            FeedMediaKindBadge(title: "Audio")
            FeedMediaHeroIcon(systemName: "waveform.circle.fill")
            FeedMediaTitleBlock(file: file)
            FeedMediaTeaserBlock(teaserImage: file.teaserImage)
        }
    }
}

private struct LocalPDFMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            FeedMediaKindBadge(title: "PDF")
            FeedMediaHeroIcon(systemName: "document.fill")
            FeedMediaTitleBlock(file: file)
            FeedMediaTeaserBlock(teaserImage: file.teaserImage)
        }
    }
}

private struct FeedMediaKindBadge: View {
    let title: String

    var body: some View {
        Text(title)
            .font(AppTypography.label)
            .foregroundStyle(AppTheme.textPrimary)
            .padding(.horizontal, AppSpacing.sm)
            .padding(.vertical, AppSpacing.xxs)
            .background(AppTheme.surfacePrimary)
            .clipShape(Capsule())
    }
}

private struct FeedMediaHeroIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(AppTheme.textSecondary)
    }
}

private struct FeedMediaTitleBlock: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            if let displayTitle = resolvedDisplayTitle {
                Text(displayTitle)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)
                    .multilineTextAlignment(.center)
            }

            if let caption = file.caption, !caption.isEmpty {
                Text(caption)
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var resolvedDisplayTitle: String? {
        switch file.kind {
        case .photo:
            return nil
        case .video:
            return file.displayTitle == "Video" ? nil : file.displayTitle
        case .audio:
            return file.displayTitle == "Audio" ? nil : file.displayTitle
        case .pdf:
            return file.displayTitle == "PDF" ? nil : file.displayTitle
        }
    }
}

private struct FeedMediaTeaserBlock: View {
    let teaserImage: LocalFeedTeaserImageContent?

    var body: some View {
        if let teaserImage {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppTheme.surfacePrimary)
                .frame(height: 92)
                .overlay {
                    VStack(spacing: AppSpacing.xxs) {
                        Text("Teaser image")
                            .font(AppTypography.label)
                            .foregroundStyle(AppTheme.textTertiary)

                        Image(systemName: "photo")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)

                        if let copyright = teaserImage.copyright, !copyright.isEmpty {
                            Text(copyright)
                                .font(AppTypography.label)
                                .foregroundStyle(AppTheme.textTertiary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, AppSpacing.md)
                        }
                    }
                    .padding(AppSpacing.sm)
                }
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
