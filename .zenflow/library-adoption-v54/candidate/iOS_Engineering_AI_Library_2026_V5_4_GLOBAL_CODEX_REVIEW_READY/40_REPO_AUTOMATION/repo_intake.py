#!/usr/bin/env python3
"""Read-only iOS repository intake. Emits JSON; never edits project files."""
from pathlib import Path
import json, re, subprocess, sys
root=Path(sys.argv[1] if len(sys.argv)>1 else '.').resolve()
def rels(pattern): return sorted(str(p.relative_to(root)) for p in root.rglob(pattern) if '.git' not in p.parts and '.build' not in p.parts and 'DerivedData' not in p.parts)
def run(args):
    try: return subprocess.run(args,cwd=root,text=True,capture_output=True,timeout=8).stdout.strip()
    except Exception: return ''
projects=rels('*.xcodeproj'); workspaces=rels('*.xcworkspace'); packages=rels('Package.swift')
schemes=rels('*.xcscheme')
swift_files=rels('*.swift')
ci=[p for p in rels('*') if p.startswith('.github/workflows/') or p.startswith('.circleci/') or p in ('Jenkinsfile','.gitlab-ci.yml')]
pbx=[]
for proj in projects:
    pp=root/proj/'project.pbxproj'
    if pp.exists(): pbx.append(pp.read_text(errors='ignore'))
blob='\n'.join(pbx)
def vals(key): return sorted(set(re.findall(rf'\b{re.escape(key)}\s*=\s*([^;]+);',blob)))[:50]
patterns={'task_detached':r'\bTask\.detached\b','unchecked_sendable':r'@unchecked\s+Sendable','force_try':r'\btry!\b','force_cast':r'\bas!\s','observable':r'@Observable\b','swiftdata':r'\bModelContainer\b|@Model\b','coredata':r'\bNSPersistentContainer\b','urlsession':r'\bURLSession\b'}
counts={k:0 for k in patterns}
for fp in swift_files[:10000]:
    try: t=(root/fp).read_text(errors='ignore')
    except: continue
    for k,pat in patterns.items(): counts[k]+=len(re.findall(pat,t))
out={
 'root':str(root),'git_branch':run(['git','branch','--show-current']),'projects':projects,'workspaces':workspaces,'packages':packages,
 'shared_schemes':schemes,'swift_file_count':len(swift_files),'ci_files':ci,'swift_version_settings':vals('SWIFT_VERSION'),
 'ios_deployment_targets':vals('IPHONEOS_DEPLOYMENT_TARGET'),'product_bundle_ids':vals('PRODUCT_BUNDLE_IDENTIFIER'),
 'heuristic_counts':counts,'notes':['Counts are heuristics, not findings.','Resolve actual scheme/config/destination from CI or shared project settings before build claims.']}
print(json.dumps(out,ensure_ascii=False,indent=2))
