# Final acceptance — external lifecycle and fresh Desktop observations

Date: 2026-09-16. Executor: Astra, mode эконом. Fresh observers: Luna Xhigh.
Overall verdict: isolated candidate lifecycle PASS; automatic host application gate NOT PASSED.
This is not an accepted release or independent review of Astra-authored corrections.

## One-time authority and cleanup

The user authorized /Users/Shared/ioslib-acceptance solely for isolated library verification,
only after checking absence of foreign data and a Git boundary, and required removal afterward.
No real Codex settings or other external directories were authorized for mutation.

- Initial path absent (including symlink check); /Users/Shared was not inside a Git repository.
- Created mode 0700, owner Artem; device/inode 16777230:311788486.
- TMPDIR and IOSLIB_TEST_TMP_ROOT both pointed into this area; logs went directly to .zenflow.
- After all test processes completed, the tests had removed all fixture contents.
- Verified the same directory identity; rmdir removed the empty root; absence confirmed.
- The external permission is consumed. Do not recreate or reuse this path without new authority.
- No recovery needed: only disposable synthetic data were removed; all verification logs remain.

## Verification and corrective scope

Initial external run: six test methods, three failed with five assertion/subtest failures.
The real historical .6→.7→.6 sequence and two installer cases already passed.
[Initial log](external-lifecycle.log).

Targeted recheck: two manual preflight methods passed; manual lifecycle still exposed two
reconnect failures for existing AGENTS. [Recheck log](external-manual-recheck.log).

Corrections were confined to tests/test_review_ready.py and MANUAL_DEPLOYMENT.md, plus package
manifest/evidence mirrors:

1. Give both positive manual preflight fixtures explicit isolated skills roots. Previously their
   default resolved to a real-home skills path and production Git admission refused it.
   No real-home settings were changed.
2. Preserve the recorded original AGENTS snapshot mode, not hard-coded 0644 instead of 0640.
3. After removing verified owned skill files, remove only empty directories derived from those
   paths, bottom-up via rmdir. Unknown residual contents cause refusal, not recursive deletion.
4. Disable removes the verified activation-owned separator and block newlines too, restoring
   exact original user bytes/mode before reconnect. The harness asserts the complete expected
   composition before restoration; it does not overwrite a mismatching snapshot to make PASS.

Production installer/preflight/runtime code and Git-admission rules were NOT changed.

Final full serial suite: **199 total / 199 PASS / 0 FAIL / 0 SKIP**, exit 0.
[Final log](external-final-suite.log). The exact environment/command is in the packaged report.
This includes all six formerly skipped methods, four manual mode/existing-AGENTS branches,
reference→full, payload A→B→A, tamper refusal, disable/reconnect and preserved state.
The real historical ZIP SHA was pinned to
`57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27`.
R1 manual lifecycle and R3 real-release rollback are now verified in the isolated scope.
Mocked unit tests remain unit evidence, not host-delivery proof.

Validator: **1366 files / 60 skills / 51 sections / 288 playbooks / 0 errors**.
Only report wording/cleanup status and its manifest entry changed after the final suite;
executable sources stayed unchanged. Validator and archive checks were performed afterward.

## Fresh Desktop observations

The user registered three local projects without sending messages. Each was opened directly in
its existing local folder, not a new worktree or projectless substitute. No bootstrap was added
before observation; this is the runbook's explicit deferred-bootstrap intake exception.

Initial prompt in each task:
“Кратко опиши структуру текущего проекта и предложи один небольшой следующий шаг. Ничего
не изменяй, не устанавливай зависимости, не запускай сборки и тесты.”

Only after completion, each received a request to name already-available user/project instruction
sources versus subsequently read files, without further reads or disclosure of hidden instructions.
Those answers are supplementary self-reports, not authoritative host configuration records.

| Case | Task ID | Observed result |
| --- | --- | --- |
| Ghibli — первый read-only вход | 01a0aae7-ae71-7742-a920-516a63d1bd6f | research skill → source inspection; no common/library route; no root AGENTS |
| Firefox — первый read-only вход | 01a0aae7-bcd8-7da3-9663-2f0582dc84d9 | upstream AGENTS reported as initially supplied; research skill/source reads, no common/library route |
| Countries — первый read-only вход | 01a0aae7-cf37-79d3-976e-4d6e94b147da | research skill → extensive source inspection; no common/library route; no root AGENTS |

Sanitized public observations, command ordering, exact cwd and responses:
[fresh-ghibli.json](fresh-ghibli.json), [fresh-firefox.json](fresh-firefox.json),
[fresh-countries.json](fresh-countries.json). Hidden reasoning is excluded.

Pins:
- GhibliSwiftUIApp-entry: 524c434882dcc22d95b1c5781f295d8fbfe0ced6.
- firefox-ios: 0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071.
- clean-architecture-swiftui: 9eca97b8cfff96a14084b564b1fefd949c93d232.

All three source trees remained clean. The existing Retry patch in the separate original Ghibli
implementation copy is preserved. No upstream commit/push, dependency installation, build or app
test occurred. No second coached task is counted as automatic entry.

Observed common/library application: **not demonstrated / acceptance gate not passed**.
No baseline header or canonical/library route read appears in the recorded first actions.
Exact active CODEX_HOME and physical delivery/precedence cause: **UNKNOWN**. Absence of a read
alone does not prove instruction absence; it is combined here with visible behavior and bounded
self-reports, without claiming access to hidden prompts or real-home configuration.

The approved installed AGENTS block exists in the named canonical runtime, and parent
/Users/Artem/.zenflow/AGENTS.md exists. The parent file is not a valid automatic delivery route
for these three repositories: Codex project discovery starts at each project root (normally its
Git root) and walks down to the task cwd; it does not walk from an unrelated parent directory
above that root. This matches both the official Codex discovery contract and the candidate's own
MANUAL_DEPLOYMENT.md activation boundary. Therefore the fresh-entry result is expected unless
the active Codex global scope supplies the block. It is not evidence of a candidate runtime defect.

The remaining unknown is narrower: whether the actual Desktop process global scope uses the
named canonical runtime, another CODEX_HOME, or a non-empty AGENTS.override.md that takes global
precedence. Resolving that requires separately authorized read-only inspection of at most the two
global AGENTS candidates; config.toml is not needed unless those files leave CODEX_HOME unresolved.
Official discovery reference:
https://learn.chatgpt.com/docs/agent-configuration/agents-md#how-codex-discovers-guidance.

Additional empty/non-iOS/linked first-entry controls remain NOT_RUN: their exact roots are not
registered, and expanding the matrix before resolving the already-observed common-route gap is
not economical. No false non-iOS PASS is inferred from an iOS project's cross-layer review.

## Previously completed pilots

- Ghibli: one-file Retry implementation, static scope only; retained prior evidence, no app runtime PASS.
- Firefox: bounded read-only search review retained; no confirmed P0–P2 in that reviewed scope.
- Countries: [scenario table and P2 cancellation trace](countries-scenarios.md); read-only deliverable
  complete, not an approved app release. Fixing upstream Countries is outside the pilot contract.
These static results are not causal evidence of automatic library delivery or quality uplift.

## Candidate artifact and promotion boundary

Archive: ../../dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_ASTRA_LIFECYCLE_20260916.zip.
SHA-256: `4150ebf4870934b21ed1f08eb234a478d33e66238144790dd227fa8cdb348380`.
Size: 2,994,435 bytes. ZIP CRC, unique safe paths, no symlink/.git/bytecode entries and exact
equality of all 1366 files with the candidate passed. No redundant extracted archive was created.
Earlier archives remain unchanged.

Canonical repository and actual source-in-place runtime were intentionally NOT updated.
Canonical remains clean at 3ad93db5122063b15bf83b345f93747169cc89d5. Existing installed identity
remains the previous e0a0eb6a…d39d1c. The new candidate differs; do not claim canonical/runtime
synchronization or activation of this correction. Promotion would also change source used by the
real runtime, so it is deferred under the latest no-real-configuration-change instruction.

## Review and next decision

Trusted task base: af4c23156298cbdcd9321f02abfdfd9b2c41ae42.
Contract: isolated fixture destinations, exact byte/mode restoration, no boundary bypass,
failure on unknown contents, cleanup, and no automatic-delivery PASS without observation.
Review covers all changed code/docs, both preflight consumers, all manual lifecycle branches,
manifest identities and the distinction between candidate and actual installation.
No known P0–P2 in this bounded candidate correction; the host integration acceptance gap remains
open and is not an authorization to modify real settings. Exact committed range and remote SHA
are recorded after commit without self-referential receipt churn.

Next: authorize, if desired, read-only inspection of the active global AGENTS candidates needed
to distinguish missing block from override precedence; do not inspect unrelated settings.
Do not silently change CODEX_HOME, restart Codex, edit real settings, seed imported projects,
or reopen the consumed external test area. Further host diagnosis may require separately named
read authority; a configuration patch requires its own scoped approval.
Skill ios-evidence-gate kept lifecycle, project outcomes, host provenance and deployment claims separate.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
