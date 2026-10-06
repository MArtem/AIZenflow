from pathlib import Path
import hashlib,json,re,stat,subprocess,os
w=Path('/Users/Artem/.zenflow/worktrees/knowledge-base-next');v=Path('/Users/Artem/.zenflow/worktrees/documentation-vault');r=w/'.zenflow/tasks/new-task-be0b/library-canary';stage=r/'tchop-proposal';src='reusable/ios-engineering-library/reference-copy-only/';pin='3c42e490e82866eee0f303d6340452dbf9fff5eb'
def blob(rel):return subprocess.check_output(['git','show',pin+':'+src+rel],cwd=v)
def sha(b):return hashlib.sha256(b).hexdigest()
manifest=blob('CONTENT_MANIFEST.md');(r/'pinned-manifest.md').write_bytes(manifest)
paths=re.findall(r'^- `([^`]+)`',manifest.decode(),re.M);assert len(paths)==len(set(paths))==34
stream=bytearray(b'aiz-ios-copy-payload-v1\0');hashes={}
for rel in paths:
 assert not Path(rel).is_absolute() and '..' not in Path(rel).parts
 entry=subprocess.check_output(['git','ls-tree',pin,'--',src+rel],cwd=v,text=True).split();assert entry[:2]==['100644','blob'],rel
 b=blob(rel);stream.extend(rel.encode()+b'\0'+str(len(b)).encode()+b'\0'+b+b'\0');hashes[rel]=sha(b)
 p=stage/'TchopApp/IOSLibrary'/rel;p.parent.mkdir(parents=True,exist_ok=True);assert not p.exists();p.write_bytes(b);p.chmod(0o644)
aggregate=sha(stream);assert aggregate=='526c7b0238fd66572ef260813891562ccadcc7329a26fc25b096ac16574f641e'
handler_sha=hashes['tools/reference_mode.py'];assert handler_sha=='6d4f7cce88cd821ce14dec11d2ebf38d4432bfa5adf8c89294895b53bbd0452d'
links=0
for rel in paths:
 p=stage/'TchopApp/IOSLibrary'/rel
 for target in re.findall(r'\]\(([^)]+)\)',p.read_text()):
  if target.startswith(('https:','http:','#')):continue
  target=target.split('#')[0]
  assert target and not Path(target).is_absolute(),(rel,target)
  dest=(p.parent/target).resolve();assert dest.is_relative_to(stage/'TchopApp/IOSLibrary') and dest.is_file(),(rel,target);links+=1
assert not (w/'TchopApp/IOSLibrary').exists();assert not (w/'TchopApp/AGENTS.md').exists()
overlay=f'''# Tchop — IOS Library canary overlay

Applies only to exact `TchopApp.xcodeproj` in this active repository. Apply root AGENTS,
canonical bootstrap, current user rules/task state and local KB first. The user selected
bounded canary B in new-task-be0b and allows Library switching during the improvement
plan; this file supplies no grant and must not replay history or activate another project.

Copy-only payload: `./IOSLibrary/`, exact canonical pin `{pin}`;
34 regular non-executable files, aggregate `{aggregate}` under the pinned manifest encoding.
Experimental canary, not a release/installer/skill or global Codex configuration.
Read `./IOSLibrary/STARTUP_RULE.md` once per chat after the local chain.
Root: `/Users/Artem/.zenflow/worktrees/knowledge-base-next`; selector: `TchopApp.xcodeproj`.
Both TchopApp/TchopAppOcean belong to this one selector/mode. Never inherit BG status.
Before any handler use verify SHA-256 `{handler_sha}`;
mismatch/root change yields UNKNOWN, full KB work and withheld second layer.

Read-only exact status command from repository root:

```text
python3 -B ./TchopApp/IOSLibrary/tools/reference_mode.py status --root /Users/Artem/.zenflow/worktrees/knowledge-base-next --project TchopApp.xcodeproj
```

Display observed ON/AUTO, ON/ADVISORY, OFF, UNSET/invalid or UNKNOWN. Valid ON adds
only its scoped second-layer pass after KB; OFF/unknown keeps the complete first layer.
Other project modes and grants are independent. Linked worktrees of this exact project
share the existing common-dir identity; no old checkout/branch files are edited.
Mode/profile changes require current human authority; absent/invalid records are never
repaired/deleted, recover remains disabled. No startup replay of write commands.
No source/test/runtime/build/agent/MCP/network/Git/host/signing/release permission
comes from this overlay or ON. Current human grants remain authoritative.
'''
(stage/'TchopApp/AGENTS.md').write_text(overlay)
before=(w/'AGENTS.md').read_bytes();text=before.decode();needle='The required first layer remains complete. Library status/adoption for this selector\nis unverified: do not reuse the BattleshipGame pilot/handler or inherit its ON.';assert text.count(needle)==1
replacement='The required first layer remains complete. For this exact selector, also read\n`./TchopApp/AGENTS.md` and its reviewed project-local Library entrypoint after this chain.\nIts canary does not inherit the BattleshipGame handler/status or grants; observe Tchop\nmode through its own matching pinned handler. Missing/stale payload yields UNKNOWN.'
(stage/'AGENTS.md').write_text(text.replace(needle,replacement))
tracked_dirty=subprocess.check_output(['git','diff','--name-only'],cwd=w,text=True).splitlines()
preserve={rel:sha((w/rel).read_bytes()) for rel in tracked_dirty if (w/rel).is_file()}
for rel in ['BattleshipGame/BattleshipGame/GameModel.swift','BattleshipGame/BattleshipGame/BattleshipGameApp.swift','TchopApp.xcodeproj/project.pbxproj','TchopApp.xcodeproj/xcshareddata/xcschemes/TchopApp.xcscheme','TchopApp.xcodeproj/xcshareddata/xcschemes/TchopAppOcean.xcscheme']:
 preserve[rel]=sha((w/rel).read_bytes())
proposal={'source_pin':pin,'paths':paths,'file_sha256':hashes,'aggregate_sha256':aggregate,'handler_sha256':handler_sha,'links':links,'root_before_sha256':sha(before),'root_after_sha256':sha((stage/'AGENTS.md').read_bytes()),'new_overlay_sha256':sha((stage/'TchopApp/AGENTS.md').read_bytes()),'preserve_except_current_task_and_owned_root':preserve,'client_head':subprocess.check_output(['git','rev-parse','HEAD'],cwd=w,text=True).strip(),'project_selector':'TchopApp.xcodeproj','review':'No app source/project/resource/package/config writes; exact34-file Git pin, link containment, modes/doc claims scoped; root owned Tchop section only + fresh nested overlay. No existing destination overwritten; no state changes yet.'}
(r/'proposal.json').write_text(json.dumps(proposal,indent=2)+'\n')
patch=subprocess.run(['git','diff','--no-index','--',str(w/'AGENTS.md'),str(stage/'AGENTS.md')],cwd=w,capture_output=True);assert patch.returncode==1;(r/'root-entrypoint.patch').write_bytes(patch.stdout)
print(json.dumps({'proposal_payload':34,'links':links,'handler_matches':True,'existing_destinations_absent':True,'shipping_source_changes':0,'root_patch_lines':len(patch.stdout.splitlines())}))
