import Observation
import SwiftUI
import TchopNavigation
import UIKit

private struct FeedComposerView: View {
    @Bindable var viewModel: FeedComposerViewModel
    let onCancel: () -> Void
    let onPublish: () -> Void

    @State private var showsInsertionSheet = false
    @State private var showsChannelSheet = false
    @State private var showsMediaChoiceSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        ForEach(viewModel.orderedVisibleTextFieldKinds) { kind in
                            ComposerTextInputView(
                                text: binding(for: kind),
                                placeholder: viewModel.fieldPlaceholder(for: kind),
                                style: textInputStyle(for: kind),
                                onDeleteBackwardWhenEmpty: {
                                    viewModel.handleBackspaceOnEmptyField(kind)
                                }
                            )
                        }

                        if let media = viewModel.media {
                            ComposerMediaPlaceholderView(media: media)
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 104)
                }
            }

            toolbar

            if showsInsertionSheet {
                ComposerBottomSheet(
                    items: viewModel.availableInsertions.map { insertion in
                        ComposerBottomSheetItem(id: insertion.id, title: insertion.title)
                    },
                    onSelect: handleInsertionSelection,
                    onDismiss: { showsInsertionSheet = false }
                )
            }

            if showsChannelSheet {
                ComposerBottomSheet(
                    items: viewModel.availableChannels.map { channel in
                        ComposerBottomSheetItem(id: channel.id, title: channel.title)
                    },
                    onSelect: { selectedID in
                        viewModel.selectChannel(id: selectedID)
                    },
                    onDismiss: { showsChannelSheet = false }
                )
            }

            if showsMediaChoiceSheet {
                ComposerBottomSheet(
                    items: [
                        ComposerBottomSheetItem(id: "photo", title: "Photo"),
                        ComposerBottomSheetItem(id: "video", title: "Video")
                    ],
                    onSelect: { selectedID in
                        if selectedID == "photo" {
                            viewModel.addPhoto()
                        } else if selectedID == "video" {
                            viewModel.selectVideo()
                        }
                    },
                    onDismiss: { showsMediaChoiceSheet = false }
                )
            }
        }
        .background(AppTheme.surfacePrimary.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .font(AppTypography.bodyRegular)
                .foregroundStyle(AppTheme.accent)

            Spacer()

            Button(action: { showsChannelSheet = true }) {
                HStack(spacing: AppSpacing.xs) {
                    Text("Post in")
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(viewModel.selectedChannelTitle)
                        .foregroundStyle(AppTheme.accent)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .font(AppTypography.cardTitle)
            }
            .buttonStyle(.plain)

            Spacer()
            Color.clear.frame(width: 52)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.surfacePrimary)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)
        }
    }

    private var toolbar: some View {
        HStack {
            Button(action: { showsInsertionSheet = true }) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .font(AppTypography.actionTitle)
                .foregroundStyle(AppTheme.textPrimary)
            }
            .buttonStyle(.plain)

            Spacer()

            if viewModel.showsPhotoToolbarAction {
                Button(action: handlePhotoToolbarTap) {
                    Image(systemName: "photo")
                        .font(AppTypography.actionTitle)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, AppSpacing.lg)
            }

            Button(action: publish) {
                Text("Publish")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(Color.white)
                    .padding(.horizontal, AppSpacing.lg)
                    .padding(.vertical, AppSpacing.sm)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.accent.opacity(viewModel.canPublish ? 1 : 0.5))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!viewModel.canPublish)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.surfaceSecondary)
    }

    private func binding(for kind: ChannelCardTextFieldKind) -> Binding<String> {
        Binding(
            get: { viewModel.textValue(for: kind) },
            set: { viewModel.updateText($0, for: kind) }
        )
    }

    private func textInputStyle(for kind: ChannelCardTextFieldKind) -> ComposerTextInputStyle {
        switch kind {
        case .text:
            return ComposerTextInputStyle(
                textFont: .system(size: 16, weight: .regular),
                placeholderFont: .system(size: 24, weight: .regular),
                uiTextFont: .systemFont(ofSize: 16, weight: .regular),
                textColor: AppTheme.textPrimary,
                placeholderColor: AppTheme.textTertiary,
                minimumHeight: 120
            )
        case .headline:
            return ComposerTextInputStyle(
                textFont: AppTypography.cardTitleBold,
                placeholderFont: AppTypography.cardTitleBold,
                uiTextFont: .systemFont(ofSize: 18, weight: .bold),
                textColor: AppTheme.textPrimary,
                placeholderColor: AppTheme.textSecondary,
                minimumHeight: 44
            )
        case .subheadline:
            return ComposerTextInputStyle(
                textFont: AppTypography.bodySemibold,
                placeholderFont: AppTypography.bodySemibold,
                uiTextFont: .systemFont(ofSize: 15, weight: .semibold),
                textColor: AppTheme.textSecondary,
                placeholderColor: AppTheme.textTertiary,
                minimumHeight: 40
            )
        case .source:
            return ComposerTextInputStyle(
                textFont: AppTypography.captionSemibold,
                placeholderFont: AppTypography.captionSemibold,
                uiTextFont: .systemFont(ofSize: 13, weight: .semibold),
                textColor: AppTheme.accent,
                placeholderColor: AppTheme.textTertiary,
                minimumHeight: 36
            )
        }
    }

    private func handleInsertionSelection(_ selectedID: String) {
        guard let insertion = viewModel.availableInsertions.first(where: { $0.id == selectedID }) else {
            return
        }

        switch insertion {
        case .photoOrVideo:
            showsMediaChoiceSheet = true
        default:
            viewModel.applyInsertion(insertion)
        }
    }

    private func handlePhotoToolbarTap() {
        if viewModel.media == nil {
            showsMediaChoiceSheet = true
        } else {
            viewModel.addPhoto()
        }
    }

    private func publish() {
        guard viewModel.publish() != nil else {
            return
        }

        onPublish()
    }
}

private struct ComposerMediaPlaceholderView: View {
    let media: ChannelCardMediaContent

    var body: some View {
        RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
            .fill(AppTheme.surfaceSecondary)
            .frame(height: media.kind == .photo ? 220 : 180)
            .overlay {
                VStack(spacing: AppSpacing.xs) {
                    Image(systemName: iconName)
                        .font(.system(size: 28, weight: .semibold))
                        .foregroundStyle(AppTheme.textSecondary)

                    Text(media.displayTitle)
                        .font(AppTypography.cardTitle)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
    }

    private var iconName: String {
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

private struct ComposerBottomSheetItem: Identifiable {
    let id: String
    let title: String
}

private struct ComposerBottomSheet: View {
    let items: [ComposerBottomSheetItem]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 0) {
                Capsule(style: .continuous)
                    .fill(AppTheme.textTertiary.opacity(0.35))
                    .frame(width: 50, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)

                ForEach(items) { item in
                    Button {
                        onSelect(item.id)
                        onDismiss()
                    } label: {
                        Text(item.title)
                            .font(AppTypography.cardTitle)
                            .foregroundStyle(AppTheme.textPrimary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, AppSpacing.screenHorizontal)
                            .padding(.vertical, AppSpacing.md)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppTheme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .padding(.horizontal, 8)
            .padding(.bottom, 24)
        }
    }
}

private struct ComposerTextInputStyle {
    let textFont: Font
    let placeholderFont: Font
    let uiTextFont: UIFont
    let textColor: Color
    let placeholderColor: Color
    let minimumHeight: CGFloat
}

private struct ComposerTextInputView: View {
    @Binding var text: String
    let placeholder: String
    let style: ComposerTextInputStyle
    let onDeleteBackwardWhenEmpty: () -> Void

    @State private var dynamicHeight: CGFloat

    init(
        text: Binding<String>,
        placeholder: String,
        style: ComposerTextInputStyle,
        onDeleteBackwardWhenEmpty: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.style = style
        self.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        self._dynamicHeight = State(initialValue: style.minimumHeight)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(style.placeholderFont)
                    .foregroundStyle(style.placeholderColor)
                    .padding(.top, 8)
                    .padding(.horizontal, 5)
                    .allowsHitTesting(false)
            }

            ComposerTextViewRepresentable(
                text: $text,
                dynamicHeight: $dynamicHeight,
                font: style.uiTextFont,
                textColor: UIColor(style.textColor),
                minimumHeight: style.minimumHeight,
                onDeleteBackwardWhenEmpty: onDeleteBackwardWhenEmpty
            )
            .frame(height: max(style.minimumHeight, dynamicHeight))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ComposerTextViewRepresentable: UIViewRepresentable {
    @Binding var text: String
    @Binding var dynamicHeight: CGFloat
    let font: UIFont
    let textColor: UIColor
    let minimumHeight: CGFloat
    let onDeleteBackwardWhenEmpty: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            dynamicHeight: $dynamicHeight,
            minimumHeight: minimumHeight
        )
    }

    func makeUIView(context: Context) -> DeleteAwareTextView {
        let textView = DeleteAwareTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        textView.textContainer.lineFragmentPadding = 0
        textView.isScrollEnabled = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        textView.returnKeyType = .default
        textView.font = font
        textView.textColor = textColor
        textView.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        textView.text = text
        context.coordinator.recalculateHeight(for: textView)
        return textView
    }

    func updateUIView(_ uiView: DeleteAwareTextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.font = font
        uiView.textColor = textColor
        uiView.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        context.coordinator.recalculateHeight(for: uiView)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String
        @Binding private var dynamicHeight: CGFloat
        private let minimumHeight: CGFloat

        init(
            text: Binding<String>,
            dynamicHeight: Binding<CGFloat>,
            minimumHeight: CGFloat
        ) {
            self._text = text
            self._dynamicHeight = dynamicHeight
            self.minimumHeight = minimumHeight
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            recalculateHeight(for: textView)
        }

        func recalculateHeight(for textView: UITextView) {
            let fittedHeight = textView.sizeThatFits(
                CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            ).height

            let resolvedHeight = max(minimumHeight, fittedHeight)
            if dynamicHeight != resolvedHeight {
                DispatchQueue.main.async {
                    self.dynamicHeight = resolvedHeight
                }
            }
        }
    }
}

private final class DeleteAwareTextView: UITextView {
    var onDeleteBackwardWhenEmpty: (() -> Void)?

    override func deleteBackward() {
        if text.isEmpty {
            onDeleteBackwardWhenEmpty?()
        }
        super.deleteBackward()
    }
}

/// Layout wrapper combining top chrome, tab content, and overlays.
struct ShellContentView: View {
    private static let floatingActionButtonTabBarSpacing: CGFloat = 15

    let viewModel: AppShellViewModel
    let coordinator: AppCoordinator
    @Bindable var newsRouter: TabRouter<NewsRoute>
    let currentUser: AppUser?
    let profileTabViewModel: ProfileTabViewModel?
    let onLogout: () -> Void

    /// Whether the shell-level floating action button is allowed for the current tab, route depth and scroll position.
    private var shouldShowFloatingActionButton: Bool {
        coordinator.selectedTab == .news &&
            newsRouter.path.isEmpty &&
            viewModel.showsFloatingActionButton &&
            viewModel.isNewsFeedNearTop
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                TopBarView(
                    channelsStore: viewModel.channelsStore,
                    isSearchPresented: viewModel.newsFeedViewModel.isSearchPresented,
                    onMenuTap: viewModel.toggleMenu,
                    onSelectChannel: handleChannelSelection,
                    onSearchTap: handleSearchTap,
                    onNotificationsTap: {}
                )

                TabContentView(
                    selectedTab: coordinator.selectedTab,
                    coordinator: coordinator,
                    newsFeedViewModel: viewModel.newsFeedViewModel,
                    onNewsFeedScrollProximityChange: viewModel.setNewsFeedNearTop,
                    currentUser: currentUser,
                    profileTabViewModel: profileTabViewModel,
                    onLogout: onLogout
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)

            AppGlassContainer(spacing: 16) {
                ZStack(alignment: .bottom) {
                    if shouldShowFloatingActionButton {
                        FloatingActionButton(action: viewModel.presentComposer)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(.trailing, 18)
                            .padding(
                                .bottom,
                                BottomTabBar.occupiedHeight + Self.floatingActionButtonTabBarSpacing
                            )
                    }

                    BottomTabBar(selectedTab: coordinator.selectedTab, onSelect: coordinator.selectTab)
                }
            }
        }
        .accessibilityIdentifier("shell.content")
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
        .sheet(
            isPresented: Binding(
                get: { viewModel.activeComposer != nil },
                set: { isPresented in
                    if !isPresented {
                        viewModel.dismissComposer()
                    }
                }
            )
        ) {
            if let composer = viewModel.activeComposer {
                FeedComposerView(
                    viewModel: composer,
                    onCancel: viewModel.dismissComposer,
                    onPublish: viewModel.publishComposer
                )
            }
        }
    }

    /// Applies one selected channel from the top-bar dropdown and keeps the shell on the news tab.
    private func handleChannelSelection(_ channelID: String) {
        viewModel.selectChannel(id: channelID)
        coordinator.selectTab(.news)
    }

    /// Opens or closes search for the current channel feed.
    private func handleSearchTap() {
        if coordinator.selectedTab != .news {
            coordinator.selectTab(.news)
        }

        viewModel.newsFeedViewModel.toggleSearchPresentation()
    }
}

#if DEBUG
#Preview("Shell Content") {
    let coordinator = ViewPreviewSupport.makeCoordinator(selectedTab: .news)

    return ShellContentView(
        viewModel: ViewPreviewSupport.makeShellViewModel(),
        coordinator: coordinator,
        newsRouter: coordinator.newsRouter,
        currentUser: ViewPreviewSupport.sampleUser,
        profileTabViewModel: ViewPreviewSupport.makeProfileTabViewModel(
            currentUser: ViewPreviewSupport.sampleUser
        ),
        onLogout: {}
    )
}
#endif
