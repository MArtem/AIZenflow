# Targets, packages and resources — curated copy-only route

Use this route when an iOS task changes project structure, a build-graph input or a public
SDK/package API. It distills the relevant concerns from imported `IOS-16-01`, `IOS-16-02`,
`IOS-16-04`, `IOS-16-05` and the former `ioslib-sdk-api` checklist. Their generic copy-paste
prompts and installed-runtime instructions are not execution authority. Apply current project
rules, exact target facts and user permissions first; do not assume any project uses SwiftPM,
source-only packages, a particular persistence runtime or a specific app architecture.

## Inspect before changing

- Identify the actual workspace/project, affected target and scheme, configuration, destination,
  toolchain, deployment range and package integration mode. Unknown values remain unknown.
- Trace each changed graph edge: source compilation, generated output, resource copy, script
  phase, package product, linkage, embedding, signing or extension consumption. Inspect the
  effective setting or project file, not only the Xcode sidebar.
- Identify every producer and consumer: app, tests, extension, widget, package product and build
  configuration. A file's physical presence is not proof it is included in a target.

## Review the change contract

- Sources and resources have intentional target membership with no duplicate compilation,
  embedding or conflicting bundle lookup. Package resources use the correct owning bundle;
  app/extension consumers can actually access them.
- Module/package dependencies have a clear direction and no new cycles or accidental public API.
  Put reusable, entity-neutral mechanics in the package only when the current package contract
  supports that boundary; keep product-specific mapping, schema, routing and UX policy in the app.
  Do not add decorative wrappers over an adequate package surface.
  Check test seams and expected build-time impact at affected consumers rather than assuming
  that extracting a module automatically improves testability or compilation time.
- Build settings, availability, capabilities, entitlements and environment configuration remain
  consistent across affected targets. Do not expose secrets through settings dumps or logs.
- Generated code has a known source, version and output contract. Script phases declare inputs
  and outputs where possible and must not silently overwrite human-owned files.
  Check deterministic generation, schema/version inputs and the project's checked-in output
  policy; correct the generator/source of truth rather than hand-editing derived output.
  Review cache keys and invalidation against all relevant inputs, pinned dependency/toolchain
  facts and local/CI parity. Cache only artifacts whose reproduction contract is understood.
  For a build-performance claim, distinguish compiler/type-checking, linking, codegen/scripts
  and dependency graph costs using proposed or observed timing evidence before restructuring.
  Plugins/macros and formatter/linter changes need bounded scope; passing style checks never
  justifies compiler suppressions, unrelated churn or hidden developer-machine modifications.
- A new or changed dependency has an explicit need, ownership, transitive/plug-in/script and
  binary provenance review, platform/license/privacy impact and removal cost. No dependency
  resolution or download follows merely from consulting this route.
  Include maintenance status and expected binary-size, memory and performance impact in that
  decision; recommend measurements only when they resolve a material uncertainty.
- For a third-party SDK, check whether an existing project/package boundary already fits before
  proposing a wrapper. If a seam is needed, keep it narrow: map lifecycle, configuration,
  vendor errors, consent-dependent calls and replacement/rollback at actual consumers. Do not
  add a decorative facade or claim vendor interchangeability without consumer evidence.
  Inspect actual initialization/offline/failure behavior, callback isolation and startup cost;
  lazy initialization is an option only if the required lifecycle permits it. Framework adoption
  needs state/effect/dependency scope, team fit and migration-cost evidence, not popularity.
  Recommend synthetic contract/upgrade comparisons only when useful and authorized; vendor debug
  modes or logs must not introduce secret exposure or unauthorized production access.
- For a public SDK/package API, enumerate changed exported symbols and Objective-C exposure;
  distinguish source, semantic, module and ABI compatibility for the actual distribution
  boundary. Trace existing source and binary consumers, version/deprecation commitments,
  migration path and documentation. An additive declaration can still change behavior or
  overload resolution; do not infer compatibility from the diff shape alone.

## Evidence and handoff

Review the **complete** source, project, resource, package, configuration and documentation diff.
Select affected build/test/QA checks by risk and permission; report their exact target/configuration
scope and observed result. If build, signing, dependency resolution, simulator or release work is
not authorized, do not run it and do not claim the graph works at runtime. A clean static diff
is not evidence that every affected target compiles or finds its resources. For a distributed
SDK, recommend consumer-build, generated-interface or API/symbol comparison only when it would
answer a concrete compatibility question and is separately authorized; otherwise mark it unverified.
