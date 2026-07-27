# Documentation Cleanup Audit

## Purpose
Record the evidence, retention decisions, recovery path, and verification contract for the preservation-first cleanup of `MArtem/AIZenflowDocumentation` and its current worktree mirrors.

## Recovery Baseline
- Canonical repository: `/Users/Artem/.zenflow/worktrees/documentation-vault`
- Pre-cleanup commit: `a88bb9b388f1ac44b7af927b3f5310728712ff6e`
- The pre-cleanup Git commit is the recovery source for every tracked file removed by this block.
- Project repository changes remain uncommitted and are not a recovery mechanism for canonical documentation.

## Removal Threshold
A file may be removed only when at least one of these conditions is proven:

1. It is byte-identical to a retained authoritative copy.
2. It is generated inventory that can be reproduced deterministically from the repository tree.
3. It is a dangerous obsolete tool whose supported replacement is installed in the same change.
4. It is a raw generated trace or zero-byte artifact, and any unique readable analysis has been retained in the correct app-specific evidence boundary.
5. It is detached obsolete guidance whose current rule is already authoritative, routed, and materially more accurate.

Uncertain, unique, historical, or provenance-bearing material stays retained and is labelled non-authoritative when needed.

## Approved Cleanup Scope
- Replace the destructive worktree-to-vault sync script with a non-destructive inventory generator supporting `--check` and `--write`; retain the old script only inside an explicitly unsafe retired quarantine.
- Replace stale overlapping active inventory files with one generated root `MANIFEST.md` and one concise `MANIFEST_SUMMARY.md`; preserve old inventory snapshots only in retired quarantine.
- Consolidate sync/retention invariants into the documentation-repository operations runbook.
- Move duplicate retired prompt trees and detached `agent-working-rules.md` copies out of all active reusable boundaries after their replacements are verified.
- Move current-task copies of old Tchop engineering/archive files out of the active task boundary where the same content is retained under the Tchop legacy-reference boundary.
- Quarantine raw Instruments trace bundles outside active docs; retain the non-empty readable analysis JSON under Tchop app-specific legacy evidence.
- Remove temporary boundary-audit/overlay staging directories only after their canonical results are validated.
- Keep unique archive intake, assistant-conversation history, saved-prompt provenance, legacy handbooks, and the historical documentation-split export.

## Deletion Decision
The canonical repository safety control rejected a broad tracked deletion. The cleanup therefore uses a materially safer quarantine: files move under `retired/`, remain recoverable byte-for-byte, and are excluded from active routing and ownership surfaces. Physical deletion is deferred to a separate explicitly reviewed retention decision.

## Policy Corrections
- Model selection follows the user-approved quality-first policy: at the same reasoning level, `sol` is the maximum-quality route; `tera` is the resource-efficient high-quality route for bounded work with strong evidence; `luna` is limited to low-risk reversible work.
- App-specific and reusable/global knowledge remain physically and logically separated. Historical snapshots are not active routing sources.

## Verification Contract
- No Xcode build, tests, Simulator, device run, or Instruments execution is part of this documentation-only block.
- Run inventory freshness, vault shape, documentation index, router, consistency, boundary, reusable-baseline drift, secret, and `git diff --check` validations.
- Commit and push only `/Users/Artem/.zenflow/worktrees/documentation-vault`.
- Confirm canonical `main` is clean and synchronized with `origin/main` after publication.

## Verification Results
- Root manifest freshness: pass.
- Canonical vault shape: pass, `3608` files and four app boundaries.
- Active documentation index, consistency, boundary, router, reusable-baseline drift, knowledge-system, and diff checks: pass.
- Router state: zero missing, optional-missing, unreachable, or unclassified active documents.
- Documentation-scoped secret scan: pass.
- Full project secret scan: not clean due to seven pre-existing generic-token fixture matches in unchanged `TchopAppTests/AppStateTests.swift`; tests are outside this authorized documentation scope and were not modified.
- Xcode build, tests, Simulator, device, Instruments, archive, and signing: not run and not required for this documentation-only block.

## Context Transfer Rule
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
