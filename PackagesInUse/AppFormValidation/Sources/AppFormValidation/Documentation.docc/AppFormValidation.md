# AppFormValidation

Standalone form validation primitives for Swift applications.

## Overview

`AppFormValidation` provides app-independent building blocks for validating forms without coupling validation to UI, networking, persistence, analytics, or product-specific models.

The package includes:

- safe form, field, rule, and code identifiers;
- privacy-safe field values and diagnostics;
- touched and dirty field state;
- built-in required, length, and equality rules;
- an async validation rule protocol for host-owned checks;
- a validator actor;
- an explicit snapshot store boundary;
- an in-memory standalone store for tests and simple use cases.

## Standalone contract

This root package has no sibling package imports and no remote package dependencies. Host apps can compose it with storage, logging, networking, or analytics packages outside this package.

## Privacy baseline

Descriptions and debug descriptions do not reveal raw field values. Identifiers are redacted in diagnostics by type and length.

## State and concurrency

`FormStateController` serializes form operations across suspending store calls. This keeps concurrent field updates from overwriting each other with the same source revision when a durable store or test store suspends during `load` or `save`.

## Host-owned policy

The package returns validation issue codes and severities. Host apps own localized display strings, accessibility phrasing, field labels, analytics decisions, and product-specific limits.
