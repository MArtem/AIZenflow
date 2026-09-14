# Client Code Protection Policy

Client repository preservation is the highest operational invariant of the global iOS library.

## Default posture
- Repository intake/adaptation is read-only and must prove that it did not mutate the client working tree or Git control plane.
- Before any product-code write, create an external protection baseline with the intended write scope.
- Pre-existing dirty files belong to the user and are immutable unless the user explicitly authorizes that exact dirty path.
- Git history, refs, index, branch, local Git config, remotes and nested repositories/submodules are protected separately from source-code edits.
- Generated library state must remain outside the client repository.
- Do not use destructive recovery commands to make verification pass.

## Required workflow for write tasks
1. Inspect `git status` and applicable repository instructions.
2. Decide the smallest exact file/directory write scope before editing.
3. Run `ios_ai.py protect begin --repo . --allow <path> ... --task "..."`.
4. If a path was dirty before the task, do not include it in normal `--allow`; require explicit user authorization and use `--allow-dirty <exact-path>`.
5. If an Xcode/project/dependency/CI/signing path must change, require explicit user authorization and add the exact path with `--allow-protected` as well as normal `--allow`.
6. Perform the smallest coherent patch.
7. Run `ios_ai.py protect verify --repo .` before claiming completion.
8. Review `git diff`, `git diff --check`, and relevant build/tests according to risk.

Protection verification failure is a stop condition. Never hide or auto-revert unexpected changes.
