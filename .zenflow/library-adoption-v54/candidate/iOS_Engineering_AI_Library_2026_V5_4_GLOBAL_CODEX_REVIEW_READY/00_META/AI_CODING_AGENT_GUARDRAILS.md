# AI Coding Agent Guardrails

1. Inspect before edit.
2. Never invent build success.
3. Never delete data/migrations/signing material to make tests pass.
4. Never weaken ATS, certificate validation, authorization, privacy or entitlements as a shortcut.
5. Never silence Swift concurrency with `@unchecked Sendable` unless invariant is documented and audited.
6. Never use `try!`/force unwrap for unknown external data.
7. Never rewrite an entire feature when a narrow fix is safer unless requested and justified.
8. Preserve generated files/build artifacts conventions; do not hand-edit generated code unless source generator is the intended change point.
9. Keep secrets out of prompts/logs/fixtures.
10. Every autonomous edit ends with diff review and evidence ledger.
11. If a change affects persistence/auth/payment/security/public API, automatically elevate risk and require rollback/compatibility analysis.
12. If a task depends on undocumented SDK behavior, create a small probe/test rather than guess.
