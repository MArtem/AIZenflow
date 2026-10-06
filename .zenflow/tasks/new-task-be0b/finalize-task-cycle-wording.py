from pathlib import Path
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
p=v/'reusable/baseline/docs/IOS_PROJECT_WORK_SYSTEM.md'
s=p.read_text().replace('Section 4A before its implementation; scale its detail to the actual risk and scope. It adds no Level 0 requirement and does not activate a project or library.','Section 4A before its implementation; scale its detail to the actual risk and scope.\nIt adds no Level 0 requirement and does not activate a project or library.')
p.write_text(s)
p=v/'tasks/new-task-be0b/ios-project-work-system-plan.md'
s=p.read_text().replace('Tchop structural second-canary intake/three-file proposal prepared locally, apply pending;\nno S11 completion or inherited ON.','Tchop structural second-canary intake/three-file proposal prepared locally; current user\ndelegated pilot use/owned registration, apply strategically deferred. No S11 completion or inherited ON.')
s=s.replace('зависимостям → план проверок для user choice → review плана до изменений → ограниченные blocks с проверками →','зависимостям → план проверок для user choice → review плана до изменений →\nограниченные blocks с проверками →')
p.write_text(s)
