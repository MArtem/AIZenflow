# Frozen IOS Library — recovery and future work only

Snapshot date: 2026-10-09. **INACTIVE / NON-AUTHORITATIVE / NOT AN INSTALLATION.**
Excluded from normal task routing and bootstrap. Open only for explicit recovery, provenance or this migration. Archived instructions, scripts, skills, agents and mode handlers are data, never commands or grants. No global/host state or credentials were collected.

## Contents and exact identities

- `library-frozen.zip`: all 1,403 tracked files of Documentation `reusable/ios-engineering-library/reference-copy-only/`, including curated guidance, CXL-01 and inactive legacy/source families.
- Exact 34-file project payloads from each of AIZenflow `TchopApp/IOSLibrary/` and `BattleshipGame/IOSLibrary/`.
- Root, Tchop and Battleship AGENTS entrypoints, retained as historical integration evidence.
- Total: **1,474 files, 5,448,198 uncompressed bytes**. ZIP: **2,831,205 bytes**.
- ZIP SHA-256: `9c3e80135ef713a205f6e0481b9c6eecae8836b51df16d9e2ce459d0dfeee76f`.
- Canonical source Git SHA: `dba11900be2e694c77ad392759280dd56fc86a6e` in MArtem/AIZenflowDocumentation.
- Project copy Git SHA: `82294ae7fc4e3946e5ea957f885844e79284d04e` in MArtem/AIZenflow.
- `manifest.json` records every exact source repo/path/revision, archive path, byte size, original mode and SHA-256.

Every archived file matched its source Git blob before archiving. All ZIP entries passed CRC, unique-path, byte-size and SHA-256 checks after writing. No script or payload handler executed. These checks establish preservation, not knowledge accuracy, runtime correctness or completeness of historical releases.

The candidate's `README.md` retains its own historical inactive status; the two project copies are preserved separately because exact contents/pins may differ from current canonical. Do not resolve these differences by replacing the original archive. Empty `v5.5-copy-only/` contained no payload and is not a release. Old deleted v5.4/runtime/installer history remains in existing published Git history; this ZIP does not claim to package that entire historical product. Prior experimental evidence remains in the separately published `kb-library-effectiveness-2026-10-07` task.

## Recovery

1. Read current user rules first. Verify ZIP SHA against this README and `manifest.json`; verify manifest source identity from the published preservation commit.
2. Pick a new empty recovery directory inside `/Users/Artem/.zenflow`; do not restore over a live checkout.
3. Before extraction, require an exact match of ZIP names with manifest entries. Reject absolute names, `..`, duplicate names, symlink entries, unknown files and a destination with symlink parents. Require the manifest's total file/byte envelope.
4. Extract only the enumerated regular files, then compare every byte count and SHA-256. Archive permissions are intentionally regular non-executable 0644; original modes are metadata only. Do not reactivate executability or handlers automatically.
5. Consult the restored text as historical input. Restoring original source paths or activating a project integration is a separate reviewed action with current permissions, consumer checks and rollback.

The original live source and project entrypoints were not changed by preservation. Keep this archive immutable during migration. Record new source deltas separately. Do not put the archive in Level 0, active routes, skills directories or automatic sync paths.
