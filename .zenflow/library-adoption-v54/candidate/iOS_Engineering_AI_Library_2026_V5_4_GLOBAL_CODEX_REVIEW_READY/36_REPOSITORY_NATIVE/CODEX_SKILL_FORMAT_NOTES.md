# Codex Skill Format Notes

V3 skills use a required `SKILL.md` with YAML `name` and `description`; the body is loaded after the skill triggers. `agents/openai.yaml` carries user-facing display metadata/default prompt. References are kept in `references/` and should be loaded only when needed. The repository kit intentionally uses narrow skills rather than one giant iOS skill so context stays bounded and routing remains predictable.
