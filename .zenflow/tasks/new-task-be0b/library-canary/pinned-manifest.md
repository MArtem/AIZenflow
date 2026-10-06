# Candidate content manifest — not a release

The user selected **IOS Library** as the future copy-only library name on 2026-09-30. Naming
does not approve this candidate, activate it in a project or change any `reference` command.

This is the **current curated-file allowlist for offline review**, not permission to copy it into
a client project or activate a new-chat rule. The candidate still lacks complete scenario,
cross-chat and whole-corpus evidence. Every file not listed below is excluded from the proposed
active payload, even if it exists beside these files.

The earlier 2026-09-29 B1 check covered 32 regular, non-executable paths and 50 local Markdown
links. After adding the inactive mode handler and Swift-runtime route, a static check found
34 regular non-executable paths without symlink components and 53 local links contained in
this allowlist. Repeat the exact checks after any edit. This snapshot is **not** a semantic
review, content-identity
receipt, skill conversion, activation, runtime test or release approval.

## Core and control documents

### Aggregate identity encoding

`aiz-ios-copy-payload-v1` is SHA-256 of the following byte stream. Begin with
UTF-8 `aiz-ios-copy-payload-v1` followed by one NUL byte. Process the backtick-quoted
payload paths in the two allowlist sections below in their displayed order (core,
then thematic); this manifest itself and other prose paths are not payload entries.
For each file append: UTF-8 relative path, NUL, ASCII decimal raw byte count without
leading zeros, NUL, exact raw file bytes, NUL. Do not normalize newlines or text,
sort paths, hash hexadecimal digests in place of bytes, or insert other separators.
Display the resulting digest as 64 lowercase hexadecimal characters.

- `KNOWLEDGE_ROUTER.md` — one bounded knowledge entrypoint.
- `QUALITY_STANDARD.md` — additive local-first quality contract.
- `EVIDENCE_POLICY.md` — observed versus unverified claims.
- `PROJECT_FACTS.md` — task-relevant project facts without writing a profile.
- `REPOSITORY_INSPECTION.md` — read-only owner/consumer mapping.
- `RISK_AND_EVIDENCE.md` — risk-scaled verification choices, not command authority.
- `REVIEW_GUIDE.md` — complete changed-artifact review.
- `PROJECT_MODE.md` — proposed external per-Xcode-project ON/OFF state contract.
- `STARTUP_RULE.md` — dormant entry rule requiring later explicit safe activation.
- `COPY_ONLY_QUICKSTART.md` — draft no-install usage guide; not a deployment command.
- `tools/reference_mode.py` — explicit per-project mode operation; never auto-run or treat as an installer.

## Curated thematic routes

- `19_CODE_REVIEW_REFACTOR/COPY_ONLY_REVIEW_ROUTE.md` — actionable code-review findings.
- `16_BUILD_MODULARITY_TOOLING/COPY_ONLY_BUILD_GRAPH_ROUTE.md` — targets, packages and resources.
- `13_ACCESSIBILITY_LOCALIZATION/COPY_ONLY_INCLUSIVE_UI_ROUTE.md` — accessibility/localization.
- `29_DESIGN_SYSTEM/COPY_ONLY_DESIGN_TO_IOS_ROUTE.md` — Figma/design-to-iOS.
- `03_CONCURRENCY/COPY_ONLY_CONCURRENCY_ROUTE.md` — actor and task lifecycle.
- `02_SWIFT_LANGUAGE/COPY_ONLY_SWIFT_RUNTIME_ROUTE.md` — Swift semantics, ownership and public language/runtime contracts.
- `08_NETWORKING/COPY_ONLY_NETWORK_ROUTE.md` — API/network reliability.
- `09_PERSISTENCE_DATA/COPY_ONLY_DATA_ROUTE.md` — storage and migration safety.
- `10_TESTING/COPY_ONLY_TEST_STRATEGY_ROUTE.md` — risk-based, permission-aware verification.
- `12_SECURITY_PRIVACY/COPY_ONLY_SECURITY_PRIVACY_ROUTE.md` — threat-driven privacy/security review.
- `04_ARCHITECTURE/COPY_ONLY_ARCHITECTURE_ROUTE.md` — architecture and state ownership.
- `05_SWIFTUI/COPY_ONLY_UI_FLOW_ROUTE.md` — SwiftUI/UIKit and navigation flow.
- `34_AUDIT_GATES/COPY_ONLY_FULL_AUDIT_ROUTE.md` — full-project audit coverage and recommendations.
- `44_MULTI_AGENT_ORCHESTRATION/COPY_ONLY_AGENT_COORDINATION_ROUTE.md` — bounded, authorized agent coordination.
- `50_CLIENT_CODE_PROTECTION/COPY_ONLY_REPOSITORY_SAFETY_ROUTE.md` — repository and command safety without installed protection runtime.
- `11_PERFORMANCE_MEMORY/COPY_ONLY_PERFORMANCE_ROUTE.md` — measured performance/memory review, no unobserved speedup claim.
- `17_CI_CD_RELEASE/COPY_ONLY_RELEASE_ROUTE.md` — release evidence, rollout and recovery, no signing or publishing authority.
- `15_AI_INTELLIGENCE/COPY_ONLY_AI_FEATURE_ROUTE.md` — model/data/tool boundaries, evaluation and fallback.
- `14_PLATFORM_SERVICES/COPY_ONLY_APP_INTENTS_ROUTE.md` — intent identity, authority, duplicate actions and handoff.
- `14_PLATFORM_SERVICES/COPY_ONLY_STOREKIT_ROUTE.md` — entitlement source of truth and purchase-state review.
- `27_SYSTEM_INTEGRATION/COPY_ONLY_SYSTEM_INTEGRATION_ROUTE.md` — capability lifecycle, interruption and recovery.
- `08_NETWORKING/COPY_ONLY_API_CONTRACT_ROUTE.md` — DTO/domain/persistence/UI compatibility and error semantics.
- `18_OBSERVABILITY_DEBUGGING/COPY_ONLY_OBSERVABILITY_ROUTE.md` — actionable, privacy-bounded production evidence.

The 813 imported `01–35` thematic files, 189 `legacy-source/` Markdown/JSON files, 240 files in
`source-skills/`, 49 Markdown/JSON files in `source-runtime/`, 11 documents in
`source-protection/`, `source-meta/`, `source-global/`, `source-package-docs/`, four preserved
audit scripts in `source-tools/`, the draft scanner and other nonlisted files in `tools/`, eight `00_META/` compatibility
pointers, `source-catalog.csv`, draft/evaluation documents
are **not** on this allowlist. A filename or historical `type: skill` front matter never grants
Codex skill installation or authority. Useful unlisted material must be curated into a reviewed
route and explicitly added here before it can become payload. The retired `v5.4` working-tree
source was removed after the coverage check in `MIGRATION_COVERAGE_RECEIPT.md`; its Git history
remains available. No installed runtime selects this candidate.

## Gate before a future copy-only release

This draft list is not a validated package. Before publishing an exact payload, check that every
listed path is a regular file inside the intended copy root, no symlink or unexpected executable
is included, all relative links and selected skill metadata resolve, and no excluded source or
installer file is pulled in by a dependency. Compare the complete proposed file list and content
identities with the release record. Check that documentation claims about audits, tests and
coverage match actual evidence; an absent or stale input blocks a release-ready claim. The old
`validate_package.py` cannot serve this gate because it requires V5.4 installer files and
installed-runtime invariants. This paragraph describes a required review, not a passing check.
