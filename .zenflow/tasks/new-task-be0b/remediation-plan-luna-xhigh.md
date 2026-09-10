# Luna xhigh remediation plan — independent audit closure

## Execution identity

- Task: `new-task-be0b`.
- Required implementation route: **GPT-5.6 Luna, reasoning xhigh**.
- Operating mode: `эконом`.
- Starting application revision: `0d22978cd397a313a130fe62a7b4922301736ccc` on `development`.
- Starting documentation revision: `398744c129a51d48d31cfd40469c3d8bb283bf9d` on `main`.
- Recommended implementation branch: `codex/audit-remediation-luna`.
- This plan supersedes the `30/30` completion claim as the current executable plan. The previous
  state remains recoverable in Git and in `universal-quality-control-plan.md` plus its receipts.

Before implementation, reread Level 0, the documentation-governance route, universal QC route,
iOS review/evidence route, reusable-package route, current `plan.md`, and this file. Apply
`ENGINEERING_CHANGE_QUALITY_STANDARD.md` before every commit and push.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

## Objective and final verdict

Close the independent-audit findings without weakening a gate, deleting unique evidence, or
turning an internal pilot into a stable/release claim. Completion requires:

1. canonical baseline drift is zero under the canonical policy;
2. the repository static gate passes with retained ignored runtime evidence present;
3. German locale metadata and the package-migration tool agree with owner-selected Option A;
4. current task state is compact, non-contradictory, and bound to the final SHA;
5. reusable package catalog, app adoption authority, package docs, and snapshot identities agree;
6. the reusable knowledge registry reports current evidence and honest maturity;
7. a fresh final-diff semantic review finds no P0–P2; P3 is fixed or explicitly recorded.

The final permitted claim is `INTERNAL_PILOT_COMPLETE_WITH_ACCEPTED_LIMITATIONS`. Stable QC
promotion, TestFlight, App Store, signing, tagging, rollout, and production readiness remain out of
scope unless the user separately authorizes them.

## Global change contract

- **Behavior:** restore trustworthy documentation/QC/package evidence while preserving current app
  behavior and the accepted unsupported-German decision.
- **Authority:** Documentation Vault owns reusable policy and package documentation; Tchop app docs
  own adoption/localization decisions; AIZenflow owns consumer scripts, profile, Xcode metadata,
  task state, and evidence.
- **Producer/consumer agreement:** canonical policy must classify every mirror; static gates must
  distinguish tracked authority from allowed ignored evidence; package manifests must identify the
  exact source consumed by app-owned adoption records.
- **Ordering:** canonical decisions first, consumer mirrors second, current-state receipts last.
- **Resource envelope:** no global caches or artifacts outside `/Users/Artem/.zenflow`; do not scan
  secrets or follow symlinks; preserve retained runtime evidence.
- **Failure semantics:** unavailable or stale evidence is `BLOCKED`/`STALE`, never `PASS`; any P0–P2
  blocks commit/push and final closure.
- **Tests/builds:** the planning phase grants no new runtime authority. Before modifying tests or
  running build/test/Simulator commands, re-check the current explicit permission record. Static
  fixture tests that do not invoke Xcode remain part of the relevant script change when permitted.

## Phase 0 — fresh baseline and immutable audit receipt

- [ ] Create `codex/audit-remediation-luna` from the confirmed clean `origin/development` SHA.
- [ ] Record local/remote identities for AIZenflow, Documentation Vault, and QualityControl.
- [ ] Reproduce the six P2 findings and P3 inventory before editing; save commands, exit codes, and
  hashes in a new machine-readable audit receipt.
- [ ] Confirm that no app source, package source, tests, build products, or historical receipts have
  changed before the first patch.

Acceptance: clean starting state, exact SHAs, all findings independently reproducible. A changed
starting SHA invalidates the receipt and requires a refresh.

## Phase 1 — canonical baseline authority and drift

- [ ] Diff the five disputed paths against canonical baseline:
  `REUSABLE_BASELINE_POLICY.json`, `TASK_DOCUMENT_ROUTES.json`,
  `check_docs_consistency.py`, `check_repository_integrity.py`, and
  `check_swift6_gate_contract.py`.
- [ ] Keep `REUSABLE_BASELINE_POLICY.json` and `TASK_DOCUMENT_ROUTES.json` canonical-first and exact.
  Promote valid app-neutral route/policy changes to Documentation Vault before copying them back.
- [ ] For `check_docs_consistency.py`, promote reusable behavior into the canonical checker; split
  any Tchop-only behavior into a separately named local extension instead of exempting the core.
- [ ] Add `check_repository_integrity.py` and `check_swift6_gate_contract.py` to the canonical
  local-only classification only if their contents remain consumer-specific; otherwise promote
  them as exact mirrors.
- [ ] Remove the local policy's ability to authorize its own divergence.
- [ ] Run canonical vault checks, regenerate manifests only if required, commit/push Documentation
  Vault, confirm remote SHA, then update the AIZenflow mirrors.

Acceptance: canonical drift checker reports `missing=0`, `stale=0`, `unexpected=0`, policy failures
zero; worktree validators still pass. Do not accept a result produced only by the modified local
policy.

## Phase 2 — static metadata gate with retained runtime evidence

- [ ] Refactor metadata preflight in `run_static_quality_gates.sh` so the narrow ignored-artifact
  allowlist is resolved before recursive symlink rejection.
- [ ] Never follow symlinks. Reject symlinks in tracked/authoritative metadata, ignored symlinks
  outside the allowlist, escapes, and malformed allowlisted paths.
- [ ] Add deterministic positive and negative fixtures for: current allowed runtime symlink,
  tracked symlink, ignored symlink outside allowlist, nested escape, and ordinary ignored runtime.
- [ ] Preserve the current metadata receipt schema and fail-closed behavior.

Acceptance: the complete static gate passes on the current worktree with
`runtime/tchop-8-2/qc-build/debug` retained; every deliberate negative fixture fails with the
expected check ID/message; `git diff --check` passes.

## Phase 3 — German locale and Xcode migration tool

- [ ] Remove `de` from `knownRegions` while `de.lproj` is absent, preserving `en`, `ru`, and `Base`.
- [ ] Remove the hard-coded German insertion from `migrate_packages_in_use_project.py`; derive
  regions only from current resource directories or leave region ownership to an explicit input.
- [ ] Introduce an explicit non-mutating `--check`, an explicit mutating mode, and functional
  `--help`. Unknown arguments must fail without writing.
- [ ] Make migration idempotent: two applications produce the same bytes; `--check` on the
  committed project produces no diff.
- [ ] Add bounded script fixtures for group ordering, locale removal, missing resources, and
  no-write failure paths. Update every command example to use the new CLI contract.
- [ ] Correct the German decision receipt's current status without rewriting historical evidence;
  point it to the new remediation receipt.

Acceptance: `de.lproj` absent in both package copies, `de` absent from Xcode regions, localization
catalog PASS, `plutil` PASS, migration check PASS, apply/apply idempotence PASS. Run graph-static
evidence after the final Xcode metadata change; build only if separately authorized.

## Phase 4 — package-library authority and completeness

- [x] Replace obsolete `./Packages/...` adoption paths with actual `PackagesInUse/...` paths in the
  Tchop app-owned adoption document; validate target membership rather than inferring it from folder
  presence.
- [x] Remove app-adoption authority from `PackagesForReuse/ADOPTION_AUDIT.md`: move unique current
  facts to `apps/Tchop/`, then replace the local file with a neutral pointer or retire it with
  provenance.
- [x] Add a deterministic package snapshot manifest covering 40 root packages and 5 helpers. Each
  entry records path, content hash/revision, products, maturity, and Documentation Vault revision.
- [x] Make the reusable catalog refer to that exact manifest instead of only a snapshot date.
- [x] Define and validate the package-doc mirror transformation. Remove executable
  `source-app` placeholders from active reusable instructions; retain provenance only in explicitly
  historical sections.
- [x] Resolve the product-localization boundary with a short ADR: product resource packages are
  app-owned; generic localization mechanics remain reusable. Do not move runtime source in this
  block unless the ADR and user authority explicitly require it.
- [x] Add missing `REUSE.md` for `AppDeviceInfo`, `AppEnvironment`, `AppLifecycle`, and
  `AppPermissions`.
- [x] Add deterministic tests for `AppIntentSupport` validation behavior, or record a narrowly
  justified exception if there is genuinely no executable contract. Test modification/execution
  requires the applicable current permission.
- [x] Fix the canonical broken link to `ios-reusable-packages`: promote a neutral skill into the
  canonical baseline or link only to routed canonical documents.
- [x] Remove user-specific default paths from reusable package verification; require a supplied
  sandbox root or derive a repository-contained path safely.

Acceptance: catalogs and actual folders both report 40 roots/5 helpers and 21 active roots/3 active
helpers; every catalog entry resolves; no active broken local links; every package has required
contract/reuse/verification surfaces; snapshot hashes reproduce; app adoption document names the
exact source and targets.

## Phase 5 — current task state and evidence reconciliation

- [x] Preserve old receipts as historical evidence; do not silently edit their original command
  results. Add a current evidence index marking each receipt `CURRENT`, `SUPERSEDED`, `STALE`, or
  `HISTORICAL` with reason and replacement.
- [x] Reconcile `universal-quality-control-plan.md`: mark 8.2 closed only when Phases 1–4 pass and
  remove contradictory current-status paragraphs while retaining historical chronology under an
  explicit history heading.
- [x] Rewrite `handoff.md` to the maximum allowed shape: identities, current restrictions, current
  state, verification, risks, next step, must-not-do list.
- [x] Keep `plan.md` as the compact executable checklist pointing to this detailed plan.
- [x] Re-run context-cost reporting and update the context receipt with fresh measurements.
- [x] Update 8.3, 9.1, 9.2, 10.1, 10.2, 11.1, and 11.2 through a new superseding closeout receipt,
  not by pretending their stale snapshots were current.

Acceptance: active `plan.md + handoff.md <= 3500` words; no active document says both open and
closed for the same gate; every current claim resolves to exact-SHA evidence; stale receipts are
clearly routed away from current decisions.

## Phase 6 — reusable iOS knowledge freshness

- [x] Revalidate the 18 mandatory core domains against current primary sources, prioritizing
  Swift/Xcode/iOS availability, App Review/privacy, accessibility, extensions, concurrency, and
  release engineering.
- [x] Update the registry review date only for domains actually reviewed. Keep `operational` where
  the full coverage unit is incomplete; do not upgrade maturity from document count alone.
- [x] For every remaining operational gap, record missing theory/rule/route/execution aid/evidence,
  owner, and revisit trigger. Deferred Apple platforms remain deferred unless a real target
  activates them.
- [x] Run registry, router, framework, link, and context checks after updates.

Acceptance: every mandatory domain has current review metadata and either `complete` evidence or an
explicit accepted gap; zero missing/unrouted paths; beta guidance remains labelled and separate
from the stable project baseline.

## Phase 7 — final verification, independent review, and publication

- [x] Review the complete final diff against the global change contract and every credible
  false-success/irreversible-state route.
- [x] Run: JSON parse, docs index/consistency/bootstrap/boundaries/router, canonical baseline drift,
  vault manifest/checker, active-link validation, package snapshot validation, forbidden/large-file
  checks, full repository static gate with retained runtime, localization, migration `--check`,
  `plutil`, and graph-scoped static evidence.
- [x] Run authorized package/app tests and build evidence only where code/Xcode changes require it;
  record omitted checks explicitly.
- [x] Perform a new independent semantic review on the exact final AIZenflow and Documentation Vault
  SHAs. The prior `748548f` audit cannot be reused as final review.
- [x] Fix all P0–P2, fix or explicitly report P3, then repeat one complete final-diff review.
- [x] Commit by concern, record post-commit receipts, verify `HEAD` unchanged, push under the
  explicit repository authorization, and confirm remote SHAs for the remediation, development,
  and main branches.
- [x] Update the final pilot receipt and compact handoff. Do not perform promotion/release; the
  internal-pilot limitation and no-release boundary remain explicit.

Final acceptance: clean synchronized repositories; zero open P0–P2; current static and canonical
gates PASS; task state within budget; exact-SHA independent review PASS; internal-pilot limitation
and no-release boundary remain explicit.

## Recommended commit sequence

1. Documentation Vault: canonical policy/routes/checker classification.
2. AIZenflow: exact mirrors plus metadata-gate hardening.
3. AIZenflow: migration CLI and German Xcode metadata.
4. Documentation Vault: package manifest, app adoption, package docs, link and knowledge updates.
5. AIZenflow: package mirrors/tests required by the accepted package contract.
6. AIZenflow: task-state reconciliation and final exact-SHA receipt.

Each commit needs its own compact change contract and final-diff review. A later commit invalidates
only receipts whose source universe changed, but the final semantic review always binds the complete
range.
