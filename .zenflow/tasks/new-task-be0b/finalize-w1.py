from pathlib import Path
import json,hashlib,re,subprocess
v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault')
a=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next/.zenflow/tasks/new-task-be0b')
d=v/'tasks/new-task-be0b'
i=json.loads((d/'archive/main-plan-B-before/IDENTITIES.json').read_text())
for k,x in i['snapshots'].items():
 assert hashlib.sha256((v/x['archive']).read_bytes()).hexdigest()==x['sha256'], k
 if k.startswith('canonical-'):
  rel=str(Path(x['source']).relative_to(v))
  original=subprocess.check_output(['git','show',i['trusted_base']+':'+rel],cwd=v)
  assert original==(v/x['archive']).read_bytes(),k
 else:
  assert (a/'archive/main-plan-B-before'/Path(x['archive']).name).read_bytes()==(v/x['archive']).read_bytes(),k
m=d/'ios-project-work-system-plan.md'
s=m.read_text().replace('Принят пользователем 2026-10-03 вместе','Закреплён 2026-10-04 по решению пользователя вместе')
leaves=re.findall(r'\| \[ \] (W\d\.\d+\.[a-z]) \|',s)
assert len(leaves)==len(set(leaves))==62
for n in range(1,22): assert f'R{n:02}' in s
for leaf in leaves:
 if leaf.startswith('W1.') and leaf!='W1.5.b': s=s.replace('[ ] '+leaf,'[x] '+leaf)
s=s.replace('### W2. Общие механизмы', 'W1 static evidence: exact five archives/identities, R01–R21 coverage, 62 unique leaves,\ncurrent BG inputs, links/route/vault/manifests/boundaries/consistency and whitespace PASS.\nComplete candidate self-reviewed; no confirmed P0–P2/P3 in this documentary scope.\nObserved canaries remain open; W1.5.b closes only after observed remote SHA.\n\n### W2. Общие механизмы')
m.write_text(s)
for base in (a,d):
 p=base/'plan.md'; t=p.read_text().replace('Next: finish W1 static gates/publication, then bounded W2 docs block.','W1 outputs and static gates complete; publication pending. Next: publish W1 → bounded W2 docs block.');p.write_text(t)
 p=base/'handoff.md';t=p.read_text().replace('Current W1 contract/matrix/history/current-state work; W2 common mechanisms next,','W1 contract/matrix/history/current-state and static gates complete, publication pending; W2 next,');p.write_text(t)
print('PASS: snapshots, original bytes, 62 leaves and current task state')
