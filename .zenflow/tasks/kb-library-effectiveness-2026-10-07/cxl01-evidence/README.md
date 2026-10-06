# CXL-01 local mechanism evidence

User accepted the proposed block on 2026-10-07: one module, entry/router changes (maximum three
active Markdown files), one temporary Swift fixture, type-check and eight deterministic local
scenarios, 30–60 minutes. No app edits/builds/Simulator/network/installations or evaluation workers.

Contract: KB retains authority; candidate recipe selected before a cancellation publication fix;
actual state actor owns invocation identity, both success/error publication and identity-bound
cleanup; current errors remain visible; cancellation does not undo committed side effects. Real
integration must specify cancellation UX, producer lifetime and resource bounds. Existing app pins
remain unchanged. Sealed holdout bodies/oracles were not opened or emitted.

Swift file was preserved here from the temporary block to make the evidence reproducible. Its
PublicationOwner section is byte-identical to the module example. Model tests do not verify any
app patch, real storage, WebKit or runtime profile. Candidate status persists.

Commands (from active repository root; shell login:false):

```sh
CXL_DIR="$PWD/.zenflow/task-artifacts/kb-library-effectiveness-2026-10-07/cxl01"
CXL_SOURCE="$PWD/.zenflow/tasks/kb-library-effectiveness-2026-10-07/cxl01-evidence/CancellationPublication.swift"
CXL_COMPILER=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/swiftc
CXL_SDK=/Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/MacOSX.sdk
mkdir -p "$CXL_DIR/cache" "$CXL_DIR/tmp"
TMPDIR="$CXL_DIR/tmp" "$CXL_COMPILER" -sdk "$CXL_SDK" -swift-version 6 -strict-concurrency=complete -warnings-as-errors -module-cache-path "$CXL_DIR/cache" -parse-as-library -typecheck "$CXL_SOURCE"
TMPDIR="$CXL_DIR/tmp" "$CXL_COMPILER" -sdk "$CXL_SDK" -swift-version 6 -strict-concurrency=complete -warnings-as-errors -module-cache-path "$CXL_DIR/cache" -parse-as-library "$CXL_SOURCE" -o "$CXL_DIR/CancellationPublication"
"$CXL_DIR/CancellationPublication"
```

Observed: Swift 6.4 (swiftlang-6.4.0.34.1), macOS27 host/SDK. Initial direct compiler invocation
without SDK failed to load the standard library; explicit installed SDK resolved it. No installer
or app build. Successful compilation/local run: [results.txt](results.txt), 8/8 PASS. Initial
xcrun type-check passed but reported SDK discovery/cache warnings; final explicit-SDK type-check
is recorded separately. Outputs/cache/tmp stay within .zenflow. SDK/compiler are read-only tools.

iPad/physical device/actual VoiceOver: OMITTED_BY_USER. Library benefit and delivery: NOT_MEASURED.
Final semantic review must inspect both error/success guards, cleanup, retention and exact example
parity; compilation alone does not replace that review. No high-risk app integration occurred.
