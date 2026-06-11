# Local Source Use: AppNavigation

This folder is currently used by TchopApp as local source, not as an active Swift Package dependency.

## Local-source mode
1. Add required `Sources/**/*.swift` files to the host Xcode target.
2. Add required `Sources/**/Resources` files to the same target resources if the package uses localized strings or other assets.
3. Remove `import AppNavigation` from host source files because the package is no longer compiled as a separate module.
4. Keep this folder free of `.build`, `.swiftpm`, `build`, `DerivedData`, logs, and Xcode user data.

## SwiftPM mode
This package still contains `Package.swift`, package docs, and package-owned tests. A future project can copy this folder or reference it as a Swift Package and then run the package verification script from `Scripts/verify_package.sh`.
