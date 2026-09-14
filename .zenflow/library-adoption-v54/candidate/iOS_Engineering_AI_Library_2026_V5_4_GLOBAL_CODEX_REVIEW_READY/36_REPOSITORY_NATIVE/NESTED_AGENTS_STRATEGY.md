# Nested AGENTS Strategy

Good candidates for nested instruction files:
- `Sources/Persistence/` — schema/migration invariants.
- `Sources/Auth/` — secret/session/logout semantics.
- `Sources/SDK/` — public API/ABI/source compatibility.
- `Extensions/` — restricted APIs, lifecycle/background budgets.
- `Tests/` — fixture/test isolation conventions.
- `Generated/` — never hand-edit; regeneration command.
- `Scripts/Release/` — signing/release safety.

Install a nested file only after the real repository paths are known. Templates live in `39_PROJECT_CONTEXT/NESTED_AGENTS_TEMPLATES/`.
