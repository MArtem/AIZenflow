# Domain Checklist — iOS Repo Intake

- workspace/project and shared schemes
- Swift mode and deployment targets
- targets/extensions/packages
- CI/build/test command sources
- persistence/network/auth boundaries
- high-risk generated/signing/release areas

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/21_AGENT_WORKFLOWS/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
