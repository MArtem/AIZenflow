import AuthenticationServices
import SwiftUI
import TchopAppleAuthentication
import TchopErrors
import UIKit

/// Authentication screen shown before entering the app shell.
///
/// The view intentionally supports two presentation contracts:
/// - local username + Apple sign-in for the normal stub-backed runtime
/// - email/password + register for the ReqRes external-auth development environment
struct LoginScreenView: View {
    @StateObject private var viewModel: LoginViewModel

    /// Creates a new LoginScreenView instance.
    init(
        mode: LoginScreenMode,
        onCredentialLogin: @escaping (String, String) async throws -> Void,
        onRegister: @escaping (String, String) async throws -> Void,
        onLogin: @escaping (String) async throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging
    ) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                mode: mode,
                onCredentialLogin: onCredentialLogin,
                onRegister: onRegister,
                onLogin: onLogin,
                onAppleLogin: onAppleLogin,
                appleAuthenticationManager: appleAuthenticationManager,
                errorManager: errorManager
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(titleText)
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(subtitleText)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if viewModel.mode == .localUsername {
                SignInWithAppleButton(.signIn) { request in
                    request.requestedScopes = [.fullName, .email]
                } onCompletion: { result in
                    viewModel.handleAppleSignInCompletion(result)
                }
                .accessibilityIdentifier("login.appleButton")
                .frame(height: 52)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .disabled(viewModel.isSubmitting)
                .opacity(viewModel.isSubmitting ? 0.8 : 1)

#if targetEnvironment(simulator)
                Text(
                    AppLocalization.text(
                        "login.apple.simulatorHint",
                        fallback: "Apple sign-in is prepared in code, but simulator-only validation is unreliable. Real authorization still requires a real bundle id, Apple capability setup, and ideally a physical device."
                    )
                )
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
#endif

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

            switch viewModel.mode {
            case .localUsername:
                usernameLoginForm
            case .reqResDemoExternalAuth:
                reqResCredentialForm
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.85))
            }

            switch viewModel.mode {
            case .localUsername:
                primaryButton(
                    title: AppLocalization.text("login.continueButton", fallback: "Continue with username"),
                    identifier: "login.continueButton",
                    action: viewModel.submit
                )
            case .reqResDemoExternalAuth:
                VStack(spacing: 12) {
                    primaryButton(
                        title: AppLocalization.text("login.external.signInButton", fallback: "Sign in with ReqRes"),
                        identifier: "login.reqresSignInButton",
                        action: viewModel.submitCredentialLogin
                    )

                    secondaryButton(
                        title: AppLocalization.text("login.external.registerButton", fallback: "Register with ReqRes"),
                        identifier: "login.reqresRegisterButton",
                        action: viewModel.submitRegistration
                    )
                }
            }

            if viewModel.mode == .reqResDemoExternalAuth {
                Text(
                    AppLocalization.text(
                        "login.external.reqresHint",
                        fallback: "ReqRes demo auth currently requires a configured x-api-key and fixture credentials such as eve.holt@reqres.in / pistol."
                    )
                )
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.textTertiary)
                .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(AppTheme.canvasBackground.ignoresSafeArea())
    }

    private var titleText: String {
        switch viewModel.mode {
        case .localUsername:
            return AppLocalization.text("login.title", fallback: "Sign in")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.title", fallback: "ReqRes Auth")
        }
    }

    private var subtitleText: String {
        switch viewModel.mode {
        case .localUsername:
            return AppLocalization.text(
                "login.subtitle",
                fallback: "Sign in with Apple or use any local username."
            )
        case .reqResDemoExternalAuth:
            return AppLocalization.text(
                "login.external.subtitle",
                fallback: "Development-only external auth backed by ReqRes demo login and registration."
            )
        }
    }

    private var usernameLoginForm: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(AppLocalization.text("login.usernameLabel", fallback: "Username"))
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)

            TextField(
                AppLocalization.text("login.usernamePlaceholder", fallback: "Enter your name"),
                text: $viewModel.username
            )
            .accessibilityIdentifier("login.usernameField")
            .textInputAutocapitalization(.words)
            .autocorrectionDisabled()
            .disabled(viewModel.isSubmitting)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(AppTheme.surfacePrimary)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(AppTheme.borderSubtle, lineWidth: 1)
            )
        }
    }

    private var reqResCredentialForm: some View {
        VStack(alignment: .leading, spacing: 14) {
            credentialField(
                title: AppLocalization.text("login.emailLabel", fallback: "Email"),
                placeholder: AppLocalization.text("login.emailPlaceholder", fallback: "eve.holt@reqres.in"),
                text: $viewModel.email,
                identifier: "login.emailField",
                contentType: .emailAddress,
                capitalization: .never
            )

            VStack(alignment: .leading, spacing: 10) {
                Text(AppLocalization.text("login.passwordLabel", fallback: "Password"))
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(AppTheme.textTertiary)

                SecureField(
                    AppLocalization.text("login.passwordPlaceholder", fallback: "Enter password"),
                    text: $viewModel.password
                )
                .accessibilityIdentifier("login.passwordField")
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .textContentType(.password)
                .disabled(viewModel.isSubmitting)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
            }
        }
    }

    private func credentialField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        identifier: String,
        contentType: UITextContentType?,
        capitalization: TextInputAutocapitalization
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(AppTheme.textTertiary)

            TextField(placeholder, text: text)
                .accessibilityIdentifier(identifier)
                .textInputAutocapitalization(capitalization)
                .autocorrectionDisabled()
                .textContentType(contentType)
                .keyboardType(contentType == .emailAddress ? .emailAddress : .default)
                .disabled(viewModel.isSubmitting)
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(AppTheme.surfacePrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(AppTheme.borderSubtle, lineWidth: 1)
                )
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
                        .padding(.vertical, 15)
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
            }
            .foregroundStyle(.white)
            .background(AppTheme.accent)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
        .accessibilityIdentifier(identifier)
        .buttonStyle(.plain)
        .disabled(viewModel.isSubmitting)
        .opacity(viewModel.isSubmitting ? 0.8 : 1)
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
        .opacity(viewModel.isSubmitting ? 0.8 : 1)
    }
}
