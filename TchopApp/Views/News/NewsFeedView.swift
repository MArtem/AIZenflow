import AVFoundation
import ImageIO
import Observation
import os
import PDFKit
import SwiftUI
import AppOnDeviceAI
import UIKit

private let feedPerformanceLog = OSLog(
    subsystem: Bundle.main.bundleIdentifier ?? "com.example.TchopApp",
    category: "FeedPerformance"
)

private enum FeedPerformanceSignpost {
    static func scrollNearTopStateChanged(_ isNearTop: Bool) {
        os_signpost(
            .event,
            log: feedPerformanceLog,
            name: "ScrollNearTopStateChange",
            "%{public}s",
            isNearTop ? "nearTop" : "notNearTop"
        )
    }

    static func feedCardAppeared(cardID: String) {
        os_signpost(
            .event,
            log: feedPerformanceLog,
            name: "FeedCardAppear",
            "%{public}s",
            cardID
        )
    }

    static func beginMediaPreviewLoad(fileURLString: String?, kind: FeedMediaPreviewKind) -> OSSignpostID {
        let signpostID = OSSignpostID(log: feedPerformanceLog)
        os_signpost(
            .begin,
            log: feedPerformanceLog,
            name: "FeedMediaPreviewLoad",
            signpostID: signpostID,
            "%{public}s %{public}s",
            kind.rawValue,
            fileURLString ?? "nil"
        )
        return signpostID
    }

    static func endMediaPreviewLoad(_ signpostID: OSSignpostID) {
        os_signpost(
            .end,
            log: feedPerformanceLog,
            name: "FeedMediaPreviewLoad",
            signpostID: signpostID
        )
    }
}

/// Main feed list rendering heterogeneous card content.
struct NewsFeedView: View {
    /// The shell-level plus button hides once the feed scroll position moves away from the top content area.
    private static let floatingActionButtonHideThreshold: CGFloat = 30
    private static let scrollCoordinateSpace = "news-feed-scroll"

    @Bindable var viewModel: NewsFeedViewModel
    @State private var languageSelectionState: TranslationLanguageSelectionState?
    @State private var isFeedNearTop = true
    /// Reports whether the list is close enough to the top for the shell-level floating action button to stay visible.
    let onScrollProximityChange: (Bool) -> Void
    let onCardTap: (NewsRoute) -> Void

    var body: some View {
        let screenState = viewModel.screenState

        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 0) {
                // Keep the fallback scroll-position sentinel outside LazyVStack. Lazy containers can
                // evict offscreen children, which would reset the preference on iOS 17 fallback.
                NewsFeedTopOffsetSentinel(coordinateSpaceName: Self.scrollCoordinateSpace)
                    .frame(height: 1)

                LazyVStack(spacing: AppSpacing.md) {
                    if screenState.isSearchPresented {
                        NewsFeedSearchFieldView(
                            searchQuery: $viewModel.searchQuery,
                            clearLabel: AppLocalization.text("news.feed.search.clear")
                        )
                    }

                    switch screenState.contentPresentation {
                    case .empty:
                        NewsFeedEmptyStateView()

                    case .noSearchResults:
                        NewsFeedSearchEmptyStateView()

                    case let .cards(cardStates):
                        ForEach(cardStates) { cardState in
                            makeCardView(for: cardState)
                        }
                    }
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.top, AppSpacing.md)
                .padding(.bottom, AppSpacing.shellBottomInset)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .coordinateSpace(.named(Self.scrollCoordinateSpace))
        .modifier(NewsFeedScrollProximityModifier(
            threshold: Self.floatingActionButtonHideThreshold,
            coordinateSpaceName: Self.scrollCoordinateSpace,
            onChange: { isNearTop in
                handleScrollProximityChange(
                    isNearTop,
                    hasVisibleCards: screenState.hasVisibleCards
                )
            }
        ))
        .accessibilityIdentifier("news.feed")
        .clipped()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .refreshable {
            await viewModel.sendAndWait(.refreshRequested)
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

    private func makeCardView(for cardState: NewsFeedCardViewState) -> NewsFeedCardRendererView {
        NewsFeedCardRendererView(
            state: cardState,
            translationAction: translationAction(for: cardState),
            onCardTap: onCardTap,
            onLikeTap: { cardID in
                viewModel.send(.cardLikeTapped(cardID: cardID))
            },
            onCommentsTap: { cardID in
                viewModel.send(.cardCommentsTapped(cardID: cardID))
            },
            onSetDisplayMode: { cardID, displayMode in
                viewModel.send(.cardDisplayModeChanged(cardID: cardID, displayMode: displayMode))
            }
        )
    }

    private func handleScrollProximityChange(_ isNearTop: Bool, hasVisibleCards: Bool) {
        guard hasVisibleCards else {
            guard !isFeedNearTop else {
                return
            }

            isFeedNearTop = true
            FeedPerformanceSignpost.scrollNearTopStateChanged(true)
            onScrollProximityChange(true)
            return
        }

        guard isFeedNearTop != isNearTop else {
            return
        }

        isFeedNearTop = isNearTop
        FeedPerformanceSignpost.scrollNearTopStateChanged(isNearTop)
        onScrollProximityChange(isNearTop)
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

    private func translationAction(for cardState: NewsFeedCardViewState) -> FeedCardTranslationAction? {
        guard let translation = cardState.translation else {
            return nil
        }

        return FeedCardTranslationAction(
            title: translation.title,
            isInFlight: translation.isInFlight,
            onTap: { handleTranslationTap(for: cardState) }
        )
    }

    private func handleTranslationTap(for cardState: NewsFeedCardViewState) {
        guard let translation = cardState.translation, !translation.isInFlight else {
            return
        }

        switch translation.tapBehavior {
        case let .restoreOriginal(cardID):
            viewModel.send(.cardOriginalTextRequested(cardID: cardID))

        case let .startTranslation(card, targetLanguage):
            startTranslation(for: card, targetLanguage: targetLanguage)

        case let .chooseLanguage(card, languages):
            languageSelectionState = TranslationLanguageSelectionState(
                card: card,
                languages: languages
            )
        }
    }

    private func startTranslation(
        for card: NewsFeedCard,
        targetLanguage: OnDeviceLanguage
    ) {
        languageSelectionState = nil
        Task {
            await viewModel.sendAndWait(.cardTranslationRequested(card: card, targetLanguage: targetLanguage))
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
    let state: NewsFeedCardViewState
    let translationAction: FeedCardTranslationAction?
    let onCardTap: (NewsRoute) -> Void
    let onLikeTap: (String) -> Void
    let onCommentsTap: (String) -> Void
    let onSetDisplayMode: (String, FeedCardDisplayMode) -> Void

    var body: some View {
        switch state.renderedCard {
        case let .photo(content):
            switch content {
            case let .card(card):
                FeedPhotoCardView(
                    card: card,
                    actionState: state.actionState,
                    translationAction: translationAction,
                    onTap: { onCardTap(state.route) },
                    onLikeTap: { onLikeTap(state.id) },
                    onCommentsTap: { onCommentsTap(state.id) },
                    onSetDisplayMode: { onSetDisplayMode(state.id, $0) }
                )
                .onAppear {
                    FeedPerformanceSignpost.feedCardAppeared(cardID: state.id)
                }
            }
        case let .text(content):
            switch content {
            case let .card(card):
                FeedTextCardView(
                    card: card,
                    actionState: state.actionState,
                    translationAction: translationAction,
                    onTap: { onCardTap(state.route) },
                    onLikeTap: { onLikeTap(state.id) },
                    onCommentsTap: { onCommentsTap(state.id) },
                    onSetDisplayMode: { onSetDisplayMode(state.id, $0) }
                )
                .onAppear {
                    FeedPerformanceSignpost.feedCardAppeared(cardID: state.id)
                }
            }
        case let .video(content):
            switch content {
            case let .card(card):
                VideoCardView(
                    content: .card(card),
                    actionState: state.actionState,
                    translationAction: translationAction,
                    onTap: { onCardTap(state.route) },
                    onLikeTap: { onLikeTap(state.id) },
                    onCommentsTap: { onCommentsTap(state.id) },
                    onSetDisplayMode: { onSetDisplayMode(state.id, $0) }
                )
                .onAppear {
                    FeedPerformanceSignpost.feedCardAppeared(cardID: state.id)
                }
            }
        case let .audio(content):
            switch content {
            case let .card(card):
                AudioCardView(
                    content: .card(card),
                    actionState: state.actionState,
                    translationAction: translationAction,
                    onTap: { onCardTap(state.route) },
                    onLikeTap: { onLikeTap(state.id) },
                    onCommentsTap: { onCommentsTap(state.id) },
                    onSetDisplayMode: { onSetDisplayMode(state.id, $0) }
                )
                .onAppear {
                    FeedPerformanceSignpost.feedCardAppeared(cardID: state.id)
                }
            }
        case let .pdf(content):
            switch content {
            case let .card(card):
                PDFCardView(
                    content: .card(card),
                    actionState: state.actionState,
                    translationAction: translationAction,
                    onTap: { onCardTap(state.route) },
                    onLikeTap: { onLikeTap(state.id) },
                    onCommentsTap: { onCommentsTap(state.id) },
                    onSetDisplayMode: { onSetDisplayMode(state.id, $0) }
                )
                .onAppear {
                    FeedPerformanceSignpost.feedCardAppeared(cardID: state.id)
                }
            }
        }
    }
}

private struct NewsFeedTopOffsetSentinel: View {
    let coordinateSpaceName: String

    var body: some View {
        GeometryReader { proxy in
            Color.clear.preference(
                key: NewsFeedTopOffsetPreferenceKey.self,
                value: proxy.frame(in: .named(coordinateSpaceName)).minY
            )
        }
        .frame(height: 0)
        .accessibilityHidden(true)
    }
}

private struct NewsFeedTopOffsetPreferenceKey: PreferenceKey {
    static let defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

private struct NewsFeedScrollProximityModifier: ViewModifier {
    let threshold: CGFloat
    let coordinateSpaceName: String
    let onChange: (Bool) -> Void
    @State private var topOffsetBaseline: CGFloat?
    @State private var lastReportedIsNearTop: Bool?

    func body(content: Content) -> some View {
        if #available(iOS 18.0, *) {
            content.onScrollGeometryChange(for: Bool.self) { geometry in
                geometry.contentOffset.y <= threshold
            } action: { _, isNearTop in
                reportIfNeeded(isNearTop)
            }
        } else {
            content.onPreferenceChange(NewsFeedTopOffsetPreferenceKey.self) { topOffset in
                let baseline = topOffsetBaseline.map { max($0, topOffset) } ?? topOffset
                topOffsetBaseline = baseline
                reportIfNeeded(topOffset >= baseline - threshold)
            }
        }
    }

    private func reportIfNeeded(_ isNearTop: Bool) {
        guard lastReportedIsNearTop != isNearTop else {
            return
        }

        lastReportedIsNearTop = isNearTop
        onChange(isNearTop)
    }
}

private struct FeedTextCardView: View {
    let card: FeedCard
    let actionState: NewsFeedCardActionViewState
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void

    var body: some View {
        FeedCardContainer(
            card: card,
            actionState: actionState,
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

private struct FeedPhotoCardView: View {
    let card: FeedCard
    let actionState: NewsFeedCardActionViewState
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void

    var body: some View {
        FeedCardContainer(
            card: card,
            actionState: actionState,
            mediaHeight: 220,
            translationAction: translationAction,
            onTap: onTap,
            onLikeTap: onLikeTap,
            onCommentsTap: onCommentsTap,
            onSetDisplayMode: onSetDisplayMode
        ) {
            if case let .photos(items)? = card.mediaContent {
                FeedPhotoMediaPreview(items: items)
            }
        }
    }
}

private struct VideoCardView: View {
    let content: NewsFeedVideoCardContent
    let actionState: NewsFeedCardActionViewState
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void

    var body: some View {
        switch content {
        case let .card(card):
            FeedFileCardView(
                card: card,
                actionState: actionState,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in FeedVideoMediaView(file: file) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: FeedCard) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct AudioCardView: View {
    let content: NewsFeedAudioCardContent
    let actionState: NewsFeedCardActionViewState
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void

    var body: some View {
        switch content {
        case let .card(card):
            FeedFileCardView(
                card: card,
                actionState: actionState,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in FeedAudioMediaView(file: file) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: FeedCard) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct PDFCardView: View {
    let content: NewsFeedPDFCardContent
    let actionState: NewsFeedCardActionViewState
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void
    var body: some View {
        switch content {
        case let .card(card):
            FeedFileCardView(
                card: card,
                actionState: actionState,
                mediaHeight: Self.fileMediaPreviewHeight(for: card),
                translationAction: translationAction,
                onTap: onTap,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode,
                preview: { file in FeedPDFMediaView(file: file) }
            )
        }
    }

    private static func fileMediaPreviewHeight(for card: FeedCard) -> CGFloat {
        guard case let .file(file)? = card.mediaContent else {
            return 180
        }

        return file.teaserImage == nil ? 220 : 456
    }
}

private struct FeedFileCardView<Preview: View>: View {
    let card: FeedCard
    let actionState: NewsFeedCardActionViewState
    let mediaHeight: CGFloat
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void
    let preview: (FeedFileMediaContent) -> Preview

    var body: some View {
        FeedCardContainer(
            card: card,
            actionState: actionState,
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

    private var fileContent: FeedFileMediaContent? {
        guard case let .file(file)? = card.mediaContent else {
            return nil
        }

        return file
    }
}

private struct FeedCardContainer<MediaBody: View>: View {
    @Environment(\.openURL) private var openURL

    let card: FeedCard
    let actionState: NewsFeedCardActionViewState
    let mediaHeight: CGFloat?
    let translationAction: FeedCardTranslationAction?
    let onTap: () -> Void
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void
    let mediaBody: MediaBody

    init(
        card: FeedCard,
        actionState: NewsFeedCardActionViewState,
        mediaHeight: CGFloat?,
        translationAction: FeedCardTranslationAction?,
        onTap: @escaping () -> Void,
        onLikeTap: @escaping () -> Void,
        onCommentsTap: @escaping () -> Void,
        onSetDisplayMode: @escaping (FeedCardDisplayMode) -> Void,
        @ViewBuilder mediaBody: () -> MediaBody
    ) {
        self.card = card
        self.actionState = actionState
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
            VStack(alignment: .leading, spacing: 0) {
                if let resolvedMediaHeight = resolvedMediaHeight {
                    Rectangle()
                        .fill(AppTheme.surfaceSecondary)
                        .frame(height: resolvedMediaHeight)
                        .overlay {
                            mediaBody
                                .frame(maxWidth: .infinity)
                                .frame(height: resolvedMediaHeight, alignment: .center)
                                .clipped()
                        }
                        .clipped()
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
                        .frame(height: noTextBottomSpacerHeight)
                }
            }
            .onTapGesture(perform: onTap)
            .contentShape(Rectangle())
            .clipped()
            .zIndex(0)

            Divider()
                .overlay(AppTheme.borderSubtle)
                .padding(.horizontal, 14)

            FeedActionBar(
                state: actionState,
                onLikeTap: onLikeTap,
                onCommentsTap: onCommentsTap,
                onSetDisplayMode: onSetDisplayMode
            )
            .background(AppTheme.surfacePrimary)
            .contentShape(Rectangle())
            .zIndex(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        }
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
            if hasMediaMetadata {
                return max(200, mediaHeight - 20)
            }

            return max(180, mediaHeight - 40)
        }
    }

    private var hasMediaMetadata: Bool {
        switch card.mediaContent {
        case let .photos(items):
            return items.contains {
                $0.caption?.isEmpty == false || $0.copyright?.isEmpty == false
            }
        case let .file(file):
            return file.caption?.isEmpty == false ||
                file.teaserImage?.copyright?.isEmpty == false
        case nil:
            return false
        }
    }

    private var noTextBottomSpacerHeight: CGFloat {
        switch card.displayMode {
        case .expanded:
            return 30
        case .compact:
            return 60
        }
    }

    private var sourceURL: URL? {
        guard let resourceURLString = card.sourceContent?.resourceURLString,
              let url = URL(string: resourceURLString),
              let scheme = url.scheme?.lowercased(),
              scheme == "https" || scheme == "http"
        else {
            return nil
        }

        return url
    }

    private func font(for kind: FeedTextFieldKind) -> Font {
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

    private func color(for kind: FeedTextFieldKind) -> Color {
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

private struct FeedActionBar: View {
    let state: NewsFeedCardActionViewState
    let onLikeTap: () -> Void
    let onCommentsTap: () -> Void
    let onSetDisplayMode: (FeedCardDisplayMode) -> Void

    var body: some View {
        HStack {
            Button(action: onLikeTap) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "hand.thumbsup.fill")
                    Text(
                        AppLocalization.text("news.photo.action.liked")
                    )
                }
                .foregroundStyle(state.isLiked ? AppTheme.accent : AppTheme.iconSecondary)
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onCommentsTap) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "bubble.left.fill")
                    Text(state.commentsText)
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
                        systemImage: state.displayMode == .expanded ? "checkmark.circle.fill" : "text.alignleft"
                    )
                }

                Button {
                    onSetDisplayMode(.compact)
                } label: {
                    Label(
                        AppLocalization.text("news.photo.menu.compact"),
                        systemImage: state.displayMode == .compact ? "checkmark.circle.fill" : "rectangle.compress.vertical"
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

/// Render-ready translation button action for one feed card.
struct FeedCardTranslationAction {
    let title: String
    let isInFlight: Bool
    let onTap: () -> Void
}

/// Small reusable translation control rendered inside feed card action areas.
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

private struct FeedPhotoMediaPreview: View {
    let items: [FeedPhotoItem]

    var body: some View {
        if let item = items.first {
            FeedAsyncMediaFrame(
                fileURLString: item.fileURLString,
                previewKind: .image,
                fallbackSystemImage: "photo",
                fallbackIconSize: 32,
                caption: item.caption,
                copyright: item.copyright
            )
        }
    }
}

private struct FeedAsyncMediaFrame: View {
    let fileURLString: String?
    let previewKind: FeedMediaPreviewKind
    let fallbackSystemImage: String
    let fallbackIconSize: CGFloat
    let caption: String?
    let copyright: String?

    @State private var image: UIImage?

    private var requestID: String {
        "\(previewKind.rawValue)|\(fileURLString ?? "")"
    }

    var body: some View {
        FeedImageLikeMediaFrame(
            image: image,
            fallbackSystemImage: fallbackSystemImage,
            fallbackIconSize: fallbackIconSize,
            caption: caption,
            copyright: copyright
        )
        .task(id: requestID) {
            image = await FeedMediaPreviewLoader.preview(
                fileURLString: fileURLString,
                kind: previewKind
            )
        }
    }
}

private struct FeedVideoMediaView: View {
    let file: FeedFileMediaContent

    var body: some View {
        FeedFileMediaStackView(file: file) {
            FeedVideoPreviewFrame(file: file)
        }
    }
}

private struct FeedAudioMediaView: View {
    let file: FeedFileMediaContent

    var body: some View {
        FeedFileMediaStackView(file: file) {
            FeedAudioPreviewFrame(file: file)
        }
    }
}

private struct FeedPDFMediaView: View {
    let file: FeedFileMediaContent

    var body: some View {
        FeedFileMediaStackView(file: file) {
            FeedPDFPreviewFrame(file: file)
        }
    }
}

private struct FeedFileMediaStackView<MediaPreview: View>: View {
    let file: FeedFileMediaContent
    let mediaPreview: MediaPreview

    init(file: FeedFileMediaContent, @ViewBuilder mediaPreview: () -> MediaPreview) {
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

private struct FeedVideoPreviewFrame: View {
    let file: FeedFileMediaContent

    var body: some View {
        ZStack {
            FeedAsyncMediaFrame(
                fileURLString: file.fileURLString,
                previewKind: .video,
                fallbackSystemImage: "video",
                fallbackIconSize: 42,
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

private struct FeedAudioPreviewFrame: View {
    let file: FeedFileMediaContent

    var body: some View {
        FeedImageLikeMediaFrame(
            image: nil,
            fallbackSystemImage: "music.note",
            caption: file.caption,
            copyright: nil
        )
    }
}

private struct FeedPDFPreviewFrame: View {
    let file: FeedFileMediaContent

    var body: some View {
        FeedAsyncMediaFrame(
            fileURLString: file.fileURLString,
            previewKind: .pdf,
            fallbackSystemImage: "doc.text",
            fallbackIconSize: 42,
            caption: file.caption,
            copyright: nil
        )
    }
}

private struct FeedImageLikeMediaFrame: View {
    let image: UIImage?
    let fallbackSystemImage: String
    var fallbackIconSize: CGFloat = 42
    let caption: String?
    let copyright: String?

    var body: some View {
        ZStack(alignment: .bottom) {
            imageSurface
                .frame(maxWidth: .infinity, maxHeight: .infinity)

            if hasMetadata {
                FeedMediaMetadataBar(caption: caption, copyright: copyright)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.badge, style: .continuous))
    }

    @ViewBuilder
    private var imageSurface: some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            AppTheme.surfaceSecondary
                .overlay {
                    Image(systemName: fallbackSystemImage)
                        .font(.system(size: fallbackIconSize, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)
                }
        }
    }

    private var hasMetadata: Bool {
        caption?.isEmpty == false || copyright?.isEmpty == false
    }
}

private struct FeedMediaMetadataBar: View {
    private static let height: CGFloat = 56

    let caption: String?
    let copyright: String?

    var body: some View {
        VStack(spacing: AppSpacing.xxs) {
            if let copyright, !copyright.isEmpty {
                Text(copyright)
                    .font(AppTypography.label)
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }

            if let caption, !caption.isEmpty {
                Text(caption)
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(Color.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .background(Color.black.opacity(0.38))
    }
}

private struct FeedMediaTeaserBlock: View {
    let teaserImage: FeedTeaserImageContent?

    var body: some View {
        if let teaserImage {
            FeedAsyncMediaFrame(
                fileURLString: teaserImage.fileURLString,
                previewKind: .image,
                fallbackSystemImage: "photo",
                fallbackIconSize: 32,
                caption: nil,
                copyright: teaserImage.copyright
            )
        }
    }
}


private enum FeedMediaPreviewKind: String, Hashable, Sendable {
    case image
    case video
    case pdf
}

@MainActor
private final class FeedMediaPreviewMemoryCache {
    static let shared = FeedMediaPreviewMemoryCache()

    private let cache = NSCache<NSString, UIImage>()

    private init() {
        cache.countLimit = 160
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)
    }

    func setImage(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }
}

private enum FeedMediaPreviewLoader {
    static func preview(fileURLString: String?, kind: FeedMediaPreviewKind) async -> UIImage? {
        guard let fileURLString, !fileURLString.isEmpty else {
            return nil
        }

        let cacheKey = "\(kind.rawValue)|\(fileURLString)"
        if let cachedImage = await FeedMediaPreviewMemoryCache.shared.image(for: cacheKey) {
            return cachedImage
        }

        let signpostID = FeedPerformanceSignpost.beginMediaPreviewLoad(
            fileURLString: fileURLString,
            kind: kind
        )
        defer {
            FeedPerformanceSignpost.endMediaPreviewLoad(signpostID)
        }

        let image = await Task.detached(priority: .utility) {
            guard let fileURL = ComposerMediaPathResolver.resolve(fileURLString: fileURLString) else {
                return nil as UIImage?
            }

            switch kind {
            case .image:
                return downsampledImage(at: fileURL, maxPixelSize: 1200)
            case .video:
                return videoThumbnail(at: fileURL)
            case .pdf:
                return pdfThumbnail(at: fileURL)
            }
        }.value

        if let image {
            await FeedMediaPreviewMemoryCache.shared.setImage(image, for: cacheKey)
        }

        return image
    }

    private static func downsampledImage(at url: URL, maxPixelSize: CGFloat) -> UIImage? {
        let options = [kCGImageSourceShouldCache: false] as CFDictionary
        guard let source = CGImageSourceCreateWithURL(url as CFURL, options) else {
            return nil
        }

        let thumbnailOptions = [
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceShouldCacheImmediately: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceThumbnailMaxPixelSize: maxPixelSize
        ] as CFDictionary

        guard let cgImage = CGImageSourceCreateThumbnailAtIndex(source, 0, thumbnailOptions) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private static func videoThumbnail(at url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        guard let cgImage = try? generator.copyCGImage(at: .zero, actualTime: nil) else {
            return nil
        }

        return UIImage(cgImage: cgImage)
    }

    private static func pdfThumbnail(at url: URL) -> UIImage? {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else {
            return nil
        }

        return page.thumbnail(of: CGSize(width: 640, height: 420), for: .mediaBox)
    }
}

private enum ComposerMediaPathResolver {
    private static let mediaDirectoryName = "TchopComposerMedia"

    static func resolve(fileURLString: String?) -> URL? {
        guard let fileURLString, !fileURLString.isEmpty else {
            return nil
        }

        if let url = URL(string: fileURLString), url.scheme != nil {
            if FileManager.default.fileExists(atPath: url.path) {
                return url
            }
        }

        if FileManager.default.fileExists(atPath: fileURLString) {
            return URL(fileURLWithPath: fileURLString)
        }

        // Fallback for persisted absolute paths that become stale across app container changes.
        let filename = URL(fileURLWithPath: fileURLString).lastPathComponent
        guard !filename.isEmpty else {
            return nil
        }

        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }

        let candidateURL = documentsURL
            .appendingPathComponent(mediaDirectoryName, isDirectory: true)
            .appendingPathComponent(filename, isDirectory: false)

        return FileManager.default.fileExists(atPath: candidateURL.path) ? candidateURL : nil
    }
}

#if DEBUG
#Preview("News Feed") {
    NewsFeedView(
        viewModel: ViewPreviewSupport.makeNewsFeedViewModel(),
        onScrollProximityChange: { _ in },
        onCardTap: { _ in }
    )
}
#endif
