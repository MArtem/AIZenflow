# 03 — Swift Language Policy

## Baseline

Use the project’s configured Swift language mode and compiler. Do not silently adopt syntax/features unavailable to its toolchain or deployment target.

For modern projects, Swift 6 language mode is preferred because full data-race safety becomes part of compiler checking. Legacy projects should migrate intentionally, module-by-module if needed.

## API clarity

Follow Swift API Design Guidelines:

- optimize names for clarity at the call site;
- omit needless words;
- name parameters by role, not type;
- mutating operations should read as imperative verbs;
- boolean properties should read as assertions (`isEmpty`, `hasAccess`).

## Value vs reference semantics

SHOULD prefer `struct`/`enum` when:

- independent copies are semantically correct;
- shared identity is unnecessary;
- mutation does not need shared observation.

Use `class` when identity/reference semantics/lifecycle/interoperability are required.

## Optionals and force operations

MUST NOT introduce force unwrap/force cast/`try!` unless a local invariant makes failure impossible and the invariant is obvious or documented.

Prefer:

- `guard let` for required preconditions;
- optional chaining for optional behavior;
- throwing/result state for recoverable failures.

## Errors

Do not erase errors with broad `try?` when failure affects correctness, persistence, security, or user-visible behavior.

## Access control

- Keep implementation details `private`/`fileprivate`/`internal` where possible.
- Treat new `public`/`open` API as compatibility surface.
- Public `Sendable` conformance is part of API contract and must be intentional.

## Generics / existentials

- Use generics/`some` when preserving concrete type relationships matters.
- Use `any` when runtime heterogeneity/type erasure is actually needed.
- Avoid type erasure merely to silence generic complexity without understanding lost constraints.

## Collections/performance

Avoid unnecessary repeated allocation/copying in hot paths. Do not optimize speculatively; use measurement for performance-sensitive changes.

## Unsafe constructs — review triggers

- `UnsafePointer` family;
- `withUnsafe*` APIs;
- `Unmanaged`;
- Objective-C runtime tricks;
- manual memory layouts;
- `withoutActuallyEscaping`;
- unchecked casts.

Any new use requires an invariant explanation and focused tests.

## Warnings

MUST NOT globally suppress compiler warnings. New warnings caused by the change must be resolved. Projects configured to treat warnings as errors must remain clean.
