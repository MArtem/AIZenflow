# Fact vs Inference Policy

## Evidence classes
`observed` must cite its origin: repository path, parsed Xcode object, command output, or VCS metadata. `derived` must identify the source facts. `heuristic` must carry a confidence in `[0,1]` and evidence leads. `unknown` is preferred to a confident-looking guess.

## Forbidden upgrades
Never promote these solely from filename/class-name frequency:
- MVVM / Clean / TCA as the repository architecture.
- a Makefile/Fastlane/xcodebuild invocation as the canonical CI gate.
- a deployment target parsed from one configuration as universal across targets.
- a singleton as the state owner.
- a test target as comprehensive coverage.

## Confidence language
- 0.90–1.00: strong repository evidence, still not a formal guarantee.
- 0.70–0.89: multiple consistent signals.
- 0.40–0.69: useful lead requiring confirmation.
- below 0.40: normally omit from generated recommendation and retain as a diagnostic lead.

Generated Markdown must visually label heuristics.
