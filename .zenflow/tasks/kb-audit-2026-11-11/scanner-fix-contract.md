# Scoped static-scanner repair contract

## Confirmed failure
At the current canonical baseline, the forbidden-pattern, localization and SwiftUI hot-path scripts ignore positional scope arguments and enumerate the repository root. Their wrapper can emit a receipt naming a narrower scope. Wrapper eligibility and scanner exclusion logic also differ. This can misrepresent evidence or report findings outside the selected scope. The scope-aware project overrides are distinct implementations and must not be silently replaced.

## Required behavior
For these three canonical scanners, resolve supplied roots with the governed `static_gate_scope` module and scan only its eligible Swift files inside those roots. Applicability and scanner enumeration must share exactly the same eligibility and exclusion predicate. Do not hard-code an app name; document exclusion semantics and retain current pattern severity and privacy boundaries. Fail closed on invalid paths, unavailable enumeration, escaping links and empty/unsupported universes; never fabricate PASS. Preserve output and exit-code contracts as far as the existing wrapper can support them.

## Validation needed before publication
With explicit user authorization for writing/running tests, create isolated fixtures inside `.zenflow` that cover: sibling roots with findings in only one, nested and single-file scopes, test-only input, no eligible Swift files, excluded/ignored content, invalid or escaping paths and baseline severity/exit behavior. Verify wrapper receipts describe actual scan scope and classify non-applicable/blocked/failure honestly. Run permitted static syntax checks and review the complete canonical diff and affected call sites. Include evidence limitations; do not run app builds, simulator, physical devices or general test suites. Existing project wrapper exclusion correction has only static syntax/diff evidence.

No scanner repair has been published; a safety warning in `STATIC_QUALITY_GATE_POLICY.md` is present only as an uncommitted working-tree change pending the blocking finding's disposition.
