# Domain Checklist — SDK / Public API

- public symbols
- source/ABI assumptions
- Objective-C exposure
- semver/deprecation
- consumer migration
- documentation/tests

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/28_ECOSYSTEM_INTEROP/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
