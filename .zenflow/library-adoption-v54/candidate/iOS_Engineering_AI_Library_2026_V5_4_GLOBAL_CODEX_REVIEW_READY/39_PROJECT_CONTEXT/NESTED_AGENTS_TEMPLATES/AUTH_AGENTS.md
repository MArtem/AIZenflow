# Auth subtree rules
- Secrets never enter logs, fixtures or analytics.
- Session/token state has one explicit owner.
- Refresh is concurrency-safe and logout invalidates in-flight work.
- Replay only requests proven safe/idempotent.
