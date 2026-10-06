from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
p=v/'apps/BattleshipGame/TASK_BG_T01.md';s=p.read_text().replace('Current task exception: [USER.VERIFICATION.SCOPE]','Global user rule: [USER.VERIFICATION.SCOPE]');p.write_text(s)
p=v/'apps/BattleshipGame/history/bg-t01-verification-2026-10-04.md';s=p.read_text().replace('launch per audit isolates framework state; each audit remains an actual system call.','launch per audit records its own attributable result; each audit remains an actual system call.').replace('This supplies independent hit-region/description/text-clipping/Dynamic-Type outcomes','This supplies separate hit-region/description/text-clipping/Dynamic-Type outcomes');p.write_text(s)
