# Client Repository Threat Model

Primary accidental-risk classes addressed by the hardened global library:

- agent edits outside intended task scope;
- overwriting pre-existing uncommitted user work;
- hidden Git control-plane mutation that leaves a clean worktree;
- dependency/lockfile drift;
- Xcode build-phase side effects;
- nested-repository/submodule mutation;
- symlink/path escape during scanning or cache writes;
- release/signing/upload commands invoked as verification;
- secrets or source content copied into global state;
- destructive cleanup used to mask mistakes;
- multi-agent write collisions.

The model reduces accidental damage but does not replace OS sandboxing, backups, branch protection, least-privilege credentials, secure secret storage, code review or remote repository protections.
