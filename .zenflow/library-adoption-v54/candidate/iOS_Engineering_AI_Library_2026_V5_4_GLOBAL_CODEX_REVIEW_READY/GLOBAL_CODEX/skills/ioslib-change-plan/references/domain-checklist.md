# Domain Checklist — iOS Change Plan

- facts vs assumptions
- invariants
- blast radius/call sites
- two alternatives for R2+
- verification ladder
- rollback/containment

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/21_AGENT_WORKFLOWS/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
