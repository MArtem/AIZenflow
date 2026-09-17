# Independent control-plane review receipt

Date: **2026-09-13**. Scope: task-local proposed knowledge-route patch and its resolver delta;
no canonical checkout, real Codex home, consumer, or remote repository was changed.

## Findings and disposition

| Finding | Disposition | Evidence |
|---|---|---|
| P1: a new unmanaged target could appear after preflight and be moved/deleted by sync | **CLOSED** | `sync_global.py` now aborts on an unmanaged target appearing after preflight; `test_F10_sync_raced_unmanaged_target_is_preserved` keeps the sentinel, registry, shim, and no backup residue. |
| P2: route integrity did not cover overlay-added optional documents | **CLOSED in accepted route contract** | Resolver requires exact set equality between selected/optional documents and the integrity map; rehearsal `overlay_optional_document_skips_route=true`. |
| P2: a skipped route could return process success | **CLOSED** | Resolver returns nonzero when `skipped_routes` is non-empty; altered pin/profile rehearsal exits 1 and preserves baseline routing. |
| P2: integrity check and later consumer read are not one atomic filesystem operation | **Bounded residual; claim narrowed** | Resolver rechecks immediately before returning; PROFILE/README explicitly define this as advisory handoff consistency evidence, not a filesystem security boundary. The route grants no permission and consumers retain safe-read/authority rules. |
| P3: stale test-count wording | **CLOSED** | Matrix/report/manifest synchronized to 143 tests and the observed `tests/run_all.py` wall time. |

## Independent disposition

The accepted task-local scope has no remaining P0–P2 finding that is being presented as a
permission or filesystem security guarantee. The integrity TOCTOU limitation is retained as an
explicit residual boundary, not silently called atomic. Runtime/installer correctness remains
bounded synthetic evidence; it is not a whole-Mac or universal project guarantee.

The independent review was read-only. The corrective candidate was then revalidated with:

```text
tests/run_all.py: 143/143 PASS, 0 FAIL, 0 SKIP, exit 0
validate_package.py: files=1357 skills=60 sections=51 playbooks=288 errors=0
route rehearsal: PASS, including altered-pin, altered-profile, overlay, disable/re-enable,
and consumer-Git-preservation scenarios
```
