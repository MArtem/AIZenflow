import Observation
import SwiftUI

struct FeedComposerView: View {
    @Bindable var viewModel: FeedComposerViewModel
    let onCancel: () -> Void
    let onPublish: () -> Void

    @State private var showsInsertionSheet = false
    @State private var showsChannelSheet = false

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                header
                ScrollView {
                    VStack(alignment: .leading, spacing: AppSpacing.md) {
                        composerField(
                            title: nil,
                            placeholder: ChannelCardTextFieldKind.text.placeholder,
                            text: $viewModel.text,
                            minimumHeight: 180
                        )

                        if viewModel.showsHeadlineField {
                            composerField(
                                title: ChannelCardTextFieldKind.headline.title,
                                placeholder: ChannelCardTextFieldKind.headline.placeholder,
                                text: $viewModel.headline
                            )
                        }

                        if viewModel.showsSubheadlineField {
                            composerField(
                                title: ChannelCardTextFieldKind.subheadline.title,
                                placeholder: ChannelCardTextFieldKind.subheadline.placeholder,
                                text: $viewModel.subheadline
                            )
                        }

                        if viewModel.showsSourceField {
                            composerField(
                                title: ChannelCardTextFieldKind.source.title,
                                placeholder: ChannelCardTextFieldKind.source.placeholder,
                                text: $viewModel.source
                            )
                        }

                        if let mediaKind = viewModel.mediaKind {
                            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                                .fill(AppTheme.surfaceSecondary)
                                .frame(height: 180)
                                .overlay {
                                    Text(mediaKind.rawValue.capitalized)
                                        .font(AppTypography.cardTitle)
                                        .foregroundStyle(AppTheme.textSecondary)
                                }
                        }
                    }
                    .padding(.horizontal, AppSpacing.screenHorizontal)
                    .padding(.top, AppSpacing.lg)
                    .padding(.bottom, 96)
                }
            }

            toolbar

            if showsInsertionSheet {
                bottomSheet(
                    title: "Add content",
                    items: viewModel.availableInsertions.map(\.title),
                    onSelect: { title in
                        if let insertion = viewModel.availableInsertions.first(where: { $0.title == title }) {
                            viewModel.applyInsertion(insertion)
                        }
                    },
                    onDismiss: { showsInsertionSheet = false }
                )
            }

            if showsChannelSheet {
                bottomSheet(
                    title: "Post in",
                    items: viewModel.availableChannels.map(\.title),
                    onSelect: { title in
                        if let channel = viewModel.availableChannels.first(where: { $0.title == title }) {
                            viewModel.selectChannel(id: channel.id)
                        }
                    },
                    onDismiss: { showsChannelSheet = false }
                )
            }
        }
        .background(AppTheme.canvasBackground.ignoresSafeArea())
    }

    private var header: some View {
        HStack {
            Button("Cancel", action: onCancel)
                .buttonStyle(.plain)
                .foregroundStyle(AppTheme.accent)

            Spacer()

            HStack(spacing: AppSpacing.xs) {
                Text("Post in")
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Button(action: { showsChannelSheet = true }) {
                    HStack(spacing: 4) {
                        Text(viewModel.selectedChannelTitle)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.accent)
                }
                .buttonStyle(.plain)
            }

            Spacer()
            Color.clear.frame(width: 52)
        }
        .padding(.horizontal, AppSpacing.screenHorizontal)
        .padding(.vertical, AppSpacing.md)
        .background(AppTheme.surfacePrimary)
    }

    private var toolbar: some View {
        HStack {
            Button(action: { showsInsertionSheet = true }) {
                HStack(spacing: AppSpacing.xs) {
                    Image(systemName: "plus")
                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundStyle(AppTheme.textPrimary)
            }
            .buttonStyle(.plain)

            Spacer()

            if viewModel.mediaKind == nil || viewModel.mediaKind == .photo {
                Button(action: { showsInsertionSheet = true }) {
                    Image(systemName: "photo")
                        .foregroundStyle(AppTheme.textPrimary)
                }
                .buttonStyle(.plain)
                .padding(.trailing, AppSpacing.lg)
            }

            Button(action: {
                guard viewModel.publish() != nil else { return }
                onPublish()
            }) {
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

    private func composerField(
        title: String?,
        placeholder: String,
        text: Binding<String>,
        minimumHeight: CGFloat = 64
    ) -> some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            if let title {
                Text(title)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)
            }

            ZStack(alignment: .topLeading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .font(AppTypography.body)
                        .foregroundStyle(AppTheme.textTertiary)
                        .padding(.top, 8)
                        .padding(.leading, 4)
                }

                TextEditor(text: text)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textPrimary)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minimumHeight)
                    .padding(.horizontal, -4)
            }
        }
    }

    private func bottomSheet(
        title: String,
        items: [String],
        onSelect: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) -> some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture(perform: onDismiss)

            VStack(alignment: .leading, spacing: 0) {
                Capsule(style: .continuous)
                    .fill(AppTheme.textTertiary.opacity(0.3))
                    .frame(width: 50, height: 5)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, AppSpacing.md)

                ForEach(items, id: \.self) { item in
                    Button {
                        onSelect(item)
                        onDismiss()
                    } label: {
                        Text(item)
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
