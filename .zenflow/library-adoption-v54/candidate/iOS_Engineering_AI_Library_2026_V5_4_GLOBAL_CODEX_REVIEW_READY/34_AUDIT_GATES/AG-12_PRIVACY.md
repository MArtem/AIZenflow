# AG-12 — Privacy gate

- [ ] Data minimization и purpose определены.
- [ ] Permissions запрашиваются только когда нужны и handle denial/revocation.
- [ ] Logs/analytics/crash breadcrumbs не содержат PII/secrets.
- [ ] PrivacyInfo.xcprivacy соответствует real collection/required-reason APIs.
- [ ] Third-party SDK privacy manifests/signatures checked.
- [ ] App Store privacy disclosures не расходятся с runtime behavior.
- [ ] Retention/deletion policy учитывается для collected/generated data.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
