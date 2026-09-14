# Domain Checklist — iOS Design System

- token source of truth
- component API
- state variants
- Dynamic Type/a11y
- UIKit/SwiftUI parity
- visual regression

## Deep reference
When installed, search only the relevant the global deep library root described in `INSTALLATION.md` + `/29_DESIGN_SYSTEM/` files and matching `31_DEEP_PLAYBOOKS/OP-IOS-*`; do not load the entire section unless necessary.

## Stop / escalate
Stop destructive action and surface the unknown when the unresolved fact can cause data loss, auth/security failure, public API breakage, irreversible migration, signing/release mutation, or an unsafe concurrency workaround.
