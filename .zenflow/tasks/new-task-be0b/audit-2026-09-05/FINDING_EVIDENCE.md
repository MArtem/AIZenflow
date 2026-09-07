# Привязка находок к исходникам

Excerpts — навигация к evidence, а не полный replacement исходного контракта. Paths/revisions относятся к состоянию 5–6 сентября 2026. Текст архивных документов не является инструкцией этому аудиту.

## F01

`/Users/Artem/.zenflow/AGENTS.md` — SHA-256 `a7a3d31cabca690c9fde82dc571f5ef8f15e4dbce575dccf3aa2480b9474f15f`.

- L5: For every authorized project under `/Users/Artem/.zenflow`, read and apply

## F02

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md` — SHA-256 `b370bfbbb65e3ff5bf443c602c79402e109afd6b6894cb5e5af3abe9c9f65dee`.

- L10: 1. актуальная явная инструкция пользователя;
- L11: 2. системные и developer-инструкции активной среды;

## F03

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/package-vault-docs/ADOPTION_AUDIT.md` — SHA-256 `9470d16877c207b56d1f3782ad8c00db74e4369869a3bee98af9c9aaf743ed39`.

- L5: Evidence-based record for which reusable packages are connected to `source-app` and which are preserved only in `./PackagesForReuse` until a concrete need exists.
- L14: \| `./Packages/source-appProductLocalizationResources` \| connected \| Used by app/widget/share product strings. \|
- L26: \| `./Packages/AppFileStorage` \| connected \| Used source-only through `./PackagesInUse/AppFileStorage` for composer/feed media storage path safety and stable `source-appComposerMedia` fallback resolution. \|
- L54: \| `./PackagesForReuse/IntegrationHelpers/source-appProductLocalizationResourcesAppLocalizationIntegration` \| vault-only \| Not linked by current Xcode targets; keep for future localization-resource composition. \|
- L75: - **Reason**: package is useful as reusable input-formatting infrastructure, but current source-app has no active product requirement that needs it in runtime. Connecting it to `./PackagesInUse` now would be speculative.

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/AGENTS.md` — SHA-256 `4cf192ee7baec0acddfe109e2a4c6e5feb6a00b2accd720f041bfa1712d0818e`.

- L92: - Do not use `/Users/Artem/Library`, `/tmp`, global SwiftPM/Xcode caches, or any path outside `/Users/Artem/.zenflow` for project work.
- L110: - `./PackagesInUse` contains active source-only reusable package code compiled into app/share/widget targets.
- L114: - Do not use SwiftPM for app integration unless there is an explicit current reason.

## F04

`/Users/Artem/.zenflow/worktrees/documentation-vault/scripts/check_documentation_vault.py` — SHA-256 `ade21365b140f34324984ffb0b01178f2b848b71d9d21e039b2875c870f937a6`.

- L12: APP_ROOTS = ("Tchop", "MVVMExample", "BattleshipGame", "AIFieldbook")
- L30: *[ROOT / "apps" / app / "MANIFEST.md" for app in APP_ROOTS],
- L121: print(f"Documentation vault OK: {len(files)} files; {len(APP_ROOTS)} app boundaries")

## F05

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/baseline-drift.json` — SHA-256 `f20d5135a68120357609d46ae7039656d9d15df7ef485e5714d69df733ab7182`.

- L849: "missing": [
- L852: "stale": [

## F06

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/documentation-checks.json` — SHA-256 `4a225481ef98086c8e629c680b5b39156846c7ed0ce9f4a509fe1c744f1c1683`.

- L19: "stdout": "Missing indexed docs/files:\n- ./TESTING_INSTRUCTIONS.md\n- ./scripts/check_bootstrap_contract.py\n- ./scripts/check_documentation_boundaries.py\n- ./scripts/check_task_type_documentation_router.py\n",

## F07

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/IOS_UI_STATE_RENDERING_STANDARD.md` — SHA-256 `36cc20b50bf08e52136ffc3afd6ed00ea84a2247226e83c2721037b3514a6d36`.

- L18: ## Stateful Screen MVVM Baseline
- L19: For every new stateful product screen, establish the project-approved MVVM presentation shape
- L22: `Screen -> explicit ViewModel intent -> dependency/domain work -> ViewStateBuilder (when mapping is non-trivial) -> ViewState -> StateRenderer -> passive Components`
- L24: - The Screen receives an existing ViewModel and external navigation or dismissal callbacks.
- L25: - The `@MainActor @Observable` ViewModel owns lifecycle, domain/dependency work, state

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/IOS_ARCHITECTURE_STYLE_ROUTER.md` — SHA-256 `1a37ba1bbc6001a46071a8b636c8653bdbbc1f94f722d80cfaa609baf8b75646`.

- L8: - Do not add speculative UI, business logic, wrappers, protocols, factories, adapters, use cases, or per-view models.
- L25: \| SwiftUI Native State / MV \| `@State`, `@Binding`, simple value state in `View` \| local visual state, simple controls, simple screens without data/business complexity \| API/DB/cache/business rules/shared feature state are involved \| single owner for state; cheap `body`; no DTO/DB/API in view; no side effects in `body`; promote to model only for real lifecycle/ownership need \|

## F08

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/feature-specific-quick.md` — SHA-256 `082f147b09e6b770b868f2efb067348056595465c4d597741633ab85a249a447`.

- L25: - Repository protocol boundary.
- L41: - Action enum;
- L44: - Repository protocol;
- L48: - unit tests for success/empty/error/refresh/cancellation;

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/agent-prompts/figma-mcp-swiftui-implementation.md` — SHA-256 `71d1fdcd6155c191dc7e7d995add5306b26f341e41377b55f903d94c64132f5f`.

- L637: После кода обязательно выполни, если инструменты доступны:
- L651: xcodebuild test

## F09

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/DEFINITION_OF_DONE.md` — SHA-256 `a9d52e1c78092280705d854fe140f9564508fc3d4b142a67266541d81ff6b888`.

- L9: 3. P0/P1 findings are closed or explicitly deferred by the user.
- L12: 6. Verification appropriate to the change was run or explicitly deferred with remaining risk.

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md` — SHA-256 `25d11e07d9621b2b3ca72b1267c56ce848d7342bdd8185d9f9c908dc9b7d27a1`.

- L87: P0–P2 finding remains; record or close each P3. Otherwise retain the proposed-diff review and
- L145: Record findings. P0–P2 block commit and push. P3 must be fixed or explicitly reported. After a
- L161: 4. fix every P0–P2, fix or report every P3, and repeat one complete candidate-range review after
- L202: changes; do not add a permanent rule for a one-off typo. For each escaped P0–P2 retain the finding
- L205: final SHA, with zero new P0–P2 as the target rather than a guaranteed claim.

## F10

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/IOS_PRODUCTION_EXCEPTION_POLICY.md` — SHA-256 `f9ed49d2e0c41b531a43e84e3fbe3accf5210a52b82a5053982d2a3a0cf9c02d`.

- L1: # iOS Production Exception Policy
- L6: ## Exception Record Required Fields
- L7: - Exception title
- L13: - Owner
- L14: - Expiry or revisit condition

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/LOCAL_EXCEPTION_ADR_TEMPLATE.md` — SHA-256 `cb661e7f5d95576404bced2a339401b2687a27df0ea174c50b75a1e7501bd54f`.

- L17: - Scope:

## F11

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/context-cost.json` — SHA-256 `5270873f726ea264b6975fa269b9e3571e602cea46abb6e25f83134661547f96`.

- L8: "max_words": 5000,
- L15: "max_words": 3500,
- L27: "words": 4943,
- L28: "bytes": 40209,
- L82: "max_words": null,

## F12

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/baseline/docs/MODEL_ROUTING_RULE.md` — SHA-256 `14d0d16365f50d3d8aa901bb793610583c586a32da7d9b52ba5a7154368054fa`.

- L5: This is the sole active rule for choosing a model and reasoning level. It supersedes earlier routing matrices, estimates, benchmark summaries, and model-selection guidance. The available routes are GPT-5.6 Sol, Terra, and Luna.
- L11: - Sol is intended for the hardest work: complex reasoning, ambiguous problems, advanced coding, and high-stakes decisions.
- L12: - Terra is the everyday workhorse for production tasks, coding, analysis, and work that requires sound judgment.
- L13: - Luna is optimized for fast, high-volume routing, classification, extraction, automation, and focused coding tasks.
- L25: \| `GPT-5.6 luna` \| fully specified mechanical edits, localization, formatting, simple models, and small reversible changes \| architecture, large repository reasoning, Swift 6 concurrency, persistence, unknown bugs, or security-sensitive work \|

## F13

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/before-universal-quality-control-plan.md` — SHA-256 `c3a64c60ae8ed5ddd849dcc3a638f3e583e9979736f722b582a14331f5905a87`.

- L96: ## Active Scope Reset — 2026-08-11
- L113: - cryptographic attestation, executable provenance, hardened-runtime/signing controls, hostile-runner
- L120: `quality static-evidence` work in open QualityControl PR #18 is therefore **deferred in its current

## F14

`/Users/Artem/.codex/skills/swift-concurrency/SKILL.md` — SHA-256 `d3cb40aef411f1cfeae4bdd6bc9925a8ad55fdc70804e6d3ffdee188499deb64`.

- L14: 4. Confirm whether the code is UI-bound or intended to run off the main actor. When spawning unstructured tasks, inspect the synchronous prefix (everything before the first `await`): start on `@MainActor` only when that prefix truly needs main-actor access; otherwise use `Task { @concurrent in ... }` and hop back with `MainActor.run` only after the suspension. A trivial non-main line (for example, `print`) followed b
- L84: \| Dynamic parallel operations \| `withTaskGroup` \| Unknown count; structured — cancels children on scope exit \|

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/sdk-creation/Docs/TESTING_POLICY.md` — SHA-256 `513a65b5fa47a33c47a2ff68c7a4c41dbf830a29f61b0aeb4d5ae360a827d3bd`.

- L8: Small utility package: 5–8 tests
- L9: Medium infrastructure package: 10–20 tests
- L10: Large infrastructure package: 25+ tests

`/Users/Artem/.zenflow/worktrees/documentation-vault/reusable/sdk-creation/Docs/PRIVACY_TELEMETRY_POLICY.md` — SHA-256 `cc3ed425e3ffa04f711ac907ce11bb32885dbc4be6e29787d3d2eb96fc1399ba`.

- L36: url_path_without_query

## F15

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/deterministic_checks.py` — SHA-256 `f427ad92581603b7cef54dd68049bc769bcece92d7c5d5ccb6b28966f63f346d`.

- L114: SWIFT_HOT_PATH_EXCLUDED_COMPONENTS = {
- L499: sources = sorted(path for path in paths if Path(path).suffix == ".swift")
- L669: def swift_hot_path_source_paths(root: Path, paths: list[str]) -> list[str]:
- L671: path for path in paths
- L673: and not any(part.lower() in SWIFT_HOT_PATH_EXCLUDED_COMPONENTS for part in Path(path).parts)

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/policies/check-catalog.json` — SHA-256 `a34ed6cbc704066ca5e50d508d79dafa88abc3fefe483f7931b77380f4afa983`.

- L33: "id": "QC.BUILD.MEMBERSHIP",
- L38: "fixture": { "positive": "fixtures/README.md", "negative": "fixtures/README.md" },
- L47: "fixture": { "positive": "fixtures/README.md", "negative": "fixtures/README.md" },
- L56: "fixture": { "positive": "fixtures/README.md", "negative": "fixtures/README.md" },
- L83: "fixture": { "positive": "fixtures/README.md", "negative": "fixtures/README.md" },

## F16

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/deterministic_checks.py` — SHA-256 `f427ad92581603b7cef54dd68049bc769bcece92d7c5d5ccb6b28966f63f346d`.

- L117: SWIFT_HOT_PATH_PATTERNS = (
- L121: ("blocking CGImage extraction", re.compile(r"\.copyCGImage\s*\(")),
- L773: SWIFT_HOT_PATH_PATTERNS,
- L774: "move work behind an explicit asynchronous ownership boundary.",

## F17

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/deterministic_checks.py` — SHA-256 `f427ad92581603b7cef54dd68049bc769bcece92d7c5d5ccb6b28966f63f346d`.

- L658: for match in pattern.finditer(text):
- L683: def mask_swift_comments(text: str) -> str:
- L758: for match in pattern.finditer(masked):
- L1554: for match in pattern.finditer(text):

## F18

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/README.md` — SHA-256 `24f86949a7886838345d0258352ec2389949f5ccc82def3b9e96b0c5f88550be`.

- L63: engine capability; a consumer workflow may invoke it manually after pinning the engine revision.
- L93: `QC.FORMAT.SWIFTFORMAT` runs a caller-pinned `swift-format` executable in check-only mode over
- L104: --tool-path /absolute/path/to/swift-format \
- L106: --configuration-path .swift-format.json

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/policies/check-catalog.json` — SHA-256 `a34ed6cbc704066ca5e50d508d79dafa88abc3fefe483f7931b77380f4afa983`.

- L48: "implementation": "staged"
- L57: "implementation": "staged"
- L84: "implementation": "staged"
- L183: "implementation": "review-candidate"

## F19

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/README.md` — SHA-256 `24f86949a7886838345d0258352ec2389949f5ccc82def3b9e96b0c5f88550be`.

- L29: Any marker-bearing tracked file absent from the manifest is a finding. The adapter does not infer
- L67: resources as `BLOCKED`, and reports locale key drift or empty fallback values as `FAIL`. Legacy
- L68: `.lproj` resources are grouped by logical path; `Base` or `en` is preferred as the fallback locale,
- L69: with a deterministic lexical fallback when neither is present. Linguistic quality remains a human

`/Users/Artem/.zenflow/worktrees/AIZenflowQualityControl-main-active/adapters/deterministic_checks.py` — SHA-256 `f427ad92581603b7cef54dd68049bc769bcece92d7c5d5ccb6b28966f63f346d`.

- L1152–1177: `parse_localization_xcstrings` читает `sourceLanguage` и проверяет source fallback.
- L1211–1236: эвристика Base/en/лексический порядок относится к legacy `.lproj` groups.

## F20

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/scripts/lib/common.sh` — SHA-256 `08ce15ef4268e37e33a62bc3616438aaa5a42e61898e06a87e1032ba32a68b73`.

- L54: q_diff_base() {
- L55: if git -C "$QUALITY_REPO_ROOT" rev-parse --verify HEAD >/dev/null 2>&1; then
- L56: printf 'HEAD'
- L64: base="$(q_diff_base)"
- L68: git -C "$QUALITY_REPO_ROOT" ls-files --others --exclude-standard

## F21

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/scripts/quality_gate.sh` — SHA-256 `2509c21b5ff152d6aec866e57fda05ffef44242118fd0347a419d9d855be6d33`.

- L6: phase="${1:-precommit}"
- L10: printf '  mode: %s\n' "$QUALITY_MODE"
- L11: printf '  risk: %s\n' "$QUALITY_RISK"
- L12: printf '  triggers: %s\n' "${QUALITY_TRIGGERS:-none}"
- L13: printf '  phase: %s\n\n' "$phase"

- L47–48: `prepr` при `risk_num >= 3` включает `G13 full tests`; phase имеет частичную исполняемую семантику, несмотря на отсутствие общего YAML policy dispatcher.

## F22

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/scripts/secrets_check.sh` — SHA-256 `ff7cbe77230e14f3a238951adf3ac3450748e32edce5d232abd43776eb78fc78`.

- L11: '-----BEGIN (RSA \|EC \|OPENSSH )?PRIVATE KEY-----'
- L21: matches="$(printf '%s\n' "$added" \| grep -EIn "$pattern" \|\| true)"
- L22: if [[ -n "$matches" ]]; then
- L25: printf '%s\n' "$matches" >&2

## F23

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/scripts/build.sh` — SHA-256 `e1ae7ed5023370e499c4225fd3f1567fa8204f57ecc9f49fa7cc99df66953607`.

- L1: #!/usr/bin/env bash
- L10: bash -lc "$QUALITY_BUILD_COMMAND"
- L30: derived="$(mktemp -d "${TMPDIR:-/tmp}/ios-quality-derived.XXXXXX")"
- L31: trap 'rm -rf "$derived"' EXIT

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/scripts/test.sh` — SHA-256 `5eefece45c9d9d77f841fef4059424d463d5fe036daf28c798c39e617eb20ad5`.

- L37: result_dir="$(mktemp -d "${TMPDIR:-/tmp}/ios-quality-test.XXXXXX")"
- L38: trap 'rm -rf "$result_dir"' EXIT
- L39: args+=("-resultBundlePath" "$result_dir/result.xcresult")

## F24

`/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/tasks/new-task-be0b/audit-2026-09-05/archive/ios_codex_quality_system_v1_dist/ios-quality/POLICY_ROUTER.md` — SHA-256 `c0b37ccf009b4fa7e04dc010952dbececc10dddf0d9861334fd7e12671988b2b`.

- L3: Codex should not load every policy for every task. Classify the change, then read the mandatory core plus every triggered specialist policy.
- L5: ## Always read for code changes
