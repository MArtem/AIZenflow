# Build & Test Command Synthesis

V4 discovers **candidates**, not invented commands. Priority:
1. commands executed by merge/release CI;
2. repository scripts/Makefile/Fastlane called by CI;
3. documented developer commands;
4. shared Xcode scheme evidence;
5. synthesized xcodebuild suggestion, explicitly labelled `suggested`.

For tests, detect test plans and preserve them in candidate commands. Apple supports discovering test plans with `xcodebuild -scheme <scheme> -showTestPlans` and selecting one with `-testPlan`.

Do not hard-code a simulator runtime that the repository never establishes. A generated destination may use a clearly marked placeholder. Never report a synthesized command as having passed.
