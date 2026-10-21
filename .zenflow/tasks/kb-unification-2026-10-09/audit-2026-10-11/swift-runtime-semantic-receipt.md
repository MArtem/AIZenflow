# Swift language/runtime source preservation review

2026-10-13. LIB-0016–LIB-0029: fourteen source bodies read completely, including
all shared workflow/prompt/anti-pattern/V2 sections. Curated source LIB-0015 was
separately reviewed in curated-routes-semantic-receipt.md. Current Swift deep owner,
API Contract and Localization standards read completely for this comparison.

| Source U01 | Independent assessment and owner anchors |
|---|---|
| LIB-0016–0018 | Swift Public API Rules/Error And Result Design/Mental Model/Type And API Decisions retain expressive typed contracts, identity/mutation/sharing, concrete/opaque/existential/generic choice and meaningful seams. Value semantics do not imply stack allocation or measured speed. |
| LIB-0019–0020 | Ownership And Memory retains real benefit/toolchain conditions for borrowing/consuming/noncopyable features. Type And API Decisions preserves finite state and invalid-combination modeling; no automatic architecture transition. |
| LIB-0021 | Typed recoverable errors and stable consumer branching remain; API Errors/Retry/Observability and the already-read user-feedback owner carry localized recovery, logging and retry requirements. Swift Error And Result Design alone is not the entire consumer contract. |
| LIB-0022 | API DTO And Domain Boundaries explicitly preserves versioned JSON, missing/unknown/extra/null values, enum policy, timestamp units/timezone, polymorphic discrimination, schema skew and deliberate lossy policy without suppressing integrity-critical failure. |
| LIB-0023–0024 | Macro diagnostics/expanded source/generated identity/access/build cost and ordinary-language alternative preserved. Wrappers require repeated semantics and explicit state/effect/ownership/lifetime; concise annotations are not evidence of a safe hidden implementation. Permitted invariant-based verification remains governed by Engineering §3. |
| LIB-0025–0026 | Complexity/allocation/copying/bridging/readability and measured-path qualification retained in Swift Performance Discipline. Locale/Calendar/TimeZone and supported FormatStyle/Foundation use, display-versus-wire distinction retained in Localization Required Checks. |
| LIB-0027–0029 | Pointer validity/lifetime/alignment/initialization/exclusivity, C/ObjC nullability/layout/ownership, generated interface and separate public source/module/ABI/semantic consumers retained. SPI/inlinable exposure, version/deprecation/removal and compatibility evidence remain explicit. No unchecked annotation exception is introduced by these source bodies. |

Forty-two current units adjudicated: fourteen active and twenty-eight archive-only.
Each U02 archives a fixed comparison quota, while viable material alternatives remain
conditional; U03 archives old V2/mode/Library delivery without reviewing linked OP bodies.
No useful condition loss found in this family. A01 remains an active skill delivery
contradiction even though the normative Swift owner is strict. Compiler/API/toolchain,
ABI and performance behavior were not executed or independently refreshed; this receipt
supports static preservation only, not general correctness or equal instructional utility.
