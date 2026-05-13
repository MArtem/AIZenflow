import AuthenticationServices
import Observation
import SwiftUI

private enum LoginFieldFocus {
    case email
    case password
}

/// Authentication screen shown before entering the app shell.
///
/// The default app mode now follows a modern credential-first login pattern with:
/// - email + password
/// - inline validation
/// - password reveal toggle
/// - debounced validation feedback
/// - disabled submit until the form is valid
///
/// The ReqRes mode keeps its separate development-only registration action and demo guidance.
struct LoginScreenView: View {
    @Bindable var viewModel: LoginViewModel
    @FocusState private var focusedField: LoginFieldFocus?

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.formSection) {
                LoginHeroSectionView(
                    mode: viewModel.mode,
                    titleText: titleText,
                    subtitleText: subtitleText
                )

                if viewModel.mode == .defaultAppAuth {
                    LoginAppleSectionView(
                        isSubmitting: viewModel.isSubmitting,
                        onCompletion: viewModel.handleAppleSignInCompletion
                    )
                    LoginDividerView()
                }

                LoginCredentialCardView(
                    viewModel: viewModel,
                    focusedField: $focusedField,
                    formTitleText: formTitleText,
                    formSubtitleText: formSubtitleText,
                    emailPlaceholderText: emailPlaceholderText
                )

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.destructive)
                        .fixedSize(horizontal: false, vertical: true)
                }

                LoginActionSectionView(
                    mode: viewModel.mode,
                    isSubmitting: viewModel.isSubmitting,
                    canSubmit: viewModel.canSubmit,
                    primaryActionTitle: primaryActionTitle,
                    primaryActionIdentifier: primaryActionIdentifier,
                    onSubmit: viewModel.submit,
                    onRegistration: viewModel.submitRegistration
                )

                if viewModel.mode == .reqResDemoExternalAuth {
                    Text(
                        AppLocalization.text("login.external.reqresHint")
                    )
                    .font(AppTypography.label)
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, AppSpacing.xl)
            .padding(.top, AppSpacing.loginTopInset)
            .padding(.bottom, AppSpacing.loginBottomInset)
        }
        .background(LoginBackgroundView())
        .scrollDismissesKeyboard(.interactively)
    }

    private var titleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.title")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.title")
        }
    }

    private var subtitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.subtitle")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.subtitle")
        }
    }

    private var formTitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.form.title")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.form.title")
        }
    }

    private var formSubtitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.form.subtitle")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.form.subtitle")
        }
    }

    private var emailPlaceholderText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.emailPlaceholder")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.emailPlaceholder")
        }
    }

    private var primaryActionTitle: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.continueButton")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.signInButton")
        }
    }

    private var primaryActionIdentifier: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return "login.continueButton"
        case .reqResDemoExternalAuth:
            return "login.reqresSignInButton"
        }
    }

}

private struct LoginBackgroundView: View {
    var body: some View {
        LinearGradient(
            colors: [
                AppTheme.canvasBackground,
                AppTheme.surfaceSecondary.opacity(0.75),
                AppTheme.canvasBackground
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }
}

private struct LoginHeroSectionView: View {
    let mode: LoginScreenMode
    let titleText: String
    let subtitleText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: mode == .defaultAppAuth ? "person.crop.circle.badge.checkmark" : "network")
                .font(AppTypography.profileDisplay)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 58, height: 58)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
                .shadow(color: AppTheme.shadow.opacity(0.16), radius: 18, y: 8)
                .accessibilityHidden(true)

            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text(titleText)
                    .font(AppTypography.heroDisplay)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitleText)
                    .font(AppTypography.body)
                    .foregroundStyle(AppTheme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }
}

private struct LoginAppleSectionView: View {
    let isSubmitting: Bool
    let onCompletion: (Result<ASAuthorization, Error>) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                onCompletion(result)
            }
            .accessibilityIdentifier("login.appleButton")
            .accessibilityLabel(AppLocalization.text("accessibility.login.apple"))
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .disabled(isSubmitting)
            .opacity(isSubmitting ? 0.85 : 1)

#if targetEnvironment(simulator)
            Text(
                AppLocalization.text("login.apple.simulatorHint")
            )
            .font(AppTypography.label)
            .foregroundStyle(AppTheme.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
#endif
        }
    }
}

private struct LoginDividerView: View {
    var body: some View {
        HStack(spacing: AppSpacing.sm) {
            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)

            Text(AppLocalization.text("login.separator"))
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textTertiary)

            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)
        }
    }
}

private struct LoginCredentialCardView: View {
    @Bindable var viewModel: LoginViewModel
    let focusedField: FocusState<LoginFieldFocus?>.Binding
    let formTitleText: String
    let formSubtitleText: String
    let emailPlaceholderText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.cardSection) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formTitleText)
                    .font(AppTypography.cardTitle)
                    .foregroundStyle(AppTheme.textPrimary)

                Text(formSubtitleText)
                    .font(AppTypography.caption)
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 14) {
                LoginEmailFieldView(
                    viewModel: viewModel,
                    focusedField: focusedField,
                    emailPlaceholderText: emailPlaceholderText
                )
                LoginPasswordFieldView(
                    viewModel: viewModel,
                    focusedField: focusedField
                )
            }
        }
        .padding(AppSpacing.cardPadding)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: AppRadius.card, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow.opacity(0.12), radius: 18, y: 10)
    }
}

private struct LoginEmailFieldView: View {
    @Bindable var viewModel: LoginViewModel
    let focusedField: FocusState<LoginFieldFocus?>.Binding
    let emailPlaceholderText: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(AppLocalization.text("login.emailLabel"))
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textTertiary)

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "envelope")
                    .foregroundStyle(LoginFieldAppearance.tintColor(for: viewModel.emailValidationState))
                    .frame(width: 18)

                TextField(
                    emailPlaceholderText,
                    text: $viewModel.email
                )
                .accessibilityIdentifier("login.emailField")
                .accessibilityLabel(AppLocalization.text("login.emailLabel"))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
                .focused(focusedField, equals: .email)
                .submitLabel(.next)
                .disabled(viewModel.isSubmitting)
                .onSubmit {
                    focusedField.wrappedValue = .password
                }

                LoginValidationIconView(state: viewModel.emailValidationState)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous)
                    .stroke(LoginFieldAppearance.borderColor(for: viewModel.emailValidationState), lineWidth: 1.5)
            )

            if let helperText = viewModel.emailHelperText {
                LoginHelperTextView(
                    text: helperText,
                    color: LoginFieldAppearance.helperColor(for: viewModel.emailValidationState)
                )
            }
        }
    }
}

private struct LoginPasswordFieldView: View {
    @Bindable var viewModel: LoginViewModel
    let focusedField: FocusState<LoginFieldFocus?>.Binding

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            HStack {
                Text(AppLocalization.text("login.passwordLabel"))
                    .font(AppTypography.captionSemibold)
                    .foregroundStyle(AppTheme.textTertiary)

                Spacer()

                Button(action: viewModel.togglePasswordVisibility) {
                    Text(
                        viewModel.isPasswordVisible
                            ? AppLocalization.text("login.password.hide")
                            : AppLocalization.text("login.password.show")
                    )
                    .font(AppTypography.labelSemibold)
                    .foregroundStyle(AppTheme.accent)
                }
                .accessibilityIdentifier("login.passwordVisibilityButton")
                .accessibilityLabel(
                    viewModel.isPasswordVisible
                        ? AppLocalization.text("accessibility.login.hidePassword")
                        : AppLocalization.text("accessibility.login.showPassword")
                )
                .buttonStyle(.plain)
                .disabled(viewModel.isSubmitting)
            }

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "lock")
                    .foregroundStyle(LoginFieldAppearance.tintColor(for: viewModel.passwordValidationState))
                    .frame(width: 18)

                Group {
                    if viewModel.isPasswordVisible {
                        TextField(
                            AppLocalization.text("login.passwordPlaceholder"),
                            text: $viewModel.password
                        )
                    } else {
                        SecureField(
                            AppLocalization.text("login.passwordPlaceholder"),
                            text: $viewModel.password
                        )
                    }
                }
                .accessibilityIdentifier("login.passwordField")
                .accessibilityLabel(AppLocalization.text("login.passwordLabel"))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.password)
                .focused(focusedField, equals: .password)
                .submitLabel(.go)
                .disabled(viewModel.isSubmitting)
                .onSubmit {
                    viewModel.submit()
                }

                LoginValidationIconView(state: viewModel.passwordValidationState)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous)
                    .stroke(LoginFieldAppearance.borderColor(for: viewModel.passwordValidationState), lineWidth: 1.5)
            )

            LoginHelperTextView(
                text: viewModel.passwordHelperText ?? viewModel.passwordGuidanceText,
                color: LoginFieldAppearance.helperColor(for: viewModel.passwordValidationState)
            )
        }
    }
}

private struct LoginActionSectionView: View {
    let mode: LoginScreenMode
    let isSubmitting: Bool
    let canSubmit: Bool
    let primaryActionTitle: String
    let primaryActionIdentifier: String
    let onSubmit: () -> Void
    let onRegistration: () -> Void

    var body: some View {
        VStack(spacing: AppSpacing.sm) {
            LoginPrimaryButtonView(
                title: primaryActionTitle,
                identifier: primaryActionIdentifier,
                isSubmitting: isSubmitting,
                canSubmit: canSubmit,
                action: onSubmit
            )

            if mode == .reqResDemoExternalAuth {
                LoginSecondaryButtonView(
                    title: AppLocalization.text("login.external.registerButton"),
                    identifier: "login.reqresRegisterButton",
                    isSubmitting: isSubmitting,
                    action: onRegistration
                )
            }
        }
    }
}

private struct LoginPrimaryButtonView: View {
    let title: String
    let identifier: String
    let isSubmitting: Bool
    let canSubmit: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Group {
                if isSubmitting {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                } else {
                    HStack(spacing: 10) {
                        Text(title)
                            .font(AppTypography.actionTitle)

                        Image(systemName: "arrow.right")
                            .font(AppTypography.detailSemibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .foregroundStyle(AppTheme.accentOnColor)
            .background(canSubmit ? AppTheme.accent : AppTheme.textTertiary.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
        }
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
        .buttonStyle(.plain)
        .disabled(!canSubmit || isSubmitting)
        .opacity(isSubmitting ? 0.88 : 1)
    }
}

private struct LoginSecondaryButtonView: View {
    let title: String
    let identifier: String
    let isSubmitting: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(AppTypography.actionTitle)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(AppTheme.textPrimary)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
        }
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
        .buttonStyle(.plain)
        .disabled(isSubmitting)
        .opacity(isSubmitting ? 0.88 : 1)
    }
}

private struct LoginValidationIconView: View {
    let state: LoginFieldValidationState

    var body: some View {
        switch state {
        case .validating:
            ProgressView()
                .progressViewStyle(.circular)
                .tint(AppTheme.textTertiary)
        case .valid:
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(AppTheme.success)
                .accessibilityHidden(true)
        case .invalid:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(AppTheme.destructive)
                .accessibilityHidden(true)
        case .untouched:
            EmptyView()
        }
    }
}

private struct LoginHelperTextView: View {
    let text: String
    let color: Color

    var body: some View {
        Text(text)
            .font(AppTypography.label)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }
}

@MainActor
private enum LoginFieldAppearance {
    static func borderColor(for state: LoginFieldValidationState) -> Color {
        switch state {
        case .untouched:
            return AppTheme.borderSubtle
        case .validating:
            return AppTheme.accent.opacity(0.4)
        case .valid:
            return AppTheme.success.opacity(0.6)
        case .invalid:
            return AppTheme.destructive.opacity(0.85)
        }
    }

    static func tintColor(for state: LoginFieldValidationState) -> Color {
        switch state {
        case .untouched:
            return AppTheme.textTertiary
        case .validating:
            return AppTheme.accent
        case .valid:
            return AppTheme.success
        case .invalid:
            return AppTheme.destructive
        }
    }

    static func helperColor(for state: LoginFieldValidationState) -> Color {
        switch state {
        case .untouched:
            return AppTheme.textTertiary
        case .validating:
            return AppTheme.textSecondary
        case .valid:
            return AppTheme.success
        case .invalid:
            return AppTheme.destructive
        }
    }
}

#if DEBUG
#Preview("Login - Default Auth") {
    LoginScreenView(
        viewModel: ViewPreviewSupport.makeLoginViewModel(mode: .defaultAppAuth)
    )
}

#Preview("Login - ReqRes") {
    LoginScreenView(
        viewModel: ViewPreviewSupport.makeLoginViewModel(mode: .reqResDemoExternalAuth)
    )
}
#endif
