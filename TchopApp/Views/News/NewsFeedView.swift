import AVFoundation
import Observation
import PDFKit
import SwiftUI
import TchopOnDeviceAI
import UIKit

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    /// The shell-level plus button hides once the user has clearly moved away from the top card.
    private static let floatingActionButtonHideThreshold: CGFloat = 30

    @Bindable var viewModel: NewsFeedViewModel
    @State private var languageSelectionState: TranslationLanguageSelectionState?
    /// Reports whether the list is close enough to the top for the shell-level floating action button to stay visible.
    let onScrollProximityChange: (Bool) -> Void
    let onPhotoTap: (PhotoCardModel) -> Void
    /// Card actions stay outside the card view so the screen view model remains the owner of state changes.
    let onPhotoAction: (PhotoCardModel, PhotoCardAction) -> Void
    let onTextTap: (TextCardModel) -> Void
    let onLocalCardTap: (NewsRoute) -> Void
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
                    NewsFeedSearchFieldView(
                        searchQuery: $viewModel.searchQuery,
                        clearLabel: AppLocalization.text("news.feed.search.clear")
                    )
                }

                NewsFeedContentSectionView(
                    viewModel: viewModel,
                    translationActionProvider: translationAction(for:),
                    onPhotoTap: onPhotoTap,
                    onPhotoAction: onPhotoAction,
                    onTextTap: onTextTap,
                    onTextAction: onTextAction,
                    onLocalCardTap: onLocalCardTap
                )
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
        .confirmationDialog(
            AppLocalization.text("news.card.translation.languagePicker.title"),
            isPresented: languageSelectionIsPresented
        ) {
            if let languageSelectionState {
                ForEach(languageSelectionState.languages, id: \.localeIdentifier) { language in
                    Button(AppLocalization.displayName(for: language.localeIdentifier)) {
                        startTranslation(for: languageSelectionState.card, targetLanguage: language)
                    }
                }
            }

            Button(AppLocalization.text("common.cancel"), role: .cancel) {
                languageSelectionState = nil
            }
        }
    }

    private var languageSelectionIsPresented: Binding<Bool> {
        Binding(
            get: { languageSelectionState != nil },
            set: { isPresented in
                if !isPresented {
                    languageSelectionState = nil
                }
            }
        )
    }

    private func translationAction(for card: NewsFeedCard) -> FeedCardTranslationAction? {
        guard viewModel.showsTranslationAction(for: card) else {
            return nil
        }

        return FeedCardTranslationAction(
            title: viewModel.translationActionTitle(for: card.id),
            isInFlight: viewModel.isTranslationInFlight(card.id),
            onTap: { handleTranslationTap(for: card) }
        )
    }

    private func handleTranslationTap(for card: NewsFeedCard) {
        guard !viewModel.isTranslationInFlight(card.id) else {
            return
        }

        if viewModel.isCardTranslated(card.id) {
            viewModel.restoreOriginalCardText(cardID: card.id)
            return
        }

        let targetLanguages = viewModel.translationTargetLanguages(for: card)
        guard !targetLanguages.isEmpty else {
            return
        }

        if targetLanguages.count == 1, let targetLanguage = targetLanguages.first {
            startTranslation(for: card, targetLanguage: targetLanguage)
            return
        }

        languageSelectionState = TranslationLanguageSelectionState(
            card: card,
            languages: targetLanguages
        )
    }

    private func startTranslation(
        for card: NewsFeedCard,
        targetLanguage: OnDeviceLanguage
    ) {
        languageSelectionState = nil
        Task {
            await viewModel.performTranslation(for: card, targetLanguage: targetLanguage)
        }
    }
}

private struct NewsFeedContentSectionView: View {
    let viewModel: NewsFeedViewModel
    let translationActionProvider: (NewsFeedCard) -> FeedCardTranslationAction?
    let onPhotoTap: (PhotoCardModel) -> Void
    let onPhotoAction: (PhotoCardModel, PhotoCardAction) -> Void
    let onTextTap: (TextCardModel) -> Void
    let onTextAction: (TextCardModel, TextCardAction) -> Void
    let onLocalCardTap: (NewsRoute) -> Void

    var body: some View {
        if viewModel.visibleContent.cards.isEmpty && !viewModel.showsNoSearchResults {
            NewsFeedEmptyStateView()
        } else if viewModel.showsNoSearchResults {
            NewsFeedSearchEmptyStateView()
        } else {
            ForEach(Array(viewModel.visibleContent.cards), id: \.id) { card in
                NewsFeedCardRendererView(
                    feedCard: card,
                    viewModel: viewModel,
                    translationAction: translationActionProvider(card),
                    onPhotoTap: onPhotoTap,
                    onPhotoAction: onPhotoAction,
                    onTextTap: onTextTap,
                    onTextAction: onTextAction,
                    onLocalCardTap: onLocalCardTap
                )
            }
        }
    }
}

private struct NewsFeedEmptyStateView: View {
    var body: some View {
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

private struct NewsFeedSearchEmptyStateView: View {
    var body: some View {
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
}

private struct NewsFeedSearchFieldView: View {
    @Binding var searchQuery: String
    let clearLabel: String

    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(AppTheme.textTertiary)

            TextField(
                AppLocalization.text("news.feed.search.placeholder"),
                text: $searchQuery
            )
            .textInputAutocapitalization(.never)
            .disableAutocorrection(true)

            if !searchQuery.isEmpty {
                Button(action: { searchQuery = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(AppTheme.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(clearLabel)
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
}

private struct NewsFeedCardRendererView: View {
    let feedCard: NewsFeedCard
    let viewModel: NewsFeedViewModel
    let translationAction: FeedCardTranslationAction?
    let onPhotoTap: (PhotoCardModel) -> Void
    let onPhotoAction: (PhotoCardModel, PhotoCardAction) -> Void
    let onTextTap: (TextCardModel) -> Void
    let onTextAction: (TextCardModel, TextCardAction) -> Void
    let onLocalCardTap: (NewsRoute) -> Void

    var body: some View {
        switch feedCard {
        case let .photo(content):
            switch content {
            case let .local(localCard):
                LocalPhotoCardView(
                    card: viewModel.translatedLocalFeedCard(localCard),
                    translationAction: translationAction,
                    onTap: { onLocalCardTap(localCard.detailRoute) },
                    onLikeTap: { viewModel.toggleLocalCardLike(cardID: localCard.id) },
                    onCommentsTap: { viewModel.incrementLocalCardComments(cardID: localCard.id) },
                    onSetDisplayMode: { viewModel.setLocalCardDisplayMode(cardID: localCard.id, displayMode: $0) }
                )
            case .remote:
                EmptyView()
            }
        case let .text(content):
            switch content {
            case let .local(localCard):
                LocalTextCardView(
                    card: viewModel.translatedLocalFeedCard(localCard),
                    translationAction: translationAction,
                    onTap: { onLocalCardTap(localCard.detailRoute) },
                    onLikeTap: { viewModel.toggleLocalCardLike(cardID: localCard.id) },
                    onCommentsTap: { viewModel.incrementLocalCardComments(cardID: localCard.id) },
                    onSetDisplayMode: { viewModel.setLocalCardDisplayMode(cardID: localCard.id, displayMode: $0) }
                )
            case .remote:
                EmptyView()
            }
        case let .video(content):
            switch content {
            case let .local(card):
                VideoCardView(
                    content: .local(viewModel.translatedLocalFeedCard(card)),
                    translationAction: translationAction,
                    onTap: { onLocalCardTap(card.detailRoute) },
                    onLikeTap: { viewModel.toggleLocalCardLike(cardID: card.id) },
                    onCommentsTap: { viewModel.incrementLocalCardComments(cardID: card.id) },
                    onSetDisplayMode: { viewModel.setLocalCardDisplayMode(cardID: card.id, displayMode: $0) }
                )
            }
        case let .audio(content):
            switch content {
            case let .local(card):
                AudioCardView(
                    content: .local(viewModel.translatedLocalFeedCard(card)),
                    translationAction: translationAction,
                    onTap: { onLocalCardTap(card.detailRoute) },
                    onLikeTap: { viewModel.toggleLocalCardLike(cardID: card.id) },
                    onCommentsTap: { viewModel.incrementLocalCardComments(cardID: card.id) },
                    onSetDisplayMode: { viewModel.setLocalCardDisplayMode(cardID: card.id, displayMode: $0) }
                )
            }
        case let .pdf(content):
            switch content {
            case let .local(card):
                PDFCardView(
                    content: .local(viewModel.translatedLocalFeedCard(card)),
                    translationAction: translationAction,
                    onTap: { onLocalCardTap(card.detailRoute) },
                    onLikeTap: { viewModel.toggleLocalCardLike(cardID: card.id) },
                    onCommentsTap: { viewModel.incrementLocalCardComments(cardID: card.id) },
                    onSetDisplayMode: { viewModel.setLocalCardDisplayMode(cardID: card.id, displayMode: $0) }
                )
            }
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
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void

    var body: some View {
        LocalFeedCardContainer(
            card: card,
            mediaHeight: nil,
            translationAction: translationAction,
            onTap: onTap,
            onLikeTap: onLikeTap,
            onCommentsTap: onCommentsTap,
            onSetDisplayMode: onSetDisplayMode
        ) {
            EmptyView()
        }
    }
}

private struct LocalPhotoCardView: View {
    let card: LocalFeedCardModel
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void

    var body: some View {
        LocalFeedCardContainer(
            card: card,
            mediaHeight: 220,
            translationAction: translationAction,
            onTap: onTap,
            onLikeTap: onLikeTap,
            onCommentsTap: onCommentsTap,
            onSetDisplayMode: onSetDisplayMode
        ) {
            if case let .photos(items)? = card.mediaContent {
                LocalPhotoMediaPreview(items: items)
            }
        }
    }
}

private struct VideoCardView: View {
    let content: NewsFeedVideoCardContent
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void

    var body: some View {
        switch content {
        case let .local(card):
            LocalFileCardView(
                card: card,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in AnyView(LocalVideoMediaView(file: file)) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct AudioCardView: View {
    let content: NewsFeedAudioCardContent
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void

    var body: some View {
        switch content {
        case let .local(card):
            LocalFileCardView(
                card: card,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in AnyView(LocalAudioMediaView(file: file)) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct PDFCardView: View {
    let content: NewsFeedPDFCardContent
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void

    var body: some View {
        switch content {
        case let .local(card):
            LocalFileCardView(
                card: card,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in AnyView(LocalPDFMediaView(file: file)) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: LocalFeedCardModel) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct LocalFileCardView: View {
    let card: LocalFeedCardModel
    let mediaHeight: CGFloat
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void
    let preview: (LocalFeedFileMediaContent) -> AnyView

    var body: some View {
        LocalFeedCardContainer(
            card: card,
            mediaHeight: mediaHeight,
            translationAction: translationAction,
            onTap: onTap,
            onLikeTap: onLikeTap,
            onCommentsTap: onCommentsTap,
            onSetDisplayMode: onSetDisplayMode
        ) {
            if let fileContent = fileContent {
                preview(fileContent)
            }
        }
    }

    private var fileContent: LocalFeedFileMediaContent? {
        guard case let .file(file)? = card.mediaContent else {
            return nil
        }

        return file
    }
}

private struct LocalFeedCardContainer<MediaBody: View>: View {
    @Environment(\.openURL) private var openURL

    let card: LocalFeedCardModel
    let mediaHeight: CGFloat?
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void
    let mediaBody: MediaBody

    init(
        card: LocalFeedCardModel,
        mediaHeight: CGFloat?,
        translationAction: FeedCardTranslationAction?,
        onTap: @escaping () -> Void,
        onLikeTap: @escaping () -> Void,
        onCommentsTap: @escaping () -> Void,
        onSetDisplayMode: @escaping (LocalFeedCardDisplayMode) -> Void,
        @ViewBuilder mediaBody: () -> MediaBody
    ) {
        self.card = card
        self.mediaHeight = mediaHeight
        self.translationAction = translationAction
        self.onTap = onTap
        self.onLikeTap = onLikeTap
        self.onCommentsTap = onCommentsTap
        self.onSetDisplayMode = onSetDisplayMode
        self.mediaBody = mediaBody()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                VStack(alignment: .leading, spacing: 0) {
                    if let resolvedMediaHeight = resolvedMediaHeight {
                        Rectangle()
                            .fill(AppTheme.surfaceSecondary)
                            .frame(height: resolvedMediaHeight)
                            .overlay { mediaBody }
                    }

                    if !card.orderedTextContent.isEmpty {
                        VStack(alignment: .leading, spacing: AppSpacing.sm) {
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

                            if let translationAction, hasVisibleTextContent {
                                FeedCardTranslationButton(action: translationAction)
                            }
                        }
                        .padding(.horizontal, 14)
                        .padding(.top, 20)
                        .padding(.bottom, 12)
                    } else if resolvedMediaHeight != nil {
                        Color.clear
                            .frame(height: 20)
                    }
                }
            }
            .buttonStyle(.plain)

            Divider()
                .overlay(AppTheme.borderSubtle)
                .padding(.horizontal, 14)

            LocalFeedActionBar(
                isLiked: card.isLiked,
                commentsCount: card.commentsCount,
                displayMode: card.displayMode,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                onRefreshCard: {},
                onRunUpdateTask: {}
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous))
        .shadow(color: AppTheme.shadow.opacity(0.35), radius: 6, y: 1)
    }

    private var hasVisibleTextContent: Bool {
        !card.orderedTextContent.isEmpty
    }

    private var resolvedMediaHeight: CGFloat? {
        guard let mediaHeight else {
            return nil
        }

        switch card.displayMode {
        case .expanded:
            return mediaHeight
        case .compact:
            return max(156, mediaHeight - 64)
        }
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
            return .system(size: 24, weight: .regular)
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

private struct LocalFeedActionBar: View {
    let isLiked: Bool
    let commentsCount: Int
    let displayMode: LocalFeedCardDisplayMode
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (LocalFeedCardDisplayMode) -> Void
    let onRefreshCard: () -> Void
    let onRunUpdateTask: () -> Void

    var body: some View {
        HStack {
            Button(action: onLikeTap) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text(
                        AppLocalization.text("news.photo.action.liked")
                    )
                }
                .foregroundStyle(isLiked ? AppTheme.accent : AppTheme.iconSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onCommentsTap) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "bubble.left.fill")
                    Text("\(commentsCount) " + AppLocalization.text("news.photo.action.comments"))
                }
            }
            .buttonStyle(.plain)

            Spacer()

            Menu {
                Button {
                    onSetDisplayMode(.expanded)
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.expanded"),
                        systemImage: displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                    )
                }

                Button {
                    onSetDisplayMode(.compact)
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.compact"),
                        systemImage: displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
                    )
                }

                Divider()

                Button {
                    onRefreshCard()
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.refresh"),
                        systemImage: "arrow.clockwise"
                    )
                }

                Button {
                    onRunUpdateTask()
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.update"),
                        systemImage: "wand.and.stars"
                    )
                }
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .font(AppTypography.bodySemibold)
        .foregroundStyle(AppTheme.iconSecondary)
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
}

private struct TranslationLanguageSelectionState {
    let card: NewsFeedCard
    let languages: [OnDeviceLanguage]
}

struct FeedCardTranslationAction {
    let title: String
    let isInFlight: Bool
    let onTap: () -> Void
}

struct FeedCardTranslationButton: View {
    let action: FeedCardTranslationAction

    var body: some View {
        Button(action: action.onTap) {
            HStack(spacing: AppSpacing.xs) {
                if action.isInFlight {
                    ProgressView()
                        .controlSize(.small)
                        .tint(AppTheme.accent)
                }

                Text(action.title)
                    .font(AppTypography.bodySemibold)
            }
            .foregroundStyle(AppTheme.accent)
        }
        .buttonStyle(.plain)
        .disabled(action.isInFlight)
        .accessibilityLabel(action.title)
    }
}

private struct LocalPhotoMediaPreview: View {
    let items: [LocalFeedPhotoItem]

    var body: some View {
        if let item = items.first {
            LocalImageMediaFrame(
                fileURLString: item.fileURLString,
                fallbackSystemImage: "photo",
                caption: item.caption,
                copyright: item.copyright
            )
        }
    }
}

private struct LocalImageMediaFrame: View {
    let fileURLString: String?
    let fallbackSystemImage: String
    let caption: String?
    let copyright: String?

    private var image: UIImage? {
        guard let fileURL = resolvedFileURL else {
            return nil
        }

        if let image = UIImage(contentsOfFile: fileURL.path) {
            return image
        }

        if let decodedPath = fileURL.path.removingPercentEncoding,
           let image = UIImage(contentsOfFile: decodedPath) {
            return image
        }

        if let fileURLString,
           let image = UIImage(contentsOfFile: fileURLString) {
            return image
        }

        return nil
    }

    private var resolvedFileURL: URL? {
        guard let fileURLString else {
            return nil
        }

        if let url = URL(string: fileURLString), url.scheme != nil {
            return url
        }

        return URL(fileURLWithPath: fileURLString)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AppTheme.surfaceSecondary
                    .overlay {
                        Image(systemName: fallbackSystemImage)
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
            }

            if hasMetadata {
                VStack(spacing: AppSpacing.xxs) {
                    if let copyright, !copyright.isEmpty {
                        Text(copyright)
                            .font(AppTypography.label)
                            .foregroundStyle(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }

                    if let caption, !caption.isEmpty {
                        Text(caption)
                            .font(AppTypography.captionSemibold)
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(AppSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.38))
            }
        }
        .frame(maxWidth: .infinity)
        .frame(maxHeight: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.badge, style: .continuous))
    }

    private var hasMetadata: Bool {
        caption?.isEmpty == false || copyright?.isEmpty == false
    }
}

private struct LocalVideoMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        LocalFileMediaStackView(file: file) {
            LocalVideoPreviewFrame(file: file)
        }
    }
}

private struct LocalAudioMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        LocalFileMediaStackView(file: file) {
            LocalAudioPreviewFrame(file: file)
        }
    }
}

private struct LocalPDFMediaView: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        LocalFileMediaStackView(file: file) {
            LocalPDFPreviewFrame(file: file)
        }
    }
}

private struct LocalFileMediaStackView<MediaPreview: View>: View {
    let file: LocalFeedFileMediaContent
    let mediaPreview: MediaPreview

    init(file: LocalFeedFileMediaContent, @ViewBuilder mediaPreview: () -> MediaPreview) {
        self.file = file
        self.mediaPreview = mediaPreview()
    }

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            if file.teaserImage != nil {
                FeedMediaTeaserBlock(teaserImage: file.teaserImage)
                    .frame(height: 220)
                mediaPreview
                    .frame(height: 220)
            } else {
                mediaPreview
                    .frame(maxHeight: .infinity)
            }
        }
    }
}

private struct LocalVideoPreviewFrame: View {
    let file: LocalFeedFileMediaContent

    private var thumbnail: UIImage? {
        guard let fileURL = file.fileURL else {
            return nil
        }

        let asset = AVURLAsset(url: fileURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    var body: some View {
        ZStack {
            LocalImageLikeMediaFrame(
                image: thumbnail,
                fallbackSystemImage: "video",
                caption: file.caption,
                copyright: nil
            )

            Image(systemName: "play.circle.fill")
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(Color.white.opacity(0.92))
                .shadow(color: .black.opacity(0.25), radius: 8, x: 0, y: 2)
        }
    }
}

private struct LocalAudioPreviewFrame: View {
    let file: LocalFeedFileMediaContent

    var body: some View {
        LocalImageLikeMediaFrame(
            image: nil,
            fallbackSystemImage: "music.note",
            caption: file.caption,
            copyright: nil
        )
    }
}

private struct LocalPDFPreviewFrame: View {
    let file: LocalFeedFileMediaContent

    private var thumbnail: UIImage? {
        guard let fileURL = file.fileURL,
              let document = PDFDocument(url: fileURL),
              let page = document.page(at: 0) else {
            return nil
        }

        return page.thumbnail(of: CGSize(width: 640, height: 420), for: .mediaBox)
    }

    var body: some View {
        LocalImageLikeMediaFrame(
            image: thumbnail,
            fallbackSystemImage: "doc.text",
            caption: file.caption,
            copyright: nil
        )
    }
}

private struct LocalImageLikeMediaFrame: View {
    let image: UIImage?
    let fallbackSystemImage: String
    let caption: String?
    let copyright: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
            } else {
                AppTheme.surfaceSecondary
                    .overlay {
                        Image(systemName: fallbackSystemImage)
                            .font(.system(size: 42, weight: .semibold))
                            .foregroundStyle(AppTheme.textSecondary)
                    }
            }

            if hasMetadata {
                VStack(spacing: AppSpacing.xxs) {
                    if let copyright, !copyright.isEmpty {
                        Text(copyright)
                            .font(AppTypography.label)
                            .foregroundStyle(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }

                    if let caption, !caption.isEmpty {
                        Text(caption)
                            .font(AppTypography.captionSemibold)
                            .foregroundStyle(Color.white.opacity(0.92))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(AppSpacing.sm)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.38))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.badge, style: .continuous))
    }

    private var hasMetadata: Bool {
        caption?.isEmpty == false || copyright?.isEmpty == false
    }
}

private struct FeedMediaTeaserBlock: View {
    let teaserImage: LocalFeedTeaserImageContent?

    var body: some View {
        if let teaserImage {
            LocalImageMediaFrame(
                fileURLString: teaserImage.fileURLString,
                fallbackSystemImage: "photo",
                caption: nil,
                copyright: teaserImage.copyright
            )
        }
    }
}

private extension LocalFeedFileMediaContent {
    var fileURL: URL? {
        guard let fileURLString else {
            return nil
        }

        if let url = URL(string: fileURLString), url.scheme != nil {
            return url
        }

        return URL(fileURLWithPath: fileURLString)
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
        onTextAction: { _, _ in },
        onLocalCardTap: { _ in }
    )
}
#endif
