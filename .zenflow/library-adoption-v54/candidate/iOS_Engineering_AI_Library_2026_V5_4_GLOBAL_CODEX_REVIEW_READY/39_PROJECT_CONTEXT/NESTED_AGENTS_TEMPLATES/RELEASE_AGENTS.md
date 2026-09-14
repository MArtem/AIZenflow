# Release subtree rules
- Never rotate signing, submit builds, tag releases or mutate production config implicitly.
- Require explicit target/environment and preserve rollback/containment.
- Redact credentials from command output and docs.
