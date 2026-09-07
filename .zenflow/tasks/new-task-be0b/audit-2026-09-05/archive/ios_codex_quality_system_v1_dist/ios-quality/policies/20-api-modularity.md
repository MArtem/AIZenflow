# 20 — API Design and Modularity

## Public surface

Public API is long-lived compatibility debt. Keep it as small as possible.

## MUST

- make access level intentional;
- avoid exposing internal DTO/storage/network implementation types through module boundaries without reason;
- document behavioral contracts that callers depend on;
- consider source/binary compatibility policy for shared libraries;
- treat removing/renaming/changing signatures/semantics as public API change.

## Protocols

Use protocols for real abstraction/substitutability/boundary needs. Avoid one-protocol-per-type cargo cult.

Protocol requirements differ from extension-only methods; when dynamic witness dispatch is part of the intended contract, declare the requirement in the protocol.

## Generic/existential choice

- generics/opaque types preserve relationships and static specialization;
- existentials provide runtime heterogeneity at the cost of erased relationships;
- choose based on API semantics, not fashion.

## SPM modules

A package/module should be able to build/test according to its declared dependencies. It must not secretly depend on application-target internals.

Resources inside packages use package-bundle semantics (`Bundle.module`) where applicable.

## API-breaking gates

R3+ if changing a shared library/module consumed by multiple features/targets. Require call-site search and focused compatibility tests.
