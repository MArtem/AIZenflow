# Staff/Principal Decision Framework

For non-trivial decisions score each candidate 1–5 on:
- correctness robustness;
- conceptual complexity;
- change amplification;
- testability;
- concurrency clarity;
- ownership/lifetime clarity;
- performance predictability;
- security/privacy;
- migration/rollback;
- team familiarity;
- operability/debuggability.

Do not choose the solution with the most abstraction. Choose the one with the best long-term risk-adjusted cost.

## Architectural smell checks
- abstraction has one implementation and no volatile boundary;
- view model owns navigation + networking + storage + analytics + formatting;
- repository merely renames service methods;
- global DI container hides dependencies;
- protocol exists only to mock everything;
- reducer/effect architecture used for trivial state;
- Observable singleton is used as app-wide mutable event bus;
- actor is added without defining invariant it owns.
