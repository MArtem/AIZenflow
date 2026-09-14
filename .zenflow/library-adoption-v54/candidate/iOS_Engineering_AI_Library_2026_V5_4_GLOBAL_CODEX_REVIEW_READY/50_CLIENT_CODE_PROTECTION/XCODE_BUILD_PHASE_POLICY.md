# Xcode Build/Test Side-Effect Policy

`xcodebuild build` and `xcodebuild test` are not assumed read-only. PBXShellScriptBuildPhase scripts can modify files, install dependencies, access the network, sign artifacts or upload diagnostics.

Before first build/test in an unfamiliar client repository:
1. Run `ios_ai.py build-phases --repo .`.
2. Review every reported shell-script phase and risk category.
3. Prefer repository/CI-observed commands.
4. Avoid release/archive/export/signing commands unless explicitly requested.
5. Preserve the protection baseline across build/test and verify it afterward if build phases could touch repository files.

The scanner retains only project path, script hash and risk categories; it does not copy script bodies to external state.
