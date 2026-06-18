# ``AppValidationCore``

Reusable validation primitives for standalone Swift packages and applications.

## Overview

`AppValidationCore` contains the low-level validation layer used to describe values, rules, issues, severities, and rule sets without coupling to any UI or app-specific domain.

The package intentionally does not store forms, write files, send network requests, or log diagnostics.

Bulk validation validates every configured rule set. Missing configured values are evaluated as `.missing` instead of being skipped, and duplicate value IDs are rejected before rule evaluation. Built-in type-specific rules report missing or wrong-kind values as validation issues using the configured code and severity.

## Topics

### Identifiers

- ``SafeValidationIdentifier``
- ``ValidationSetID``
- ``ValidationValueID``
- ``ValidationRuleID``
- ``ValidationCode``

### Values

- ``ValidationValue``
- ``ValidationValueKind``
- ``NamedValidationValue``
- ``ValidationContext``

### Issues and results

- ``ValidationIssue``
- ``ValidationSeverity``
- ``ValidationResult``

### Rules and engine

- ``ValidationRule``
- ``ValidationRuleInput``
- ``BuiltInValidationRule``
- ``ValidationRuleSet``
- ``AppValidationCoreEngine``

### Failures

- ``ValidationFailure``
