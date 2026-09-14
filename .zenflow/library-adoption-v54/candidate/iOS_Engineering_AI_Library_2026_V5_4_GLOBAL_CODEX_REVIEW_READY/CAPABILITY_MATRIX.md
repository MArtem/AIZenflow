# Capability matrix — review candidate

| Capability | Reference mode | Full mode | Evidence boundary |
| --- | --- | --- | --- |
| Read-only knowledge routing | yes | yes | router and selected-document report |
| Risk/plan classifier | yes | yes | `ios_ai.py plan`; advisory only |
| Protection sessions and before/after detection | yes | yes | external state; no kernel sandbox or backup |
| Command guard | yes | yes | classifier; it does not execute or intercept commands |
| Bounded project adaptation | yes | yes | metadata only; partial is never fresh |
| Namespaced Codex skills | no | explicit opt-in | matching dry-run/preflight and target hashes |
| Exact external duplicate profile | explicit opt-in | explicit opt-in | source identity revalidated before exclusions |
| Automatic subagent fan-out | no | no | availability/permission must be reported honestly |
| Installer ownership and rollback | installer only | installer only | manual path uses read-only preflight and operator backup |

No row in this table grants build, test, network, Git, signing, release, or client-repository
write permission. “Yes” means the shipped capability is available, not that it was used for a
particular task.
