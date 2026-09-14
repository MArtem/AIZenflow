#!/usr/bin/env python3
"""Bounded heuristic scan of changed Swift files. Emits review leads only, never source bodies."""
from pathlib import Path
import importlib.util, json, os, re, stat, sys
sys.dont_write_bytecode=True
ROOT=Path(__file__).resolve().parents[1]
spec=importlib.util.spec_from_file_location('ioslib_risk_protection',ROOT/'GLOBAL_CODEX/runtime/protection/protection.py')
P=importlib.util.module_from_spec(spec); assert spec and spec.loader; sys.modules['ioslib_risk_protection']=P; spec.loader.exec_module(P)
repo=P.git_root(Path(sys.argv[1] if len(sys.argv)>1 else '.'))
budget=P.Budget(max_files_visited=5000,max_files_inspected=1000,max_total_bytes=16*1024*1024,max_file_bytes=2*1024*1024,max_output_bytes=1024*1024,subprocess_timeout=8,total_deadline_seconds=20)
patterns=[
 ('force_try',re.compile(r'\btry\s*!')),('force_cast',re.compile(r'\bas\s*!')),
 ('task_detached',re.compile(r'\bTask\s*\.\s*detached\b')),('unchecked_sendable',re.compile(r'@unchecked\s+Sendable')),
 ('nonisolated_unsafe',re.compile(r'\bnonisolated\s*\(\s*unsafe\s*\)')),('blocking_sleep',re.compile(r'\bThread\s*\.\s*sleep\b')),
 ('main_async',re.compile(r'DispatchQueue\s*\.\s*main\s*\.\s*async'))]
try:
    changed=P.changed_paths(repo,budget); leads=[]; incomplete=[]
    for rel in sorted(changed):
        if not rel.endswith('.swift'): continue
        path=repo/rel
        try: st=os.lstat(path)
        except OSError: incomplete.append({'path':rel,'reason':'lstat_failed'}); continue
        if stat.S_ISLNK(st.st_mode): incomplete.append({'path':rel,'reason':'symlink_skipped'}); continue
        if not stat.S_ISREG(st.st_mode): continue
        try:
            budget.inspect(st.st_size)
            flags=os.O_RDONLY | getattr(os,'O_NOFOLLOW',0)
            fd=os.open(path,flags)
            try:
                fst=os.fstat(fd)
                if not stat.S_ISREG(fst.st_mode) or fst.st_dev != st.st_dev or fst.st_ino != st.st_ino:
                    raise P.ObservationError('file identity changed during bounded scan')
                data=os.read(fd,budget.max_file_bytes+1)
            finally:
                os.close(fd)
            if len(data)>budget.max_file_bytes or len(data)!=fst.st_size: raise P.ObservationError('bounded read incomplete')
            text=data.decode('utf-8')
        except Exception as e: incomplete.append({'path':rel,'reason':type(e).__name__}); continue
        for line_no,line in enumerate(text.splitlines(),1):
            for label,pat in patterns:
                if pat.search(line): leads.append({'path':rel,'line':line_no,'rule':label})
    out={'heuristic':True,'review_required':True,'status':'complete' if not incomplete else 'incomplete','leads':leads,'incomplete':incomplete,'source_bodies_emitted':False,'budget':budget.summary()}
    print(json.dumps(out,indent=2)); raise SystemExit(0 if not incomplete else 2)
except P.ObservationError as e:
    print(json.dumps({'heuristic':True,'review_required':True,'status':'incomplete','reason':str(e),'source_bodies_emitted':False},indent=2)); raise SystemExit(2)
