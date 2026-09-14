# Task Routing Matrix

| Task | Primary skill | Often compose with |
|---|---|---|
| Feature implementation | `ioslib-implementation` | architecture, testing, domain skill |
| PR/diff review | `ioslib-pr-review` | concurrency, security, persistence, API contract |
| Crash/hang | `ioslib-crash-debugging` | diagnostic, concurrency, memory |
| Race/isolation | `ioslib-swift-concurrency` | diagnostic, testing |
| SwiftUI behavior/state | `ioslib-swiftui` | architecture, testing, accessibility |
| Auth/token/session | `ioslib-networking-auth` | security-privacy, concurrency, testing |
| Schema/data migration | `ioslib-data-migration` | persistence, release, observability |
| Performance regression | `ioslib-performance` | observability, memory-leaks |
| Legacy modernization | `ioslib-legacy-modernization` | migration, architecture, testing |
| Release/hotfix | `ioslib-hotfix-release` / `ioslib-release` | observability, feature-flags, security |

Start with one primary skill. Add another only when it owns a distinct risk boundary.
