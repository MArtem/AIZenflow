import AuthenticationServices
import Foundation
import Observation
import TchopAppleAuthentication
import TchopErrors

/// Login screen behavior selected by the active app environment.
enum LoginScreenMode {
    case defaultAppAuth
    case reqResDemoExternalAuth
}

/// Validation state for one login form field.
enum LoginFieldValidationState: Equatable {
    case untouched
    case validating
    case valid(String?)
    case invalid(String)

    var message: String? {
        switch self {
        case .valid(let message):
            return message
        case .invalid(let message):
            return message
        case .untouched, .validating:
            return nil
        }
    }

    var isInvalid: Bool {
        if case .invalid = self {
            return true
        }

        return false
    }

    var isValid: Bool {
        if case .valid = self {
            return true
        }

        return false
    }
}

/// View model backing the default app login screen and the development-only external ReqRes auth flow.
@MainActor
@Observable
final class LoginViewModel {
    private enum ValidationField {
        case email
        case password
    }

    /// Active login presentation mode selected by the app environment.
    let mode: LoginScreenMode

    /// User-entered email value.
    var email = "" {
        didSet {
            scheduleValidation(for: .email)
        }
    }

    /// User-entered password value.
    var password = "" {
        didSet {
            scheduleValidation(for: .password)
        }
    }

    /// Toggles secure/plain password field presentation.
    var isPasswordVisible = false

    /// Debounced email validation state used for inline UI feedback.
    private(set) var emailValidationState: LoginFieldValidationState = .untouched

    /// Debounced password validation state used for inline UI feedback.
    private(set) var passwordValidationState: LoginFieldValidationState = .untouched

    /// Prevents duplicate submissions while an async sign-in attempt is in flight.
    private(set) var isSubmitting = false

    /// Tracks whether the form is ready for submission under the current mode-specific policy.
    private(set) var canSubmit = false

    /// Presentation-ready validation or sign-in error.
    private(set) var errorMessage: String?

    private let onCredentialLogin: (String, String) async throws -> Void
    private let onRegister: (String, String) async throws -> Void
    private let onAppleLogin: (AppleAuthenticationIdentity) async throws -> Void
    private let appleAuthenticationManager: any AppleAuthenticationManaging
    private let errorManager: any AppErrorManaging
    private let submissionThrottleInterval: TimeInterval
    private var lastSubmissionDate = Date.distantPast
    private var emailValidationTask: Task<Void, Never>?
    private var passwordValidationTask: Task<Void, Never>?

    /// Creates a login view model.
    ///
    /// The view model owns:
    /// - form input and validation state
    /// - single-flight and throttled submission policy
    ///
    /// It intentionally does not own:
    /// - session persistence
    /// - backend transport specifics
    /// - Apple credential parsing rules
    init(
        mode: LoginScreenMode,
        onCredentialLogin: @escaping (String, String) async throws -> Void,
        onRegister: @escaping (String, String) async throws -> Void,
        onAppleLogin: @escaping (AppleAuthenticationIdentity) async throws -> Void,
        appleAuthenticationManager: any AppleAuthenticationManaging,
        errorManager: any AppErrorManaging,
        submissionThrottleInterval: TimeInterval = 1
    ) {
        self.mode = mode
        self.onCredentialLogin = onCredentialLogin
        self.onRegister = onRegister
        self.onAppleLogin = onAppleLogin
        self.appleAuthenticationManager = appleAuthenticationManager
        self.errorManager = errorManager
        self.submissionThrottleInterval = submissionThrottleInterval
    }

    /// Starts the primary sign-in flow for the currently active mode.
    func submit() {
        guard let credentials = validateCredentialsForSubmission() else {
            return
        }

        guard canStartSubmission() else {
            return
        }

        runSignInTask(
            operation: { [self] in
                try await self.onCredentialLogin(credentials.email, credentials.password)
            },
            failureContext: AppErrorContext(
                operation: mode == .defaultAppAuth ? "defaultCredentialLogin" : "credentialLogin",
                feature: "login"
            )
        )
    }

    /// Starts the ReqRes registration flow.
    func submitRegistration() {
        guard mode == .reqResDemoExternalAuth else {
            return
        }

        guard let credentials = validateCredentialsForSubmission() else {
            return
        }

        guard canStartSubmission() else {
            return
        }

        runSignInTask(
            operation: { [self] in
                try await self.onRegister(credentials.email, credentials.password)
            },
            failureContext: AppErrorContext(
                operation: "credentialRegistration",
                feature: "login"
            )
        )
    }

    /// Toggles password visibility between secure and plain text.
    func togglePasswordVisibility() {
        isPasswordVisible.toggle()
    }

    /// Handles the Sign in with Apple completion result and converts it into the app session payload.
    func handleAppleSignInCompletion(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case let .success(authorization):
            handleSuccessfulAppleAuthorization(authorization)
        case let .failure(error):
            handleAppleAuthorizationFailure(error)
        }
    }

    /// Returns the current inline helper text for the email field.
    var emailHelperText: String? {
        emailValidationState.message
    }

    /// Returns the current inline helper text for the password field.
    var passwordHelperText: String? {
        passwordValidationState.message
    }

    /// Describes the current password policy for the active login mode.
    var passwordGuidanceText: String {
        switch mode {
        case .defaultAppAuth:
            return AppLocalization.text("login.password.guidance")
        case .reqResDemoExternalAuth:
            return AppLocalization.text("login.external.password.guidance")
        }
    }

    deinit {
        MainActor.assumeIsolated {
            emailValidationTask?.cancel()
            passwordValidationTask?.cancel()
        }
    }

    private func scheduleValidation(for field: ValidationField) {
        switch field {
        case .email:
            emailValidationTask?.cancel()
            emailValidationState = .validating
        case .password:
            passwordValidationTask?.cancel()
            passwordValidationState = .validating
        }

        errorMessage = nil
        refreshCanSubmitState()

        let task = Task { @MainActor [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(250))
            } catch {
                return
            }

            guard let self else {
                return
            }

            switch field {
            case .email:
                self.emailValidationState = self.validateEmail(self.email)
            case .password:
                self.passwordValidationState = self.validatePassword(self.password)
            }

            self.refreshCanSubmitState()
        }

        switch field {
        case .email:
            emailValidationTask = task
        case .password:
            passwordValidationTask = task
        }
    }

    private func validateCredentialsForSubmission() -> (email: String, password: String)? {
        let normalizedEmail = normalizedEmail(email)
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        let emailState = validateEmail(normalizedEmail)
        let passwordState = validatePassword(password)

        emailValidationState = emailState
        passwordValidationState = passwordState
        refreshCanSubmitState()

        guard emailState.isValid, passwordState.isValid else {
            errorMessage = AppLocalization.text("login.error.invalidCredentials")
            return nil
        }

        errorMessage = nil
        return (normalizedEmail, normalizedPassword)
    }

    private func validateEmail(_ rawEmail: String) -> LoginFieldValidationState {
        let normalizedEmail = normalizedEmail(rawEmail)
        guard !normalizedEmail.isEmpty else {
            return .invalid(AppLocalization.text("login.error.emptyEmail"))
        }

        guard Self.isValidEmail(normalizedEmail) else {
            return .invalid(AppLocalization.text("login.error.invalidEmail"))
        }

        switch mode {
        case .defaultAppAuth:
            return .valid(AppLocalization.text("login.email.valid"))
        case .reqResDemoExternalAuth:
            return .valid(AppLocalization.text("login.external.email.valid"))
        }
    }

    private func validatePassword(_ rawPassword: String) -> LoginFieldValidationState {
        switch mode {
        case .defaultAppAuth:
            return validateDefaultPassword(rawPassword)
        case .reqResDemoExternalAuth:
            return validateReqResPassword(rawPassword)
        }
    }

    private func validateDefaultPassword(_ rawPassword: String) -> LoginFieldValidationState {
        guard !rawPassword.isEmpty else {
            return .invalid(AppLocalization.text("login.error.emptyPassword"))
        }

        guard !rawPassword.contains(where: { $0.isWhitespace }) else {
            return .invalid(AppLocalization.text("login.error.passwordWhitespace"))
        }

        guard rawPassword.count >= 8 else {
            return .invalid(AppLocalization.text("login.error.passwordTooShort"))
        }

        let hasLetter = rawPassword.contains(where: { $0.isLetter })
        let hasDigit = rawPassword.contains(where: { $0.isNumber })
        let hasSymbol = rawPassword.contains(where: { !$0.isLetter && !$0.isNumber && !$0.isWhitespace })

        guard hasLetter else {
            return .invalid(AppLocalization.text("login.error.passwordMissingLetter"))
        }

        guard hasDigit else {
            return .invalid(AppLocalization.text("login.error.passwordMissingDigit"))
        }

        if rawPassword.count >= 12 && hasSymbol {
            return .valid(AppLocalization.text("login.password.strong"))
        }

        return .valid(AppLocalization.text("login.password.valid"))
    }

    private func validateReqResPassword(_ rawPassword: String) -> LoginFieldValidationState {
        let normalizedPassword = rawPassword.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedPassword.isEmpty else {
            return .invalid(AppLocalization.text("login.error.emptyPassword"))
        }

        return .valid(AppLocalization.text("login.external.password.valid"))
    }

    private func refreshCanSubmitState() {
        canSubmit = emailValidationState.isValid && passwordValidationState.isValid && !isSubmitting
    }

    private func canStartSubmission() -> Bool {
        guard !isSubmitting else {
            return false
        }

        let now = Date()
        guard now.timeIntervalSince(lastSubmissionDate) >= submissionThrottleInterval else {
            errorMessage = AppLocalization.text("login.error.throttled")
            return false
        }

        lastSubmissionDate = now
        return true
    }

    private func normalizedEmail(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    }

    /// Extracts the credential payload and starts the Apple-backed sign-in flow.
    private func handleSuccessfulAppleAuthorization(_ authorization: ASAuthorization) {
        do {
            let identity = try appleAuthenticationManager.identity(from: authorization)
            guard !isSubmitting else {
                return
            }
            runSignInTask(
                operation: { [self] in
                    try await self.onAppleLogin(identity)
                },
                failureContext: AppErrorContext(
                    operation: "appleLogin",
                    feature: "login"
                )
            )
        } catch AppleAuthenticationError.invalidCredential {
            errorMessage = AppLocalization.text("login.apple.error.invalidCredential")
        } catch {
            presentLoginError(
                error,
                context: AppErrorContext(
                    operation: "appleLogin",
                    feature: "login"
                )
            )
        }
    }

    /// Handles Apple authorization failures while keeping user-cancelled flows silent.
    private func handleAppleAuthorizationFailure(_ error: Error) {
        if appleAuthenticationManager.isCancellationError(error) {
            errorMessage = nil
            return
        }

        presentLoginError(
            error,
            context: AppErrorContext(
                operation: "appleAuthorization",
                feature: "login"
            )
        )
    }

    /// Maps and reports login-flow failures through the shared app error manager.
    private func presentLoginError(
        _ error: Error,
        context: AppErrorContext
    ) {
        Task { @MainActor [weak self, errorManager] in
            let presentation = await errorManager.presentableError(
                from: error,
                context: context
            )
            self?.errorMessage = presentation.userMessage
        }
    }

    /// Runs a single sign-in operation while keeping the screen responsive and duplicate-safe.
    private func runSignInTask(
        operation: @escaping () async throws -> Void,
        failureContext: AppErrorContext
    ) {
        isSubmitting = true
        errorMessage = nil
        refreshCanSubmitState()

        Task { @MainActor [weak self] in
            defer {
                self?.isSubmitting = false
                self?.refreshCanSubmitState()
            }

            do {
                try await operation()
                self?.errorMessage = nil
            } catch {
                self?.presentLoginError(error, context: failureContext)
            }
        }
    }

    private static func isValidEmail(_ email: String) -> Bool {
        let emailPredicate = NSPredicate(
            format: "SELF MATCHES %@",
            #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
        )
        return emailPredicate.evaluate(with: email)
    }
}
