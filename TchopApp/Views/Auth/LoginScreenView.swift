import SwiftUI

struct LoginScreenView: View {
    @StateObject private var viewModel: LoginViewModel

    init(onLogin: @escaping (String) throws -> Void) {
        _viewModel = StateObject(
            wrappedValue: LoginViewModel(onLogin: onLogin)
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Spacer()

            VStack(alignment: .leading, spacing: 8) {
                Text("Sign in")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundStyle(Color(red: 0.22, green: 0.23, blue: 0.33))

                Text("Use any username. A new one will be stored locally on first login.")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.gray)
                    .fixedSize(horizontal: false, vertical: true)
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Username")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(Color(red: 0.40, green: 0.41, blue: 0.50))

                TextField("Enter your name", text: $viewModel.username)
                    .textInputAutocapitalization(.words)
                    .autocorrectionDisabled()
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.black.opacity(0.06), lineWidth: 1)
                    )
            }

            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(Color.red.opacity(0.85))
            }

            Button(action: viewModel.submit) {
                Text("Continue")
                    .font(.system(size: 16, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .foregroundStyle(.white)
                    .background(Color(red: 0.95, green: 0.50, blue: 0.37))
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
            .buttonStyle(.plain)

            Spacer()
        }
        .padding(.horizontal, 24)
        .background(Color(red: 0.97, green: 0.96, blue: 0.94).ignoresSafeArea())
    }
}
