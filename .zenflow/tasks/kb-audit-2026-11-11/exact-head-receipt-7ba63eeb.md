# Exact HEAD receipt — 7ba63eeb

- **Trusted base:** `6d9454f2edd5459531c34a49143cc5b4cdf5247c`.
- **Merge HEAD:** `7ba63eeb03720bffac666f1343dced3a0be90e7f`; parents are preservation commit `40ad58705fd4d85aec4de7eb41a6983896a41ab4` (the complete prior 855-path local main snapshot) and previously published KB commit `f7f1949e6b3c3b1372a7c9bf24eb1a20d429821d`.
- **Contract:** preserve every tracked local change before reconciling branches; keep active reusable guidance at canonical owners; do not expose unverified external skill snapshots to practical use; keep original history recoverable and report current-tree disposition honestly.
- **Review:** snapshot commit preserved all 855 tracked paths (854 insertions, 96,890 deletions) before merge. Ten conflicts were reviewed; the newer published side was selected for scanner contracts and generated manifest, with the original snapshot retained as the first parent. Final merge differs from published `f7f1949e` only in the corrected historical README and removal of 20 unmatched external-environment assets/scripts from the active tree. All 20 removed blobs were verified present at the trusted base. The duplicate asynchronous-confirmation section was removed. No Swift source/test paths changed.
- **Ignored data:** all 206 ignored attachments/assets were left untouched and excluded from commits; no ordinary untracked items remain.
- **Checks:** `git diff --cached --check`, exact diff checks against both parents, and `python3 -B scripts/generate_package_snapshot_manifest.py --check` passed. No conflict markers or unresolved paths remain. Previously completed scanner synthetic evidence is reused; no suites rerun.
- **Omitted:** no build, tests, Simulator/UI, package verifier, runtime, or archive execution.
- **Residuals:** source provenance/redistribution rights and full upstream/API freshness remain UNKNOWN as documented. The 20 removed historical blobs are recoverable from Git history, not present in the active worktree.
