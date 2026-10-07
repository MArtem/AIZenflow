# Project facts to gather before iOS advice or changes

This is a read-only checklist derived from `v5.4/00_META/PROJECT_CONTEXT_TEMPLATE.md`. Inspect only
facts relevant to the task. Do not create a project file or save a profile merely because this
reference was read. Mark unavailable facts `UNKNOWN`; never fill gaps from another app.

- Product goal, acceptance criteria, non-goals, supported user journeys and affected targets.
- Toolchain and platform range: Xcode/Swift language mode, deployment targets, availability,
  build configuration and target membership.
- Local rules and conventions: source layout, architecture, state owner, dependency direction,
  error model, naming, existing analogous implementation, tests and CI entry points.
- Relevant integrations: API/data contracts, persistence and migration, authentication,
  privacy/security, observability, localization, accessibility and third-party dependencies.
- Task-specific constraints: public API, compatibility, feature flags, offline behavior,
  failure/retry/cancellation, performance budgets and release restrictions.

Use these facts to choose the smallest relevant reference route. Missing toolchain or design
facts restrict claims; they do not authorize setup, installation or project mutation.

Distinguish compiler version, Swift language mode and SDK version. A library date or archived
technology baseline is not proof of the project's released APIs. Check current official sources
or the installed SDK when a recommendation depends on availability or changing policy; label
beta/snapshot assumptions and preserve the supported-platform fallback. Do not raise the minimum
OS, change package integration or migrate frameworks merely to match an archived preference.

When a fact matters to a recommendation, label its provenance: `OBSERVED` in an inspected
file/tool result, `DERIVED` by a repeatable transformation, `HEURISTIC` from a fallible pattern,
or `UNKNOWN`. Do not promote a heuristic to a project rule. A project's existing maintained docs
and decisions remain authoritative; reference does not generate `.ai/project`, a hidden model,
nested `AGENTS.md`, or a profile as a side effect of intake. Ask before writing any new project
documentation and preserve human decisions separately from mechanically derived facts.

If an already selected profile or generated report supplies a relevant fact, verify its source,
revision and freshness against current project files. Keep stale or untraceable facts UNKNOWN;
neither the report's existence nor a generated field grants authority. This validation does
not require creating or rewriting a profile or invoking the retired installed runtime.
