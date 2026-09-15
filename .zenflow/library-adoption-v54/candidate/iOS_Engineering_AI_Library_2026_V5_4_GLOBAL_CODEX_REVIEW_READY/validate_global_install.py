#!/usr/bin/env python3
"""Validate an installed V5.4 registry/ownership state without trusting managed paths.

Standard-library only. Validation is observational; it does not repair an installation.
"""
from __future__ import annotations
from pathlib import Path
import argparse, hashlib, importlib.util, json, os, re, stat

REGISTRY='ios-engineering-global.json'
BEGIN='<!-- IOS_ENGINEERING_GLOBAL:BEGIN -->'; END='<!-- IOS_ENGINEERING_GLOBAL:END -->'
MAX_FILES=10000; MAX_BYTES=128*1024*1024

class ValidationError(Exception): pass

def abs_lex(value)->Path:
    p=Path(value).expanduser()
    if not p.is_absolute(): p=Path.cwd()/p
    return Path(os.path.abspath(os.path.normpath(str(p))))

def sha_bytes(b:bytes): return hashlib.sha256(b).hexdigest()

def lstat_regular(p:Path):
    st=os.lstat(str(p))
    if stat.S_ISLNK(st.st_mode) or not stat.S_ISREG(st.st_mode):
        raise ValidationError('not a regular no-follow file: '+str(p))
    return st

def nofollow_read(p:Path,max_bytes:int=8*1024*1024)->bytes:
    before=lstat_regular(p)
    flags=os.O_RDONLY|getattr(os,'O_CLOEXEC',0)|getattr(os,'O_NOFOLLOW',0)
    fd=os.open(str(p),flags)
    try:
        after=os.fstat(fd)
        if not stat.S_ISREG(after.st_mode) or (after.st_dev,after.st_ino)!=(before.st_dev,before.st_ino):
            raise ValidationError('file identity changed during read: '+str(p))
        if after.st_size>max_bytes: raise ValidationError('file exceeds validation budget: '+str(p))
        chunks=[]; total=0
        while True:
            c=os.read(fd,min(65536,max_bytes-total+1))
            if not c: break
            chunks.append(c); total+=len(c)
            if total>max_bytes: raise ValidationError('file exceeds validation budget: '+str(p))
        return b''.join(chunks)
    finally: os.close(fd)

def sha_file(p:Path): return sha_bytes(nofollow_read(p))

def package_tree_identity(root:Path):
    root=abs_lex(root); installer=root/'install_global.py'
    reject_symlink_components(installer); lstat_regular(installer)
    spec=importlib.util.spec_from_file_location('ioslib_identity_installer', installer)
    if spec is None or spec.loader is None: raise ValidationError('package identity mechanism is unavailable')
    module=importlib.util.module_from_spec(spec); spec.loader.exec_module(module)
    identity=module.package_tree_identity(root)
    if not isinstance(identity,str) or len(identity)!=64 or any(c not in '0123456789abcdef' for c in identity):
        raise ValidationError('package identity is malformed')
    return identity

def reject_symlink_components(path:Path):
    p=abs_lex(path)
    parts=p.parts; cur=Path(parts[0])
    for part in parts[1:]:
        cur=cur/part
        try: st=os.lstat(str(cur))
        except FileNotFoundError: continue
        except OSError as e: raise ValidationError(f'lstat failed {cur}: {type(e).__name__}')
        if stat.S_ISLNK(st.st_mode): raise ValidationError('symlink path component: '+str(cur))

def check_tree(root:Path,expected:dict,label:str,errs:list[str]):
    root=abs_lex(root)
    try: reject_symlink_components(root); st=os.lstat(str(root))
    except Exception as e: errs.append(f'{label}: managed root unavailable: {e}'); return
    if not stat.S_ISDIR(st.st_mode): errs.append(f'{label}: managed root is not directory: {root}'); return
    current={}; count=0; total=0
    for base,dirs,files in os.walk(str(root),topdown=True,followlinks=False,onerror=lambda e: errs.append(f'{label}: directory walk failed: {type(e).__name__}')):
        b=Path(base)
        for name in list(dirs):
            q=b/name
            try: stq=os.lstat(str(q))
            except OSError as e: errs.append(f'{label}: lstat failed: {q}: {type(e).__name__}'); dirs.remove(name); continue
            if stat.S_ISLNK(stq.st_mode) or not stat.S_ISDIR(stq.st_mode): errs.append(f'{label}: unsafe directory entry: {q}'); dirs.remove(name)
        for name in files:
            q=b/name; count+=1
            if count>MAX_FILES: errs.append(f'{label}: validation file budget exceeded'); return
            try:
                stq=lstat_regular(q); total+=stq.st_size
                if total>MAX_BYTES: errs.append(f'{label}: validation byte budget exceeded'); return
                current[q.relative_to(root).as_posix()]=sha_file(q)
            except Exception as e: errs.append(f'{label}: unsafe/unreadable file {q}: {e}')
    for rel,h in expected.items():
        if current.get(rel)!=h: errs.append(f'{label}: modified/missing managed file: {rel}')
    for rel in current:
        if rel not in expected: errs.append(f'{label}: unknown file inside managed tree: {rel}')

def main():
    ap=argparse.ArgumentParser(description='Validate a V5.4 review-ready global installation from its ownership registry.')
    ap.add_argument('--codex-home'); a=ap.parse_args()
    ch=abs_lex(a.codex_home or os.environ.get('CODEX_HOME',str(Path.home()/'.codex')))
    mf=ch/REGISTRY; errs=[]; m={}
    try:
        reject_symlink_components(mf.parent)
        m=json.loads(nofollow_read(mf).decode('utf-8'))
    except Exception as e: errs.append('missing/invalid registry: '+type(e).__name__+': '+str(e))
    if m:
        required={'version','protection_version','mode','content_root','source','source_in_place','source_tree_sha256','shim_root','state_root','skills_root','agents_file','ownership','agents','claims'}
        missing=sorted(required-set(m))
        if missing: errs.append('registry missing keys: '+','.join(missing))
        mode=m.get('mode')
        if mode not in {'reference','full'}: errs.append('invalid mode: '+repr(mode))
        registered_identity=m.get('source_tree_sha256')
        if not isinstance(registered_identity,str) or len(registered_identity)!=64 or any(c not in '0123456789abcdef' for c in registered_identity):
            errs.append('installed source_tree_sha256 is malformed')
        if not str(m.get('version','')).startswith('5.4-review-ready.'):
            errs.append('unexpected installed version: '+repr(m.get('version')))
        own=m.get('ownership',{}) if isinstance(m.get('ownership'),dict) else {}
        try:
            for key in ('content_root','shim_root','state_root','skills_root','agents_file'):
                if key in m: reject_symlink_components(abs_lex(m[key]))
        except Exception as e: errs.append('unsafe registered target path: '+str(e))
        if not m.get('source_in_place') and m.get('content_root'):
            check_tree(Path(m['content_root']),own.get('content',{}),'content',errs)
        if m.get('content_root') and isinstance(registered_identity,str) and len(registered_identity)==64:
            try:
                actual_identity=package_tree_identity(Path(m['content_root']))
                if actual_identity!=registered_identity:
                    errs.append(f'installed package identity mismatch: registered {registered_identity}, observed {actual_identity}')
            except Exception as e:
                errs.append('installed package identity unavailable: '+type(e).__name__+': '+str(e))
        if m.get('shim_root'): check_tree(Path(m['shim_root']),own.get('shim',{}),'shim',errs)
        skills=own.get('skills',{}) if isinstance(own.get('skills'),dict) else {}
        if mode=='reference' and skills: errs.append('reference mode unexpectedly owns skills')
        if mode=='full' and len(skills)!=60: errs.append(f'full mode skill count {len(skills)}/60')
        for n,expected in skills.items():
            if not n.startswith('ioslib-'): errs.append('non-namespaced managed skill: '+n)
            if m.get('skills_root'): check_tree(Path(m['skills_root'])/n,expected,'skill '+n,errs)
        if mode=='full' and any(not n.startswith('ioslib-') for n in skills): errs.append('full mode contains unnamespaced skill')
        try:
            agents=Path(m['agents_file']); raw=nofollow_read(agents); text=raw.decode('utf-8')
            matches=list(re.finditer(re.escape(BEGIN)+r'.*?'+re.escape(END),text,re.S))
            if len(matches)!=1: errs.append(f'managed AGENTS block count {len(matches)} != 1')
            elif sha_bytes(matches[0].group(0).rstrip().encode())!=m.get('agents',{}).get('managed_block_sha256'):
                errs.append('managed AGENTS block hash mismatch')
        except Exception as e: errs.append('AGENTS unreadable/unsafe: '+type(e).__name__+': '+str(e))
        state=Path(m['state_root']); marker=state/'.ioslib-state-owned.json'
        expected_marker=own.get('state_files',{}).get('.ioslib-state-owned.json') if isinstance(own.get('state_files'),dict) else None
        try:
            reject_symlink_components(state); st=os.lstat(str(state))
            if not stat.S_ISDIR(st.st_mode): errs.append('state root is not a directory')
            elif stat.S_IMODE(st.st_mode)&0o077: errs.append('state root is not private (expected no group/other bits)')
        except Exception as e: errs.append('state root missing/unsafe: '+str(e))
        try:
            if not expected_marker or sha_file(marker)!=expected_marker: errs.append('owned state marker missing/modified')
            elif stat.S_IMODE(os.lstat(str(marker)).st_mode)!=0o600: errs.append('owned state marker permissions are not 0600')
        except Exception as e: errs.append('owned state marker missing/unsafe: '+type(e).__name__)
        try:
            launcher=Path(m['shim_root'])/'bin'/'ios_ai.py'; lstat_regular(launcher)
        except Exception: errs.append('runtime launcher missing/unsafe')
        try:
            descriptor=Path(m['shim_root'])/'INSTALLATION.md'
            desc=nofollow_read(descriptor).decode('utf-8')
            expected_fragments=(
                f'Runtime shim: `python3 \"{Path(m["shim_root"])/"bin"/"ios_ai.py"}\"`',
                f'Knowledge root: `{Path(m["content_root"])}`',
                f'External state root: `{Path(m["state_root"])}`',
            )
            for frag in expected_fragments:
                if frag not in desc: errs.append('installation descriptor mismatch: '+frag.split(':',1)[0])
        except Exception as e: errs.append('installation descriptor missing/unsafe: '+type(e).__name__+': '+str(e))
        try:
            data=json.loads(nofollow_read(Path(m['shim_root'])/'INSTALLATION.json').decode('utf-8'))
            required_descriptor={'schema_version','managed_by','release_id','protection_version','mode','knowledge_root','runtime_cli','state_root','source_tree_sha256','generated_by'}
            if not isinstance(data,dict) or not required_descriptor.issubset(data):
                errs.append('installation JSON descriptor is incomplete')
            else:
                expected_runtime=Path(m['content_root'])/'GLOBAL_CODEX'/'runtime'/'bin'/'ios_ai.py'
                checks={
                    'managed_by':'ios-engineering-library', 'schema_version':1,
                    'release_id':m['version'], 'protection_version':m['protection_version'],
                    'mode':m['mode'], 'knowledge_root':str(Path(m['content_root'])),
                    'runtime_cli':str(expected_runtime), 'state_root':str(Path(m['state_root'])),
                    'source_tree_sha256':m['source_tree_sha256'],
                }
                for key,value in checks.items():
                    if data.get(key)!=value: errs.append('installation JSON descriptor mismatch: '+key)
                reject_symlink_components(expected_runtime)
                lstat_regular(expected_runtime)
        except Exception as e: errs.append('installation JSON descriptor missing/unsafe: '+type(e).__name__+': '+str(e))
        if m.get('source_in_place'):
            if abs_lex(m.get('content_root',''))!=abs_lex(m.get('source','')): errs.append('source-in-place content root does not match registered source')
        claims=m.get('claims',{}) if isinstance(m.get('claims'),dict) else {}
        if claims.get('knowledge_is_permission_authority') is not False: errs.append('registry authority claim invalid')
        if claims.get('client_repo_install_required') is not False: errs.append('registry client-repo claim invalid')
    out={'codex_home':str(ch),'registry':str(mf),'mode':m.get('mode') if m else None,'errors':errs,'ok':not errs}
    print(json.dumps(out,indent=2)); return 0 if not errs else 1

if __name__=='__main__': raise SystemExit(main())
