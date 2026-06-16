# AppFormValidation

`AppFormValidation` is a standalone Swift package for app-independent form validation.

It is intended for forms in iOS, macOS, watchOS, tvOS, server-side Swift tests, and shared domain modules where validation must be separate from UI and backend models.

## Features

- Safe form, field, rule, and code identifiers.
- Redacted descriptions and debug descriptions.
- Field values with no raw-value diagnostics.
- Field touched and dirty state.
- Required, minimum length, maximum length, and equals-field rules.
- Async `FormValidationRule` protocol for host-owned checks.
- `FormValidator` actor.
- `FormSnapshotStore` protocol boundary.
- `InMemoryFormSnapshotStore` actor for standalone usage and tests.
- Source-owned DocC documentation.
- Fail-fast package verifier.

## Example

```swift
import AppFormValidation

let formID = try FormID("signup")
let email = try FormFieldID("email")
let required = try FormValidationRuleID("required")
let code = try FormValidationCode("required")

let snapshot = try FormSnapshot(
    formID: formID,
    fields: [FormFieldState(id: email, value: .empty)]
)

let fieldPlan = try FormFieldValidationPlan(
    fieldID: email,
    rules: [.required(id: required, code: code, severity: .error)]
)
let plan = try FormValidationPlan(formID: formID, fieldPlans: [fieldPlan])
let validator = FormValidator(plan: plan)
let result = try await validator.validate(snapshot)
```

## Verification

Run:

```bash
./Scripts/verify_package.sh
```

The verifier uses a worktree-local scratch path outside the package folder:

```text
WorktreeScratch/AppFormValidation
```

It does not use system temporary directories.

## Runtime guarantees

- `FormStateController` serializes mutating and validation operations across awaiting store calls, so concurrent field updates do not lose revisions through actor reentrancy.
- `FormSnapshot` rejects revision overflow instead of wrapping or trapping.
- Missing stored snapshots are reported as `FormValidationFailure.missingSnapshot`, separate from missing form fields.
- Built-in rules emit stable validation codes only; host apps own localized/user-visible validation copy.
- Host apps own product-specific maximum input sizes and should express them through explicit rules such as `maxLength` or host-owned `FormValidationRule` implementations.
