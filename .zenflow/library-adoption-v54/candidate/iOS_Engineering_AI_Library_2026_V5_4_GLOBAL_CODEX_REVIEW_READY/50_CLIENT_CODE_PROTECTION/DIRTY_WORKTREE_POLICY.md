# Dirty Worktree Policy

Pre-existing local changes are user-owned state.

- Capture content hashes for every tracked or untracked dirty path at protection-baseline time.
- A normal task write scope never authorizes modifying a path that was already dirty.
- Exact `--allow-dirty` authorization is required for such a file.
- Reverting, deleting, renaming, staging or replacing a pre-existing dirty file counts as mutation.
- Never use blanket stashing/resetting to get a clean baseline.
- If the requested task overlaps a dirty file, explain the overlap before touching it unless the user's request already explicitly targets that dirty work.
