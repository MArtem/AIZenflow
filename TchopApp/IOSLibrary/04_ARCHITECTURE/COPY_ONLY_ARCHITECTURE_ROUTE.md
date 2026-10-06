# Architecture and state ownership — curated copy-only route

Use after project-local architecture rules when a task changes feature boundaries, state owners,
dependency direction, navigation ownership or a public module contract. This route distills
`IOS-04-01` through `IOS-04-12`; historical generic prompts are not active instructions.

- Detect the existing style from actual types and data flow before applying a style-specific
  review. Native SwiftUI state, MVVM, UIKit MVC, coordinators, layered architecture and reducers
  have different valid boundaries. Do not convert a project to a preferred style by default.
- Identify one owner for each mutable state concept and name producers, consumers, lifecycle,
  cancellation, ordering, failure and persistence contracts. Rendering should not secretly own
  network/database effects or perform expensive transformations in a hot path.
- Keep dependency direction and module APIs intentional. Introduce a protocol, use case,
  adapter, factory, ViewModel, reducer or package only when a current boundary needs it; a
  pass-through layer is not evidence of quality.
  Trace actual injected dependencies and their scopes; a global container/service locator or
  coordinator must not hide a dependency or become the owner of unrelated effects. Assess
  change amplification, coupling and operational/team cost, not layer or file count alone.
  Keep remote/local/cache orchestration and DTO/domain mapping tied to the data contract rather
  than adding a repository/service boundary automatically. Prefer repairing the demonstrated
  ownership seam over a broad rewrite for an unproven diagnosis.
- For MVVM, follow the project's public intent conventions. Generic action dispatch is not a
  universal default. For reducer-style code, review pure transitions, effect ownership and
  cancellation under that project's chosen architecture.
- Trace every consumer before moving an owner or API, including app/extension targets, tests,
  serialization and navigation. A broad or durable architecture migration needs an explicit
  user decision and a reversible transition plan; this route alone cannot authorize it.
- For legacy modernization, define one bounded slice and characterize its existing observable
  behavior from source and permitted evidence. Trace old/new coexistence, compatibility seams
  needed by actual consumers, rollout/rollback and the criterion for retiring the old path.
  Recommend characterization/regression checks when useful; do not add an adapter or shim
  solely to reproduce a historical checklist.

Review the complete affected code, target and documentation diff. Choose compile, test and
runtime evidence only when authorized; otherwise state which ownership or integration claims
remain unverified. Do not invent an architecture or an ADR requirement for a trivial edit.
