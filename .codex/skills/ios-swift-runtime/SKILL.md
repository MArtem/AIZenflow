---
name: ios-swift-runtime
description: Use for Swift language, compiler, ARC, ownership, generics, protocols, existentials, macros, unsafe memory, interoperability, public API, ABI, module stability, or binary compatibility work. Trigger when the task depends on Swift semantics rather than only app architecture.
---

# iOS Swift Runtime

## Required Context
Read:

- `./docs/IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md`
- `./docs/knowledge/global/ios/SWIFT_LANGUAGE_RUNTIME_AND_API_DESIGN.md`
- the affected module's build settings and public interfaces

## Workflow
1. Record compiler version, language mode, SDK, deployment target, and module/distribution boundary.
2. Identify the semantic question: value/reference identity, ownership, dispatch, generic/existential behavior, unsafe memory, interoperability, macro expansion, or compatibility.
3. Compare the smallest viable designs and state call-site, evolution, performance, and ownership tradeoffs.
4. Inspect actual consumers and generated interfaces/expansion when relevant.
5. Implement only after invariants and compatibility expectations are explicit.
6. Select compile, consumer-build, memory, benchmark, or binary evidence from the claim.

## Guardrails
- Do not infer allocation or dispatch from syntax alone.
- Do not add protocols or type erasure without a real boundary.
- Treat unsafe and unchecked annotations as audited promises.
- Do not expose implementation types or compiler-specific attributes casually.
- Distinguish source, semantic, module, and ABI compatibility.

## Output
Report the semantic model, chosen alternative, rejected alternatives, ownership/compatibility risks, affected consumers, and required evidence.
