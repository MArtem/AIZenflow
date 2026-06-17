import AuthenticationServices
import Foundation
import Observation

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


private enum LoginValidationConstants {
    static let formID = try! FormID("login")
    static let emailFieldID = try! FormFieldID("email")
    static let passwordFieldID = try! FormFieldID("password")
    static let emailRequiredRuleID = try! FormValidationRuleID("email.required")
    static let emailFormatRuleID = try! FormValidationRuleID("email.format")
    static let passwordRequiredRuleID = try! FormValidationRuleID("password.required")
    static let passwordMinimumLengthRuleID = try! FormValidationRuleID("password.minimum-length")
    static let passwordWhitespaceRuleID = try! FormValidationRuleID("password.whitespace")
    static let passwordLetterRuleID = try! FormValidationRuleID("password.letter")
    static let passwordDigitRuleID = try! FormValidationRuleID("password.digit")
    static let emailRequiredCode = try! FormValidationCode("email.required")
    static let emailInvalidCode = try! FormValidationCode("email.invalid")
    static let passwordRequiredCode = try! FormValidationCode("password.required")
    static let passwordWhitespaceCode = try! FormValidationCode("password.whitespace")
    static let passwordTooShortCode = try! FormValidationCode("password.too-short")
    static let passwordMissingLetterCode = try! FormValidationCode("password.missing-letter")
    static let passwordMissingDigitCode = try! FormValidationCode("password.missing-digit")
}


private struct LoginEmailFormatRule: FormValidationRule {
    let id = LoginValidationConstants.emailFormatRuleID

    func validate(
        fieldID: FormFieldID,
        value: FormFieldValue,
        context: FormValidationContext
    ) async throws -> FormValidationRuleResult {
        guard fieldID == LoginValidationConstants.emailFieldID else {
            return .valid
        }
        guard case let .string(email) = value, !value.isEmptyForValidation else {
            return .valid
        }
        guard isValidLoginEmail(email) else {
            return FormValidationRuleResult(
                issues: [
                    FormValidationIssue(
                        fieldID: fieldID,
                        ruleID: id,
                        code: LoginValidationConstants.emailInvalidCode,
                        severity: .error
                    )
                ]
            )
        }
        return .valid
    }
}

private struct DefaultPasswordWhitespaceRule: FormValidationRule {
    let isEnabled: Bool
    let id = LoginValidationConstants.passwordWhitespaceRuleID

    func validate(
        fieldID: FormFieldID,
        value: FormFieldValue,
        context: FormValidationContext
    ) async throws -> FormValidationRuleResult {
        guard isEnabled, fieldID == LoginValidationConstants.passwordFieldID else {
            return .valid
        }
        guard case let .string(password) = value, !value.isEmptyForValidation else {
            return .valid
        }
        guard password.contains(where: { $0.isWhitespace }) else {
            return .valid
        }
        return FormValidationRuleResult(
            issues: [
                FormValidationIssue(
                    fieldID: fieldID,
                    ruleID: id,
                    code: LoginValidationConstants.passwordWhitespaceCode,
                    severity: .error
                )
            ]
        )
    }
}

private struct DefaultPasswordLetterRule: FormValidationRule {
    let isEnabled: Bool
    let id = LoginValidationConstants.passwordLetterRuleID

    func validate(
        fieldID: FormFieldID,
        value: FormFieldValue,
        context: FormValidationContext
    ) async throws -> FormValidationRuleResult {
        guard isEnabled, fieldID == LoginValidationConstants.passwordFieldID else {
            return .valid
        }
        guard case let .string(password) = value, !value.isEmptyForValidation else {
            return .valid
        }
        guard password.contains(where: { $0.isLetter }) else {
            return FormValidationRuleResult(
                issues: [
                    FormValidationIssue(
                        fieldID: fieldID,
                        ruleID: id,
                        code: LoginValidationConstants.passwordMissingLetterCode,
                        severity: .error
                    )
                ]
            )
        }
        return .valid
    }
}

private struct DefaultPasswordDigitRule: FormValidationRule {
    let isEnabled: Bool
    let id = LoginValidationConstants.passwordDigitRuleID

    func validate(
        fieldID: FormFieldID,
        value: FormFieldValue,
        context: FormValidationContext
    ) async throws -> FormValidationRuleResult {
        guard isEnabled, fieldID == LoginValidationConstants.passwordFieldID else {
            return .valid
        }
        guard case let .string(password) = value, !value.isEmptyForValidation else {
            return .valid
        }
        guard password.contains(where: { $0.isNumber }) else {
            return FormValidationRuleResult(
                issues: [
                    FormValidationIssue(
                        fieldID: fieldID,
                        ruleID: id,
                        code: LoginValidationConstants.passwordMissingDigitCode,
                        severity: .error
                    )
                ]
            )
        }
        return .valid
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

    private enum SubmissionKind {
        case signIn
        case registration
    }

    /// Mutable presentation state for the login form.
    ///
    /// Ownership:
    /// Owned only by `LoginViewModel`; SwiftUI reads derived bindings and sends explicit intents back.
    struct State {
        var email: String = ""
        var password: String = ""
        var isPasswordVisible: Bool = false
        var emailValidationState: LoginFieldValidationState = .untouched
        var passwordValidationState: LoginFieldValidationState = .untouched
        var isSubmitting: Bool = false
        var canSubmit: Bool = false
        var errorMessage: String?
    }

    private(set) var state = State()

    /// Active login presentation mode selected by the app environment.
    let mode: LoginScreenMode

    /// User-entered email value.
    var email: String {
        get { state.email }
        set {
            state.email = newValue
            scheduleValidation(for: .email)
        }
    }

    /// User-entered password value.
    var password: String {
        get { state.password }
        set {
            state.password = newValue
            scheduleValidation(for: .password)
        }
    }

    /// Toggles secure/plain password field presentation.
    var isPasswordVisible: Bool {
        get { state.isPasswordVisible }
        set { state.isPasswordVisible = newValue }
    }

    /// Debounced email validation state used for inline UI feedback.
    private(set) var emailValidationState: LoginFieldValidationState {
        get { state.emailValidationState }
        set { state.emailValidationState = newValue }
    }

    /// Debounced password validation state used for inline UI feedback.
    private(set) var passwordValidationState: LoginFieldValidationState {
        get { state.passwordValidationState }
        set { state.passwordValidationState = newValue }
    }

    /// Prevents duplicate submissions while an async sign-in attempt is in flight.
    private(set) var isSubmitting: Bool {
        get { state.isSubmitting }
        set { state.isSubmitting = newValue }
    }

    /// Tracks whether the form is ready for submission under the current mode-specific policy.
    private(set) var canSubmit: Bool {
        get { state.canSubmit }
        set { state.canSubmit = newValue }
    }

    /// Presentation-ready validation or sign-in error.
    private(set) var errorMessage: String? {
        get { state.errorMessage }
        set { state.errorMessage = newValue }
    }

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
        Task { @MainActor [weak self] in
            await self?.submitValidated(kind: .signIn)
        }
    }

    /// Starts the ReqRes registration flow.
    func submitRegistration() {
        guard mode == .reqResDemoExternalAuth else {
            return
        }

        Task { @MainActor [weak self] in
            await self?.submitValidated(kind: .registration)
        }
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
                self.emailValidationState = await self.validateEmail(self.email)
            case .password:
                self.passwordValidationState = await self.validatePassword(self.password)
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

    private func submitValidated(kind: SubmissionKind) async {
        guard let credentials = await validateCredentialsForSubmission() else {
            return
        }

        guard canStartSubmission() else {
            return
        }

        switch kind {
        case .signIn:
            runSignInTask(
                operation: { [self] in
                    try await self.onCredentialLogin(credentials.email, credentials.password)
                },
                failureContext: AppErrorContext(
                    operation: mode == .defaultAppAuth ? "defaultCredentialLogin" : "credentialLogin",
                    feature: "login"
                )
            )
        case .registration:
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
    }

    private func validateCredentialsForSubmission() async -> (email: String, password: String)? {
        let normalizedEmail = normalizedEmail(email)
        let normalizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        let states = await validateCurrentCredentials(
            email: normalizedEmail,
            password: mode == .reqResDemoExternalAuth ? normalizedPassword : password
        )

        emailValidationState = states.email
        passwordValidationState = states.password
        refreshCanSubmitState()

        guard states.email.isValid, states.password.isValid else {
            errorMessage = AppLocalization.text("login.error.invalidCredentials")
            return nil
        }

        errorMessage = nil
        return (normalizedEmail, normalizedPassword)
    }

    private func validateEmail(_ rawEmail: String) async -> LoginFieldValidationState {
        let normalizedEmail = normalizedEmail(rawEmail)
        let states = await validateCurrentCredentials(email: normalizedEmail, password: currentPasswordValueForValidation())
        return states.email
    }

    private func validatePassword(_ rawPassword: String) async -> LoginFieldValidationState {
        let passwordValue = mode == .reqResDemoExternalAuth
            ? rawPassword.trimmingCharacters(in: .whitespacesAndNewlines)
            : rawPassword
        let states = await validateCurrentCredentials(email: normalizedEmail(email), password: passwordValue)
        return states.password
    }

    private func validateCurrentCredentials(
        email: String,
        password: String
    ) async -> (email: LoginFieldValidationState, password: LoginFieldValidationState) {
        do {
            let result = try await makeCredentialValidator().validate(
                try FormSnapshot(
                    formID: LoginValidationConstants.formID,
                    fields: [
                        FormFieldState(id: LoginValidationConstants.emailFieldID, value: .string(email)),
                        FormFieldState(id: LoginValidationConstants.passwordFieldID, value: .string(password))
                    ]
                )
            )
            return (
                email: emailValidationState(from: result),
                password: passwordValidationState(from: result, rawPassword: password)
            )
        } catch {
            return (
                email: .invalid(AppLocalization.text("login.error.invalidCredentials")),
                password: .invalid(AppLocalization.text("login.error.invalidCredentials"))
            )
        }
    }

    private func makeCredentialValidator() throws -> FormValidator {
        let emailPlan = try FormFieldValidationPlan(
            fieldID: LoginValidationConstants.emailFieldID,
            rules: [
                .required(
                    id: LoginValidationConstants.emailRequiredRuleID,
                    code: LoginValidationConstants.emailRequiredCode,
                    severity: .error
                )
            ]
        )

        let passwordRules: [BuiltInFormValidationRule]
        switch mode {
        case .defaultAppAuth:
            passwordRules = [
                .required(
                    id: LoginValidationConstants.passwordRequiredRuleID,
                    code: LoginValidationConstants.passwordRequiredCode,
                    severity: .error
                ),
                .minLength(
                    id: LoginValidationConstants.passwordMinimumLengthRuleID,
                    length: 8,
                    code: LoginValidationConstants.passwordTooShortCode,
                    severity: .error
                )
            ]
        case .reqResDemoExternalAuth:
            passwordRules = [
                .required(
                    id: LoginValidationConstants.passwordRequiredRuleID,
                    code: LoginValidationConstants.passwordRequiredCode,
                    severity: .error
                )
            ]
        }

        let passwordPlan = try FormFieldValidationPlan(
            fieldID: LoginValidationConstants.passwordFieldID,
            rules: passwordRules
        )
        let plan = try FormValidationPlan(
            formID: LoginValidationConstants.formID,
            fieldPlans: [emailPlan, passwordPlan]
        )

        return FormValidator(
            plan: plan,
            externalRules: [
                LoginEmailFormatRule(),
                DefaultPasswordWhitespaceRule(isEnabled: mode == .defaultAppAuth),
                DefaultPasswordLetterRule(isEnabled: mode == .defaultAppAuth),
                DefaultPasswordDigitRule(isEnabled: mode == .defaultAppAuth)
            ]
        )
    }

    private func emailValidationState(from result: FormValidationResult) -> LoginFieldValidationState {
        guard let issue = result.issues(for: LoginValidationConstants.emailFieldID).first else {
            switch mode {
            case .defaultAppAuth:
                return .valid(AppLocalization.text("login.email.valid"))
            case .reqResDemoExternalAuth:
                return .valid(AppLocalization.text("login.external.email.valid"))
            }
        }

        switch issue.code {
        case LoginValidationConstants.emailRequiredCode:
            return .invalid(AppLocalization.text("login.error.emptyEmail"))
        case LoginValidationConstants.emailInvalidCode:
            return .invalid(AppLocalization.text("login.error.invalidEmail"))
        default:
            return .invalid(AppLocalization.text("login.error.invalidCredentials"))
        }
    }

    private func passwordValidationState(
        from result: FormValidationResult,
        rawPassword: String
    ) -> LoginFieldValidationState {
        guard let issue = result.issues(for: LoginValidationConstants.passwordFieldID).first else {
            switch mode {
            case .defaultAppAuth:
                let hasSymbol = rawPassword.contains { !$0.isLetter && !$0.isNumber && !$0.isWhitespace }
                if rawPassword.count >= 12 && hasSymbol {
                    return .valid(AppLocalization.text("login.password.strong"))
                }
                return .valid(AppLocalization.text("login.password.valid"))
            case .reqResDemoExternalAuth:
                return .valid(AppLocalization.text("login.external.password.valid"))
            }
        }

        switch issue.code {
        case LoginValidationConstants.passwordRequiredCode:
            return .invalid(AppLocalization.text("login.error.emptyPassword"))
        case LoginValidationConstants.passwordWhitespaceCode:
            return .invalid(AppLocalization.text("login.error.passwordWhitespace"))
        case LoginValidationConstants.passwordTooShortCode:
            return .invalid(AppLocalization.text("login.error.passwordTooShort"))
        case LoginValidationConstants.passwordMissingLetterCode:
            return .invalid(AppLocalization.text("login.error.passwordMissingLetter"))
        case LoginValidationConstants.passwordMissingDigitCode:
            return .invalid(AppLocalization.text("login.error.passwordMissingDigit"))
        default:
            return .invalid(AppLocalization.text("login.error.invalidCredentials"))
        }
    }

    private func currentPasswordValueForValidation() -> String {
        switch mode {
        case .defaultAppAuth:
            return password
        case .reqResDemoExternalAuth:
            return password.trimmingCharacters(in: .whitespacesAndNewlines)
        }
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

}

private func isValidLoginEmail(_ email: String) -> Bool {
    let emailPredicate = NSPredicate(
        format: "SELF MATCHES %@",
        #"^[A-Z0-9a-z._%+\-]+@[A-Za-z0-9.\-]+\.[A-Za-z]{2,}$"#
    )
    return emailPredicate.evaluate(with: email)
}
