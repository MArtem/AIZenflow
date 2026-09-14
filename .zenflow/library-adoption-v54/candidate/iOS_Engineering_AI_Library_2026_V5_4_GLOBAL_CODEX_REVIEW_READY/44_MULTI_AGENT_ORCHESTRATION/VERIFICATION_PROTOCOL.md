# Verification Fan-out Protocol

Verification must target the highest-risk falsifiable claims.

Use parallel verification only when checks are independent: e.g. targeted tests, concurrency audit, migration compatibility review, security negative paths, performance measurement analysis.

Verification agents are read-only by default and report failures to the integrator. A green child report is insufficient without command/output provenance. If verification cannot run, explicitly downgrade evidence instead of substituting static confidence.
