from pathlib import Path
import os, json, hashlib, subprocess, datetime
cwd=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next')
root=cwd/'.zenflow/tasks/new-task-be0b/bg-t01-build-retry'
assert not root.exists(), 'Repeat grant may only be consumed once'
source=cwd/'BattleshipGame/BattleshipGame/ContentView.swift'
assert hashlib.sha256(source.read_bytes()).hexdigest()=='d9134483db19a9d1e7e8edcca42f06120f66bb410c2cea124b86700146b010c1'
previous=json.loads((cwd/'.zenflow/tasks/new-task-be0b/bg-t01-build/invocation.json').read_text())
old=str(cwd/'.zenflow/tasks/new-task-be0b/bg-t01-build')
args=[arg.replace(old,str(root)) for arg in previous['args']]
isolated={key:value.replace(old,str(root)) for key,value in previous['isolated_environment'].items()}
for suffix in ['tmp','cocoa-home','cache','derived-data','source-packages','cache/swiftpm','cache/module-cache','cache/sdk-stat']:
    (root/suffix).mkdir(parents=True,exist_ok=True)
env=os.environ.copy()
env.update(isolated)
receipt={**previous,'grant':'Explicit user A: one repeat build with execution escalation; no signing/tests/Simulator launch; 2026-10-03','args':args,'isolated_environment':isolated,'started_utc':datetime.datetime.now(datetime.timezone.utc).isoformat()}
inputs=['BattleshipGame/BattleshipGame/ContentView.swift','BattleshipGame/BattleshipGame/GameModel.swift','BattleshipGame/BattleshipGame/BattleshipGameApp.swift','BattleshipGame/BattleshipGame.xcodeproj/project.pbxproj','BattleshipGame/BattleshipGame.xcodeproj/xcshareddata/xcschemes/BattleshipGame.xcscheme']
receipt['input_sha256']={name:hashlib.sha256((cwd/name).read_bytes()).hexdigest() for name in inputs}
(root/'invocation.json').write_text(json.dumps(receipt,ensure_ascii=False,indent=2)+'\n')
with (root/'build.log').open('w') as log:
    result=subprocess.run(args,cwd=cwd,env=env,stdout=log,stderr=subprocess.STDOUT)
(root/'exit-status.txt').write_text(str(result.returncode)+'\n')
assert all(hashlib.sha256((cwd/name).read_bytes()).hexdigest()==digest for name,digest in receipt['input_sha256'].items()), 'Build inputs changed'
print('Build exit:',result.returncode)
print('Log:',root/'build.log')
