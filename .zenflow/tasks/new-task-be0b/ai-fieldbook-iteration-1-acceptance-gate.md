# AI Fieldbook Iteration 1 Acceptance Gate

## Purpose
The non-AI baseline is accepted in two evidence stages because only Simulator is currently available. `1.26-S` may unlock only the documented Simulator-verifiable subset of Iteration 2. `1.26-D` remains mandatory before device-only implementation or any full runtime-completion claim.

## Current Gate Status
Status: `1.26-S` open; `1.26-D` blocked by missing physical hardware.

## 1.26-S — Simulator Validation And Acceptance
- CRUD for workspaces and every supported knowledge-item type.
- Picker fixtures for image, imported audio, PDF, URL, and UTF-8 plain-text content, including invalid, corrupt, oversized, multi-frame, missing, and digest-mismatch cases.
- Imported-audio playback, cancel/error states, and resource release. This does not prove microphone recording.
- URL create/edit/move/open flow, including credential rejection, HTTP warning, and deep-link kind mismatch.
- Populated V1-to-V2 migration and saved-record relaunch durability.
- Crash injection at every staged-deletion boundary for item, workspace, and delete-all flows, followed by relaunch reconciliation.
- Dynamic Type pass on primary flows, including Russian text expansion and plural forms; Simulator accessibility inspection may support this evidence but does not replace physical-device VoiceOver.
- Deep-link routing after accepting the system open confirmation.
- Export success, cancellation, functional responsiveness, share availability, cleanup, and insufficient-storage behavior to the extent Simulator can reproduce them.
- Delete-all confirmation, Spotlight cleanup, runtime-cache reset, and result state.

`1.26-S` can be accepted only after the user explicitly authorizes and reviews this validation block. It permits no microphone capture, real audio-session hardware lifecycle, locked-device file-protection claim, full VoiceOver/touch claim, hardware-performance claim, Foundation Models inference, or Siri voice claim.

## 1.26-D — Physical-Device Validation
- Actual microphone permission, recording, playback, interruption, route-change, foreground/background, cancel, re-record, and save-failure behavior.
- Locked-device verification for complete file protection.
- Physical-device VoiceOver, focus, touch-target, and full Dynamic Type pass on primary flows and every error/progress state.
- Repeated media open/close, search at realistic scale, memory growth, and main-thread responsiveness on representative hardware.
- Hardware share-sheet behavior, Siri voice invocation, and any Apple Intelligence capability used by later work.

## Simulator/Static Validation Allowed
- Static plist/localization checks, URL-scheme recognition, and SwiftUI navigation/system-integration smoke checks when separately authorized.

## Tests
Automated test writing remains prohibited until the user explicitly opens a test-writing phase.

## Acceptance Criteria
`1.26-S` can be accepted only when:

- every required manual validation item is passed or explicitly deferred by the user;
- P0/P1 Simulator runtime findings are closed with evidence;
- remaining risks are listed;
- no device-only or AI-runtime implementation has started;
- handoff and plan are updated;
- completion report follows `./docs/COMPLETION_REPORT_CONTRACT.md`.

`1.26-D` closes the physical-device evidence only when its required items are passed or explicitly deferred by the user. Neither stage waives archive/signing, Privacy Report, dSYM, or release-readiness evidence.
