#!/usr/bin/env python3
from pathlib import Path
import re,sys
root=Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve()
errors=[]
skills=list((root/'.agents/skills').glob('*/SKILL.md')) if (root/'.agents/skills').exists() else []
seen=set()
for p in skills:
    t=p.read_text(errors='ignore')
    m=re.match(r'^---\n(.*?)\n---\n',t,re.S)
    if not m: errors.append(f'{p}: missing YAML frontmatter'); continue
    name=re.search(r'^name:\s*(.+)$',m.group(1),re.M); desc=re.search(r'^description:\s*(.+)$',m.group(1),re.M)
    if not name or not desc: errors.append(f'{p}: requires name and description'); continue
    n=name.group(1).strip()
    if n in seen: errors.append(f'duplicate skill name: {n}')
    seen.add(n)
    oy=p.parent/'agents/openai.yaml'
    if not oy.exists(): errors.append(f'{p.parent}: missing agents/openai.yaml')
print(f'skills={len(skills)} unique={len(seen)} errors={len(errors)}')
for e in errors: print('ERROR',e)
sys.exit(1 if errors else 0)
