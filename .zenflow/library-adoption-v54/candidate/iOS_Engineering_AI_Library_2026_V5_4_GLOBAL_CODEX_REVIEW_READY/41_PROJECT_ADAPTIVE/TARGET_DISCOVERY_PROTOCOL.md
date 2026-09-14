# Target Discovery Protocol

Use multiple evidence layers rather than one regex result:
1. PBXNativeTarget records for name/product type.
2. XCBuildConfiguration / configuration-list relationships when parsable.
3. Shared schemes and their build/test references.
4. `.xctestplan` files.
5. CI commands that name schemes/workspaces/projects.
6. Optional `xcodebuild -list -json` output on macOS.

Deployment and Swift settings are target/configuration-specific. A global minimum/maximum may be rendered only as a derived summary over observed settings. Extensions, widgets, watch targets, tests and tooling targets remain first-class because their availability requirements can differ from the app.
