import AuthenticationServices
import SwiftUI
import TchopAppleAuthentication
import TchopErrors
import UIKit

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
    @StateObject private var viewModel: LoginViewModel
    @FocusState private var focusedField: Field?

    private enum Field {
        case email
        case password
    }

    /// Creates a new LoginScreenView instance.
    init(
        mode: LoginScreenMode,
        onCredentialLogin: @escaping (String, String) async throws -> Void,
        onRegister: @escaping (String, String) async throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging
    ) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                mode: mode,
                onCredentialLogin: onCredentialLogin,
                onRegister: onRegister,
                onAppleLogin: onAppleLogin,
                appleAuthenticationManager: appleAuthenticationManager,
                errorManager: errorManager
            )
        )
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 24) {
                heroSection

                if viewModel.mode == .defaultAppAuth {
                    appleSection
                    divider
                }

                credentialCard

                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(AppTheme.destructive)
                        .fixedSize(horizontal: false, vertical: true)
                }

                actionSection

                if viewModel.mode == .reqResDemoExternalAuth {
                    Text(
                        AppLocalization.text(
                            "login.external.reqresHint",
                            fallback: "ReqRes demo auth requires a configured x-api-key and fixture credentials such as eve.holt@reqres.in / pistol."
                        )
                    )
                    .font(.system(size: 12, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 36)
            .padding(.bottom, 32)
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
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(AppTheme.accent)
                .frame(width: 58, height: 58)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: AppTheme.shadow.opacity(0.16), radius: 18, y: 8)

            VStack(alignment: .leading, spacing: 8) {
                Text(titleText)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitleText)
                    .font(.system(size: 15, weight: .medium))
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
            .frame(height: 54)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .disabled(viewModel.isSubmitting)
            .opacity(viewModel.isSubmitting ? 0.85 : 1)

#if targetEnvironment(simulator)
            Text(
                AppLocalization.text(
                    "login.apple.simulatorHint",
                    fallback: "Apple sign-in is prepared in code, but simulator-only validation is unreliable. Real authorization still requires a real bundle id, Apple capability setup, and ideally a physical device."
                )
            )
            .font(.system(size: 12, weight: .medium))
            .foregroundStyle(AppTheme.textTertiary)
            .fixedSize(horizontal: false, vertical: true)
#endif
        }
    }

    private var divider: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)

            Text(AppLocalization.text("login.separator", fallback: "or"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)

            Rectangle()
                .fill(AppTheme.borderSubtle)
                .frame(height: 1)
        }
    }

    private var credentialCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            VStack(alignment: .leading, spacing: 6) {
                Text(formTitleText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(formSubtitleText)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(spacing: 14) {
                emailField
                passwordField
            }
        }
        .padding(20)
        .background(AppTheme.surfacePrimary)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(AppTheme.borderSubtle, lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow.opacity(0.12), radius: 18, y: 10)
    }

    private var emailField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(AppLocalization.text("login.emailLabel", fallback: "Email"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)

            HStack(spacing: 12) {
                Image(systemName: "envelope")
                    .foregroundStyle(fieldTintColor(for: viewModel.emailValidationState))
                    .frame(width: 18)

                TextField(
                    emailPlaceholderText,
                    text: $viewModel.email
                )
                .accessibilityIdentifier("login.emailField")
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
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
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
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(AppLocalization.text("login.passwordLabel", fallback: "Password"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)

                Spacer()

                Button(action: viewModel.togglePasswordVisibility) {
                    Text(
                        viewModel.isPasswordVisible
                            ? AppLocalization.text("login.password.hide", fallback: "Hide")
                            : AppLocalization.text("login.password.show", fallback: "Show")
                    )
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.accent)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.isSubmitting)
            }

            HStack(spacing: 12) {
                Image(systemName: "lock")
                    .foregroundStyle(fieldTintColor(for: viewModel.passwordValidationState))
                    .frame(width: 18)

                Group {
                    if viewModel.isPasswordVisible {
                        TextField(
                            AppLocalization.text("login.passwordPlaceholder", fallback: "Enter password"),
                            text: $viewModel.password
                        )
                    } else {
                        SecureField(
                            AppLocalization.text("login.passwordPlaceholder", fallback: "Enter password"),
                            text: $viewModel.password
                        )
                    }
                }
                .accessibilityIdentifier("login.passwordField")
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
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .background(AppTheme.surfaceSecondary.opacity(0.55))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(fieldBorderColor(for: viewModel.passwordValidationState), lineWidth: 1.5)
            )

            helperTextView(
                viewModel.passwordHelperText ?? viewModel.passwordGuidanceText,
                color: helperColor(for: viewModel.passwordValidationState)
            )
        }
    }

    private var actionSection: some View {
        VStack(spacing: 12) {
            primaryButton(
                title: primaryActionTitle,
                identifier: primaryActionIdentifier,
                action: viewModel.submit
            )

            if viewModel.mode == .reqResDemoExternalAuth {
                secondaryButton(
                    title: AppLocalization.text("login.external.registerButton", fallback: "Register with ReqRes"),
                    identifier: "login.reqresRegisterButton",
                    action: viewModel.submitRegistration
                )
            }
        }
    }

    private var titleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.title", fallback: "Welcome back")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.title", fallback: "ReqRes Auth")
        }
    }

    private var subtitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text(
                "login.subtitle",
                fallback: "Sign in with your email and password, or continue with Apple if your account is already linked."
            )
        case .reqResDemoExternalAuth:
            return AppLocalization.text(
                "login.external.subtitle",
                fallback: "Development-only external auth backed by ReqRes demo login and registration."
            )
        }
    }

    private var formTitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.form.title", fallback: "Sign in with email")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.form.title", fallback: "Use demo credentials")
        }
    }

    private var formSubtitleText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text(
                "login.form.subtitle",
                fallback: "Validation runs as you type and the button unlocks only when the form is ready."
            )
        case .reqResDemoExternalAuth:
            return AppLocalization.text(
                "login.external.form.subtitle",
                fallback: "ReqRes accepts fixture accounts only. Use sign in or create a demo account below."
            )
        }
    }

    private var emailPlaceholderText: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.emailPlaceholder", fallback: "name@company.com")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.emailPlaceholder", fallback: "eve.holt@reqres.in")
        }
    }

    private var primaryActionTitle: String {
        switch viewModel.mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.continueButton", fallback: "Sign in")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.signInButton", fallback: "Sign in with ReqRes")
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
                            .font(.system(size: 16, weight: .semibold))

                        Image(systemName: "arrow.right")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
            }
            .foregroundStyle(AppTheme.accentOnColor)
            .background(viewModel.canSubmit ? AppTheme.accent : AppTheme.textTertiary.opacity(0.45))
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .accessibilityIdentifier(identifier)
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
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .foregroundStyle(AppTheme.textPrimary)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 18, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
        }
        .accessibilityIdentifier(identifier)
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
        case .invalid:
            Image(systemName: "exclamationmark.circle.fill")
                .foregroundStyle(AppTheme.destructive)
        case .untouched:
            EmptyView()
        }
    }

    private func helperTextView(_ text: String, color: Color) -> some View {
        Text(text)
            .font(.system(size: 12, weight: .medium))
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
