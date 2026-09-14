# Nested Repository and Submodule Policy

A nested Git repository or submodule is an independent protected boundary.

- Root project adaptation does not scan nested repository source as if it belonged to the parent project.
- Capture nested repository HEAD/status/refs/config fingerprints at baseline.
- Do not change submodule HEAD, nested worktree content, nested Git config or nested refs as a side effect of parent-project work.
- Explicitly authorize the exact nested path before intentional changes.
- Never recursively clean/reset nested repositories to make the parent appear stable.
