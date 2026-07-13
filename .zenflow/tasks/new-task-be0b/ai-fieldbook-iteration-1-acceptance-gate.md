# AI Fieldbook Iteration 1 Acceptance Gate

## Purpose
Iteration 2 App Intents and AI work must not begin until Iteration 1 has an accepted local-app baseline.

## Current Gate Status
Status: open.

## Manual Validation Required
- CRUD for workspaces and knowledge items.
- Picker fixtures for photo, video, audio, PDF, URL, and text content.
- Actual microphone recording and playback.
- URL edit/open flow.
- Populated data relaunch durability and migration posture.
- VoiceOver pass on primary flows.
- Dynamic Type pass on primary flows.
- Deep-link routing after accepting the system open confirmation.
- Export flow.
- Delete-all/destructive flow confirmation and result state.
- Saved-record relaunch check.

## Simulator/Static Validation Allowed
- Build only when materially useful.
- Static plist/localization checks.
- URL scheme recognition.
- SwiftUI navigation smoke checks when resource-justified.

## Tests
Automated test writing remains prohibited until the user explicitly opens a test-writing phase.

## Acceptance Criteria
Iteration 1 can be accepted only when:

- every required manual validation item is passed or explicitly deferred by the user;
- remaining risks are listed;
- no Iteration 2/App Intents/AI work has started;
- handoff and plan are updated;
- completion report follows `./docs/COMPLETION_REPORT_CONTRACT.md`.
