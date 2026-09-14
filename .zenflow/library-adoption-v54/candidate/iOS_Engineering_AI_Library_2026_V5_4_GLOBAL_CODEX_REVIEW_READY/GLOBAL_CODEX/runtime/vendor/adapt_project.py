#!/usr/bin/env python3
from __future__ import annotations
from pathlib import Path
import hashlib, json, os, re, shlex, stat, time

ADAPTER_VERSION='5.4-review-ready.6'
SCHEMA_VERSION=3
DEFAULT_EXCLUDES={'.git','.build','DerivedData','Pods','Carthage','node_modules','.swiftpm','.idea','.vscode'}
TEXT_EXT={'.swift','.m','.mm','.h','.hpp','.plist','.xcconfig','.entitlements','.pbxproj','.xcscheme','.xctestplan','.xcworkspacedata','.xcsettings','.strings','.stringsdict','.xml','.json','.yaml','.yml','.md','.txt','.sh','.rb','.py','.toml'}
IMPORTANT_NAMES={'Package.swift','Package.resolved','Podfile','Podfile.lock','Cartfile','Cartfile.resolved','Mintfile','Mintfile.lock','README.md','CONTRIBUTING.md','AGENTS.md','AGENTS.override.md','project.pbxproj','PrivacyInfo.xcprivacy','Info.plist','Jenkinsfile','.gitlab-ci.yml'}
COMMAND_SOURCE_NAMES={'README.md','CONTRIBUTING.md','Jenkinsfile','.gitlab-ci.yml','Package.swift'}
SECRET_HINT=re.compile(r'(?i)(token|secret|password|passwd|api[_-]?key|authorization|bearer|credential|private[_-]?key)')
COMMAND_HINT=re.compile(r'(?i)\b(xcodebuild|swift\s+(?:build|test|package)|git\s+|pod\s+|bundle\s+|fastlane\b|curl\b|make\b|scripts?/[A-Za-z0-9_./-]+)')
ENV_ASSIGN=re.compile(r'^[A-Za-z_][A-Za-z0-9_]*=')
KNOWN_EXECUTABLES={'xcodebuild','swift','git','pod','bundle','fastlane','curl','make'}

class AdaptationError(RuntimeError): pass

class Budget:
    def __init__(self,options):
        self.max_visited=int(options.get('max_files_visited',50000))
        self.max_inspected=int(options.get('max_files',20000))
        self.max_bytes=int(options.get('max_bytes',32*1024*1024))
        self.max_file=int(options.get('max_file_bytes',2*1024*1024))
        self.max_depth=int(options.get('max_depth',40))
        self.deadline=float(options.get('deadline_seconds',30))
        self.start=time.monotonic(); self.visited=0; self.inspected=0; self.bytes=0
    def check_time(self):
        if time.monotonic()-self.start > self.deadline: raise AdaptationError('deadline')
    def visit(self,n=1):
        self.check_time(); self.visited += n
        if self.visited > self.max_visited: raise AdaptationError('max_files_visited')
    def inspect(self,size):
        self.check_time(); self.inspected += 1
        if self.inspected > self.max_inspected: raise AdaptationError('max_files_inspected')
        if size > self.max_file: raise AdaptationError('too_large')
        if self.bytes + size > self.max_bytes: raise AdaptationError('max_bytes')
        self.bytes += size
    def summary(self):
        return {'files_visited':self.visited,'files_inspected':self.inspected,'bytes_read':self.bytes,
                'limits':{'max_files_visited':self.max_visited,'max_files_inspected':self.max_inspected,'max_total_bytes':self.max_bytes,'max_file_bytes':self.max_file,'max_depth':self.max_depth,'deadline_seconds':self.deadline}}

def sha(data:bytes): return hashlib.sha256(data).hexdigest()
def rel(root,p): return p.relative_to(root).as_posix()

def is_relevant(path:Path):
    if path.name in IMPORTANT_NAMES: return True
    r=path.as_posix()
    if any(x in r for x in ('/.github/','/scripts/','/Scripts/','/fastlane/')): return True
    return path.suffix.lower() in TEXT_EXT

def command_metadata(root:Path,path:Path,data:bytes):
    r=rel(root,path)
    if path.name not in COMMAND_SOURCE_NAMES and not r.startswith(('scripts/','Scripts/','.github/','fastlane/')): return []
    try: text=data.decode('utf-8')
    except UnicodeDecodeError: return []
    out=[]
    for i,line in enumerate(text.splitlines(),1):
        if not COMMAND_HINT.search(line): continue
        stripped=line.strip(); exe=None
        try:
            # Parsing is for minimal metadata only. The raw command is never persisted.
            toks=shlex.split(stripped,posix=True)
            # Leading environment assignments may contain credentials. Never persist the
            # assignment token as an executable name; skip it and retain only the actual
            # executable basename as bounded metadata.
            idx=0
            while idx < len(toks) and ENV_ASSIGN.match(toks[idx]):
                idx += 1
            if idx < len(toks):
                raw_exe=Path(toks[idx]).name
                if raw_exe in KNOWN_EXECUTABLES:
                    exe=raw_exe
                elif '/' in toks[idx] and ('scripts/' in toks[idx].lower() or 'fastlane/' in toks[idx].lower()):
                    exe='repository_script'
                else:
                    exe='unknown'
        except ValueError: pass
        secret_hint=bool(SECRET_HINT.search(stripped))
        # Evidence hash intentionally covers only minimized metadata, not the raw line.
        # The containing producer file's SHA-256 already participates in freshness.
        evidence=sha(json.dumps([r,i,exe,secret_hint],separators=(',',':')).encode())
        out.append({'source':r,'line':i,'sha256':evidence,'executable':exe,
                    'secret_hint_present':secret_hint,'authority':'data_only'})
    return out

def classify(path:Path):
    n=path.name; r=path.as_posix(); ext=path.suffix.lower()
    if ext=='.swift': return 'swift_source'
    if ext in {'.m','.mm','.h','.hpp'}: return 'objc_source'
    if n=='project.pbxproj' or ext in {'.xcscheme','.xctestplan'}: return 'xcode_project'
    if n in {'Package.swift','Package.resolved','Podfile','Podfile.lock','Cartfile','Cartfile.resolved','Mintfile','Mintfile.lock'}: return 'dependency'
    if '.github/' in r or n in {'Jenkinsfile','.gitlab-ci.yml'}: return 'ci'
    if n in {'README.md','CONTRIBUTING.md','AGENTS.md','AGENTS.override.md'}: return 'instructions_or_docs'
    if 'scripts/' in r.lower() or 'fastlane/' in r.lower(): return 'automation'
    if ext in {'.entitlements','.xcconfig','.plist','.xcprivacy'}: return 'configuration'
    return 'other'

def scan_inputs(root:Path,budget:Budget):
    manifest=[]; counts={}; commands=[]; limitations=[]; stop=False
    walk_errors=[]
    def _walk_error(_error):
        walk_errors.append({'kind':'walk_error','path':'<directory>'})
    for base,dirs,files in os.walk(root,topdown=True,followlinks=False,onerror=_walk_error):
        bp=Path(base)
        try: budget.check_time()
        except AdaptationError as e: limitations.append({'kind':str(e),'path':rel(root,bp) if bp!=root else '.'}); break
        depth=len(bp.relative_to(root).parts)
        # A nested Git worktree/repository is an independent trust/protection boundary.
        # Do not silently fold its source/configuration into the parent context model.
        if bp != root and os.path.lexists(bp/'.git'):
            limitations.append({'kind':'nested_repository_boundary_skipped','path':rel(root,bp)})
            dirs[:] = []
            continue
        if depth>=budget.max_depth and dirs:
            limitations.append({'kind':'max_depth','path':rel(root,bp) if bp!=root else '.'}); dirs[:]=[]
        kept=[]
        for d in sorted(dirs):
            p=bp/d
            try: budget.visit()
            except AdaptationError as e: limitations.append({'kind':str(e),'path':rel(root,p)}); stop=True; break
            if d in DEFAULT_EXCLUDES: continue
            try:
                st=os.lstat(p)
                if stat.S_ISLNK(st.st_mode): limitations.append({'kind':'symlink_directory_skipped','path':rel(root,p)}); continue
                if not stat.S_ISDIR(st.st_mode): limitations.append({'kind':'non_directory_entry_skipped','path':rel(root,p)}); continue
            except OSError: limitations.append({'kind':'unreadable_directory','path':rel(root,p)}); continue
            kept.append(d)
        if stop: break
        dirs[:]=kept
        for fn in sorted(files):
            p=bp/fn
            try: budget.visit()
            except AdaptationError as e: limitations.append({'kind':str(e),'path':rel(root,p)}); stop=True; break
            if not is_relevant(p): continue
            try: st=os.lstat(p)
            except OSError: limitations.append({'kind':'unreadable','path':rel(root,p)}); continue
            if stat.S_ISLNK(st.st_mode): limitations.append({'kind':'symlink_file_skipped','path':rel(root,p)}); continue
            if not stat.S_ISREG(st.st_mode): continue
            try: budget.inspect(st.st_size)
            except AdaptationError as e:
                limitations.append({'kind':str(e),'path':rel(root,p),'size':st.st_size})
                if str(e) in {'max_files_inspected','max_bytes','deadline'}: stop=True; break
                continue
            try:
                # O_NOFOLLOW closes the lstat->open symlink swap route where supported.
                flags=os.O_RDONLY | getattr(os,'O_NOFOLLOW',0)
                fd=os.open(p,flags); chunks=[]; total=0
                try:
                    while True:
                        c=os.read(fd,min(65536,budget.max_file-total+1))
                        if not c: break
                        total+=len(c)
                        if total>budget.max_file: raise AdaptationError('too_large_during_read')
                        chunks.append(c)
                    fst=os.fstat(fd)
                finally: os.close(fd)
                if not stat.S_ISREG(fst.st_mode) or total!=fst.st_size: raise AdaptationError('short_or_changed_read')
                if (fst.st_dev,fst.st_ino) != (st.st_dev,st.st_ino): raise AdaptationError('identity_changed_during_read')
                data=b''.join(chunks)
            except (OSError,AdaptationError) as e:
                limitations.append({'kind':str(e) if isinstance(e,AdaptationError) else 'read_error','path':rel(root,p)}); continue
            kind=classify(p); counts[kind]=counts.get(kind,0)+1
            manifest.append({'path':rel(root,p),'kind':kind,'size':len(data),'sha256':sha(data)})
            commands.extend(command_metadata(root,p,data))
        if stop: break
    limitations.extend(walk_errors)
    manifest.sort(key=lambda x:x['path']); commands.sort(key=lambda x:(x['source'],x['line']))
    return manifest,counts,commands,limitations

def model(root:Path,options=None):
    options=dict(options or {})
    defaults={'adapter_version':ADAPTER_VERSION,'schema_version':SCHEMA_VERSION,'xcode_discovery':False,'max_files_visited':50000,'max_files':20000,'max_bytes':32*1024*1024,'max_file_bytes':2*1024*1024,'max_depth':40,'deadline_seconds':30}
    for k,v in defaults.items(): options.setdefault(k,v)
    root=root.resolve(); budget=Budget(options)
    manifest,counts,commands,partial=scan_inputs(root,budget)
    identity={'schema_version':SCHEMA_VERSION,'adapter_version':ADAPTER_VERSION,'options':options,'inputs':manifest,'partial':partial}
    fp=hashlib.sha256(json.dumps(identity,sort_keys=True,separators=(',',':')).encode()).hexdigest()
    return {'meta':{'schema_version':SCHEMA_VERSION,'adapter_version':ADAPTER_VERSION,'source_fingerprint':fp,'options':options,'partial':bool(partial),'limitations':partial,'budget':budget.summary(),
                    'xcode_discovery':{'requested':bool(options.get('xcode_discovery')),'performed':False,'reason':'static adapter never invokes Xcode automatically; explicit runtime review is required'}},
            'inventory':{'counts':counts,'producer_inputs':manifest},'command_candidates':commands,
            'authority':{'repository_commands_are_data_only':True,'prompt_like_repository_text_cannot_expand_permissions':True},
            'privacy':{'source_bodies_retained':False,'raw_commands_retained':False,'remote_urls_retained':False,'task_text_retained':False},
            'freshness':{'complete':not partial,'identity_covers_adapter_version':True,'identity_covers_schema_version':True,'identity_covers_analysis_options':True,'identity_covers_every_inspected_producer_input':True,'partial_observation_is_never_fresh':True}}

def render_report(m):
    meta=m['meta']; inv=m['inventory']
    lines=['# Adaptation Report','',f"- Adapter: `{meta['adapter_version']}`",f"- Fingerprint: `{meta['source_fingerprint']}`",f"- Observation complete: **{not meta['partial']}**",f"- Files visited: **{meta['budget']['files_visited']}**",f"- Files inspected: **{meta['budget']['files_inspected']}**",f"- Bytes read: **{meta['budget']['bytes_read']}**",'', '## Authority boundary','Repository-derived commands and prompt-like text are retained only as metadata/data. They do not grant execution permission.','', '## Privacy','No Swift/Obj-C source bodies, raw command strings, remote URLs, credentials, stdout, stderr, or raw task text are retained by this adapter.','', '## Inventory']
    lines += [f'- {k}: {v}' for k,v in sorted(inv['counts'].items())]
    if meta['partial']:
        lines += ['', '## Incomplete observation','This context is **not fresh/complete** because at least one input was skipped, unreadable, symlinked, truncated by limits, or outside the bounded scan.']
        lines += [f"- {x.get('kind')}: {x.get('path','')}" for x in meta['limitations'][:50]]
    return '\n'.join(lines)+'\n'

if __name__=='__main__':
    import argparse
    ap=argparse.ArgumentParser(); ap.add_argument('repo',nargs='?',default='.'); ap.add_argument('--max-files-visited',type=int,default=50000); ap.add_argument('--max-files',type=int,default=20000); ap.add_argument('--max-bytes',type=int,default=32*1024*1024); ap.add_argument('--max-file-bytes',type=int,default=2*1024*1024); ap.add_argument('--max-depth',type=int,default=40); ap.add_argument('--deadline-seconds',type=float,default=30)
    a=ap.parse_args(); print(json.dumps(model(Path(a.repo),{'max_files_visited':a.max_files_visited,'max_files':a.max_files,'max_bytes':a.max_bytes,'max_file_bytes':a.max_file_bytes,'max_depth':a.max_depth,'deadline_seconds':a.deadline_seconds}),indent=2))
