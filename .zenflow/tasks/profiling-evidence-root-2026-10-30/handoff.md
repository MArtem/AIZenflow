# Shared profiling results — handoff

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

- **Model/mode:** GPT-6.1 Terra, medium; эконом.
- **Root:** `/Users/Artem/.zenflow/profiling-results/`, private (`0700` directories, `0600` files); now 199 files, 92,412,718 logical bytes. See README and INDEX.
- **Centralized:** Battleship report, scenario matrix, proposals, 12 metric JSON files and 157 retained logs/XML/attachments; detailed Tchop 2026-10-29 report; historical Tchop `new-task-be0b` bundle (five opaque trace components, two analysis JSONs, and a migration report); runtime-auditor methodology review and supporting evidence.
- **Integrity/limits:** hashes for all five migrated trace components match the originals. The legacy Time Profiler analysis is system-wide and shows TchopApp only in its process list; no app-only conclusion. One adjacent JSON is empty. Previously deleted captures remain deleted by user instruction.
- **All-project scan:** found no remaining `.trace`/`.xcresult` bundles elsewhere under the scanned `.zenflow` workspace. Scoped Ghibli/Countries evidence paths had no app-performance trace/metric exports. Countries’ 18.2 log/result is Xcode dependency preflight QA, so stays with that task. Canceled app tasks were not resumed or modified.
- **Canonical docs:** storage guidance remains in skill/reference; legacy captures removed from canonical docs checkout and generated manifest updated. Second canonical commit `b63c7c60857e83f537f1402b68de02df8f44d1c3` removes the legacy captures and regenerated manifest; push succeeded and remote-state checker passed.
- **Task state:** active plans/handoffs remain in project task folders; full results live centrally. KB task moves remain uncommitted.
- **Build/tests/runtime:** not needed and not run.
