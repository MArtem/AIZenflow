# Legacy HARDENED self-validation report — superseded

This filename existed in the immutable reviewed V5 HARDENED baseline. Its former PASS/BLOCKED claims are **not validation evidence for V5.4 REVIEW READY** and must not be used to accept this candidate. The independent review found that the old report could pass while executable defects F01–F10 remained.

Current candidate evidence is intentionally separated into:

- `REVIEW_FINDINGS_MATRIX.md` — finding → root cause → patch → regression evidence → candidate status.
- `REVIEW_READY_VALIDATION_REPORT.md` — only tests and validations actually executed for the V5.4 candidate.
- `tests/run_all.py` — reproducible synthetic regression runner.

Terminology in the current candidate distinguishes **prevention/rejection before mutation**, **detection after mutation**, and **advisory classification**. Independent repeat review of the delivered ZIP is still required.
