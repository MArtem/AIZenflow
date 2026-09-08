# Package Ownership and Adoption Standard

<!-- Rule ID: QC.PACKAGE.OWNERSHIP v1.0 -->

## Purpose

This standard keeps reusable package mechanisms separate from app adoption, product policy and
rollback history for current and future projects.

## Source of truth

- `reusable/package-vault-docs/PACKAGE_CATALOG.md` is the reusable capability inventory.
- A catalog entry describes the mechanism, supported products/targets, package source revision or
  published version policy, limitations and host-owned responsibilities.
- `PackagesForReuse` is a reviewed source snapshot. A package is identified by its package path,
  content revision or published tag, and the Documentation Vault revision used for its contract.
- `PackagesInUse` is an app-owned integration snapshot. Its adoption, target membership, local
  wiring, migration and rollback history belongs under `apps/<AppName>/` or the consuming task.

The reusable catalog must not be the authority for whether a package is active in a particular
app. App-specific names, endpoints, product policy, target membership, rollout decisions and
rollback records stay with the app owner. Existing source-app material retained for provenance is
historical or explicitly app-scoped; it is never a default for a new project.

## Package states

Use separate axes instead of one ambiguous “complete” label:

- **cataloged** — capability and contract are indexed;
- **source-verified** — the exact package revision passed its permitted static/package checks;
- **app-adopted** — an app owner recorded the integration and target scope;
- **released** — a separately versioned/tagged artifact has release evidence;
- **retired** — adoption is stopped with a preserved rollback/provenance record.

The historical 50-iteration SDK roadmap is reference material only. It does not require the next
numbered package, claim that all entries are implemented, or replace a current consumer need and
evidence.

## Verification and resource boundaries

- Verification templates must name the output root, SwiftPM build/cache root and cleanup policy.
- Defaults must remain inside the active `/Users/Artem/.zenflow` sandbox or an explicitly supplied
  permitted root; do not fall back to `/tmp`, a user Library, Desktop, global SwiftPM cache or
  undeclared temporary storage.
- A read of an instruction does not authorize a permission-sensitive command. The command owner
  records whether execution was permitted, skipped, denied or unavailable.
- Package verification claims identify package revision, toolchain/profile, source universe,
  commands and terminal results. A historical template example is not fresh evidence.

## Testing and privacy

- Test scope follows the package change contract, supported platforms, failure modes and current
  permissions. Fixed test-count quotas are not quality evidence.
- A URL path is not automatically sanitized: paths and slugs may contain account IDs, private
  names or tokens. Telemetry must use an explicit allowlist/redaction policy and test the chosen
  classification; host-only or opaque route categories are safer defaults.
- Package mechanisms must not decide product copy, persistence schema, rollout, consent or domain
  policy. Those decisions remain in the consuming app.

## Change and rollback

Adding or adopting a package records the package revision, Documentation Vault revision, owner,
consumer scope, verification evidence, known limitations and rollback path. Reverting adoption
must not delete the reusable source snapshot or app history.
