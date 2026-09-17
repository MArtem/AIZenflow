# Linked-worktree upgrade receipt

Date: 2026-09-11. Executor: GPT-5.6 Luna xhigh.

- Fixture root: `library-adoption-v54/fixtures/linked-upgrade-macos/`.
- The fixture used `git worktree add`, not a second unrelated repository.
- Main and linked worktree identities shared the same Git common directory.
- V5.2 created and closed valid schema-2 sessions in both worktrees.
- V5.4 admitted and closed a new linked-worktree writer; both old JSON files remained byte-for-byte preserved.
- An active V5.2 session in main blocked V5.4 admission from the linked worktree with exit 4 and an explicit recovery error.
- V5.2 cleanup succeeded.

This closes the previously untested linked-worktree topology at the synthetic macOS runtime level.
It does not claim parallel linked writers; the deliberate contract is one writer per common directory.
