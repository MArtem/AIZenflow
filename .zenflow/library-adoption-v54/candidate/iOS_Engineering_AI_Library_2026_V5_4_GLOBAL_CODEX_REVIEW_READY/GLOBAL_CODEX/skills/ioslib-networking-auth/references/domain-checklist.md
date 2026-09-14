# Domain Checklist — Networking & Auth

- HTTP/idempotency semantics
- single-flight refresh
- logout vs in-flight work
- retry/backoff/cancellation
- cache freshness
- secret/log redaction

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/08_NETWORKING/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
