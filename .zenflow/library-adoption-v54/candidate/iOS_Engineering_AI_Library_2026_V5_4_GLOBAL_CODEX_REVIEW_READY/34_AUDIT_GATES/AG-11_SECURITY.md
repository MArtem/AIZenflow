# AG-11 — Security gate

- [ ] Threat boundary и protected assets определены.
- [ ] Authentication не подменяет authorization.
- [ ] Secrets в Keychain/platform secure storage; нет plaintext fallback.
- [ ] ATS/trust verification не ослаблены.
- [ ] Deep links/WebView/external input валидируются до privileged action.
- [ ] Logout/revocation/credential rotation paths определены.
- [ ] Negative security tests покрывают invalid/unauthorized input.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
