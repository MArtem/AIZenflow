# Domain Checklist — Offline Sync

- source of truth
- operation IDs/idempotency
- conflict policy
- ordering/clocks
- retry/backoff
- tombstones/deletes

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/09_PERSISTENCE_DATA/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
