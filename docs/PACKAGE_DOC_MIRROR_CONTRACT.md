# Package Documentation Mirror Contract

## Purpose

This contract defines how reusable package documentation is mirrored between the canonical
Documentation Vault and a consuming worktree.

## Canonical form

- Package instructions use neutral host terminology (`consuming app`, `HostApp`, or equivalent).
- No generated placeholder may appear in an executable command, path, heading or adoption step.
- Product-owned package names remain explicit; they are not renamed to generic infrastructure.
- Historical provenance may describe an earlier app context only in a clearly marked historical
  section and must not be copied into current commands.

## Consuming-worktree form

- The consuming worktree may specialize neutral host terminology to its real app name.
- `PackagesForReuse` is the source snapshot; `PackagesInUse` is the active source-only snapshot.
- Adoption, target membership, rollback and product policy remain owned by the consuming app docs.
- A mirror change must preserve package API, ownership, verification and safety semantics.

## Verification

Review the transformed diff for executable paths and commands, then validate package counts and
hashes with `scripts/generate_package_snapshot_manifest.py --check`. A package-doc change is not
complete when only a date or folder count changed without an updated snapshot identity.
