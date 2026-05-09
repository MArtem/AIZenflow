import SwiftUI

struct ShareExtensionRootView: View {
    enum State {
        case loading
        case signInRequired(message: String)
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
        case let .signInRequired(message):
            signInRequiredView(message: message)
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
                ProgressView("Preparing share…")
                Spacer(minLength: 0)
            }
            .padding(AppSpacing.xl)
            .navigationTitle("Share")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }

    private func signInRequiredView(message: String) -> some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: AppSpacing.lg) {
                Text("Open app to continue")
                    .font(AppTypography.sectionTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(message)
                    .font(AppTypography.bodyRegular)
                    .foregroundStyle(AppTheme.textSecondary)

                Button("Open app", action: onOpenApp)
                    .buttonStyle(.borderedProminent)

                Spacer(minLength: 0)
            }
            .padding(AppSpacing.xl)
            .background(AppTheme.surfacePrimary.ignoresSafeArea())
            .navigationTitle("Share")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
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
            .navigationTitle("Share")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close", action: onClose)
                }
            }
        }
    }
}
