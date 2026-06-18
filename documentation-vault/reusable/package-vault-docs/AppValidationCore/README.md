# AppValidationCore

`AppValidationCore` is a standalone Swift package with app-independent validation primitives.
It is intended to be copied as a single folder into any iOS, macOS, watchOS, or tvOS project.

The package focuses on reusable validation mechanics:

- safe validation identifiers;
- validation values with redacted diagnostics;
- validation issues and severities;
- validation rule protocols;
- built-in validation rules;
- rule set validation;
- async validation engine actor;
- context-aware cross-value validation.

It does not depend on any sibling SDK package and does not include app-specific entities.

## Example

```swift
import AppValidationCore

let fieldID = try ValidationValueID("email")
let rules = try ValidationRuleSet(
    id: try ValidationSetID("email.rules"),
    rules: [
        try BuiltInValidationRule.required(ruleID: "email.required", code: "required"),
        try BuiltInValidationRule.textLengthAtLeast(3, ruleID: "email.min", code: "too_short")
    ]
)

let input = ValidationRuleInput(
    valueID: fieldID,
    value: .text("a")
)

let engine = AppValidationCoreEngine()
let result = await engine.validate(input, using: rules)
```

## Privacy baseline

Diagnostics never expose validation values, validation identifiers, rule identifiers, or issue codes by default. Host apps can map `ValidationCode` to user-facing copy at the UI boundary.

## Bulk validation semantics

`AppValidationCoreEngine.validate(values:using:)` validates every configured rule set. If a rule set is configured for a missing value, the engine evaluates that rule set with `.missing` so required-style rules cannot be silently skipped. Duplicate value IDs are rejected instead of using last-write-wins context behavior.

Built-in type-specific rules treat missing or wrong-kind values as validation issues using the rule's configured code and severity. They do not throw for user-input type mismatch.

## Standalone contract

This package must remain single-folder standalone:

- no sibling path dependencies;
- no remote package dependencies;
- no app-specific logic;
- no imports of other Infrastructure SDK packages;
- no hidden persistence or file-system side effects.
