# Stage 6 receipt — bounded knowledge subset and canonical compatibility

Date: 2026-09-11
Candidate: `iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`

## Scope decision

The package contains 51 knowledge sections, 60 namespaced skills, and 288 deep playbooks. This
receipt does not accept that whole corpus. The initial process subset is the 12 documents below;
all other knowledge remains `reference-only / unreviewed` until separately routed and checked.
Reference-mode installation still copies the package knowledge root, so this is a routing and
adoption boundary, not a claim that the installer physically prunes the corpus.

| Document | Process disposition | Required guard |
|---|---|---|
| `03_CONCURRENCY/IOS-03-06_TASK_LIFETIME.md` | adopted reference | owner/lifetime first; strict-concurrency and cancellation evidence |
| `03_CONCURRENCY/IOS-03-07_CANCELLATION.md` | adopted reference | generation/stale-completion and cooperative-cancellation tests |
| `05_SWIFTUI/IOS-05-02_STATE_OWNERSHIP.md` | adopted reference | single source of truth; target availability and actual UI behavior |
| `05_SWIFTUI/IOS-05-03_VIEW_IDENTITY.md` | adopted reference | stable identity/navigation contract; measured update behavior |
| `08_NETWORKING/IOS-08-02_AUTH_REFRESH.md` | adopted with security gate | backend refresh/replay contract, logout race, secret-safe logging |
| `08_NETWORKING/IOS-08-03_RETRY_BACKOFF.md` | adopted with API gate | idempotency/replayability comes from server contract, not URLSession |
| `09_PERSISTENCE_DATA/IOS-09-05_MIGRATIONS.md` | adopted with migration gate | real store history, migration failure and rollback evidence |
| `11_PERFORMANCE_MEMORY/IOS-11-05_MEMORY_LEAK.md` | adopted diagnostic reference | retain-path plus Memory Graph/Allocations or lifecycle evidence |
| `11_PERFORMANCE_MEMORY/IOS-11-11_PERF_BUDGET.md` | adopted reference | controlled before/after measurement on representative device/config |
| `12_SECURITY_PRIVACY/IOS-12-03_AUTHENTICATION.md` | adopted with security gate | Keychain/AuthenticationServices, entitlements, backend and redaction review |
| `12_SECURITY_PRIVACY/IOS-12-12_SECURITY_REVIEW.md` | adopted with security gate | threat model, abuse cases, privacy manifest and current submission policy |
| `13_ACCESSIBILITY_LOCALIZATION/IOS-13-01_VOICEOVER.md` | reference-only pending manual evidence | actual VoiceOver traversal/action testing; static text is not PASS |

## Static acceptance

The 12 selected documents were checked for the review-ready scenario/common-wrong/preferred/
verification/compatibility structure, current-source marker, a primary-source URL, and a valid
`31_DEEP_PLAYBOOKS/OP-*.md` target: **12/12 PASS**. The package's official-reference index maps
each selected domain to Apple/Swift primary sources and explicitly states that project SDK,
deployment target, toolchain, persisted history, server contract, and runtime behavior override
generic guidance.

The candidate's `10_TESTING/IOS-10-02_SWIFT_TESTING.md` was inspected but excluded from the
initial subset: it has no review-ready depth section and no primary-source marker. It remains
reference-only; no Swift Testing/Xcode compile claim is made.

## Canonical-rules compatibility

- **Compatible:** repository-local rules remain authoritative; knowledge is advisory; runtime
  authority is separate; client-repository protection, declared scope, risk classification,
  cancellation/lifetime, privacy, accessibility, and evidence language match the candidate's
  global block and runtime core standards.
- **Operational override required:** generic prompts say to add tests and run available checks,
  but this cannot grant permission. Current project/user authorization, test restrictions,
  toolchain availability, and the task's evidence gate remain higher priority.
- **Not adopted:** no automatic routing of all 60 skills or 288 playbooks; no generic advice is
  allowed to authorize build, test, network, Git, dependency, signing, release, or global-config
  mutations.

## Primary-source spot check

On 2026-09-11 the cited Apple pages for strict concurrency, `Task.cancel()`, SwiftUI `State`,
`URLSession`, `SchemaMigrationPlan`, memory-use tooling, Keychain, VoiceOver, and Swift Testing
resolved to Apple Developer Documentation pages. The pages require JavaScript in the automated
reader, so this confirms URL/page availability and title, not a full semantic re-review of each
API. The library's own checked-date/source caveats are retained.

## Gate result

Knowledge subset gate: **PASS for bounded routing only**. VoiceOver remains manual-evidence
pending; testing material remains excluded from initial adoption; license/provenance remains
UNKNOWN because the supplied artifact has no detected LICENSE/NOTICE/SPDX declaration or source
commit. No global installation or automatic knowledge activation was performed.
