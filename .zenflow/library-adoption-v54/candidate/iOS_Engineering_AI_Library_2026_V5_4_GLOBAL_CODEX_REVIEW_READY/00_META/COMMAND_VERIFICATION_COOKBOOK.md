# Command Verification Cookbook

Команды — шаблоны. Агент сначала обнаруживает реальные workspace/project/scheme/destination и только потом подставляет значения.

## Discovery
```bash
xcodebuild -list -json -workspace <App.xcworkspace>
xcodebuild -showBuildSettings -workspace <App.xcworkspace> -scheme <Scheme>
xcrun simctl list devices available
```

## Build
```bash
xcodebuild \
  -workspace <App.xcworkspace> \
  -scheme <Scheme> \
  -configuration Debug \
  -destination 'platform=iOS Simulator,name=<Device>' \
  build
```

## Tests
```bash
xcodebuild \
  -workspace <App.xcworkspace> \
  -scheme <Scheme> \
  -destination 'platform=iOS Simulator,name=<Device>' \
  test
```

Targeted test execution should use the project's existing test plan/scheme conventions rather than inventing a second CI path.

## Swift Package
```bash
swift build
swift test
```

## Static checks
Run only tools already adopted by the repo unless the task explicitly introduces one:
```bash
swiftlint
swiftformat --lint .
```

## Diagnostics
Where appropriate:
- Thread Sanitizer for race-prone testable paths;
- Address Sanitizer for memory corruption/C interop;
- Main Thread Checker;
- Memory Graph/Leaks/Allocations;
- Time Profiler/Hangs/Points of Interest;
- Network template/URLSession metrics;
- Foundation Models instrument for agentic model flows.

## Rule
Never claim a command ran unless its output was actually observed. Record command + result in the evidence ledger.
