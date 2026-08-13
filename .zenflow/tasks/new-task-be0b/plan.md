# Current Plan

## Goal

Migrate AI Fieldbook's iPhone Presentation layer, one independently buildable screen at a time,
to the approved screen architecture:

`Screen -> ViewModel -> ViewState -> StateRenderer/Components`

Use a pure `ViewStateBuilder` only where a screen has real domain-to-presentation mapping or
non-trivial derived display state. Preserve `AppComposition`, `AppCoordinator`, repositories,
persistence, file ownership, routes, and product behavior.

The accepted app-specific decision is ADR-010 in:

`/Users/Artem/.zenflow/worktrees/documentation-vault/apps/AIFieldbook/product/architecture-decisions.md`

## Active Constraints

- Active mode: `сбалансированный`.
- Architecture planning uses `GPT-5.6 sol`, `high`; bounded screen implementation uses
  `GPT-5.6 tera`, `medium` unless the routing rule identifies a concrete escalation need.
- Work on one self-contained screen iteration at a time, then stop for user-run build/UI QA.
- Each screen iteration may add several small source files plus update the Xcode project because
  this project uses explicit file references. Do not combine two screens in one iteration.
- Do not run builds, tests, Simulator UI, screenshots, Instruments, archive, or signing unless
  the user specifically delegates it for the current block.
- Do not write or modify tests without explicit user permission.
- Do not commit or push the app repository.
- Preserve behavior and all existing changes; no backend, provider credentials, cloud
  infrastructure, destructive SwiftData migration, or automatic data reset.
- iPad is outside product and verification scope.
- App Intents A1/A2 remain implemented. Their iOS 26.5 Simulator runtime limitation is not part
  of this Presentation migration.

## Architecture Contract For Every Screen Iteration

- `...Screen` receives an existing ViewModel and external navigation/dismissal callbacks.
- `@MainActor @Observable ...ViewModel` owns screen lifecycle, side effects, cancellation, and
  one authoritative render state; public UI APIs remain explicit intent methods.
- `...ViewState` contains render-ready values and explicit loading/content/empty/error/working
  states appropriate to that screen.
- `...ViewStateBuilder` is a pure presentation mapper. It performs no persistence, file I/O,
  navigation, task creation, or resource ownership, and is omitted when it would only mirror
  inputs.
- `...StateRenderer` switches mutually exclusive render states when such switching exists.
- Child components receive narrow immutable state and callbacks; they do not receive the broad
  feature ViewModel without an independent lifecycle reason.
- Local confirmation, focus, picker-presentation, and other visual-only state remains in SwiftUI.
- No generic base ViewModel, generic state protocol, action dispatcher, factory layer, Use Case,
  repository protocol, adapter, or new package.

## Migration Iterations

- [x] M0 — Record ADR-010 and replace the stale task plan with this migration sequence.
- [x] M1 — Workspace List vertical slice: extract the screen, model, render state, pure builder,
  renderer, and row component; update only its composition call site.
- [x] M2 — Workspace Detail vertical slice: explicit loading/content/empty/error/action-failure
  states and render-ready item rows; retain deletion transaction behavior.
- [x] M3 — Workspace Editor vertical slice: explicit form state, validation, saving/error state,
  and unsaved-change behavior.
- [x] M4 — Text Note Detail vertical slice: explicit detail/error/action-failure state and pure
  display mapping; retain tag/move/edit/delete callbacks.
- [x] M5 — Text Note Editor vertical slice: explicit form/loading/saving/failure state and
  create/edit mode mapping.
- [x] M6 — URL Reference Detail vertical slice: explicit detail/error/action-failure state while
  preserving share/open/tag/move/delete behavior.
- [x] M7 — URL Reference Editor vertical slice: explicit form/loading/saving/validation state and
  normalized URL rules.
- [x] M8 — Search vertical slice: explicit criteria/searching/results/empty/error state, immutable
  result rows, and existing debounce/cancellation/stale-result protection.
- [x] M9 — Tag Manager vertical slice: explicit loading/content/empty/error/mutation state and
  immutable tag-row presentation.
- [x] M10 — Move Item vertical slice: explicit destination loading/content/empty/error/moving
  state while preserving repository mutation behavior.
- [x] M11 — Import Item vertical slice: explicit destination/ready/importing/error state while
  preserving file validation, copy, and rollback behavior.
- [x] M12 — Imported Item Detail vertical slice: explicit loading/content/error/action-failure
  state; split preview and metadata components. Keep `AudioPlaybackModel` as an independent
  media-resource owner rather than folding it into passive view state.
- [x] M13 — Audio Recorder vertical slice: separate recorder runtime status from render-ready
  screen state while preserving permission, interruption, route-change, draft cleanup, and save
  rollback behavior.
- [x] M14 — Settings vertical slice: explicit content/working/export-ready/error state while
  preserving cleanup, export cancellation, destructive reset, and navigation reset behavior.
  The user reported that the complete UI verification included the Settings edge-flow.
- [x] M15 — Capture chooser and physical cleanup: split the stateless chooser into its own Screen
  and passive components without inventing a ViewModel/Builder; remove the final obsolete
  aggregate presentation files and verify naming/folder consistency. The user reported the M15
  build and UI verification passed.
- [ ] M16 — Iteration 2.1 + 2.2 local image OCR: add explicit capability/provenance contracts,
  additive SwiftData V3 storage, local Apple Vision execution, cancellation, export/delete
  lifecycle, and a manual Imported Item Detail result surface. Static implementation is complete;
  user-owned build, migration/relaunch, and UI verification remain open.

## Per-Iteration Static Acceptance

- The iteration changes one screen only and leaves all later screens working in their current
  architecture.
- No product behavior, persistence contract, navigation route, or resource lifecycle is expanded.
- Xcode source references match the new physical files.
- Targeted symbol/reference inspection finds no duplicate or stale type names for that screen.
- Run `git diff --check` once for the complete iteration.
- Stop for user-run compile and UI verification; do not claim runtime completion before that
  evidence.

## Next Executable Step

Run the user-owned M16 build and focused UI check: migrate/relaunch with existing content, import
an image containing text, recognize/copy/persist/recognize-again, cancel an in-flight request,
verify an image with no readable text, and verify the failure path leaves the original intact.
Also confirm non-image imported items do not expose OCR. Do not begin another AI capability until
this block is accepted.

## Deferred App Intents State

- Gate `1.26-S` is accepted; A1 Open Workspace and A2 Find Knowledge Items are implemented.
- Shortcuts runtime verification remains blocked by the confirmed iOS 26.5 Simulator / `linkd`
  regression; do not add signing, device work, or a workaround without separate approval.

## Context Transfer Rule

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
