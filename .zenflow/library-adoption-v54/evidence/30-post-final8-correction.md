# Post-FINAL8 bounded correction

Base: 8af53c02b78d38d0c9025c62b8f46f7619b7e212. Working-tree changes, not an accepted release.

Fixed paths: candidate manual_preflight.py, MANUAL_DEPLOYMENT.md,
GLOBAL_CODEX/AGENTS.global.block.md and targeted tests; package evidence/hashes synchronized.
Contract: prepare both metadata outputs before publication; mode and skills path agree;
old receipt permits only unchanged owned content to be replaced; a new receipt checks incoming
publication; package/receipt reads are bounded; protection requires explicit task opt-in.

Targeted checks: package exact/overflow bytes, entry limit, expired deadline, short read and
premature EOF PASS. Receipt >64 KiB roundtrip, exact/overflow content and encoded limit PASS.
Existing descriptor/skill tampering and reference receipt fixtures PASS in the serial run.
Final serial: 192 total, 187 pass, 0 fail, 5 skip, exit 0, using
`/Users/Artem/.zenflow/worktrees/library-adoption-test-tmp`. An earlier attempt used a fixture
inside the candidate Git root and is superseded. Existing unit Git mocks are not evidence of
actual host installation.

The new reconnect/Unicode-safe AGENTS-prefix fixture passes. A default parallel diagnostic was not promoted
to release evidence because it intermittently hit a fixture-root permission race; the same
installer case passes alone and the serial release runner is stable. No production bypass was
added for this test-environment issue.

Added unmocked documented-shell fresh reference/full test with existing/absent AGENTS,
reference→full, changed routed material A→B→A, tampered user-content refusal, disable and
history/mode preservation. It is NOT_RUN under this host's home-level Git root.
Installer real external-to-Git acceptance and fresh Codex instruction delivery also remained open
at that point. No production check was relaxed for fixtures. Before the canonical follow-up below,
no actual host settings, canonical files, client source, Git refs or old archives had changed.
No new archive/publish was performed before the missing acceptance passed.
The manual runbook now fails closed if its fixed AGENTS snapshot path is occupied by a non-matching
or non-regular entry; it only reuses an exact byte match.

The canonical-repository runtime exception is implemented and covered by synthetic lifecycle tests:
only `MArtem/AIZenflowDocumentation` origin/root and the exact
`.codex-runtime/ios-engineering` subtree are admitted. Ordinary client Git roots remain rejected.
At this pre-activation stage the actual canonical checkout had not yet been activated; the section
above was policy/code evidence, not host adoption evidence.

No independent subagent tool was available; author performed a separate final-diff review.
Skill fix-finding used for the bounded read/publication corrections. Full verification was blocked
on actual lifecycle evidence at that stage; the canonical follow-up below records its result.

Canonical exception lifecycle follow-up (2026-09-15): the review-ready payload was copied to the
versioned canonical source `AIZenflowDocumentation/reusable/ios-engineering-library/v5.4`; the
active runtime was installed only at
`AIZenflowDocumentation/.codex-runtime/ios-engineering` after exact origin/root/path admission.
The runtime registry points to the versioned source, `/.codex-runtime/` is ignored by the
canonical repository, and the canonical checkout's source/docs/.git were not installer targets.
Unmocked results: installer fresh reference PASS; `validate_global_install.py` PASS; runtime
`doctor` PASS; `sync_global.py --dry-run` PASS; `uninstall_global.py --dry-run` PASS. The full
serial suite from the canonical source is `194 total / 189 PASS / 0 FAIL / 5 SKIP`; package
validation and documentation-vault checks are PASS. The five skips remain host/fixture-limited
scenarios and do not invalidate the exact canonical exception path.

The actual canonical checkout is now activated for reference mode. Full mode and independent
review/publication remain separate gates; no ZIP or non-canonical repository was changed. The
canonical publication receipt is commit
`c3d61a98d6fdad9e0230c0c49edb52a13d2fbfae`, confirmed at `origin/main`.
**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
