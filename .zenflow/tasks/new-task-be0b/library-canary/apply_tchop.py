from pathlib import Path
import hashlib,json,os,shutil,stat,subprocess
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');r=w/'.zenflow/tasks/new-task-be0b/library-canary';stage=r/'tchop-proposal';p=json.loads((r/'proposal.json').read_text())
def sha(b):return hashlib.sha256(b).hexdigest()
assert json.loads((r/'card.json').read_text())['Tchop_ending_choice'].startswith('Actual human reply: leave ON/AUTO')
bg_start=json.loads((r/'bg-off-auto-receipt.json').read_text());bg_end=json.loads((r/'bg-restore-on-auto-receipt.json').read_text());assert bg_start['before_record_sha256']==bg_end['after_record_sha256']
assert sha((w/'AGENTS.md').read_bytes())==p['root_before_sha256']
for rel,h in p['preserve_except_current_task_and_owned_root'].items():assert sha((w/rel).read_bytes())==h,rel
for rel,h in p['file_sha256'].items():assert sha((stage/'TchopApp/IOSLibrary'/rel).read_bytes())==h,rel
assert sha((stage/'AGENTS.md').read_bytes())==p['root_after_sha256']
assert sha((stage/'TchopApp/AGENTS.md').read_bytes())==p['new_overlay_sha256']
pbx=(w/'TchopApp.xcodeproj/project.pbxproj').read_text();assert 'PBXFileSystemSynchronized' not in pbx and 'IOSLibrary' not in pbx and 'AGENTS.md' not in pbx
assert not (w/'TchopApp/AGENTS.md').exists() and not (w/'TchopApp/IOSLibrary').exists()
(r/'root-before-AGENTS.md').write_bytes((w/'AGENTS.md').read_bytes())
copy=r/'tchop-copy-apply';assert not copy.exists();shutil.copytree(stage/'TchopApp/IOSLibrary',copy)
for f in copy.rglob('*'):
 assert not f.is_symlink()
 if f.is_file():assert stat.S_IMODE(f.stat().st_mode)==0o644
os.rename(copy,w/'TchopApp/IOSLibrary')
with (w/'TchopApp/AGENTS.md').open('xb') as f:f.write((stage/'TchopApp/AGENTS.md').read_bytes())
temp=w/'AGENTS.md.w4-library-owned';assert not temp.exists();temp.write_bytes((stage/'AGENTS.md').read_bytes());os.replace(temp,w/'AGENTS.md')
for rel,h in p['file_sha256'].items():assert sha((w/'TchopApp/IOSLibrary'/rel).read_bytes())==h,rel
for rel,h in p['preserve_except_current_task_and_owned_root'].items():
 if rel!='AGENTS.md':assert sha((w/rel).read_bytes())==h,rel
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=w,text=True).strip()==p['client_head']
receipt={'applied':'exact34 payload files + new TchopApp/AGENTS.md + owned root Tchop entrypoint edit','source_pin':p['source_pin'],'aggregate_sha256':p['aggregate_sha256'],'handler_sha256':p['handler_sha256'],'payload_file_sha256':p['file_sha256'],'root_before_sha256':p['root_before_sha256'],'root_after_sha256':p['root_after_sha256'],'new_overlay_sha256':p['new_overlay_sha256'],'links':p['links'],'non_executable_regular':True,'project_unchanged':True,'not_in_declared_source_resource_phases':True,'shipping_source_and_foreign_edits_preserved':True,'client_git_unchanged':True,'BG_initial_mode_and_record_hash_restored':True,'Tchop_mode_not_yet_changed':True,'human_choice':'CanaryB approved; Tchop aftercanary ON/AUTO selected explicitly','limits':'Experimental approved exact selector/payload only; no global release/installation, no runtime/recovery/otherrepo grants; fresh-chat entrypoint behavior not yet observed'}
(r/'adoption-receipt.json').write_text(json.dumps(receipt,indent=2)+'\n');print(json.dumps({'payload_files':34,'own_entrypoints':2,'shipping_changes':0,'BG_restored_exact':True,'foreign_preserved':True}))
