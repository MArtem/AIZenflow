import AVKit
import CoreTransferable
import Observation
import PDFKit
import PhotosUI
import SwiftUI
import UIKit
import UniformTypeIdentifiers

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
    @State private var focusedTextFieldKind: ChannelCardTextFieldKind?
    @State private var replacingPhotoItemID: String?
    @State private var showsPhotoPicker = false
    @State private var showsVideoPicker = false
    @State private var showsTeaserImagePicker = false
    @State private var selectedPhotoPickerItem: PhotosPickerItem?
    @State private var selectedVideoPickerItem: PhotosPickerItem?
    @State private var selectedTeaserPickerItem: PhotosPickerItem?
    @State private var showsFileImporter = false
    @State private var fileImportKind: ChannelCardMediaKind?

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
                                    isFocused: focusedTextFieldKind == .headline,
                                    onFocus: { focusedTextFieldKind = .headline },
                                    onDeleteBackwardWhenEmpty: {
                                        handleTextFieldBackspaceWhenEmpty(.headline)
                                    }
                                )
                            }

                            if viewModel.visibleTextFieldKinds.contains(.subheadline) {
                                ComposerTextInputView(
                                    text: binding(for: .subheadline),
                                    placeholder: viewModel.fieldPlaceholder(for: .subheadline),
                                    style: textInputStyle(for: .subheadline),
                                    isFocused: focusedTextFieldKind == .subheadline,
                                    onFocus: { focusedTextFieldKind = .subheadline },
                                    onDeleteBackwardWhenEmpty: {
                                        handleTextFieldBackspaceWhenEmpty(.subheadline)
                                    }
                                )
                                .padding(.top, subheadlineTopPadding)
                            }

                            if viewModel.visibleTextFieldKinds.contains(.text) {
                                ComposerTextInputView(
                                    text: binding(for: .text),
                                    placeholder: viewModel.fieldPlaceholder(for: .text),
                                    style: textInputStyle(for: .text),
                                    isFocused: focusedTextFieldKind == .text,
                                    onFocus: { focusedTextFieldKind = .text },
                                    onDeleteBackwardWhenEmpty: {
                                        handleTextFieldBackspaceWhenEmpty(.text)
                                    }
                                )
                                .padding(.top, textTopPadding)
                            }
                        }

                        if let media = viewModel.media {
                            ComposerMediaPreview(
                                media: media,
                                showsFileCaptionField: viewModel.isFileCaptionFieldVisible,
                                fileCaptionText: fileCaptionBinding,
                                fileCaptionInputStyle: assetMetadataInputStyle(color: AppTheme.textSecondary),
                                onFileCaptionFocus: clearFocusedTextField,
                                onFileCaptionDeleteBackwardWhenEmpty: {
                                    viewModel.removeFileCaptionFieldIfEmpty()
                                },
                                showsTeaserCopyrightField: viewModel.isTeaserCopyrightFieldVisible,
                                teaserCopyrightText: teaserCopyrightBinding,
                                teaserCopyrightInputStyle: assetMetadataInputStyle(color: AppTheme.textTertiary),
                                onTeaserCopyrightFocus: clearFocusedTextField,
                                onTeaserCopyrightDeleteBackwardWhenEmpty: {
                                    viewModel.removeTeaserCopyrightFieldIfEmpty()
                                },
                                onTeaserMoreTap: { showsTeaserActionSheet = true },
                                onTeaserTap: { showsTeaserDetail = true },
                                onFileMediaMoreTap: { showsFileMediaActionSheet = true },
                                onPhotoMoreTap: { selectedPhotoItemID = $0 },
                                onPhotoTap: { focusedPhotoItemID = $0 },
                                onFileMediaTap: { showsFileMediaDetail = true }
                            )

                            ForEach(viewModel.photoItems) { item in
                                let showsCopyright = viewModel.isPhotoCopyrightFieldVisible(id: item.id)
                                let showsCaption = viewModel.isPhotoCaptionFieldVisible(id: item.id)

                                if showsCopyright || showsCaption {
                                    VStack(alignment: .leading, spacing: 8) {
                                        if showsCopyright {
                                            ComposerTextInputView(
                                                text: photoCopyrightBinding(for: item.id),
                                                placeholder: "© Copyright text",
                                                style: assetMetadataInputStyle(color: AppTheme.textTertiary),
                                                onFocus: clearFocusedTextField,
                                                onDeleteBackwardWhenEmpty: {
                                                    viewModel.removePhotoCopyrightFieldIfEmpty(id: item.id)
                                                }
                                            )
                                        }

                                        if showsCaption {
                                            ComposerTextInputView(
                                                text: photoCaptionBinding(for: item.id),
                                                placeholder: "Write a caption...",
                                                style: assetMetadataInputStyle(color: AppTheme.textSecondary),
                                                onFocus: clearFocusedTextField,
                                                onDeleteBackwardWhenEmpty: {
                                                    viewModel.removePhotoCaptionFieldIfEmpty(id: item.id)
                                                }
                                            )
                                        }
                                    }
                                }
                            }

                        }

                        if viewModel.isSourceFieldVisible {
                            ComposerTextInputView(
                                text: binding(for: .source),
                                placeholder: viewModel.fieldPlaceholder(for: .source),
                                style: textInputStyle(for: .source),
                                isFocused: focusedTextFieldKind == .source,
                                onFocus: { focusedTextFieldKind = .source },
                                onDeleteBackwardWhenEmpty: {
                                    handleTextFieldBackspaceWhenEmpty(.source)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 116)
                    .frame(maxWidth: .infinity, alignment: .leading)
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

            if showsMediaChoiceSheet {
                ComposerBottomSheet(
                    items: [
                        ComposerBottomSheetItem(id: "photo", title: "Photo"),
                        ComposerBottomSheetItem(id: "video", title: "Video")
                    ],
                    onSelect: { selectedID in
                        if selectedID == "photo" {
                            showsPhotoPicker = true
                        } else if selectedID == "video" {
                            showsVideoPicker = true
                        }
                    },
                    onDismiss: { showsMediaChoiceSheet = false }
                )
            }

        }
        .background(AppTheme.surfacePrimary.ignoresSafeArea())
        .onAppear {
            focusInitialTextField()
        }
        .fullScreenCover(isPresented: $showsChannelSheet) {
            ComposerChannelSelectionView(
                channels: viewModel.availableChannels,
                selectedChannelID: viewModel.selectedChannelID,
                onDone: { showsChannelSheet = false },
                onSelect: { selectedID in
                    viewModel.selectChannel(id: selectedID)
                    showsChannelSheet = false
                }
            )
        }
        .fullScreenCover(
            isPresented: Binding(
                get: { selectedPhotoItemID != nil },
                set: { isPresented in
                    if !isPresented {
                        selectedPhotoItemID = nil
                    }
                }
            )
        ) {
            ComposerPhotoActionsView(
                onBack: { selectedPhotoItemID = nil },
                onDelete: { handlePhotoItemActionSelection("removePhoto") },
                onReplace: { handlePhotoItemActionSelection("replacePhoto") },
                onCaption: { handlePhotoItemActionSelection("addPhotoCaption") },
                onCopyright: { handlePhotoItemActionSelection("addPhotoCopyright") }
            )
        }
        .fullScreenCover(isPresented: $showsFileMediaActionSheet) {
            ComposerFileMediaActionsView(
                onBack: { showsFileMediaActionSheet = false },
                onDelete: { handleFileMediaActionSelection("removeMedia") },
                onReplace: { handleFileMediaActionSelection("replaceMedia") },
                onCaption: { handleFileMediaActionSelection("addCaption") },
                onTeaserImage: { handleFileMediaActionSelection("addTeaser") }
            )
        }
        .fullScreenCover(isPresented: $showsTeaserActionSheet) {
            ComposerTeaserImageActionsView(
                onBack: { showsTeaserActionSheet = false },
                onDelete: { handleTeaserActionSelection("removeTeaser") },
                onReplace: { handleTeaserActionSelection("replaceTeaser") },
                onCopyright: { handleTeaserActionSelection("addTeaserCopyright") }
            )
        }
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
                    onClose: { focusedPhotoItemID = nil }
                )
            }
        }
        .fullScreenCover(isPresented: $showsFileMediaDetail) {
            if let file = focusedFileMedia {
                ComposerFileMediaDetailView(
                    file: file,
                    onClose: { showsFileMediaDetail = false }
                )
            }
        }
        .fullScreenCover(isPresented: $showsTeaserDetail) {
            if let teaserImage = focusedTeaserImage {
                ComposerTeaserDetailView(
                    teaserImage: teaserImage,
                    onClose: { showsTeaserDetail = false }
                )
            }
        }
        .photosPicker(
            isPresented: photoPickerPresentation,
            selection: $selectedPhotoPickerItem,
            matching: .images
        )
        .photosPicker(
            isPresented: videoPickerPresentation,
            selection: $selectedVideoPickerItem,
            matching: .videos
        )
        .photosPicker(
            isPresented: $showsTeaserImagePicker,
            selection: $selectedTeaserPickerItem,
            matching: .images
        )
        .fileImporter(
            isPresented: fileImporterPresentation,
            allowedContentTypes: fileImporterAllowedContentTypes,
            allowsMultipleSelection: false,
            onCompletion: handleFileImporterCompletion
        )
        .onChange(of: selectedPhotoPickerItem) { _, newItem in
            handlePhotosPickerSelection(newItem, kind: .photo)
        }
        .onChange(of: selectedVideoPickerItem) { _, newItem in
            handlePhotosPickerSelection(newItem, kind: .video)
        }
        .onChange(of: selectedTeaserPickerItem) { _, newItem in
            handleTeaserImagePickerSelection(newItem)
        }
    }

    private func binding(for kind: ChannelCardTextFieldKind) -> Binding<String> {
        Binding(
            get: { viewModel.textValue(for: kind) },
            set: { viewModel.updateText($0, for: kind) }
        )
    }

    private var photoPickerPresentation: Binding<Bool> {
        Binding(
            get: { showsPhotoPicker },
            set: { isPresented in
                showsPhotoPicker = isPresented
                if !isPresented {
                    DispatchQueue.main.async {
                        if selectedPhotoPickerItem == nil {
                            replacingPhotoItemID = nil
                        }
                    }
                }
            }
        )
    }

    private var videoPickerPresentation: Binding<Bool> {
        Binding(
            get: { showsVideoPicker },
            set: { isPresented in
                showsVideoPicker = isPresented
            }
        )
    }

    private var fileImporterPresentation: Binding<Bool> {
        Binding(
            get: { showsFileImporter },
            set: { isPresented in
                showsFileImporter = isPresented
            }
        )
    }

    private var fileImporterAllowedContentTypes: [UTType] {
        switch fileImportKind {
        case .audio:
            return audioImporterContentTypes
        case .pdf:
            return [.pdf]
        case .video:
            return [.movie]
        case .photo:
            return [.image]
        case nil:
            return [.item]
        }
    }

    private var audioImporterContentTypes: [UTType] {
        var contentTypes: [UTType] = [.audio]
        if let mp3Type = UTType(filenameExtension: "mp3"), !contentTypes.contains(mp3Type) {
            contentTypes.append(mp3Type)
        }
        return contentTypes
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
                minimumHeight: 46
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
            minimumHeight: 16,
            textInsets: .zero
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
        case .audio:
            fileImportKind = .audio
            showsFileImporter = true
        case .pdf:
            fileImportKind = .pdf
            showsFileImporter = true
        case .text, .headline, .subheadline, .source:
            viewModel.applyInsertion(insertion)
            focusTextField(insertion.textFieldKind)
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
            showsPhotoPicker = true
        }
    }

    private func handlePhotosPickerSelection(_ item: PhotosPickerItem?, kind: ChannelCardMediaKind) {
        guard let item else {
            return
        }

        Task { @MainActor in
            defer {
                if kind == .photo {
                    selectedPhotoPickerItem = nil
                    showsPhotoPicker = false
                } else if kind == .video {
                    selectedVideoPickerItem = nil
                    showsVideoPicker = false
                }
            }

            let fileExtension = photoLibraryFileExtension(for: item, kind: kind)
            let fallbackTitle = kind == .photo ? "Photo.\(fileExtension)" : "Video.\(fileExtension)"
            if kind == .video,
               let pickedVideo = try? await item.loadTransferable(type: ComposerPickedVideo.self) {
                viewModel.selectPickedFile(
                    kind: .video,
                    displayTitle: pickedVideo.fileURL.lastPathComponent,
                    fileURL: pickedVideo.fileURL
                )
                return
            }

            guard let data = try? await item.loadTransferable(type: Data.self) else {
                return
            }

            guard let fileURL = try? ComposerPickedMediaStorage.save(
                data: data,
                suggestedFilename: fallbackTitle
            ) else {
                return
            }

            switch kind {
            case .photo:
                if let replacingPhotoItemID {
                    viewModel.replacePickedPhoto(
                        id: replacingPhotoItemID,
                        displayTitle: fileURL.lastPathComponent,
                        fileURL: fileURL
                    )
                } else {
                    viewModel.addPickedPhoto(displayTitle: fileURL.lastPathComponent, fileURL: fileURL)
                }
            case .video:
                viewModel.selectPickedFile(kind: .video, displayTitle: fileURL.lastPathComponent, fileURL: fileURL)
            case .audio, .pdf:
                return
            }
        }
    }

    private func handleTeaserImagePickerSelection(_ item: PhotosPickerItem?) {
        guard let item else {
            return
        }

        Task { @MainActor in
            defer {
                selectedTeaserPickerItem = nil
                showsTeaserImagePicker = false
            }

            guard let data = try? await item.loadTransferable(type: Data.self) else {
                return
            }

            let fileExtension = photoLibraryFileExtension(for: item, kind: .photo)
            let fallbackTitle = "Teaser image.\(fileExtension)"
            guard let fileURL = try? ComposerPickedMediaStorage.save(
                data: data,
                suggestedFilename: fallbackTitle
            ) else {
                return
            }

            viewModel.addOrReplaceTeaserImage(
                displayTitle: fileURL.lastPathComponent,
                fileURL: fileURL
            )
        }
    }

    private func handleFileImporterCompletion(_ result: Result<[URL], Error>) {
        guard let kind = fileImportKind else {
            return
        }

        defer {
            fileImportKind = nil
            showsFileImporter = false
        }

        guard case let .success(urls) = result, let sourceURL = urls.first else {
            return
        }

        let hasScopedAccess = sourceURL.startAccessingSecurityScopedResource()
        defer {
            if hasScopedAccess {
                sourceURL.stopAccessingSecurityScopedResource()
            }
        }

        guard let fileURL = try? ComposerPickedMediaStorage.copyFile(from: sourceURL) else {
            return
        }

        viewModel.selectPickedFile(
            kind: kind,
            displayTitle: sourceURL.lastPathComponent,
            fileURL: fileURL
        )
    }

    private func photoLibraryFileExtension(
        for item: PhotosPickerItem,
        kind: ChannelCardMediaKind
    ) -> String {
        let supportedExtensions = item.supportedContentTypes.compactMap(\.preferredFilenameExtension)
        if let fileExtension = supportedExtensions.first(where: { !$0.isEmpty }) {
            return fileExtension
        }

        return kind == .video ? "mp4" : "jpg"
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

    private func handleTextFieldBackspaceWhenEmpty(_ kind: ChannelCardTextFieldKind) {
        let wasFocusedFieldRemoved = viewModel.fieldSupportsRemoval(kind)
        viewModel.handleBackspaceOnEmptyField(kind)

        if wasFocusedFieldRemoved {
            focusTextField(firstAvailableTextFieldKind)
        }
    }

    private func focusTextField(_ kind: ChannelCardTextFieldKind?) {
        DispatchQueue.main.async {
            focusedTextFieldKind = kind
        }
    }

    private func clearFocusedTextField() {
        focusedTextFieldKind = nil
    }

    private func focusInitialTextField() {
        let preferredField: ChannelCardTextFieldKind? = viewModel.visibleTextFieldKinds.contains(.text)
            ? .text
            : firstAvailableTextFieldKind

        focusTextField(preferredField)
    }

    private var firstAvailableTextFieldKind: ChannelCardTextFieldKind? {
        [.headline, .subheadline, .text, .source].first {
            viewModel.visibleTextFieldKinds.contains($0)
        }
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
        case "replaceMedia":
            replaceCurrentFileMedia()
            return
        case "addTeaser", "replaceTeaser":
            presentTeaserImagePicker()
            return
        case "addTeaserCopyright":
            viewModel.showTeaserCopyrightField()
        case "removeTeaser":
            viewModel.removeTeaserImage()
        case "removeMedia":
            viewModel.removeMedia()
        default:
            break
        }

        showsFileMediaActionSheet = false
    }

    private func presentTeaserImagePicker() {
        showsFileMediaActionSheet = false
        showsTeaserActionSheet = false

        DispatchQueue.main.async {
            showsTeaserImagePicker = true
        }
    }

    private func replaceCurrentFileMedia() {
        guard case let .file(file)? = viewModel.media else {
            showsFileMediaActionSheet = false
            return
        }

        showsFileMediaActionSheet = false

        DispatchQueue.main.async {
            switch file.kind {
            case .photo:
                break
            case .video:
                showsVideoPicker = true
            case .audio, .pdf:
                fileImportKind = file.kind
                showsFileImporter = true
            }
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
            presentTeaserImagePicker()
            return
        case "removeTeaser":
            viewModel.removeTeaserImage()
        default:
            break
        }

        showsTeaserActionSheet = false
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
            set: { viewModel.updateTeaserCopyright(normalizedCopyrightInput($0)) }
        )
    }

    private func handlePhotoItemActionSelection(_ selectedID: String) {
        guard let selectedPhotoItemID else {
            return
        }

        switch selectedID {
        case "replacePhoto":
            replacingPhotoItemID = selectedPhotoItemID
            self.selectedPhotoItemID = nil
            DispatchQueue.main.async {
                showsPhotoPicker = true
            }
            return
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

    private func photoCaptionBinding(for photoID: String) -> Binding<String> {
        Binding(
            get: { viewModel.photoCaptionText(id: photoID) },
            set: { viewModel.updatePhotoCaption($0, id: photoID) }
        )
    }

    private func photoCopyrightBinding(for photoID: String) -> Binding<String> {
        Binding(
            get: { viewModel.photoCopyrightText(id: photoID) },
            set: { viewModel.updatePhotoCopyright(normalizedCopyrightInput($0), id: photoID) }
        )
    }

    private func normalizedCopyrightInput(_ value: String) -> String {
        guard !value.isEmpty else {
            return value
        }

        if value.hasPrefix("© ") {
            return value
        }

        if value == "©" {
            return "© "
        }

        if value.hasPrefix("©") {
            return "© " + value.dropFirst().trimmingCharacters(in: .whitespaces)
        }

        return "© " + value
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

private enum ComposerPickedMediaStorage {
    static func save(data: Data, suggestedFilename: String) throws -> URL {
        let destinationURL = try uniqueDestinationURL(suggestedFilename: suggestedFilename)
        try data.write(to: destinationURL, options: .atomic)
        return destinationURL
    }

    static func copyFile(from sourceURL: URL) throws -> URL {
        let destinationURL = try uniqueDestinationURL(suggestedFilename: sourceURL.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try FileManager.default.removeItem(at: destinationURL)
        }
        try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
        return destinationURL
    }

    private static func uniqueDestinationURL(suggestedFilename: String) throws -> URL {
        let directoryURL = try mediaDirectoryURL()
        let sanitizedFilename = sanitizedFilename(suggestedFilename)
        let uniqueFilename = "\(UUID().uuidString)-\(sanitizedFilename)"
        return directoryURL.appendingPathComponent(uniqueFilename, isDirectory: false)
    }

    private static func mediaDirectoryURL() throws -> URL {
        let baseURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directoryURL = baseURL.appendingPathComponent("TchopComposerMedia", isDirectory: true)
        try FileManager.default.createDirectory(
            at: directoryURL,
            withIntermediateDirectories: true
        )
        return directoryURL
    }

    private static func sanitizedFilename(_ filename: String) -> String {
        let fallbackFilename = "media"
        let trimmedFilename = filename.trimmingCharacters(in: .whitespacesAndNewlines)
        let candidate = trimmedFilename.isEmpty ? fallbackFilename : trimmedFilename
        let invalidCharacters = CharacterSet(charactersIn: "/\\:")

        return candidate
            .components(separatedBy: invalidCharacters)
            .joined(separator: "-")
    }
}

private struct ComposerPickedVideo: Transferable {
    let fileURL: URL

    static var transferRepresentation: some TransferRepresentation {
        FileRepresentation(contentType: .movie) { video in
            SentTransferredFile(video.fileURL)
        } importing: { receivedFile in
            let fileURL = try ComposerPickedMediaStorage.copyFile(from: receivedFile.file)
            return ComposerPickedVideo(fileURL: fileURL)
        }
    }
}

private struct ComposerMediaPreview: View {
    let media: ChannelCardMediaContent
    let showsFileCaptionField: Bool
    @Binding var fileCaptionText: String
    let fileCaptionInputStyle: ComposerTextInputStyle
    let onFileCaptionFocus: () -> Void
    let onFileCaptionDeleteBackwardWhenEmpty: () -> Void
    let showsTeaserCopyrightField: Bool
    @Binding var teaserCopyrightText: String
    let teaserCopyrightInputStyle: ComposerTextInputStyle
    let onTeaserCopyrightFocus: () -> Void
    let onTeaserCopyrightDeleteBackwardWhenEmpty: () -> Void
    let onTeaserMoreTap: () -> Void
    let onTeaserTap: () -> Void
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
                ComposerVideoMediaView(
                    file: file,
                    showsCaptionField: showsFileCaptionField,
                    captionText: $fileCaptionText,
                    captionInputStyle: fileCaptionInputStyle,
                    onCaptionFocus: onFileCaptionFocus,
                    onCaptionDeleteBackwardWhenEmpty: onFileCaptionDeleteBackwardWhenEmpty,
                    showsTeaserCopyrightField: showsTeaserCopyrightField,
                    teaserCopyrightText: $teaserCopyrightText,
                    teaserCopyrightInputStyle: teaserCopyrightInputStyle,
                    onTeaserCopyrightFocus: onTeaserCopyrightFocus,
                    onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
                    onTeaserMoreTap: onTeaserMoreTap,
                    onTeaserTap: onTeaserTap,
                    onMoreTap: onFileMediaMoreTap,
                    onTap: onFileMediaTap
                )
            case .audio:
                ComposerAudioMediaView(
                    file: file,
                    showsCaptionField: showsFileCaptionField,
                    captionText: $fileCaptionText,
                    captionInputStyle: fileCaptionInputStyle,
                    onCaptionFocus: onFileCaptionFocus,
                    onCaptionDeleteBackwardWhenEmpty: onFileCaptionDeleteBackwardWhenEmpty,
                    showsTeaserCopyrightField: showsTeaserCopyrightField,
                    teaserCopyrightText: $teaserCopyrightText,
                    teaserCopyrightInputStyle: teaserCopyrightInputStyle,
                    onTeaserCopyrightFocus: onTeaserCopyrightFocus,
                    onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
                    onTeaserMoreTap: onTeaserMoreTap,
                    onTeaserTap: onTeaserTap,
                    onMoreTap: onFileMediaMoreTap,
                    onTap: onFileMediaTap
                )
            case .pdf:
                ComposerPDFMediaView(
                    file: file,
                    showsCaptionField: showsFileCaptionField,
                    captionText: $fileCaptionText,
                    captionInputStyle: fileCaptionInputStyle,
                    onCaptionFocus: onFileCaptionFocus,
                    onCaptionDeleteBackwardWhenEmpty: onFileCaptionDeleteBackwardWhenEmpty,
                    showsTeaserCopyrightField: showsTeaserCopyrightField,
                    teaserCopyrightText: $teaserCopyrightText,
                    teaserCopyrightInputStyle: teaserCopyrightInputStyle,
                    onTeaserCopyrightFocus: onTeaserCopyrightFocus,
                    onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
                    onTeaserMoreTap: onTeaserMoreTap,
                    onTeaserTap: onTeaserTap,
                    onMoreTap: onFileMediaMoreTap,
                    onTap: onFileMediaTap
                )
            }
        }
    }
}

private struct ComposerPhotoStripView: View {
    let items: [ChannelCardPhotoItem]
    let onMoreTap: (String) -> Void
    let onTap: (String) -> Void

    var body: some View {
        VStack(spacing: 10) {
            ForEach(items) { item in
                ComposerPhotoStripItemView(
                    item: item,
                    onMoreTap: { onMoreTap(item.id) },
                    onTap: { onTap(item.id) }
                )
            }
        }
    }
}

private struct ComposerPhotoStripItemView: View {
    let item: ChannelCardPhotoItem
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                ComposerPhotoPreviewContent(item: item)
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .contentShape(RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous))
            }
            .buttonStyle(.plain)

            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)
                    .frame(width: 36, height: 36)
                    .background(.white.opacity(0.78))
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .frame(width: 56, height: 56)
            .contentShape(Circle())
            .padding(.top, 8)
            .padding(.trailing, 8)
            .zIndex(1)
        }
    }
}

private struct ComposerPhotoPreviewContent: View {
    let item: ChannelCardPhotoItem

    private var image: UIImage? {
        guard let fileURL = item.fileURL else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        if let image {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 240)
                    .clipped()

                photoMetadataOverlay
            }
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous))
        } else {
            VStack(spacing: AppSpacing.xs) {
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 28, weight: .semibold))
                    .foregroundStyle(AppTheme.textSecondary)

                photoMetadataText
            }
            .frame(maxWidth: .infinity)
            .frame(height: 240)
            .background(AppTheme.surfaceSecondary)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.compactCard, style: .continuous))
        }
    }

    @ViewBuilder
    private var photoMetadataOverlay: some View {
        if hasMetadata {
            VStack(spacing: AppSpacing.xxs) {
                photoMetadataText
            }
            .padding(AppSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(.black.opacity(0.38))
        }
    }

    @ViewBuilder
    private var photoMetadataText: some View {
        if let copyright = item.copyright, !copyright.isEmpty {
            Text(copyright)
                .font(AppTypography.label)
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.sm)
        }

        if let caption = item.caption, !caption.isEmpty {
            Text(caption)
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textTertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppSpacing.sm)
        }
    }

    private var hasMetadata: Bool {
        let hasCaption = item.caption?.isEmpty == false
        let hasCopyright = item.copyright?.isEmpty == false
        return hasCaption || hasCopyright
    }
}

private struct ComposerVideoMediaView: View {
    let file: ChannelCardFileMediaContent
    let showsCaptionField: Bool
    @Binding var captionText: String
    let captionInputStyle: ComposerTextInputStyle
    let onCaptionFocus: () -> Void
    let onCaptionDeleteBackwardWhenEmpty: () -> Void
    let showsTeaserCopyrightField: Bool
    @Binding var teaserCopyrightText: String
    let teaserCopyrightInputStyle: ComposerTextInputStyle
    let onTeaserCopyrightFocus: () -> Void
    let onTeaserCopyrightDeleteBackwardWhenEmpty: () -> Void
    let onTeaserMoreTap: () -> Void
    let onTeaserTap: () -> Void
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(
            file: file,
            showsCaptionField: showsCaptionField,
            captionText: $captionText,
            captionInputStyle: captionInputStyle,
            onCaptionFocus: onCaptionFocus,
            onCaptionDeleteBackwardWhenEmpty: onCaptionDeleteBackwardWhenEmpty,
            showsTeaserCopyrightField: showsTeaserCopyrightField,
            teaserCopyrightText: $teaserCopyrightText,
            teaserCopyrightInputStyle: teaserCopyrightInputStyle,
            onTeaserCopyrightFocus: onTeaserCopyrightFocus,
            onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
            onTeaserMoreTap: onTeaserMoreTap,
            onTeaserTap: onTeaserTap,
            onMoreTap: onMoreTap,
            onTap: onTap
        )
    }
}

private struct ComposerAudioMediaView: View {
    let file: ChannelCardFileMediaContent
    let showsCaptionField: Bool
    @Binding var captionText: String
    let captionInputStyle: ComposerTextInputStyle
    let onCaptionFocus: () -> Void
    let onCaptionDeleteBackwardWhenEmpty: () -> Void
    let showsTeaserCopyrightField: Bool
    @Binding var teaserCopyrightText: String
    let teaserCopyrightInputStyle: ComposerTextInputStyle
    let onTeaserCopyrightFocus: () -> Void
    let onTeaserCopyrightDeleteBackwardWhenEmpty: () -> Void
    let onTeaserMoreTap: () -> Void
    let onTeaserTap: () -> Void
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(
            file: file,
            showsCaptionField: showsCaptionField,
            captionText: $captionText,
            captionInputStyle: captionInputStyle,
            onCaptionFocus: onCaptionFocus,
            onCaptionDeleteBackwardWhenEmpty: onCaptionDeleteBackwardWhenEmpty,
            showsTeaserCopyrightField: showsTeaserCopyrightField,
            teaserCopyrightText: $teaserCopyrightText,
            teaserCopyrightInputStyle: teaserCopyrightInputStyle,
            onTeaserCopyrightFocus: onTeaserCopyrightFocus,
            onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
            onTeaserMoreTap: onTeaserMoreTap,
            onTeaserTap: onTeaserTap,
            onMoreTap: onMoreTap,
            onTap: onTap
        )
    }
}

private struct ComposerPDFMediaView: View {
    let file: ChannelCardFileMediaContent
    let showsCaptionField: Bool
    @Binding var captionText: String
    let captionInputStyle: ComposerTextInputStyle
    let onCaptionFocus: () -> Void
    let onCaptionDeleteBackwardWhenEmpty: () -> Void
    let showsTeaserCopyrightField: Bool
    @Binding var teaserCopyrightText: String
    let teaserCopyrightInputStyle: ComposerTextInputStyle
    let onTeaserCopyrightFocus: () -> Void
    let onTeaserCopyrightDeleteBackwardWhenEmpty: () -> Void
    let onTeaserMoreTap: () -> Void
    let onTeaserTap: () -> Void
    let onMoreTap: () -> Void
    let onTap: () -> Void

    var body: some View {
        ComposerFileMediaPreviewView(
            file: file,
            showsCaptionField: showsCaptionField,
            captionText: $captionText,
            captionInputStyle: captionInputStyle,
            onCaptionFocus: onCaptionFocus,
            onCaptionDeleteBackwardWhenEmpty: onCaptionDeleteBackwardWhenEmpty,
            showsTeaserCopyrightField: showsTeaserCopyrightField,
            teaserCopyrightText: $teaserCopyrightText,
            teaserCopyrightInputStyle: teaserCopyrightInputStyle,
            onTeaserCopyrightFocus: onTeaserCopyrightFocus,
            onTeaserCopyrightDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty,
            onTeaserMoreTap: onTeaserMoreTap,
            onTeaserTap: onTeaserTap,
            onMoreTap: onMoreTap,
            onTap: onTap
        )
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
    let showsCaptionField: Bool
    @Binding var captionText: String
    let captionInputStyle: ComposerTextInputStyle
    let onCaptionFocus: () -> Void
    let onCaptionDeleteBackwardWhenEmpty: () -> Void
    let showsTeaserCopyrightField: Bool
    @Binding var teaserCopyrightText: String
    let teaserCopyrightInputStyle: ComposerTextInputStyle
    let onTeaserCopyrightFocus: () -> Void
    let onTeaserCopyrightDeleteBackwardWhenEmpty: () -> Void
    let onTeaserMoreTap: () -> Void
    let onTeaserTap: () -> Void
    let onMoreTap: () -> Void
    let onTap: () -> Void

    private var presentation: ComposerFileMediaPresentation {
        ComposerFileMediaPresentation(file: file)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 0) {
                if let teaserImage = file.teaserImage {
                    ComposerFileMediaInlineTeaserView(
                        teaserImage: teaserImage,
                        onMoreTap: onTeaserMoreTap,
                        onTap: onTeaserTap
                    )
                    .padding(.horizontal, ComposerFileMediaDraftRowLayout.contentHorizontalPadding)
                    .padding(.top, ComposerFileMediaDraftRowLayout.contentVerticalPadding)

                    if showsTeaserCopyrightField || !teaserCopyrightText.isEmpty {
                        ComposerTextInputView(
                            text: $teaserCopyrightText,
                            placeholder: "© Copyright text",
                            style: teaserCopyrightInputStyle,
                            onFocus: onTeaserCopyrightFocus,
                            onDeleteBackwardWhenEmpty: onTeaserCopyrightDeleteBackwardWhenEmpty
                        )
                        .padding(.horizontal, ComposerFileMediaDraftRowLayout.contentHorizontalPadding)
                        .padding(.top, ComposerFileMediaDraftRowLayout.teaserCopyrightTopPadding)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                    }

                    Color.clear
                        .frame(height: ComposerFileMediaDraftRowLayout.teaserBottomPadding)
                }

                ZStack(alignment: .topTrailing) {
                    Button(action: onTap) {
                        fileSummaryRow
                    }
                    .buttonStyle(.plain)

                    fileMoreButton
                }

                if showsCaptionField || !captionText.isEmpty {
                    ComposerTextInputView(
                        text: $captionText,
                        placeholder: "Add caption",
                        style: captionInputStyle,
                        onFocus: onCaptionFocus,
                        onDeleteBackwardWhenEmpty: onCaptionDeleteBackwardWhenEmpty
                    )
                    .padding(.horizontal, ComposerFileMediaDraftRowLayout.contentHorizontalPadding)
                    .padding(.bottom, ComposerFileMediaDraftRowLayout.captionBottomPadding)
                    .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(ComposerFileMediaDraftRowLayout.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: ComposerFileMediaDraftRowLayout.cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: ComposerFileMediaDraftRowLayout.cornerRadius, style: .continuous)
                    .stroke(ComposerFileMediaDraftRowLayout.borderColor, lineWidth: 1)
            }

        }
        .animation(.easeInOut(duration: 0.18), value: showsCaptionField)
        .animation(.easeInOut(duration: 0.18), value: captionText)
        .animation(.easeInOut(duration: 0.18), value: showsTeaserCopyrightField)
        .animation(.easeInOut(duration: 0.18), value: teaserCopyrightText)
    }

    private var fileSummaryRow: some View {
        HStack(spacing: ComposerFileMediaDraftRowLayout.contentSpacing) {
            ComposerFileMediaDraftIcon(kind: file.kind)

            VStack(alignment: .leading, spacing: ComposerFileMediaDraftRowLayout.textSpacing) {
                Text(presentation.fileRowTitle)
                    .font(.system(size: ComposerFileMediaDraftRowLayout.titleFontSize, weight: .bold))
                    .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
                    .lineLimit(1)
                    .truncationMode(.middle)

                if let subtitle = presentation.fileRowSubtitle {
                    Text(subtitle)
                        .font(.system(size: ComposerFileMediaDraftRowLayout.subtitleFontSize, weight: .regular))
                        .foregroundStyle(ComposerFileMediaDraftRowLayout.subtitleColor)
                        .lineLimit(1)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer(minLength: ComposerFileMediaDraftRowLayout.moreButtonHitSize)
        }
        .padding(.leading, ComposerFileMediaDraftRowLayout.contentHorizontalPadding)
        .padding(.trailing, ComposerFileMediaDraftRowLayout.trailingReservedPadding)
        .frame(maxWidth: .infinity, alignment: .leading)
        .frame(height: ComposerFileMediaDraftRowLayout.rowHeight)
        .contentShape(RoundedRectangle(cornerRadius: ComposerFileMediaDraftRowLayout.cornerRadius, style: .continuous))
    }

    private var fileMoreButton: some View {
        Button(action: onMoreTap) {
            Image(systemName: "ellipsis")
                .font(.system(size: ComposerFileMediaDraftRowLayout.moreIconSize, weight: .bold))
                .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
                .frame(
                    width: ComposerFileMediaDraftRowLayout.moreButtonSize,
                    height: ComposerFileMediaDraftRowLayout.moreButtonSize
                )
                .background(ComposerFileMediaDraftRowLayout.moreButtonBackground)
                .clipShape(Circle())
        }
        .buttonStyle(.plain)
        .contentShape(Circle())
        .padding(.top, ComposerFileMediaDraftRowLayout.contentVerticalPadding)
        .padding(.trailing, ComposerFileMediaDraftRowLayout.moreButtonTrailingPadding)
        .zIndex(1)
    }
}

private enum ComposerFileMediaDraftRowLayout {
    static let rowHeight: CGFloat = 92
    static let iconSize: CGFloat = 60
    static let iconCornerRadius: CGFloat = 16
    static let cornerRadius: CGFloat = 16
    static let contentHorizontalPadding: CGFloat = 16
    static let contentVerticalPadding: CGFloat = 16
    static let trailingReservedPadding: CGFloat = 72
    static let moreButtonTrailingPadding: CGFloat = 16
    static let contentSpacing: CGFloat = 24
    static let textSpacing: CGFloat = 4
    static let teaserHeight: CGFloat = 240
    static let teaserCornerRadius: CGFloat = 14
    static let teaserCopyrightTopPadding: CGFloat = 8
    static let teaserBottomPadding: CGFloat = 16
    static let captionBottomPadding: CGFloat = 16
    static let moreButtonSize: CGFloat = 28
    static let moreButtonHitSize: CGFloat = 56
    static let moreIconSize: CGFloat = 14
    static let titleFontSize: CGFloat = 16
    static let subtitleFontSize: CGFloat = 16
    static let cardBackground = Color.white
    static let iconBackground = Color(red: 0.96, green: 0.96, blue: 0.98)
    static let moreButtonBackground = Color(red: 0.95, green: 0.95, blue: 0.97)
    static let borderColor = Color.black.opacity(0.10)
    static let titleColor = Color(red: 0.27, green: 0.27, blue: 0.38)
    static let subtitleColor = Color(red: 0.44, green: 0.44, blue: 0.46)
}

private struct ComposerFileMediaInlineTeaserView: View {
    let teaserImage: ChannelCardTeaserImageContent
    let onMoreTap: () -> Void
    let onTap: () -> Void

    private var image: UIImage? {
        guard let fileURL = teaserImage.fileURL else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: onTap) {
                Group {
                    if let image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                    } else {
                        ComposerTeaserPreviewContent(teaserImage: teaserImage)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(AppTheme.surfaceSecondary)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: ComposerFileMediaDraftRowLayout.teaserHeight)
                .clipped()
                .clipShape(
                    RoundedRectangle(
                        cornerRadius: ComposerFileMediaDraftRowLayout.teaserCornerRadius,
                        style: .continuous
                    )
                )
                .contentShape(
                    RoundedRectangle(
                        cornerRadius: ComposerFileMediaDraftRowLayout.teaserCornerRadius,
                        style: .continuous
                    )
                )
            }
            .buttonStyle(.plain)

            Button(action: onMoreTap) {
                Image(systemName: "ellipsis")
                    .font(.system(size: ComposerFileMediaDraftRowLayout.moreIconSize, weight: .bold))
                    .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
                    .frame(
                        width: ComposerFileMediaDraftRowLayout.moreButtonSize,
                        height: ComposerFileMediaDraftRowLayout.moreButtonSize
                    )
                    .background(ComposerFileMediaDraftRowLayout.moreButtonBackground)
                    .clipShape(Circle())
            }
            .buttonStyle(.plain)
            .contentShape(Circle())
            .padding(.top, ComposerFileMediaDraftRowLayout.contentVerticalPadding)
            .padding(.trailing, ComposerFileMediaDraftRowLayout.moreButtonTrailingPadding)
            .zIndex(1)
        }
    }
}

private struct ComposerFileMediaDraftIcon: View {
    let kind: ChannelCardMediaKind

    var body: some View {
        ZStack {
            RoundedRectangle(
                cornerRadius: ComposerFileMediaDraftRowLayout.iconCornerRadius,
                style: .continuous
            )
            .fill(ComposerFileMediaDraftRowLayout.iconBackground)

            switch kind {
            case .photo:
                Image(systemName: "photo")
                    .font(.system(size: 26, weight: .medium))
                    .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
            case .video:
                Image(systemName: "video")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
            case .audio:
                Image(systemName: "music.note")
                    .font(.system(size: 28, weight: .medium))
                    .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
            case .pdf:
                ZStack {
                    Image(systemName: "doc")
                        .font(.system(size: 32, weight: .medium))
                    Text("PDF")
                        .font(.system(size: 8, weight: .bold))
                        .offset(y: 2)
                }
                .foregroundStyle(ComposerFileMediaDraftRowLayout.titleColor)
            }
        }
        .frame(
            width: ComposerFileMediaDraftRowLayout.iconSize,
            height: ComposerFileMediaDraftRowLayout.iconSize
        )
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

    private var image: UIImage? {
        guard let fileURL = teaserImage.fileURL else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        if let image {
            ZStack(alignment: .bottom) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()

                if let copyright = teaserImage.copyright, !copyright.isEmpty {
                    Text(copyright)
                        .font(AppTypography.label)
                        .foregroundStyle(Color.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(AppSpacing.md)
                        .frame(maxWidth: .infinity)
                        .background(Color.black.opacity(0.38))
                }
            }
        } else {
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

    @State private var scale: CGFloat = 1
    @State private var baseScale: CGFloat = 1

    private var image: UIImage? {
        guard let fileURL = item.fileURL else {
            return nil
        }

        return UIImage(contentsOfFile: fileURL.path)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                VStack(spacing: AppSpacing.md) {
                    RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 320 * scale, height: 480 * scale)
                        .overlay {
                            ComposerPhotoDetailContent(item: item, image: image, scale: scale)
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

            ComposerDetailTopBar(onClose: onClose)
        }
    }
}

private struct ComposerPhotoDetailContent: View {
    let item: ChannelCardPhotoItem
    let image: UIImage?
    let scale: CGFloat

    var body: some View {
        ZStack(alignment: .bottom) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            } else {
                Image(systemName: "photo")
                    .font(.system(size: 56 * scale, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.9))
            }

            if hasMetadata {
                VStack(spacing: AppSpacing.sm) {
                    if let copyright = item.copyright, !copyright.isEmpty {
                        Text(copyright)
                            .font(.system(size: max(11, 13 * scale), weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                    }

                    if let caption = item.caption, !caption.isEmpty {
                        Text(caption)
                            .font(.system(size: max(13, 15 * scale), weight: .medium))
                            .foregroundStyle(Color.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(AppSpacing.lg)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.42))
            }
        }
    }

    private var hasMetadata: Bool {
        let hasCaption = item.caption?.isEmpty == false
        let hasCopyright = item.copyright?.isEmpty == false
        return hasCaption || hasCopyright
    }
}

private struct ComposerFileMediaDetailView: View {
    let file: ChannelCardFileMediaContent
    let onClose: () -> Void

    private var presentation: ComposerFileMediaPresentation {
        ComposerFileMediaPresentation(file: file)
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color.black.ignoresSafeArea()

            if let fileURL = file.fileURL {
                ComposerResolvedFileMediaDetail(file: file, fileURL: fileURL, presentation: presentation)
            } else {
                ComposerPlaceholderFileMediaDetail(file: file, presentation: presentation)
            }

            ComposerDetailTopBar(onClose: onClose)
        }
    }
}

private struct ComposerResolvedFileMediaDetail: View {
    let file: ChannelCardFileMediaContent
    let fileURL: URL
    let presentation: ComposerFileMediaPresentation

    var body: some View {
        switch file.kind {
        case .photo:
            ComposerPlaceholderFileMediaDetail(file: file, presentation: presentation)
        case .video:
            ComposerVideoDetailPlayer(file: file, fileURL: fileURL, presentation: presentation)
        case .audio:
            ComposerAudioDetailPlayer(file: file, fileURL: fileURL, presentation: presentation)
        case .pdf:
            ComposerPDFDetailView(file: file, fileURL: fileURL, presentation: presentation)
        }
    }
}

private struct ComposerPlaceholderFileMediaDetail: View {
    let file: ChannelCardFileMediaContent
    let presentation: ComposerFileMediaPresentation

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: AppSpacing.md) {
                ComposerFileMediaInfoCard(file: file, presentation: presentation)
                    .padding(.top, 80)
            }
            .padding(.horizontal, AppSpacing.screenHorizontal)
            .padding(.bottom, 40)
        }
    }
}

private struct ComposerFileMediaInfoCard: View {
    let file: ChannelCardFileMediaContent
    let presentation: ComposerFileMediaPresentation

    var body: some View {
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
    }
}

private struct ComposerVideoDetailPlayer: View {
    let file: ChannelCardFileMediaContent
    let fileURL: URL
    let presentation: ComposerFileMediaPresentation

    @State private var player: AVPlayer

    init(file: ChannelCardFileMediaContent, fileURL: URL, presentation: ComposerFileMediaPresentation) {
        self.file = file
        self.fileURL = fileURL
        self.presentation = presentation
        self._player = State(initialValue: AVPlayer(url: fileURL))
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            VideoPlayer(player: player)
                .frame(maxWidth: .infinity)
                .frame(height: 320)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

            ComposerFileMediaMetadata(file: file, presentation: presentation)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 80)
        .padding(.bottom, 40)
        .onDisappear {
            player.pause()
        }
    }
}

private struct ComposerAudioDetailPlayer: View {
    let file: ChannelCardFileMediaContent
    let fileURL: URL
    let presentation: ComposerFileMediaPresentation

    @State private var player: AVPlayer
    @State private var isPlaying = false

    init(file: ChannelCardFileMediaContent, fileURL: URL, presentation: ComposerFileMediaPresentation) {
        self.file = file
        self.fileURL = fileURL
        self.presentation = presentation
        self._player = State(initialValue: AVPlayer(url: fileURL))
    }

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .fill(Color.white.opacity(0.08))
                .frame(height: 240)
                .overlay {
                    VStack(spacing: AppSpacing.md) {
                        ComposerMediaKindBadge(title: presentation.kindTitle)

                        Button(action: togglePlayback) {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 72, weight: .semibold))
                                .foregroundStyle(Color.white)
                        }
                        .buttonStyle(.plain)

                        ComposerFileMediaMetadata(file: file, presentation: presentation)
                    }
                    .padding(.horizontal, AppSpacing.lg)
                }
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 80)
        .padding(.bottom, 40)
        .onDisappear {
            player.pause()
            isPlaying = false
        }
    }

    private func togglePlayback() {
        if isPlaying {
            player.pause()
        } else {
            player.play()
        }
        isPlaying.toggle()
    }
}

private struct ComposerPDFDetailView: View {
    let file: ChannelCardFileMediaContent
    let fileURL: URL
    let presentation: ComposerFileMediaPresentation

    var body: some View {
        VStack(spacing: AppSpacing.md) {
            ComposerPDFView(fileURL: fileURL)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))

            ComposerFileMediaMetadata(file: file, presentation: presentation)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.top, 80)
        .padding(.bottom, 40)
    }
}

private struct ComposerPDFView: UIViewRepresentable {
    let fileURL: URL

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()
        pdfView.autoScales = true
        pdfView.displayMode = .singlePageContinuous
        pdfView.displayDirection = .vertical
        pdfView.backgroundColor = .black
        pdfView.document = PDFDocument(url: fileURL)
        return pdfView
    }

    func updateUIView(_ pdfView: PDFView, context: Context) {
        if pdfView.document?.documentURL != fileURL {
            pdfView.document = PDFDocument(url: fileURL)
        }
    }
}

private struct ComposerFileMediaMetadata: View {
    let file: ChannelCardFileMediaContent
    let presentation: ComposerFileMediaPresentation

    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            ComposerMediaKindBadge(title: presentation.kindTitle)

            if let displayTitle = presentation.resolvedDisplayTitle {
                Text(displayTitle)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
            }

            if let caption = file.caption, !caption.isEmpty {
                Text(caption)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(Color.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
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

    var fileRowTitle: String {
        file.displayTitle
    }

    var fileRowSubtitle: String? {
        let sizeText = formattedFileSize

        if file.kind == .audio,
           let durationText = formattedAudioDuration {
            return [durationText, sizeText].compactMap { $0 }.joined(separator: ", ")
        }

        return sizeText
    }

    private var formattedFileSize: String? {
        guard let fileURL = file.fileURL,
              let resourceValues = try? fileURL.resourceValues(forKeys: [.fileSizeKey]),
              let fileSize = resourceValues.fileSize else {
            return nil
        }

        let megabytes = Double(fileSize) / 1_000_000
        return String(format: "%.1f Mb", megabytes)
    }

    private var formattedAudioDuration: String? {
        guard file.kind == .audio,
              let fileURL = file.fileURL else {
            return nil
        }

        guard let seconds = (try? AVAudioPlayer(contentsOf: fileURL))?.duration,
              seconds.isFinite,
              seconds > 0 else {
            return nil
        }

        let roundedSeconds = Int(seconds.rounded())
        return String(format: "%d:%02d", roundedSeconds / 60, roundedSeconds % 60)
    }
}

private struct ComposerTeaserDetailView: View {
    let teaserImage: ChannelCardTeaserImageContent
    let onClose: () -> Void

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

            ComposerDetailTopBar(onClose: onClose)
        }
    }
}

private struct ComposerDetailTopBar: View {
    let onClose: () -> Void

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

private enum ComposerChannelSelectionLayout {
    static let background = Color(red: 0.969, green: 0.969, blue: 0.969)
    static let sectionBackground = Color.white
    static let titleColor = Color(red: 0.29, green: 0.29, blue: 0.38)
    static let accentColor = Color(red: 1.0, green: 0.42, blue: 0.33)
    static let sectionHeaderColor = Color(red: 0.47, green: 0.47, blue: 0.52)
    static let rowTextColor = Color(red: 0.13, green: 0.13, blue: 0.15)
    static let dividerColor = Color.black.opacity(0.08)
    static let horizontalInset: CGFloat = 16
    static let sectionTopPadding: CGFloat = 34
    static let sectionHeaderHorizontalPadding: CGFloat = 32
    static let sectionHeaderBottomPadding: CGFloat = 16
    static let sectionCornerRadius: CGFloat = 24
    static let rowHeight: CGFloat = 44
    static let rowHorizontalPadding: CGFloat = 32
    static let headerHeight: CGFloat = 58
    static let titleFontSize: CGFloat = 18
    static let doneFontSize: CGFloat = 16
    static let sectionHeaderFontSize: CGFloat = 12
    static let rowFontSize: CGFloat = 16
    static let checkFontSize: CGFloat = 20
}

private struct ComposerChannelSelectionView: View {
    let channels: [AppChannel]
    let selectedChannelID: String
    let onDone: () -> Void
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    Text(AppLocalization.text("composer.channelPicker.section.yourMixes"))
                        .font(.system(size: ComposerChannelSelectionLayout.sectionHeaderFontSize, weight: .regular))
                        .foregroundStyle(ComposerChannelSelectionLayout.sectionHeaderColor)
                        .padding(.horizontal, ComposerChannelSelectionLayout.sectionHeaderHorizontalPadding)
                        .padding(.bottom, ComposerChannelSelectionLayout.sectionHeaderBottomPadding)

                    VStack(spacing: 0) {
                        ForEach(channels.indices, id: \.self) { index in
                            let channel = channels[index]
                            ComposerChannelSelectionRow(
                                title: channel.title,
                                isSelected: channel.id == selectedChannelID,
                                showsDivider: index < channels.count - 1,
                                action: { onSelect(channel.id) }
                            )
                        }
                    }
                    .background(ComposerChannelSelectionLayout.sectionBackground)
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: ComposerChannelSelectionLayout.sectionCornerRadius,
                            style: .continuous
                        )
                    )
                    .padding(.horizontal, ComposerChannelSelectionLayout.horizontalInset)
                }
                .padding(.top, ComposerChannelSelectionLayout.sectionTopPadding)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .background(ComposerChannelSelectionLayout.background.ignoresSafeArea())
    }

    private var header: some View {
        ZStack {
            Text(AppLocalization.text("composer.channelPicker.title"))
                .font(.system(size: ComposerChannelSelectionLayout.titleFontSize, weight: .bold))
                .foregroundStyle(ComposerChannelSelectionLayout.titleColor)

            HStack {
                Spacer()

                Button(action: onDone) {
                    Text(AppLocalization.text("common.done"))
                        .font(.system(size: ComposerChannelSelectionLayout.doneFontSize, weight: .regular))
                        .foregroundStyle(ComposerChannelSelectionLayout.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal, ComposerChannelSelectionLayout.horizontalInset)
        }
        .frame(height: ComposerChannelSelectionLayout.headerHeight)
        .background(Color.white.ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(ComposerChannelSelectionLayout.dividerColor)
                .frame(height: 1)
        }
    }
}

private struct ComposerChannelSelectionRow: View {
    let title: String
    let isSelected: Bool
    let showsDivider: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppSpacing.sm) {
                Text(title)
                    .font(.system(size: ComposerChannelSelectionLayout.rowFontSize, weight: .regular))
                    .foregroundStyle(ComposerChannelSelectionLayout.rowTextColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)

                Spacer(minLength: 0)

                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.system(size: ComposerChannelSelectionLayout.checkFontSize, weight: .regular))
                        .foregroundStyle(ComposerChannelSelectionLayout.accentColor)
                }
            }
            .padding(.horizontal, ComposerChannelSelectionLayout.rowHorizontalPadding)
            .frame(height: ComposerChannelSelectionLayout.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(ComposerChannelSelectionLayout.dividerColor)
                    .padding(.leading, ComposerChannelSelectionLayout.rowHorizontalPadding)
                    .frame(height: 1)
            }
        }
    }
}

private enum ComposerPhotoActionsLayout {
    static let background = Color(red: 0.969, green: 0.969, blue: 0.969)
    static let sectionBackground = Color.white
    static let titleColor = Color(red: 0.29, green: 0.29, blue: 0.38)
    static let accentColor = Color(red: 1.0, green: 0.42, blue: 0.33)
    static let destructiveColor = Color(red: 1.0, green: 0.25, blue: 0.34)
    static let iconColor = Color(red: 0.29, green: 0.29, blue: 0.38)
    static let dividerColor = Color.black.opacity(0.08)
    static let horizontalInset: CGFloat = 16
    static let topPadding: CGFloat = 34
    static let sectionSpacing: CGFloat = 32
    static let sectionCornerRadius: CGFloat = 14
    static let rowHeight: CGFloat = 44
    static let rowHorizontalPadding: CGFloat = 34
    static let rowSpacing: CGFloat = 18
    static let iconWidth: CGFloat = 22
    static let iconSize: CGFloat = 20
    static let backIconSize: CGFloat = 19
}

private struct ComposerPhotoActionsView: View {
    let onBack: () -> Void
    let onDelete: () -> Void
    let onReplace: () -> Void
    let onCaption: () -> Void
    let onCopyright: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ComposerPhotoActionsLayout.sectionSpacing) {
                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Delete",
                            systemImageName: "trash",
                            titleColor: ComposerPhotoActionsLayout.destructiveColor,
                            iconColor: AppTheme.textPrimary,
                            showsDivider: true,
                            action: onDelete
                        )

                        ComposerPhotoActionRow(
                            title: "Replace",
                            systemImageName: "arrow.triangle.2.circlepath",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onReplace
                        )
                    }

                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Caption",
                            systemImageName: "line.3.horizontal",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: true,
                            action: onCaption
                        )

                        ComposerPhotoActionRow(
                            title: "Copyright text",
                            systemImageName: "c.circle",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onCopyright
                        )
                    }
                }
                .padding(.horizontal, ComposerPhotoActionsLayout.horizontalInset)
                .padding(.top, ComposerPhotoActionsLayout.topPadding)
            }
        }
        .background(ComposerPhotoActionsLayout.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Actions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ComposerPhotoActionsLayout.titleColor)

                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: ComposerPhotoActionsLayout.backIconSize, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundStyle(ComposerPhotoActionsLayout.accentColor)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 54)

            Rectangle()
                .fill(ComposerPhotoActionsLayout.dividerColor)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

private struct ComposerFileMediaActionsView: View {
    let onBack: () -> Void
    let onDelete: () -> Void
    let onReplace: () -> Void
    let onCaption: () -> Void
    let onTeaserImage: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ComposerPhotoActionsLayout.sectionSpacing) {
                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Delete",
                            systemImageName: "trash",
                            titleColor: ComposerPhotoActionsLayout.destructiveColor,
                            iconColor: AppTheme.textPrimary,
                            showsDivider: true,
                            action: onDelete
                        )

                        ComposerPhotoActionRow(
                            title: "Replace",
                            systemImageName: "arrow.triangle.2.circlepath",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onReplace
                        )
                    }

                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Caption",
                            systemImageName: "line.3.horizontal",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: true,
                            action: onCaption
                        )

                        ComposerPhotoActionRow(
                            title: "Teaser image",
                            systemImageName: "photo",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onTeaserImage
                        )
                    }
                }
                .padding(.horizontal, ComposerPhotoActionsLayout.horizontalInset)
                .padding(.top, ComposerPhotoActionsLayout.topPadding)
            }
        }
        .background(ComposerPhotoActionsLayout.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Actions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ComposerPhotoActionsLayout.titleColor)

                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: ComposerPhotoActionsLayout.backIconSize, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundStyle(ComposerPhotoActionsLayout.accentColor)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 54)

            Rectangle()
                .fill(ComposerPhotoActionsLayout.dividerColor)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

private struct ComposerTeaserImageActionsView: View {
    let onBack: () -> Void
    let onDelete: () -> Void
    let onReplace: () -> Void
    let onCopyright: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: ComposerPhotoActionsLayout.sectionSpacing) {
                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Delete",
                            systemImageName: "trash",
                            titleColor: ComposerPhotoActionsLayout.destructiveColor,
                            iconColor: AppTheme.textPrimary,
                            showsDivider: true,
                            action: onDelete
                        )

                        ComposerPhotoActionRow(
                            title: "Replace",
                            systemImageName: "arrow.triangle.2.circlepath",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onReplace
                        )
                    }

                    ComposerPhotoActionsSection {
                        ComposerPhotoActionRow(
                            title: "Copyright text",
                            systemImageName: "c.circle",
                            titleColor: AppTheme.textPrimary,
                            iconColor: ComposerPhotoActionsLayout.iconColor,
                            showsDivider: false,
                            action: onCopyright
                        )
                    }
                }
                .padding(.horizontal, ComposerPhotoActionsLayout.horizontalInset)
                .padding(.top, ComposerPhotoActionsLayout.topPadding)
            }
        }
        .background(ComposerPhotoActionsLayout.background.ignoresSafeArea())
    }

    private var header: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Actions")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(ComposerPhotoActionsLayout.titleColor)

                HStack {
                    Button(action: onBack) {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: ComposerPhotoActionsLayout.backIconSize, weight: .semibold))
                            Text("Back")
                                .font(.system(size: 17, weight: .regular))
                        }
                        .foregroundStyle(ComposerPhotoActionsLayout.accentColor)
                    }
                    .buttonStyle(.plain)

                    Spacer()
                }
                .padding(.horizontal, 20)
            }
            .frame(height: 54)

            Rectangle()
                .fill(ComposerPhotoActionsLayout.dividerColor)
                .frame(height: 1)
        }
        .background(Color.white)
    }
}

private struct ComposerPhotoActionsSection<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(spacing: 0) {
            content
        }
        .background(ComposerPhotoActionsLayout.sectionBackground)
        .clipShape(
            RoundedRectangle(
                cornerRadius: ComposerPhotoActionsLayout.sectionCornerRadius,
                style: .continuous
            )
        )
    }
}

private struct ComposerPhotoActionRow: View {
    let title: String
    let systemImageName: String
    let titleColor: Color
    let iconColor: Color
    let showsDivider: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: ComposerPhotoActionsLayout.rowSpacing) {
                Image(systemName: systemImageName)
                    .font(.system(size: ComposerPhotoActionsLayout.iconSize, weight: .medium))
                    .foregroundStyle(iconColor)
                    .frame(width: ComposerPhotoActionsLayout.iconWidth, alignment: .center)

                Text(title)
                    .font(.system(size: 17, weight: .regular))
                    .foregroundStyle(titleColor)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, ComposerPhotoActionsLayout.rowHorizontalPadding)
            .frame(height: ComposerPhotoActionsLayout.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .overlay(alignment: .bottom) {
            if showsDivider {
                Rectangle()
                    .fill(ComposerPhotoActionsLayout.dividerColor)
                    .frame(height: 1)
            }
        }
    }
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
    static let maximumCharacterCount = 200
    static let defaultTextInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)

    let textFont: Font
    let placeholderFont: Font
    let uiTextFont: UIFont
    let textColor: Color
    let placeholderColor: Color
    let minimumHeight: CGFloat
    var textInsets = Self.defaultTextInsets
}

private struct SharedCardComposerHeaderView: View {
    let selectedChannelTitle: String
    let onCancel: () -> Void
    let onSelectChannel: () -> Void

    var body: some View {
        HStack {
            Button(action: onSelectChannel) {
                HStack(spacing: AppSpacing.xs) {
                    Text(AppLocalization.text("composer.header.postIn"))
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

            Button(AppLocalization.text("common.cancel"), action: onCancel)
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
    let isFocused: Bool
    let onFocus: () -> Void
    let onDeleteBackwardWhenEmpty: () -> Void

    @State private var dynamicHeight: CGFloat

    init(
        text: Binding<String>,
        placeholder: String,
        style: ComposerTextInputStyle,
        isFocused: Bool = false,
        onFocus: @escaping () -> Void = {},
        onDeleteBackwardWhenEmpty: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.style = style
        self.isFocused = isFocused
        self.onFocus = onFocus
        self.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        self._dynamicHeight = State(initialValue: style.minimumHeight)
    }

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .font(style.placeholderFont)
                    .foregroundStyle(style.placeholderColor)
                    .padding(.top, style.textInsets.top)
                    .padding(.leading, style.textInsets.left)
                    .allowsHitTesting(false)
            }

            ComposerTextViewRepresentable(
                text: $text,
                dynamicHeight: $dynamicHeight,
                font: style.uiTextFont,
                textColor: UIColor(style.textColor),
                minimumHeight: style.minimumHeight,
                textInsets: style.textInsets,
                maximumCharacterCount: ComposerTextInputStyle.maximumCharacterCount,
                isFocused: isFocused,
                onFocus: onFocus,
                onDeleteBackwardWhenEmpty: onDeleteBackwardWhenEmpty
            )
            .frame(maxWidth: .infinity, alignment: .leading)
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
    let textInsets: UIEdgeInsets
    let maximumCharacterCount: Int
    let isFocused: Bool
    let onFocus: () -> Void
    let onDeleteBackwardWhenEmpty: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(
            text: $text,
            dynamicHeight: $dynamicHeight,
            minimumHeight: minimumHeight,
            maximumCharacterCount: maximumCharacterCount,
            onFocus: onFocus
        )
    }

    func makeUIView(context: Context) -> DeleteAwareTextView {
        let textView = DeleteAwareTextView()
        textView.delegate = context.coordinator
        textView.backgroundColor = .clear
        textView.textContainerInset = textInsets
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainer.lineBreakMode = .byCharWrapping
        textView.textContainer.widthTracksTextView = true
        textView.isScrollEnabled = false
        textView.showsHorizontalScrollIndicator = false
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        textView.returnKeyType = .default
        textView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        textView.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        textView.font = font
        textView.textColor = textColor
        textView.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        textView.text = text
        context.coordinator.recalculateHeight(for: textView)
        return textView
    }

    func updateUIView(_ uiView: DeleteAwareTextView, context: Context) {
        context.coordinator.onFocus = onFocus
        let limitedText = String(text.prefix(maximumCharacterCount))
        if text != limitedText {
            DispatchQueue.main.async {
                self.text = limitedText
            }
        }
        if uiView.text != limitedText {
            uiView.text = limitedText
        }
        uiView.font = font
        uiView.textColor = textColor
        uiView.textContainerInset = textInsets
        uiView.onDeleteBackwardWhenEmpty = onDeleteBackwardWhenEmpty
        if isFocused && !uiView.isFirstResponder {
            DispatchQueue.main.async {
                uiView.becomeFirstResponder()
            }
        }
        context.coordinator.recalculateHeight(for: uiView)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        @Binding private var text: String
        @Binding private var dynamicHeight: CGFloat
        private let minimumHeight: CGFloat
        private let maximumCharacterCount: Int
        var onFocus: () -> Void

        init(
            text: Binding<String>,
            dynamicHeight: Binding<CGFloat>,
            minimumHeight: CGFloat,
            maximumCharacterCount: Int,
            onFocus: @escaping () -> Void
        ) {
            self._text = text
            self._dynamicHeight = dynamicHeight
            self.minimumHeight = minimumHeight
            self.maximumCharacterCount = maximumCharacterCount
            self.onFocus = onFocus
        }

        func textView(
            _ textView: UITextView,
            shouldChangeTextIn range: NSRange,
            replacementText: String
        ) -> Bool {
            guard let currentText = textView.text,
                  let stringRange = Range(range, in: currentText) else {
                return false
            }

            let replacedCharacterCount = currentText[stringRange].count
            let availableCharacterCount = maximumCharacterCount - currentText.count + replacedCharacterCount
            guard availableCharacterCount > 0 else {
                return replacementText.isEmpty
            }

            if replacementText.count <= availableCharacterCount {
                return true
            }

            let allowedReplacement = String(replacementText.prefix(availableCharacterCount))
            let limitedText = currentText.replacingCharacters(in: stringRange, with: allowedReplacement)
            textView.text = limitedText
            text = limitedText
            recalculateHeight(for: textView)
            return false
        }

        func textViewDidChange(_ textView: UITextView) {
            text = textView.text
            recalculateHeight(for: textView)
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            onFocus()
        }

        func recalculateHeight(for textView: UITextView) {
            let fittedHeight = textView.sizeThatFits(
                CGSize(width: textView.bounds.width, height: .greatestFiniteMagnitude)
            ).height

            // UITextView can report an inflated empty-state height while layout is settling.
            // Keep empty placeholders visually compact, but preserve dynamic growth once user types.
            let effectiveHeight: CGFloat
            if textView.text.isEmpty {
                effectiveHeight = min(fittedHeight, minimumHeight + 2)
            } else {
                effectiveHeight = fittedHeight
            }

            let resolvedHeight = max(minimumHeight, effectiveHeight)
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
