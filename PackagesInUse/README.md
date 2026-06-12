# PackagesInUse

`./PackagesInUse` contains the source-only copies of reusable infrastructure packages that are currently compiled directly into the `TchopApp` app, share-extension, and widget targets.

## Purpose

This folder exists because this worktree is being used both as an app and as a package-library testbed. Real SwiftPM linkage for many packages creates large `.build`, `.swiftpm`, cloned package, and DerivedData artifacts. Source-only integration keeps the active app small while preserving the ability to publish/copy any package as a real Swift Package later.

## Contract

- This folder is **not** connected through Swift Package Manager in this project.
- Xcode compiles selected `Sources/**/*.swift` files directly into runtime targets.
- Package folders remain self-documenting and keep `Package.swift`, `README.md`, `PackageContract.md`, `Sources`, `Tests`, DocC, and `Scripts/verify_package.sh` so the same folder can be copied or published as SwiftPM later.
- Runtime targets must include only the source files/resources they actually need.
- Do not store generated artifacts here: `.build`, `.swiftpm`, `build`, `DerivedData`, logs, or Xcode user data.
- Build/cache/DerivedData output must stay under `/Users/Artem/.zenflow/worktrees` and never under `/Users/Artem/Library`, `/tmp`, or other external locations.

## Relationship to other package folders

- `./PackagesForReuse` is the complete vault of reviewed reusable packages.
- `./PackagesInUse` is the active source-only subset compiled into this app.
- `./Packages` is now SDK/package creation docs/templates only, not runtime package code.

## Active packages

- `./PackagesInUse/AppAnalytics`
- `./PackagesInUse/AppAppleAuthentication`
- `./PackagesInUse/AppBranding`
- `./PackagesInUse/AppConfiguration`
- `./PackagesInUse/AppDatabase`
- `./PackagesInUse/AppErrors`
- `./PackagesInUse/AppGlassUI`
- `./PackagesInUse/AppLocalization`
- `./PackagesInUse/AppNavigation`
- `./PackagesInUse/AppNetworking`
- `./PackagesInUse/AppOnDeviceAI`
- `./PackagesInUse/AppPermissions`
- `./PackagesInUse/AppPushNotifications`
- `./PackagesInUse/AppShareExtensionSupport`
- `./PackagesInUse/AppWidgetSupport`
- `./PackagesInUse/TchopProductLocalizationResources`
- `./PackagesInUse/IntegrationHelpers/AppAnalyticsNavigationIntegration`
- `./PackagesInUse/IntegrationHelpers/AppAnalyticsNetworkingIntegration`
- `./PackagesInUse/IntegrationHelpers/AppAnalyticsPushNotificationsIntegration`

## Source-only integration notes

Source-only compilation differs from SwiftPM module compilation:

1. Package-module imports are removed in app/extension/test source because package declarations compile into the target module.
2. Umbrella re-export files in `./PackagesInUse` must not contain `@_exported import` of sibling package modules.
3. Package source filenames that collide with app source filenames may need unique filenames to avoid Xcode `.stringsdata` duplicate-output errors.
4. Resource bundles that previously used `Bundle.module` must use a local bundle token and target resources copied into the app/extension bundle.
5. Package tests remain preserved with each package for future SwiftPM verification, but app verification uses the app target and app tests.

## Adding a future package

1. Review/fix the archive as a standalone package.
2. Always copy the final source-only package folder into `./PackagesForReuse`.
3. If the app can use it now, also copy it into `./PackagesInUse`.
4. Remove generated artifacts from the copied folder.
5. Add only required package source/resource files to the relevant Xcode targets.
6. Replace app-specific duplicated mechanics with package APIs only when the package surface fits without decorative wrappers.
7. Run `plutil -lint ./TchopApp.xcodeproj/project.pbxproj`, `git diff --check`, and `./scripts/verify.sh low` at minimum.
