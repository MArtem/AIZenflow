import SwiftUI

/// Username-based authentication screen shown before entering the app shell.
struct LoginScreenView: View {
    @StateObject private var viewModel: LoginViewModel

    /// Creates a new LoginScreenView instance.
    init(onLogin: @escaping (String) throws -> Void) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(onLogin: onLogin)
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
                        fallback: "Use any username. A new one will be stored locally on first login."
                    )
                )
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(AppTheme.textTertiary)
                    .fixedSize(horizontal: false, vertical: true)
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
                Text(AppLocalization.text("login.continueButton", fallback: "Continue"))
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
