# Repository Evidence Contract

Agent reports must distinguish:
- **Observed** — command output, compiler diagnostics, test result, Instruments/log evidence.
- **Inspected** — directly read from source/configuration.
- **Inferred** — reasoned from inspected facts but not executed.
- **Unknown** — unavailable or intentionally unverified.

Never translate "code looks correct" into "verified". Build success does not prove semantic compatibility; unit tests do not prove absence of leaks/races; static review does not prove performance improvement.

For R2+ changes, final reporting includes the exact verification commands, affected targets, negative paths checked, and rollback/containment where meaningful.
