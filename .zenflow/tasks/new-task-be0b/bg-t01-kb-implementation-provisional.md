# BG-T01 implementation KB provisional — 2026-10-03

User grants project code edits without recurring permission and explicitly chooses A.
Compare meaningful task/bug/feature approaches with suitability/minuses/recommendation
before choosing; not a mandate to enumerate equivalent mechanical syntax.
Contract: two10×10 boards, minimum44pt cells, spacing3pt, horizontal viewport at narrow
width, complete grid height reserved, wider viewport fills as before. Explicit callbacks,
labels, phase gating and game state/rules unchanged. One ContentView source file only.
Implementation plan: measure viewport width in background GeometryReader using appearance/
width-change handlers; UI-local @State, no body state mutation. ScrollView frame fixes
viewport width independently of board content; width alone controls board side/height,
so height feedback cannot resize measured width. Deduplicate width update; finite positive
input. Default board side467pt until first measurement, no clipped rows at narrow width.
No new dependencies/resources/targets/services. Current iOS17 supports used change handler.
Read-only static/QC adoption review only; project runner/toolchain unverified and no engine
adoption invented. No build/tests/Simulator/agent/MCP/client Git authorization.
Meaningful alternatives UX A/B already user-selected; measured-width mechanism is bounded
implementation choice. Runtime scroll/VoiceOver/rotation remain evidence gaps.

KB post-patch review: ContentView SHA-256 d9134483db19a9d1e7e8edcca42f06120f66bb410c2cea124b86700146b010c1. Full affected source reviewed; UI-only viewport state, finite positive width guard, maxWidth viewport independent of board content, square grid and complete frame. No game/source graph/resource changes. Geometry calculation supports static bounds, not device hit-testing or interaction. Runtime/compile not_run.
