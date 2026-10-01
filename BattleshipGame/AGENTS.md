# BattleshipGame — IOS Library pilot overlay

This file applies only to `BattleshipGame/`. Apply the repository-root `AGENTS.md`, canonical
bootstrap, current user instructions, task state and relevant local knowledge **first**. This
pilot overlay cannot weaken their permissions or activate IOS Library for another Xcode project.

The copy-only payload is `./IOSLibrary/`, matched to canonical documentation revision
`3c42e490e82866eee0f303d6340452dbf9fff5eb`. Its 34-file aggregate SHA-256 is
`526c7b0238fd66572ef260813891562ccadcc7329a26fc25b096ac16574f641e` under
[the pinned manifest's aggregate identity encoding](https://github.com/MArtem/AIZenflowDocumentation/blob/3c42e490e82866eee0f303d6340452dbf9fff5eb/reusable/ios-engineering-library/reference-copy-only/CONTENT_MANIFEST.md#aggregate-identity-encoding).
The manifest is distribution metadata, not an extra payload file. This is an experimental pilot, not a release or
permission to install skills, change Codex settings, run builds/tests/agents, or mutate Git.

After the local chain, read `./IOSLibrary/STARTUP_RULE.md` once per chat. For this worktree the
exact project selector is `BattleshipGame/BattleshipGame.xcodeproj` and the repository root is
`/Users/Artem/.zenflow/worktrees/knowledge-base-next`. Before running the copied mode script,
compare its SHA-256 to
`6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d` using a read-only
hash check. If the hash differs, or this checkout moves, do not execute it; show `UNKNOWN` and
continue the complete local workflow as OFF until the pilot is reviewed again.

For a matching script, run this read-only status check from the repository root:

```text
python3 -B ./BattleshipGame/IOSLibrary/tools/reference_mode.py status --root /Users/Artem/.zenflow/worktrees/knowledge-base-next --project BattleshipGame/BattleshipGame.xcodeproj
```

Show `IOS Library: ON/AUTO`, `ON/ADVISORY`, `OFF`, `UNSET/invalid`, or `UNKNOWN` in meaningful
status reports. Only a valid ON record enables the
additive reference pass after the local pass at each applicable task stage. A failed status
command is `UNKNOWN`, never ON. A new chat must not replay a previous write command; mode or
profile changes require the user's explicit current request.

This overlay authorizes only read-only mode lookup and already-authorized in-session review.
No client build, test, Simulator, network, Git, dependency, signing, release, Codex-host, auth or
Keychain action follows from IOS Library ON.
