# AG-15 — Third-party dependency gate

- [ ] Need justified against system/existing APIs.
- [ ] Maintenance/license/security history acceptable.
- [ ] Swift 6/concurrency/platform support checked.
- [ ] Transitive deps/build/binary/startup cost measured/understood.
- [ ] Privacy manifest/signature/data collection reviewed.
- [ ] Vendor API isolated if replacement cost is material.
- [ ] Version pinned/reproducible and upgrade tests exist.

## Gate result
- `PASS` — all applicable items checked.
- `CONDITIONAL` — explicit accepted risk/unknown with owner.
- `FAIL` — blocker/high-risk invariant not proven.
