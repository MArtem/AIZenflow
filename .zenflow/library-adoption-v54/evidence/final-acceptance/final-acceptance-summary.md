# Final acceptance — Astra correction receipt

Date: 2026-09-16. Executor: Astra; operating mode: эконом.
This supersedes the Luna follow-up receipt. Overall acceptance remains BLOCKED, not complete.

## Change contract and result

Only the library test harness and evidence/docs change. Published shell blocks must build as
strings in both modes and reconnect; optional archive input must never silently select a
task-local historical payload; supplied archive errors must fail before Git-based skipping.
No production Git-admission policy is bypassed. No runtime feature or upstream app code is
changed by this correction.

- Fixed string/Path and string/dict shadowing in manual activation/reconnect.
- Shared marker-based command builder checks unique blocks, unresolved placeholders, both
  modes and quoted paths; always-executed `bash -n` regression passes.
- Real .6 archive is explicit via IOSLIB_LEGACY_ARCHIVE; missing input is NOT_RUN, malformed
  supplied input fails. The pinned ZIP SHA was checked before the environment skip:
  `57e34f454b5247a43864f89354cdb02a742e5a26d1e6a343d287c9b05bd76e27`.
- One final serial suite: **199 total / 193 PASS / 0 FAIL / 6 SKIP**, exit 0.
  Full output: [astra-suite.log](astra-suite.log). Exact command is in the packaged
  REVIEW_READY_VALIDATION_REPORT.md. Fixture root: candidate/test-tmp-astra under this adoption area.
- Validator: **1366 files / 60 skills / 51 sections / 288 playbooks / 0 errors**.
- Metadata-only wording correction after the suite did not change executable sources;
  validator and exact archive comparison were rerun, not the full suite.

## What the six skips mean

1. test_F14_dry_run_no_mutation — no authorized external-to-Git root.
2. test_F14_portable_area_profile_is_explicit_and_local — same boundary.
3. test_F14_manual_documented_fresh_reference_and_full — same boundary.
4. test_F14_manual_preflight_accepts_verified_transitional_shim_for_descriptor — same boundary.
5. test_F14_manual_preflight_clean_is_read_only_and_emits_selector — same boundary.
6. test_F14_real_v6_round_trip_uses_fixed_coordinator — historical SHA verified, lifecycle
   NOT_RUN due to the same boundary.

A skipped body may still contain defects. Construction/syntax evidence does not validate
manual installation, and mocked unit coverage does not prove the real .6 round trip.
R1 harness correction is verified; R2 contract/static evidence is retained; R3 remains
BLOCKED_ENVIRONMENT. Do not call these skips failure-free lifecycle acceptance.

## Canonical source, installed runtime and archive

Candidate and canonical source are byte-identical across all 1366 files.
Canonical: /Users/Artem/.zenflow/worktrees/documentation-vault/reusable/ios-engineering-library/v5.4.
Existing reference runtime: /Users/Artem/.zenflow/worktrees/documentation-vault/.codex-runtime/ios-engineering.
One normal sync dry-run/apply completed with no collisions and matching preflight id
`e8051611d11843c5bc0ef6c159db7077f790a2d4d7ea0e0e178e5b2950f6ec35`.
Installed source-tree identity:
`e0a0eb6adffc34fb9adf05e1ad123d7a2096fecc290683ac5a89811a11d39d1c`.
Release .7 / protection .5 / reference mode; validate_global_install returned ok=true, errors=[].
This verifies the named installation, NOT its selection by the active Desktop process.

Archive: ../../dist/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY_ASTRA_CORRECTED_20260916.zip.
SHA-256: `87389f791bc30ad546a4c01919394e7aea7f619141aec20801e50e432d7e9fda`.
Size: 2,994,125 bytes. ZIP CRC, unique/safe entry names, absence of symlinks/cache/.git entries,
and equality of every ZIP file with candidate and canonical passed. No extra extracted copy
was created. Previous archives remain intact. Canonical code is the durable source; the ZIP
is a local delivery artifact, not an accepted release.

## Pilots

- Ghibli implementation: existing bounded Retry patch preserved in exactly one FilmsScreen.swift.
  Prior static verification retained; no build/UI PASS. The original patch preceded fresh-entry.
  Prepared separate clean `/Users/Artem/.zenflow/library-acceptance-projects/GhibliSwiftUIApp-entry`
  at `524c434882dcc22d95b1c5781f295d8fbfe0ced6` for uncontaminated source entry observation.
  It is a separate local clone, not a reset of the implementation pilot.
- Firefox read-only review: previous bounded result retained, no confirmed P0–P2 in that scope.
  Pin `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071`; working tree checked clean.
- Countries read-only review: scenario deliverable COMPLETE with a reported P2 cancellation
  defect, not an approved app release. [Scenario table and trace](countries-scenarios.md).
  Pin `9eca97b8cfff96a14084b564b1fefd949c93d232`; working tree checked clean.
  No upstream fix is required to complete a read-only review; no upstream commit/push occurred.
- Non-iOS fresh-host control: NOT_RUN. Countries cross-layer analysis is not this control.

## Concrete remaining blockers

Saved-project catalog still exposes only new-task-be0b and mvvmexample-3c80. It lacks the pilot
roots. No project-registration tool was found. A direct attempt to use Codex UI returned:
`Computer Use is not allowed to use the app 'com.openai.codex' for safety reasons.`
No alternate UI automation or configuration-file bypass was attempted.

User action needed: add these folders as Codex projects (without starting or seeding pilot tasks):
- /Users/Artem/.zenflow/library-acceptance-projects/GhibliSwiftUIApp-entry
- /Users/Artem/.zenflow/library-acceptance-projects/firefox-ios
- /Users/Artem/.zenflow/library-acceptance-projects/clean-architecture-swiftui

Then the already-authorized neutral fresh-entry observations can run; host delivery, selected
package and non-iOS/no-AGENTS controls still require actual observation, not self-report alone.
No outside-sandbox host configuration was read or modified.

Separately, positive lifecycle acceptance needs an explicitly authorized writable fixture area
outside every detected Git repository. The current .zenflow area is enclosed by a parent Git
root. Do not move/delete that root, override discovery, or treat the canonical exception as
a clean external-host proof. Until a suitable environment is authorized, R3 stays BLOCKED.

## Review / publication boundary

Trusted bases before this correction:
task `194eec74e9f79706de07655a906ed72d613f4413`;
canonical `35d303212c8c2b06450d3551aa8416346e2919cb`.
Final diff review covers the helper, both execution consumers, archive validation ordering,
mirrored counts/hashes and claims. No known P0–P2 in this bounded correction. The Countries P2
belongs to unchanged upstream code, not this patch. Independent review of Astra-authored
correction is not claimed. Actual commit SHAs and remote verification are reported after commit
without a self-referential receipt commit loop.

Skill ios-evidence-gate was used to separate source/static evidence, historical checks,
unknown host delivery and unrun lifecycle cases. No app tests/builds/dependencies/signing,
global-home edits, upstream publication, or deletion were performed.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
