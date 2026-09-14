# Git Control-Plane Protection

Normal coding authorization does not imply authorization to mutate Git control state.

Protected by default:
- `HEAD` and current symbolic branch;
- refs/tags/remote-tracking refs;
- index/staging state;
- local `.git/config` and remotes;
- stash, commit, merge, rebase, cherry-pick, revert operations;
- force push and destructive reset/clean/restore operations.

Never run `git reset --hard`, `git clean`, destructive `git checkout/restore`, or equivalent commands to recover from an agent mistake. Preserve evidence and ask for direction.

Commit/push/fetch/pull/rebase/merge are separate user actions. Complete code protection verification before any explicitly requested commit.
