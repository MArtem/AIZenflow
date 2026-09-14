# Failure Recovery Protocol

Agent failure is not whole-task failure.

- Timeout/no result: mark node incomplete; decide whether it is critical-path.
- Partial result: retain supported evidence; do not discard useful observations.
- Tool unavailable: fall back to sequential role pass or static analysis and label evidence downgrade.
- Writer failure: inspect actual diff before retrying; never assume rollback occurred.
- Conflicting edits: stop integration, restore ownership, reconcile from diff rather than asking both writers to continue.
- Verification failure: keep product patch separate from diagnostic edits; return to integrator.

Retry only when the failure mode is understood and the second attempt changes something material.
