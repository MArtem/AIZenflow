# Handoff — V5.4 retired; copy-only reference inactive

Task `new-task-be0b`; operating mode `эконом`. Read the canonical bootstrap,
Level 0 router, this handoff and current `plan.md` before further work.

## Goal and boundaries

V5.4 installation is retired. Preserve useful iOS engineering knowledge, audits,
recommendations, agent workflows and all former `ioslib-*` skills in a future
uniquely named **copy-only** reference library. Local project rules run first.
`OFF` retains the full local quality workflow; `ON/AUTO` adds reference checks at
applicable stages; `ON/ADVISORY` offers recommendations. The candidate is **not
active or ready for project use**. No mode grants build/test/agent/Git/network or
Codex-host authority. Do not touch auth/Keychain or reset unrelated user data.

## Published state and checks

- Documentation-vault `main` commit `8cf5803` removed the bootstrap auto-route
  to V5.4. Commit `3e2c7c5` removed all 1,367 tracked V5.4 files and five
  obsolete installer documents from the **current tree**, preserving old Git
  history. Both commits were pushed; remote `main` was verified. The vault has
  no remote `development` branch. Its worktree was clean after publication.
- The preserved material is in inactive
  `reusable/ios-engineering-library/reference-copy-only/`: 1,386 tracked
  files, including source skills, thematic and runtime/protection documents,
  and four source-only audit scripts. Old installer advice in raw copies is
  not approved for active routing. Manifest, documentation-vault, link and
  final-diff static checks passed; these do **not** prove candidate readiness.
- AIZenflow `main` and `development` were atomically updated to `9f626dbd3`
  with only the separate `v54-retirement-published-status.md` task record.
  The old task branch was not merged because it contains installation history.
  Existing active plans on the two branches were not overwritten.
- The exact installed global AGENTS entry was backed up and removed. The
  ignored eight-file runtime subtree was moved to recovery under `.zenflow`;
  its former active path is absent. `config.toml` had no explicit V5.4 marker
  and was not changed; auth/Keychain were not inspected or changed.
- After a **full Codex restart and the runtime move**, the user's new-chat
  read-only check confirmed project and common baseline instructions load,
  while the checked active chain does not route to V5.4. The old current-tree
  and runtime paths were absent; the recovery copy remained. This is not
  proof that every possible external consumer or host setting is absent.

## Next safe work

The former local rules/prompts/skills are the **база знаний** (first layer);
the inactive copy-only reference candidate is the **библиотека** (second
layer). Follow `knowledge-base-library-roadmap.md`: audit and correct the
first layer, then curate the second and prove their joint stage-by-stage
operation as layered defense. `knowledge-base-audit-ledger.md` has the first
candidate finding about competing router copies. GPT-6 Luna/Sol/Astra routing
was published in canonical `main` (`e14f398`) and AIZenflow `main`/
`development` (`48e6bdeea`). Do not install or activate the library yet.
Preserve unrelated dirty work and do not merge the old task branch wholesale.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
