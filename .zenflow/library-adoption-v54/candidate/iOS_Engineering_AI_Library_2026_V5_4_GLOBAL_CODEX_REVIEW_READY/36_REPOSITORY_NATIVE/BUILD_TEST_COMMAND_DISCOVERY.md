# Build & Test Command Discovery

Priority order:
1. CI workflow commands that gate merges/releases.
2. Repository scripts / Makefile / justfile / Fastlane lanes.
3. Shared Xcode schemes in `xcshareddata/xcschemes`.
4. Swift Package commands for package-only modules.
5. Explicit project documentation.

Do not guess a simulator destination, scheme or workspace when the repo can reveal it. If a command cannot run in the current environment (signing, unavailable runtime, network), preserve its exact failure as evidence and choose the narrowest available substitute.
