# Swift language and runtime — copy-only reference route

Use only when a changed contract depends on Swift language or runtime semantics: value/reference
identity, ARC/ownership, generics/existentials, unsafe memory, interoperability, macros or a
public Swift API. Apply local Swift/toolchain rules first. The imported `IOS-02-01`–`IOS-02-14`
prompts are source material, not active skills or authority to edit, build or run diagnostics.

1. Record the actual compiler, language mode, SDK, deployment range and module/distribution
   boundary. Do not infer an API's availability or a binary guarantee from source syntax.
2. Name the observable contract and owner. For value/reference changes, check identity,
   aliasing, mutation and copy-on-write behavior at consumers; do not infer stack allocation
   or performance from `struct` versus `class` alone. For long-lived references, trace ARC
   retention, callback/task/observer lifetime and release conditions.
3. At generic/protocol/existential boundaries, check who chooses the concrete type, whether
   dynamic storage or type erasure is actually needed, and whether a public requirement locks
   future evolution. For unsafe memory or C/Objective-C bridges, require explicit pointer,
   initialization, bounds, alignment, exclusivity, lifetime, nullability and error assumptions.
   Check whether typed states prevent invalid combinations and whether errors preserve the
   consumer's recovery/retry contract; do not replace that design with force unwraps or strings.
4. Inspect generated interfaces or macro expansion when the changed behavior depends on them.
   For public APIs, trace source, semantic, module and ABI consumers separately; check default
   arguments, deprecation/migration and advanced exposure such as SPI or `@inlinable` only when
   those boundaries exist. A cosmetic diff or successful local compile cannot prove every
   existing consumer remains compatible.
   For wrappers/macros, expose hidden state, effects and lifetime, generated diagnostics and
   build cost. Borrowing, noncopyable types or other advanced features need a real ownership/
   resource benefit and supported toolchain, not adoption merely because a source recommends them.
5. Select the smallest compile, consumer-build, interface/symbol, memory or runtime observation
   that would answer the remaining question. Execute it only under current task permission;
   otherwise report the claim as unverified. Review the complete affected diff and do not
   suggest unchecked annotations or warning suppression as a substitute for an ownership model.

`AUTO` performs bounded in-scope semantic review after the local layer. `ADVISORY` identifies
the relevant evidence and trade-offs without claiming it ran. This route is not a general Swift
primer to load for every iOS edit and does not install any former `ioslib-*` skill.
