# Migration Protocol

Any migration must define:
1. source and target state;
2. compatibility window;
3. inventory/call-site count;
4. sequencing by module/feature;
5. behavioral parity tests;
6. data/API compatibility;
7. rollout flag if risk warrants;
8. rollback strategy;
9. telemetry that proves success;
10. cleanup criteria for old path.

## Preferred pattern
`observe → characterize → add seam → migrate one slice → compare → expand → remove legacy`.

Avoid big-bang rewrite unless dual-running/compatibility is more dangerous than replacement.
