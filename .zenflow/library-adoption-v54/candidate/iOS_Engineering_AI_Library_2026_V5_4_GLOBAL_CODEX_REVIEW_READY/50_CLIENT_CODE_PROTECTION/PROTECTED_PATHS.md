# Protected Path Classes

The following classes require elevated review and exact protected-path authorization when changed:

- `project.pbxproj` and Xcode schemes/test plans;
- `Package.swift`, `Package.resolved`, Pod/Carthage/Mint lockfiles;
- entitlements, xcconfig, `Info.plist`, privacy manifests;
- CI configuration and release/Fastlane files;
- repository scripts/tooling;
- Core Data model bundles and persisted-schema artifacts;
- signing/release configuration.

This list is intentionally conservative. A path being protected does not mean it is forbidden; it means accidental mutation is unacceptable and intent must be explicit.
