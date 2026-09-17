# L5 automation and safety matrix

Date: **2026-09-12**. Status: **PROPOSED ROUTE / NO GLOBAL ACTIVATION**.

The matrix defines what the automatic layer may select, what it may execute, and where it must
stop. “PASS” below means the declared synthetic entrypoint/evidence covers the row; it is not a
claim about the whole Mac or an arbitrary model following every instruction.

| Scenario | Route | Allowed action | Must not happen | Stop/disable condition | Evidence/status |
|---|---|---|---|---|---|
| New iOS/Swift project | canonical intake + matching iOS subset | load minimal pinned references; inspect facts | no client infrastructure copy, no build/test start | missing platform/target facts → generic route + unknown specialty | route proposal; no real consumer |
| Existing dirty iOS repo | baseline + explicit domain route; runtime only if separately selected | inspect Git/status and exact declared scope | no dirty-file overwrite or broad scope expansion | unexpected dirty mutation or incomplete observation | F03–F06/F10 shipped synthetic suite PASS |
| Non-iOS repository | common engineering/evidence route | use generic rules only | no Swift/iOS skill activation and no iOS claims | platform mismatch → disable specialized route | conditional global block/static contract; consumer pending |
| Unknown language/profile | common route, `unsupported specialty` | preserve unknown outcome | no heuristic downgrade to low risk | missing evidence → no delegation/specialty PASS | F13 unknown-language test PASS |
| Task has no requested changes | knowledge-only | answer/review from references | no runtime call, state write or Git mutation | any write-like action request requires a new explicit scope | proposal; no external A/B result |
| Explicit runtime task | opt-in CLI packet with absolute paths | invoke only the selected CLI entrypoint and state root | no automatic session, build, network, dependency, signing or release action | missing/altered root, invalid state, incomplete scan → non-PASS | CLI/runtime suite PASS in synthetic scope |
| Two linked worktrees | one writer slot per Git common-dir | serialize lifecycle state | no second writer through another linked path | active shared writer or damaged state → reject and recover with owner runtime | A52/A53 linked tests and V5.2 rehearsal PASS |
| Two independent clones | separate writer slots only when common dirs differ | allow independent synthetic sessions | no claim of global cross-process source-write lock | common-dir identity unknown → stop | A52 independent-repo test PASS |
| Missing library root | baseline only | report knowledge route unavailable | no silent substitute version or copied corpus | pinned root/hash unavailable → disable dependent route | proposed; no production consumer |
| Altered pinned file/manifest | integrity failure | use canonical baseline if still available | no use of altered file as accepted advice | manifest/hash mismatch → route unavailable | candidate validator PASS for current candidate; alteration consumer test pending |
| Malicious README/comment/generated text | data-only repository evidence | inspect bounded metadata where applicable | no execution of discovered commands or prompt-like text | parser/observation error → incomplete; command stays data | F08/K02 and candidate contracts PASS |
| Build/test permission absent | knowledge route only | explain required verification and wait | no inference of permission from skill/playbook | command authorization absent → stop that check, preserve rest | canonical permission rule + candidate block; no app run |
| Optional route disabled | canonical baseline | omit candidate references/CLI | no background watcher, auto-update or hidden fallback | disable entry is authoritative immediately | disable procedure documented; rehearsal on real Codex home pending |
| New candidate version appears | pinned current candidate | require explicit review/pin update | no automatic replacement or migration | hash/source/license/review missing → keep prior pin | provenance still UNKNOWN |
| Reference mode | global minimal block only if separately authorized | stable descriptor + optional runtime path | no 60 skill install | global config target not explicitly approved → do not install | synthetic installer PASS; real target forbidden here |
| Full mode | explicit separate adoption branch | namespaced skills after matching dry-run | no automatic activation of duplicate/control-plane skills | collision/modified asset → preserve and abort | 60-skill synthetic collision/update PASS |
| External state path | per-repository state outside client repo | use exact external state root | no `.ai`/`.agents`/runtime state in client repo | state inside client repo or symlink ancestry → fail closed | state isolation and symlink tests PASS |
| Secrets/credentials in evidence | redacted metadata only | retain hashes/fixed reason codes | no raw command, URL credential, token or source body | secret marker detected → redact/reject output | F08 tests PASS |
| Network/process side effects | advisory classifier and bounded subprocess only where explicit | classify and report | no OS sandbox claim; no automatic network/fan-out | unsupported or timeout → NON_PASS/incomplete | guard/subprocess tests PASS; whole-Mac coverage unknown |
| VoiceOver/device claim | reference-only | use textual accessibility checklist | no claim of device traversal or runtime accessibility PASS | physical device absent → remain reference-only | L1 semantic review; device evidence unavailable |

## Mode comparison

| Mode | Benefit | Main risk | Disable | Current recommendation |
|---|---|---|---|---|
| Passive extracted knowledge | zero global mutation; useful reference | manual route and no runtime protection | stop referencing root | safe baseline for L2 external pilot |
| Explicit opt-in CLI | bounded Git/state observations and recovery checks | adds friction and is not a sandbox/backup | stop CLI; preserve state; use documented recovery | preferred runtime target after L2/L6 |
| Global `reference` | automatic conditional iOS guidance and stable discovery descriptor | mutates global AGENTS/config and can add model attention/latency | matching uninstall/sync with preflight | only after explicit global-home authorization |
| Global `full` | exposes 60 namespaced skills | duplicate triggers, context cost, authority/control-plane confusion | manifest-aware uninstall/update | not recommended for first adoption |

## Minimum route contract for promotion

Promotion may carry only the following automatic behavior:

- choose the common route and the narrowest supported iOS subset from observable task/repository
  signals;
- state the evidence needed for compiler, backend, persistence, device and release claims;
- leave all build/test/Git/network/dependency/signing/release authority with existing rules and
  explicit user approvals;
- expose `unknown`, `partial`, `reference-only`, `runtime-not-selected` and `disabled` states;
- provide an exact disable path and retain state/history during disable.

Promotion must not carry auto-update, background monitoring, command interception, global full-skill
activation, automatic commits/pushes/resets, or automatic source rollback.

## Current safety verdict

The matrix is implementation-ready as a task-local proposal. It has no new side-effecting code and
does not authorize global installation. Synthetic runtime/installer tests cover many negative paths,
but route utility, canonical promotion, provenance, real consumer behavior and device/UI evidence
remain pending. The safe default is passive knowledge plus explicit runtime selection.
