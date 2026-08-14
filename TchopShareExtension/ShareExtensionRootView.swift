import SwiftUI

/// Root SwiftUI surface for the share extension lifecycle.
///
/// Responsibilities:
/// Renders loading, sign-in-required, composer, and failure states from immutable extension state.
struct ShareExtensionRootView: View {
        /// Explicit extension UI state owned by `ShareViewController`.
enum State {
        case loading
        case signInRequired(message: String, openAppErrorMessage: String?)
        case composer(FeedComposerViewModel)
        case failed(title: String, message: String)
    }

    let state: State
    let onClose: () -> Void
    let onOpenApp: () -> Void
    let onPublish: () -> Void

    var body: some View {
        switch state {
        case .loading:
            loadingView
        case let .signInRequired(message, openAppErrorMessage):
            signInRequiredView(message: message, openAppErrorMessage: openAppErrorMessage)
        case let .composer(viewModel):
            SharedCardComposerView(
                viewModel: viewModel,
                onCancel: onClose,
                onPublish: onPublish
            )
        case let .failed(title, message):
            failureView(title: title, message: message)
        }
    }

    private var loadingView: some View {
        NavigationStack {
            VStack(spacing: AppSpacing.lg) {
                ProgressView(AppLocalization.text("shareExtension.loading.preparing"))
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.xl)
            .navigationTitle(AppLocalization.text("shareExtension.navigation.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalization.text("common.close"), action: onClose)
                }
            }
        }
    }

    private func signInRequiredView(
        message: String,
        openAppErrorMessage: String?
    ) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text(AppLocalization.text("shareExtension.signInRequired.title"))
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.bodyRegular)
                    .foregroundStyle(AppTheme.textSecondary)

                if let openAppErrorMessage {
                    Text(openAppErrorMessage)
                        .font(AppTypography.bodyRegular)
                        .foregroundStyle(AppTheme.destructive)
                }

                Button(AppLocalization.text("shareExtension.openApp"), action: onOpenApp)
                    .buttonStyle(.borderedProminent)

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.xl)
            .background(AppTheme.surfacePrimary.ignoresSafeArea())
            .navigationTitle(AppLocalization.text("shareExtension.navigation.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalization.text("common.close"), action: onClose)
                }
            }
        }
    }

    private func failureView(title: String, message: String) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text(title)
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.bodyRegular)
                    .foregroundStyle(AppTheme.textSecondary)

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.xl)
            .background(AppTheme.surfacePrimary.ignoresSafeArea())
            .navigationTitle(AppLocalization.text("shareExtension.navigation.title"))
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(AppLocalization.text("common.close"), action: onClose)
                }
            }
        }
    }
}
