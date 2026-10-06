from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
p=v/'reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md';s=p.read_text()
a='limits. Then independently resolve execution authority for test writing/modification,\nbuilds, test runs, Simulator/device access and the operator.'
b='limits. An explicit user choice to perform a precisely scoped action is its grant;\ndo not request that same permission again. Verify the independent scope for test\nwriting/modification, builds, test runs, Simulator/device access and the operator;\nclarify only missing bounds or authority.'
assert a in s;s=s.replace(a,b,1);p.write_text(s)
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md';s=p.read_text();s=s.replace('applicability и выбранные действия записаны, permission/execution не подразумеваются','applicability, выбор и grant записаны; proposal не разрешает действия, execution подтверждается evidence',1);p.write_text(s)
