import AuthenticationServices
import SwiftUI

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
    @ObservedObject var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: AppSpacing.formSection) {
                heroSection

                if viewModel.mode == .defaultAppAuth {
                    appleSection
                    divider
                }

                credentialCard

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(AppTypography.caption)
                        .foregroundStyle(AppTheme.destructive)
                        .fixedSize(horizontal: false, vertical: true)
                }

                actionSection

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
        .background(backgroundView)
        .scrollDismissesKeyboard(.interactively)
    }

    private var backgroundView: some View {
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

    private var heroSection: some View {
        VStack(alignment: .leading, spacing: 14) {
            Image(systemName: viewModel.mode == .defaultAppAuth ? "person.crop.circle.badge.checkmark" : "network")
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

    private var appleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                viewModel.handleAppleSignInCompletion(result)
            }
            .accessibilityIdentifier("login.appleButton")
            .accessibilityLabel(AppLocalization.text("accessibility.login.apple"))
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .disabled(viewModel.isSubmitting)
            .opacity(viewModel.isSubmitting ? 0.85 : 1)

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

    private var divider: some View {
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

    private var credentialCard: some View {
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
                emailField
                passwordField
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

    private var emailField: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Text(AppLocalization.text("login.emailLabel"))
                .font(AppTypography.captionSemibold)
                .foregroundStyle(AppTheme.textTertiary)

            HStack(spacing: AppSpacing.sm) {
                Image(systemName: "envelope")
                    .foregroundStyle(fieldTintColor(for: viewModel.emailValidationState))
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
                .focused($focusedField, equals: .email)
                .submitLabel(.next)
                .disabled(viewModel.isSubmitting)
                .onSubmit {
                    focusedField = .password
                }

                validationIcon(for: viewModel.emailValidationState)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous)
                    .stroke(fieldBorderColor(for: viewModel.emailValidationState), lineWidth: 1.5)
            )

            if let helperText = viewModel.emailHelperText {
                helperTextView(
                    helperText,
                    color: helperColor(for: viewModel.emailValidationState)
                )
            }
        }
    }

    private var passwordField: some View {
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
                    .foregroundStyle(fieldTintColor(for: viewModel.passwordValidationState))
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
                .focused($focusedField, equals: .password)
                .submitLabel(.go)
                .disabled(viewModel.isSubmitting)
                .onSubmit {
                    viewModel.submit()
                }

                validationIcon(for: viewModel.passwordValidationState)
            }
            .padding(.horizontal, AppSpacing.md)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous)
                    .stroke(fieldBorderColor(for: viewModel.passwordValidationState), lineWidth: 1.5)
            )

            helperTextView(
                viewModel.passwordHelperText ?? viewModel.passwordGuidanceText,
                color: helperColor(for: viewModel.passwordValidationState)
            )
        }
    }

    private var actionSection: some View {
        VStack(spacing: AppSpacing.sm) {
            primaryButton(
                title: primaryActionTitle,
                identifier: primaryActionIdentifier,
                action: viewModel.submit
            )

            if viewModel.mode == .reqResDemoExternalAuth {
                secondaryButton(
                    title: AppLocalization.text("login.external.registerButton"),
                    identifier: "login.reqresRegisterButton",
                    action: viewModel.submitRegistration
                )
            }
        }
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

    private func primaryButton(
        title: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Group {
                if viewModel.isSubmitting {
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
            .background(viewModel.canSubmit ? AppTheme.accent : AppTheme.textTertiary.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: AppRadius.buttonField, style: .continuous))
        }
        .accessibilityIdentifier(identifier)
        .accessibilityLabel(title)
        .buttonStyle(.plain)
        .disabled(!viewModel.canSubmit || viewModel.isSubmitting)
        .opacity(viewModel.isSubmitting ? 0.88 : 1)
    }

    private func secondaryButton(
        title: String,
        identifier: String,
        action: @escaping () -> Void
    ) -> some View {
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
        .disabled(viewModel.isSubmitting)
        .opacity(viewModel.isSubmitting ? 0.88 : 1)
    }

    @ViewBuilder
    private func validationIcon(for state: LoginFieldValidationState) -> some View {
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

    private func helperTextView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(AppTypography.label)
            .foregroundStyle(color)
            .fixedSize(horizontal: false, vertical: true)
    }

    private func fieldBorderColor(for state: LoginFieldValidationState) -> Color {
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

    private func fieldTintColor(for state: LoginFieldValidationState) -> Color {
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

    private func helperColor(for state: LoginFieldValidationState) -> Color {
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
