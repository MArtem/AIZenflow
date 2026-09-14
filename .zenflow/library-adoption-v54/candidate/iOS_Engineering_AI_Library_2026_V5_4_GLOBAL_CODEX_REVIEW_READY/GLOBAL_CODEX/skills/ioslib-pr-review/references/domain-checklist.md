# Domain Checklist — iOS PR Review

- changed-file inventory
- target/module blast radius
- boundary contracts
- migration/release impact
- test evidence
- generated/lockfile changes

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/19_CODE_REVIEW_REFACTOR/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
