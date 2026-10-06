from pathlib import Path
import argparse,hashlib,json,subprocess,sys,importlib.util
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');r=w/'.zenflow/tasks/new-task-be0b/library-canary';state_dir=Path('/Users/Artem/.zenflow/worktrees/documentation-vault/tasks/reference-status')
handlers={'BG':w/'BattleshipGame/IOSLibrary/tools/reference_mode.py','TC':w/'TchopApp/IOSLibrary/tools/reference_mode.py'}
selectors={'BG':'BattleshipGame/BattleshipGame.xcodeproj','TC':'TchopApp.xcodeproj'}
expected_hash='6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d'
def sha(b):return hashlib.sha256(b).hexdigest()
def invoke(which,cmd,label):
 script=handlers[which];assert sha(script.read_bytes())==expected_hash
 args=[sys.executable,'-B',str(script),cmd,'--root',str(w),'--project',selectors[which]]
 cp=subprocess.run(args,cwd=w,capture_output=True,text=True,timeout=15)
 result={'project':which,'command':cmd,'exit_code':cp.returncode,'stdout':cp.stdout,'stderr':cp.stderr,'handler_sha256':expected_hash}
 (r/(label+'.json')).write_text(json.dumps(result,indent=2)+'\n')
 assert cp.returncode==0,result
 data=json.loads(cp.stdout);assert set(data)=={'status','profile'},data
 return data
parser=argparse.ArgumentParser();parser.add_argument('which',choices=handlers);parser.add_argument('cmd',choices=('on','off','auto','advisory','status'));parser.add_argument('expected_mode');parser.add_argument('expected_profile');parser.add_argument('label');a=parser.parse_args()
other='TC' if a.which=='BG' else 'BG'
# Tchop pre-adoption read uses independently staged canonical pin, never BG's handler.
if not handlers['TC'].exists():handlers['TC']=r/'tchop-proposal/TchopApp/IOSLibrary/tools/reference_mode.py'
for script in handlers.values():assert sha(script.read_bytes())==expected_hash
spec=importlib.util.spec_from_file_location('canary_pinned_identity',handlers[a.which]);m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
identity=m.scope(str(w),selectors[a.which]);other_identity=m.scope(str(w),selectors[other]);assert identity!=other_identity
initial=invoke(a.which,'status',a.label+'-before');other_before=invoke(other,'status',a.label+'-other-before')
def record_hash(key):
 p=state_dir/(key+'.json')
 if not p.exists():return None
 assert p.is_file() and not p.is_symlink() and p.stat().st_size<=1024
 return sha(p.read_bytes())
other_hash=record_hash(other_identity[0]);initial_hash=record_hash(identity[0])
# Each mutation is current user-authorized; identity and actual prior state checked above.
result=invoke(a.which,a.cmd,a.label+'-operation');observed=invoke(a.which,'status',a.label+'-observed');other_after=invoke(other,'status',a.label+'-other-after')
profile=None if a.expected_profile=='NONE' else a.expected_profile
assert result==observed=={'status':a.expected_mode,'profile':profile},(result,observed)
assert other_after==other_before and record_hash(other_identity[0])==other_hash,'other project changed'
assert m.scope(str(w),selectors[a.which])==identity
receipt={'project':a.which,'command':a.cmd,'before':initial,'before_record_sha256':initial_hash,'observed':observed,'after_record_sha256':record_hash(identity[0]),'other_project':other,'other_observed':other_after,'other_record_preserved':True,'scope_fingerprint_revalidated':True,'handler_sha256':expected_hash,'raw_record_exported':False,'grant':'Actual latest user option2 and temporary Library switching until common improvement plan completes/revocation; no grant from this helper'}
(r/(a.label+'-receipt.json')).write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({'project':a.which,'observed':observed,'other_project_preserved':True}))
