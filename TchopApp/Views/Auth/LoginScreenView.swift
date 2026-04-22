import AuthenticationServices
import SwiftUI
import TchopAppleAuthentication

/// Authentication screen shown before entering the app shell.
struct LoginScreenView: View {
    @StateObject private var viewModel: LoginViewModel

    /// Creates a new LoginScreenView instance.
    init(
        onLogin: @escaping (String) throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging
    ) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(
                onLogin: onLogin,
                onAppleLogin: onAppleLogin,
                appleAuthenticationManager: appleAuthenticationManager
            )
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text(AppLocalization.text("login.title", fallback: "Sign in"))
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(AppTheme.textPrimary)

                Text(
                    AppLocalization.text(
                        "login.subtitle",
                        fallback: "Sign in with Apple or use any local username."
                    )
                )
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                viewModel.handleAppleSignInCompletion(result)
            }
            .accessibilityIdentifier("login.appleButton")
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(AppTheme.surfacePrimary)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(AppTheme.borderSubtle, lineWidth: 1)
                    )
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.85))
            }

            Button(action: viewModel.submit) {
                Text(AppLocalization.text("login.continueButton", fallback: "Continue with username"))
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(AppTheme.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .accessibilityIdentifier("login.continueButton")
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(AppTheme.canvasBackground.ignoresSafeArea())
    }
}
