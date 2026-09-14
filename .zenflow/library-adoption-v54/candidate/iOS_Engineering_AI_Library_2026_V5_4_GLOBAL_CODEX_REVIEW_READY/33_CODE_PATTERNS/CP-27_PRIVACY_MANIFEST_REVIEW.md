# CP-27 — Privacy manifest is a generated-report comparison task

Review flow:
1. Inventory app + SDK data collection and required-reason APIs.
2. Inspect every bundled `PrivacyInfo.xcprivacy`.
3. Generate Xcode privacy report.
4. Compare report with App Store Connect disclosures and actual runtime behavior.
5. Re-run after dependency upgrades.

Do not treat a syntactically valid manifest as proof that privacy declarations are correct.
