# Installation

Copy both items into the root of the target Git repository:

```text
AGENTS.md
ios-quality/
```

Then:

```bash
chmod +x ios-quality/scripts/*.sh ios-quality/scripts/lib/*.sh
./ios-quality/scripts/discover_project.sh
cp ios-quality/config/project.env.example ios-quality/config/project.env
cp ios-quality/config/PROJECT_PROFILE.example.yaml ios-quality/config/PROJECT_PROFILE.yaml
```

Fill and human-review both project configuration files before treating them as authoritative.

Start Codex from the repository/worktree where root `AGENTS.md` is in scope.
