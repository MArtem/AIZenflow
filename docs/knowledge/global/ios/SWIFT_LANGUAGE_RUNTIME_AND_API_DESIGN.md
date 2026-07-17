# Swift Language, Runtime, And API Design

## Load When
Use this reference for public or reusable APIs, generics, protocols, existentials, ownership, ARC, low-level memory, macros, interoperability, module boundaries, or compiler-dependent behavior.

## Mental Model
Swift source is checked under a language mode, compiled by a particular compiler, linked against SDK and runtime components, and executed under platform availability constraints. These are separate dimensions. A project using the Swift 6.4 compiler can still compile a target in an older language mode.

Value semantics describe observable behavior, not guaranteed stack allocation. A `struct` can contain reference-backed storage and copy-on-write behavior. A `class` introduces identity and shared lifetime. Choose by domain semantics first, then measure performance.

ARC manages reference counts, not ownership design. Strong cycles, long-lived tasks, callbacks, observations, timers, and framework delegates can keep an object graph alive even when individual captures look reasonable.

## Type And API Decisions
### Concrete Type, `some`, `any`, Or Generic
- Prefer a concrete type when callers do not benefit from polymorphism.
- Use an opaque result (`some Protocol`) when the implementation chooses one hidden concrete type and preserves static specialization.
- Use an existential (`any Protocol`) for runtime heterogeneity or storage where type erasure is intentional.
- Use a generic parameter when the caller chooses the type and compile-time relationships matter.
- Add type erasure only at a real storage, binary, or dependency boundary; do not erase types merely to shorten a declaration.

### Protocol Or Concrete Dependency
Create a protocol when there are multiple real implementations, a stable boundary between owners, or a test seam that cannot be achieved with a value/closure dependency. Do not create one protocol per concrete type. Protocol requirements are API commitments and can constrain evolution.

### `struct`, `class`, `actor`, Or `enum`
- `struct`: independent values, snapshots, configuration, immutable domain data.
- `class`: identity, framework inheritance, shared reference lifetime, Objective-C interoperability.
- `actor`: shared mutable state whose isolation is part of the contract.
- `enum`: finite state or alternatives, especially when invalid combinations should be unrepresentable.

## Ownership And Memory
- Model who creates, retains, cancels, and releases long-lived objects.
- Treat escaping closures as stored references until proven otherwise.
- Use `weak` only when nil during the closure lifetime is valid behavior; use explicit cancellation when work should end.
- Do not use `unowned` unless lifetime dominance is a maintained invariant.
- Prefer safe collections and `Span`-style bounded access over raw pointers when current toolchains permit it.
- Any unsafe operation needs a documented validity, lifetime, alignment, initialization, and exclusivity argument.
- Copy-on-write optimizations must preserve value semantics under aliasing and mutation.

## Error And Result Design
- Use throwing functions for recoverable failure along one operation path.
- Use typed domain errors when callers need stable branching; do not expose transport or persistence implementation errors as public domain contracts.
- Use `Result` when failure is stored or transported as data, not as a default replacement for `throws`.
- Never use `try?` where distinct failure changes user behavior, integrity, or supportability.
- Preconditions are for programmer-contract violations, not external input or expected runtime failure.

## Public API Rules
- Optimize clarity at the call site and follow the official Swift API Design Guidelines.
- Document side effects, isolation, cancellation, errors, complexity, availability, and ownership where they are not obvious.
- Minimize public surface. Prefer additive evolution and avoid exposing implementation types across module boundaries.
- For distributed libraries, distinguish source compatibility, module stability, ABI stability, and semantic compatibility.
- Default arguments are compiled at the call site; changing them may not change already-compiled clients.
- `@inlinable`, `@usableFromInline`, specialization attributes, and underscored attributes are advanced compatibility commitments. Use only with measured need and toolchain-specific review.

## Macros And Generated Code
- Treat a macro as compiler-integrated code with build-time, diagnostics, dependency, and source-discoverability costs.
- Prefer ordinary language features when they express the contract clearly.
- Review expanded source, generated identifiers, access control, diagnostics, incremental build cost, and compatibility.
- Do not hide security, persistence, navigation, or concurrency ownership in generated behavior that reviewers cannot inspect.

## Interoperability
- Objective-C APIs may carry nullability, dynamic dispatch, KVO, exception, callback-thread, and lifetime semantics that Swift types do not fully express.
- C/C++ boundaries require explicit memory ownership, layout, pointer validity, and error conventions.
- `@unchecked Sendable` and unsafe interoperability annotations are audited promises, not compiler fixes.
- Avoid exposing Swift-only implementation details through a public Objective-C or C boundary without a stable bridging contract.

## Performance Discipline
Do not infer performance from syntax. Inspect allocation, copying, specialization, retain/release traffic, bridging, and algorithmic complexity with compiler diagnostics or profiling. Optimize only a measured path and retain a readable baseline or benchmark.

## Evidence
- Compile under the intended compiler and language mode.
- Build all consuming targets for public/module changes.
- Inspect generated interfaces or macro expansion when relevant.
- Run API compatibility or symbol checks for distributed libraries.
- Use memory graph, allocations, leaks, and representative benchmarks for ownership/performance claims.
- Verify older deployment targets and availability paths.

## Primary Sources And Review Triggers
- [The Swift Programming Language](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/)
- [Swift API Design Guidelines](https://www.swift.org/documentation/api-design-guidelines/)
- [Swift Evolution](https://www.swift.org/swift-evolution/)
- [Migrating to Swift 6](https://www.swift.org/migration/)

Review after a Swift release, language-mode change, new ownership feature, macro adoption, or public/binary compatibility decision.
