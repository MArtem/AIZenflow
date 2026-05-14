import Observation
import SwiftUI
import UIKit

struct SharedCardComposerView: View {
    @Bindable var viewModel: FeedComposerViewModel
    let onCancel: () -> Void
    let onPublish: () -> Void

    @State private var showsInsertionSheet = false
    @State private var showsChannelSheet = false
    @State private var showsMediaChoiceSheet = false
    @State private var showsFileMediaActionSheet = false
    @State private var selectedPhotoItemID: String?
    @State private var showsTeaserActionSheet = false
    @State private var focusedPhotoItemID: String?
    @State private var showsFileMediaDetail = false
    @State private var showsTeaserDetail = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                SharedCardComposerHeaderView(
                    selectedChannelTitle: viewModel.selectedChannelTitle,
                    onCancel: onCancel,
                    onSelectChannel: { showsChannelSheet = true }
                )

                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        VStack(alignment: .leading, spacing: 0) {
                            if viewModel.visibleTextFieldKinds.contains(.headline) {
                                ComposerTextInputView(
                                    text: binding(for: .headline),
                                    placeholder: viewModel.fieldPlaceholder(for: .headline),
                                    style: textInputStyle(for: .headline),
                                    onDeleteBackwardWhenEmpty: {
                                        viewModel.handleBackspaceOnEmptyField(.headline)
                                    }
                                )
                            }

                            if viewModel.visibleTextFieldKinds.contains(.subheadline) {
                                ComposerTextInputView(
                                    text: binding(for: .subheadline),
                                    placeholder: viewModel.fieldPlaceholder(for: .subheadline),
                                    style: textInputStyle(for: .subheadline),
                                    onDeleteBackwardWhenEmpty: {
                                        viewModel.handleBackspaceOnEmptyField(.subheadline)
                                    }
                                )
                                .padding(.top, subheadlineTopPadding)
                            }

                            if viewModel.visibleTextFieldKinds.contains(.text) {
                                ComposerTextInputView(
                                    text: binding(for: .text),
                                    placeholder: viewModel.fieldPlaceholder(for: .text),
                                    style: textInputStyle(for: .text),
                                    onDeleteBackwardWhenEmpty: {
                                        viewModel.handleBackspaceOnEmptyField(.text)
                                    }
                                )
                                .padding(.top, textTopPadding)
                            }
                        }

                        if let media = viewModel.media {
                            ComposerMediaPreview(
                                media: media,
                                onFileMediaMoreTap: { showsFileMediaActionSheet = true },
                                onPhotoMoreTap: { selectedPhotoItemID = $0 },
                                onPhotoTap: { focusedPhotoItemID = $0 },
                                onFileMediaTap: { showsFileMediaDetail = true }
                            )

                            if case let .file(file) = media, let teaserImage = file.teaserImage {
                                ComposerTeaserPreview(
                                    teaserImage: teaserImage,
                                    onMoreTap: { showsTeaserActionSheet = true },
                                    onTap: { showsTeaserDetail = true }
                                )
                            }

                            ForEach(viewModel.photoItems) { item in
                                if viewModel.isPhotoCaptionFieldVisible(id: item.id) {
                                    ComposerTextInputView(
                                        text: photoCaptionBinding(for: item.id),
                                        placeholder: "\(item.displayTitle): add caption",
                                        style: assetMetadataInputStyle(color: AppTheme.textSecondary),
                                        onDeleteBackwardWhenEmpty: {
                                            viewModel.removePhotoCaptionFieldIfEmpty(id: item.id)
                                        }
                                    )
                                }

                                if viewModel.isPhotoCopyrightFieldVisible(id: item.id) {
                                    ComposerTextInputView(
                                        text: photoCopyrightBinding(for: item.id),
                                        placeholder: "\(item.displayTitle): add copyright",
                                        style: assetMetadataInputStyle(color: AppTheme.textTertiary),
                                        onDeleteBackwardWhenEmpty: {
                                            viewModel.removePhotoCopyrightFieldIfEmpty(id: item.id)
                                        }
                                    )
                                }
                            }

                            if viewModel.isFileCaptionFieldVisible {
                                ComposerTextInputView(
                                    text: fileCaptionBinding,
                                    placeholder: "Add caption",
                                    style: assetMetadataInputStyle(color: AppTheme.textSecondary),
                                    onDeleteBackwardWhenEmpty: {
                                        viewModel.removeFileCaptionFieldIfEmpty()
                                    }
                                )
                            }

                            if viewModel.isTeaserCopyrightFieldVisible {
                                ComposerTextInputView(
                                    text: teaserCopyrightBinding,
                                    placeholder: "Add teaser copyright",
                                    style: assetMetadataInputStyle(color: AppTheme.textTertiary),
                                    onDeleteBackwardWhenEmpty: {
                                        viewModel.removeTeaserCopyrightFieldIfEmpty()
                                    }
                                )
                            }
                        }

                        if viewModel.isSourceFieldVisible {
                            ComposerTextInputView(
                                text: binding(for: .source),
                                placeholder: viewModel.fieldPlaceholder(for: .source),
                                style: textInputStyle(for: .source),
                                onDeleteBackwardWhenEmpty: {
                                    viewModel.handleBackspaceOnEmptyField(.source)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 116)
                }
            }

            SharedCardComposerToolbarView(
                showsPhotoToolbarAction: viewModel.showsPhotoToolbarAction,
                canPublish: viewModel.canPublish,
                onShowInsertionSheet: { showsInsertionSheet = true },
                onPhotoToolbarTap: handlePhotoToolbarTap,
                onPublish: publish
            )

            if showsInsertionSheet {
                ComposerBottomSheet(
                    items: insertionSheetItems,
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

            if showsFileMediaActionSheet {
                ComposerBottomSheet(
                    items: fileMediaActionItems,
                    onSelect: handleFileMediaActionSelection,
                    onDismiss: { showsFileMediaActionSheet = false }
                )
            }

            if showsTeaserActionSheet {
                ComposerBottomSheet(
                    items: teaserActionItems,
                    onSelect: handleTeaserActionSelection,
                    onDismiss: { showsTeaserActionSheet = false }
                )
            }

            if selectedPhotoItemID != nil {
                ComposerBottomSheet(
                    items: photoItemActionItems,
                    onSelect: handlePhotoItemActionSelection,
                    onDismiss: { selectedPhotoItemID = nil }
                )
            }
        }
        .background(AppTheme.surfacePrimary.ignoresSafeArea())
        .fullScreenCover(
            isPresented: Binding(
                get: { focusedPhotoItem != nil },
                set: { isPresented in
                    if !isPresented {
                        focusedPhotoItemID = nil
                    }
                }
            )
        ) {
            if let item = focusedPhotoItem {
                ComposerPhotoDetailView(
                    item: item,
                    onClose: { focusedPhotoItemID = nil },
                    onMoreTap: {
                        focusedPhotoItemID = nil
                        DispatchQueue.main.async {
                            selectedPhotoItemID = item.id
                        }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showsFileMediaDetail) {
            if let file = focusedFileMedia {
                ComposerFileMediaDetailView(
                    file: file,
                    onClose: { showsFileMediaDetail = false },
                    onMoreTap: {
                        showsFileMediaDetail = false
                        DispatchQueue.main.async {
                            showsFileMediaActionSheet = true
                        }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showsTeaserDetail) {
            if let teaserImage = focusedTeaserImage {
                ComposerTeaserDetailView(
                    teaserImage: teaserImage,
                    onClose: { showsTeaserDetail = false },
                    onMoreTap: {
                        showsTeaserDetail = false
                        DispatchQueue.main.async {
                            showsTeaserActionSheet = true
                        }
                    }
                )
            }
        }
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
                textFont: .system(size: 24, weight: .regular),
                placeholderFont: .system(size: 24, weight: .regular),
                uiTextFont: .systemFont(ofSize: 24, weight: .regular),
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
                minimumHeight: 32
            )
        case .subheadline:
            return ComposerTextInputStyle(
                textFont: AppTypography.bodySemibold,
                placeholderFont: AppTypography.bodySemibold,
                uiTextFont: .systemFont(ofSize: 15, weight: .semibold),
                textColor: AppTheme.textSecondary,
                placeholderColor: AppTheme.textTertiary,
                minimumHeight: 30
            )
        case .source:
            return ComposerTextInputStyle(
                textFont: AppTypography.captionSemibold,
                placeholderFont: AppTypography.captionSemibold,
                uiTextFont: .systemFont(ofSize: 13, weight: .semibold),
                textColor: AppTheme.accent,
                placeholderColor: AppTheme.textTertiary,
                minimumHeight: 28
            )
        }
    }

    private func assetMetadataInputStyle(color: Color) -> ComposerTextInputStyle {
        ComposerTextInputStyle(
            textFont: AppTypography.captionSemibold,
            placeholderFont: AppTypography.captionSemibold,
            uiTextFont: .systemFont(ofSize: 13, weight: .semibold),
            textColor: color,
            placeholderColor: AppTheme.textTertiary,
            minimumHeight: 36
        )
    }

    private func handleInsertionSelection(_ selectedID: String) {
        if selectedID == "schedule" {
            return
        }

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

    private var insertionSheetItems: [ComposerBottomSheetItem] {
        let mapped = viewModel.availableInsertions.map { insertion in
            ComposerBottomSheetItem(
                id: insertion.id,
                title: insertionSheetTitle(for: insertion),
                systemImageName: insertionSheetIcon(for: insertion)
            )
        }

        var items: [ComposerBottomSheetItem] = []
        for item in mapped {
            items.append(item)
            if item.id == FeedComposerInsertion.pdf.id {
                items.append(
                    ComposerBottomSheetItem(
                        id: "schedule",
                        title: "Schedule",
                        systemImageName: "calendar"
                    )
                )
            }
        }
        return items
    }

    private func insertionSheetTitle(for insertion: FeedComposerInsertion) -> String {
        switch insertion {
        case .pdf:
            return "PDF file"
        case .subheadline:
            return "Sub heading"
        default:
            return insertion.title
        }
    }

    private func insertionSheetIcon(for insertion: FeedComposerInsertion) -> String {
        switch insertion {
        case .photoOrVideo:
            return "photo.on.rectangle"
        case .photo:
            return "photo"
        case .audio:
            return "music.note"
        case .pdf:
            return "doc.text"
        case .text:
            return "calendar"
        case .headline:
            return "textformat.size"
        case .subheadline:
            return "textformat"
        case .source:
            return "globe"
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

    private var subheadlineTopPadding: CGFloat {
        viewModel.visibleTextFieldKinds.contains(.headline) ? 8 : 0
    }

    private var textTopPadding: CGFloat {
        if viewModel.visibleTextFieldKinds.contains(.headline)
            || viewModel.visibleTextFieldKinds.contains(.subheadline) {
            return 16
        }

        return 0
    }

    private var fileMediaActionItems: [ComposerBottomSheetItem] {
        guard case let .file(file)? = viewModel.media else {
            return []
        }

        var items: [ComposerBottomSheetItem] = []
        if !viewModel.isFileCaptionFieldVisible {
            items.append(ComposerBottomSheetItem(id: "addCaption", title: "Add caption"))
        }
        if file.teaserImage == nil {
            items.append(ComposerBottomSheetItem(id: "addTeaser", title: "Add teaser image"))
        } else {
            if !viewModel.isTeaserCopyrightFieldVisible {
                items.append(ComposerBottomSheetItem(id: "addTeaserCopyright", title: "Add teaser copyright"))
            }
            items.append(ComposerBottomSheetItem(id: "replaceTeaser", title: "Replace teaser image"))
            items.append(ComposerBottomSheetItem(id: "removeTeaser", title: "Remove teaser image"))
        }
        items.append(ComposerBottomSheetItem(id: "removeMedia", title: "Remove media"))
        return items
    }

    private func handleFileMediaActionSelection(_ selectedID: String) {
        switch selectedID {
        case "addCaption":
            viewModel.showFileCaptionField()
        case "addTeaser", "replaceTeaser":
            viewModel.addOrReplaceTeaserImage()
        case "addTeaserCopyright":
            viewModel.showTeaserCopyrightField()
        case "removeTeaser":
            viewModel.removeTeaserImage()
        case "removeMedia":
            viewModel.removeMedia()
        default:
            break
        }
    }

    private var teaserActionItems: [ComposerBottomSheetItem] {
        guard case let .file(file)? = viewModel.media, file.teaserImage != nil else {
            return []
        }

        var items: [ComposerBottomSheetItem] = []
        if !viewModel.isTeaserCopyrightFieldVisible {
            items.append(ComposerBottomSheetItem(id: "addTeaserCopyright", title: "Add teaser copyright"))
        }
        items.append(ComposerBottomSheetItem(id: "replaceTeaser", title: "Replace teaser image"))
        items.append(ComposerBottomSheetItem(id: "removeTeaser", title: "Remove teaser image"))
        return items
    }

    private func handleTeaserActionSelection(_ selectedID: String) {
        switch selectedID {
        case "addTeaserCopyright":
            viewModel.showTeaserCopyrightField()
        case "replaceTeaser":
            viewModel.addOrReplaceTeaserImage()
        case "removeTeaser":
            viewModel.removeTeaserImage()
        default:
            break
        }
    }

    private var fileCaptionBinding: Binding<String> {
        Binding(
            get: { viewModel.fileCaptionText },
            set: { viewModel.updateFileCaption($0) }
        )
    }

    private var teaserCopyrightBinding: Binding<String> {
        Binding(
            get: { viewModel.teaserCopyrightText },
            set: { viewModel.updateTeaserCopyright($0) }
        )
    }

    private func handlePhotoItemActionSelection(_ selectedID: String) {
        guard let selectedPhotoItemID else {
            return
        }

        switch selectedID {
        case "addPhotoCaption":
            viewModel.showPhotoCaptionField(id: selectedPhotoItemID)
        case "addPhotoCopyright":
            viewModel.showPhotoCopyrightField(id: selectedPhotoItemID)
        case "removePhoto":
            viewModel.removePhoto(id: selectedPhotoItemID)
        default:
            break
        }

        self.selectedPhotoItemID = nil
    }

    private var photoItemActionItems: [ComposerBottomSheetItem] {
        guard let selectedPhotoItemID else {
            return []
        }

        var items: [ComposerBottomSheetItem] = []
        if !viewModel.isPhotoCaptionFieldVisible(id: selectedPhotoItemID) {
            items.append(ComposerBottomSheetItem(id: "addPhotoCaption", title: "Add caption"))
        }
        if !viewModel.isPhotoCopyrightFieldVisible(id: selectedPhotoItemID) {
            items.append(ComposerBottomSheetItem(id: "addPhotoCopyright", title: "Add copyright"))
        }
        items.append(ComposerBottomSheetItem(id: "removePhoto", title: "Remove photo"))
        return items
    }

    private func photoCaptionBinding(for photoID: String) -> Binding<String> {
        Binding(
            get: { viewModel.photoCaptionText(id: photoID) },
            set: { viewModel.updatePhotoCaption($0, id: photoID) }
        )
    }

    private func photoCopyrightBinding(for photoID: String) -> Binding<String> {
        Binding(
            get: { viewModel.photoCopyrightText(id: photoID) },
            set: { viewModel.updatePhotoCopyright($0, id: photoID) }
        )
    }

    private var focusedPhotoItem: ChannelCardPhotoItem? {
        guard let focusedPhotoItemID else {
            return nil
        }

        return viewModel.photoItems.first(where: { $0.id == focusedPhotoItemID })
    }

    private var focusedFileMedia: ChannelCardFileMediaContent? {
        guard case let .file(file)? = viewModel.media else {
            return nil
        }

        return file
    }

    private var focusedTeaserImage: ChannelCardTeaserImageContent? {
        guard let file = focusedFileMedia else {
            return nil
        }

        return file.teaserImage
    }
}

private struct ComposerMediaPreview: View {
    let media: ChannelCardMediaContent
    let onFileMediaMoreTap: () -> Void
    let onPhotoMoreTap: (String) -> Void
    let onPhotoTap: (String) -> Void
    let onFileMediaTap: () -> Void

    var body: some View {
        switch media {
        case let .photos(items):
            ComposerPhotoStripView(
                items: items,
                onMoreTap: onPhotoMoreTap,
                onTap: onPhotoTap
            )
        case let .file(file):
            switch file.kind {
            case .photo:
                EmptyView()
            case .video:
                ComposerVideoMediaView(file: file, onMoreTap: onFileMediaMoreTap, onTap: onFileMediaTap)
            case .audio:
                ComposerAudioMediaView(file: file, onMoreTap: onFileMediaMoreTap, onTap: onFileMediaTap)
            case .pdf:
                ComposerPDFMediaView(file: file, onMoreTap: onFileMediaMoreTap, onTap: onFileMediaTap)
            }
        }
    }
}

private struct ComposerPhotoStripView: View {
    let items: [ChannelCardPhotoItem]
    let onMoreTap: (String) -> Void
    let onTap: (String) -> Void

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: AppSpacing.sm) {
                ForEach(items) { item in
                    ComposerPhotoStripItemView(
                        item: item,
                        onMoreTap: { onMoreTap(item.id) },
                        onTap: { onTap(item.id) }
                    )
                }
            }
            .padding(.vertical, AppSpacing.xxs)
        }
    }
}

private struct ComposerPhotoStripItemView: View {
    let item: ChannelCardPhotoItem
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerInteractiveMediaSurface(
            height: 184,
            onMoreTap: onMoreTap,
            onTap: onTap
        ) {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                if let caption = item.caption, !caption.isEmpty {
                    Text(caption)
                        .font(AppTypography.captionSemibold)
                        .foregroundStyle(AppTheme.textTertiary)
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
        }
        .frame(width: 184)
    }
}

private struct ComposerVideoMediaView: View {
    let file: ChannelCardFileMediaContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(file: file, onMoreTap: onMoreTap, onTap: onTap)
    }
}

private struct ComposerAudioMediaView: View {
    let file: ChannelCardFileMediaContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(file: file, onMoreTap: onMoreTap, onTap: onTap)
    }
}

private struct ComposerPDFMediaView: View {
    let file: ChannelCardFileMediaContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(file: file, onMoreTap: onMoreTap, onTap: onTap)
    }
}

private struct ComposerInteractiveMediaSurface<Content: View>: View {
    let height: CGFloat
    let onMoreTap: () -> Void
    let onTap: () -> Void
    let content: Content

    init(
        height: CGFloat,
        onMoreTap: @escaping () -> Void,
        onTap: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.height = height
        self.onMoreTap = onMoreTap
        self.onTap = onTap
        self.content = content()
    }

    var body: some View {
        Button(action: onTap) {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(AppTheme.surfaceSecondary)
                .frame(height: height)
                .overlay {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()

                            Button(action: onMoreTap) {
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundStyle(AppTheme.textSecondary)
                                    .frame(width: 32, height: 32)
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.top, AppSpacing.sm)
                        .padding(.horizontal, AppSpacing.sm)

                        Spacer()
                        content
                        Spacer()
                    }
                }
        }
        .buttonStyle(.plain)
    }
}

private struct ComposerFileMediaPreviewView: View {
    let file: ChannelCardFileMediaContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    private var presentation: ComposerFileMediaPresentation {
        ComposerFileMediaPresentation(file: file)
    }

    var body: some View {
        ComposerInteractiveMediaSurface(
            height: 184,
            onMoreTap: onMoreTap,
            onTap: onTap
        ) {
            ComposerMediaKindBadge(title: presentation.kindTitle)
            ComposerMediaHeroIcon(systemName: presentation.iconName)
            ComposerMediaTitleBlock(presentation: presentation)
        }
    }
}

private struct ComposerMediaKindBadge: View {
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

private struct ComposerMediaHeroIcon: View {
    let systemName: String

    var body: some View {
        Image(systemName: systemName)
            .font(.system(size: 30, weight: .semibold))
            .foregroundStyle(AppTheme.textSecondary)
    }
}

private struct ComposerMediaTitleBlock: View {
    let presentation: ComposerFileMediaPresentation

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            if let displayTitle = presentation.resolvedDisplayTitle {
                Text(displayTitle)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            if let caption = presentation.file.caption, !caption.isEmpty {
                Text(caption)
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
    }
}

private struct ComposerTeaserPreviewContent: View {
    let teaserImage: ChannelCardTeaserImageContent

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("Teaser image")
                .font(AppTypography.label)
                .foregroundStyle(AppTheme.textTertiary)

            Image(systemName: "photo")
                .font(.system(size: 24, weight: .semibold))
                .foregroundStyle(AppTheme.textSecondary)

            if let copyright = teaserImage.copyright, !copyright.isEmpty {
                Text(copyright)
                    .font(AppTypography.label)
                    .foregroundStyle(AppTheme.textTertiary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, AppSpacing.md)
            }
        }
    }
}

private struct ComposerTeaserPreview: View {
    let teaserImage: ChannelCardTeaserImageContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerInteractiveMediaSurface(
            height: 140,
            onMoreTap: onMoreTap,
            onTap: onTap
        ) {
            ComposerTeaserPreviewContent(teaserImage: teaserImage)
        }
    }
}

private struct ComposerPhotoDetailView: View {
    let item: ChannelCardPhotoItem
    let onClose: () -> Void
    let onMoreTap: () -> Void

    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 320 * scale, height: 480 * scale)
                        .overlay {
                            VStack(spacing: AppSpacing.sm) {
                                Image(systemName: "photo")
                                    .font(.system(size: 56 * scale, weight: .semibold))
                                    .foregroundStyle(Color.white.opacity(0.9))

                                if let caption = item.caption, !caption.isEmpty {
                                    Text(caption)
                                        .font(.system(size: max(13, 15 * scale), weight: .medium))
                                        .foregroundStyle(Color.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.lg)
                                }

                                if let copyright = item.copyright, !copyright.isEmpty {
                                    Text(copyright)
                                        .font(.system(size: max(11, 13 * scale), weight: .medium))
                                        .foregroundStyle(Color.white.opacity(0.65))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.lg)
                                }
                            }
                        }
                        .padding(.vertical, 80)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
            .gesture(
                MagnifyGesture()
                    .onChanged { value in
                        scale = min(max(baseScale * value.magnification, 1), 4)
                    }
                    .onEnded { _ in
                        baseScale = scale
                    }
            )

            ComposerDetailTopBar(onClose: onClose, onMoreTap: onMoreTap)
        }
    }
}

private struct ComposerFileMediaDetailView: View {
    let file: ChannelCardFileMediaContent
    let onClose: () -> Void
    let onMoreTap: () -> Void

    private var presentation: ComposerFileMediaPresentation {
        ComposerFileMediaPresentation(file: file)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 320)
                        .overlay {
                            VStack(spacing: AppSpacing.sm) {
                                ComposerMediaKindBadge(title: presentation.kindTitle)

                                Image(systemName: presentation.iconName)
                                    .font(.system(size: 56, weight: .semibold))
                                    .foregroundStyle(Color.white.opacity(0.9))

                                if let displayTitle = presentation.resolvedDisplayTitle {
                                    Text(displayTitle)
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(Color.white)
                                        .multilineTextAlignment(.center)
                                }

                                if let caption = file.caption, !caption.isEmpty {
                                    Text(caption)
                                        .font(.system(size: 15, weight: .medium))
                                        .foregroundStyle(Color.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                        .padding(.horizontal, AppSpacing.lg)
                                }
                            }
                            .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.top, 80)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, 40)
            }

            ComposerDetailTopBar(onClose: onClose, onMoreTap: onMoreTap)
        }
    }
}

private struct ComposerFileMediaPresentation {
    let file: ChannelCardFileMediaContent

    var kindTitle: String {
        switch file.kind {
        case .photo:
            return "Photo"
        case .video:
            return "Video"
        case .audio:
            return "Audio"
        case .pdf:
            return "PDF"
        }
    }

    var iconName: String {
        switch file.kind {
        case .photo:
            return "photo.on.rectangle.angled"
        case .video:
            return "play.rectangle.fill"
        case .audio:
            return "waveform.circle.fill"
        case .pdf:
            return "document.fill"
        }
    }

    var resolvedDisplayTitle: String? {
        switch file.kind {
        case .photo:
            return nil
        case .video, .audio, .pdf:
            return file.displayTitle == kindTitle ? nil : file.displayTitle
        }
    }
}

private struct ComposerTeaserDetailView: View {
    let teaserImage: ChannelCardTeaserImageContent
    let onClose: () -> Void
    let onMoreTap: () -> Void

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 280)
                        .overlay {
                            ComposerTeaserPreviewContent(teaserImage: teaserImage)
                                .padding(.horizontal, AppSpacing.lg)
                        }
                        .padding(.top, 80)
                }
                .padding(.horizontal, AppSpacing.screenHorizontal)
                .padding(.bottom, 40)
            }

            ComposerDetailTopBar(onClose: onClose, onMoreTap: onMoreTap)
        }
    }
}

private struct ComposerDetailTopBar: View {
    let onClose: () -> Void
    let onMoreTap: () -> Void

    var body: some View {
        HStack {
            Button(action: onClose) {
                Image(systemName: "xmark")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)

            Spacer()

            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .frame(width: 36, height: 36)
                    .background(Color.white.opacity(0.12))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, AppSpacing.md)
        .padding(.top, AppSpacing.lg)
    }
}

private struct ComposerBottomSheetItem: Identifiable {
    let id: String
    let title: String
    var systemImageName: String?
}

private struct ComposerBottomSheet: View {
    private enum Layout {
        static let overlayOpacity: CGFloat = 0.38
        static let horizontalInset: CGFloat = 22
        static let bottomInset: CGFloat = 18
        static let cornerRadius: CGFloat = 26
        static let handleWidth: CGFloat = 48
        static let handleHeight: CGFloat = 5
        static let handleTopPadding: CGFloat = 14
        static let handleBottomPadding: CGFloat = 18
        static let rowHeight: CGFloat = 68
        static let rowHorizontalPadding: CGFloat = 28
        static let iconSize: CGFloat = 18
        static let iconWidth: CGFloat = 28
        static let rowSpacing: CGFloat = 18
    }

    let items: [ComposerBottomSheetItem]
    let onSelect: (String) -> Void
    let onDismiss: () -> Void

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(Layout.overlayOpacity)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 0) {
                Capsule(style: .continuous)
                    .fill(AppTheme.textTertiary.opacity(0.28))
                    .frame(width: Layout.handleWidth, height: Layout.handleHeight)
                    .frame(maxWidth: .infinity)
                    .padding(.top, Layout.handleTopPadding)
                    .padding(.bottom, Layout.handleBottomPadding)

                ForEach(items) { item in
                    Button {
                        onSelect(item.id)
                        onDismiss()
                    } label: {
                        HStack(spacing: Layout.rowSpacing) {
                            if let icon = item.systemImageName {
                                Image(systemName: icon)
                                    .font(.system(size: Layout.iconSize, weight: .regular))
                                    .foregroundStyle(AppTheme.textPrimary)
                                    .frame(width: Layout.iconWidth, alignment: .leading)
                            }

                            Text(item.title)
                                .font(.system(size: 18, weight: .regular))
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, Layout.rowHorizontalPadding)
                        .frame(height: Layout.rowHeight, alignment: .center)
                    }
                    .buttonStyle(.plain)
                }
            }
            .background(AppTheme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius, style: .continuous))
            .padding(.horizontal, Layout.horizontalInset)
            .padding(.bottom, Layout.bottomInset)
        }
    }
}

private struct ComposerTextInputStyle {
    static let textInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

    let textFont: Font
    let placeholderFont: Font
    let uiTextFont: UIFont
    let textColor: Color
    let placeholderColor: Color
    let minimumHeight: CGFloat
}

private struct SharedCardComposerHeaderView: View {
    let selectedChannelTitle: String
    let onCancel: () -> Void
    let onSelectChannel: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelectChannel) {
                HStack(spacing: AppSpacing.xs) {
                    Text("Post in:")
                        .foregroundStyle(AppTheme.textPrimary)

                    Text(selectedChannelTitle)
                        .foregroundStyle(AppTheme.accent)

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppTheme.accent)
                }
                .font(AppTypography.cardTitle)
            }
            .buttonStyle(.plain)

            Spacer()

            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .font(AppTypography.bodyRegular)
                .foregroundStyle(AppTheme.accent)
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
}

private struct SharedCardComposerToolbarView: View {
    private enum Layout {
        static let leadingClusterWidth: CGFloat = 152
        static let plusClusterWidth: CGFloat = 46
        static let mediaClusterWidth: CGFloat = 86
        static let leadingClusterSpacing: CGFloat = 20
        static let mediaIconSpacing: CGFloat = 40
        static let toolbarHeight: CGFloat = 70
        static let toolbarTopPadding: CGFloat = 10
    }

    let showsPhotoToolbarAction: Bool
    let canPublish: Bool
    let onShowInsertionSheet: () -> Void
    let onPhotoToolbarTap: () -> Void
    let onPublish: () -> Void

    var body: some View {
        HStack(spacing: 0) {
            HStack(spacing: Layout.leadingClusterSpacing) {
                Button(action: onShowInsertionSheet) {
                    HStack(spacing: 0) {
                        Image(systemName: "plus")
                            .font(AppTypography.actionTitle)

                        Image(systemName: "chevron.down")
                            .font(.system(size: 22, weight: .regular))
                            .foregroundStyle(AppTheme.textTertiary)
                    }
                    .foregroundStyle(AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
                .frame(width: Layout.plusClusterWidth, height: 24, alignment: .leading)

                HStack(spacing: Layout.mediaIconSpacing) {
                    if showsPhotoToolbarAction {
                        Button(action: onPhotoToolbarTap) {
                            Image(systemName: "photo")
                                .font(AppTypography.actionTitle)
                                .foregroundStyle(AppTheme.textPrimary)
                        }
                        .buttonStyle(.plain)
                    }

                    Image(systemName: "calendar")
                        .font(AppTypography.actionTitle)
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .frame(width: Layout.mediaClusterWidth, alignment: .leading)
            }
            .frame(width: Layout.leadingClusterWidth, alignment: .leading)

            Spacer(minLength: 0)

            Button(action: onPublish) {
                Text("Publish")
                    .font(AppTypography.bodySemibold)
                    .foregroundStyle(Color.white)
                    .frame(width: 95, height: 38)
                    .background(
                        Capsule(style: .continuous)
                            .fill(AppTheme.accent.opacity(canPublish ? 1 : 0.5))
                    )
            }
            .buttonStyle(.plain)
            .disabled(!canPublish)
        }
        .padding(.horizontal, 16)
        .padding(.top, Layout.toolbarTopPadding)
        .frame(height: Layout.toolbarHeight, alignment: .top)
        .background(AppTheme.surfaceSecondary)
        .ignoresSafeArea(.container, edges: .bottom)
        .overlay(alignment: .top) {
            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)
        }
    }
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
                    .padding(.top, ComposerTextInputStyle.textInsets.top)
                    .padding(.leading, ComposerTextInputStyle.textInsets.left)
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
        textView.textContainerInset = ComposerTextInputStyle.textInsets
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
