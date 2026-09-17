from __future__ import annotations
import importlib.util, json, os, shutil, stat, sys, time, uuid
from pathlib import Path

BASE=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/registry-macos")
CLI=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY/GLOBAL_CODEX/runtime/bin/ios_ai.py")
spec=importlib.util.spec_from_file_location("ios_ai_measure",CLI)
C=importlib.util.module_from_spec(spec); assert spec and spec.loader; spec.loader.exec_module(C)

def write_record(path,worktree,common,status="closed",sid=None):
    baseline={"repository_identity":{"worktree":str(worktree.resolve()),"git_common_dir":str(common)}}
    scope={"allow":[],"allow_dirty":[],"allow_protected":[],"allow_nested":[],"git_transitions":[],"task":None}
    sid=sid or str(uuid.uuid4())
    data={"schema_version":2,"session_id":sid,"lifecycle":status,"created_at":"2026-09-11T00:00:00+00:00",
          "baseline":baseline,"baseline_sha256":C.jhash(baseline),"scope":scope,"audit":[]}
    C.P.secure_write(path,json.dumps(data,separators=(",",":")))
    return sid

def measure(state,repo,n):
    repos=state/"repositories"; repos.mkdir(parents=True)
    common=Path(C.P.repository_identity(repo,C.P.Budget())["git_common_dir"]).resolve()
    started=time.monotonic()
    total=0
    for i in range(n):
        wt=BASE/"fake-worktrees"/str(i)
        d=repos/C.state_key(wt)/"protection"/"sessions"; d.mkdir(parents=True); C.P.secure_dir(d)
        sid=str(uuid.uuid4()); p=d/(sid+".json"); write_record(p,wt,common,sid=sid)
        total += p.stat().st_size
    before=time.monotonic()
    result=C._scan_legacy_v52_shared_writer_blockers(repo,state)
    elapsed=time.monotonic()-before
    return {"records":n,"payload_bytes":total,"create_seconds":round(before-started,4),
            "scan_seconds":round(elapsed,4),"blockers":len(result)}

def main():
    if BASE.exists(): shutil.rmtree(BASE)
    (BASE/"repo").mkdir(parents=True); repo=BASE/"repo"
    run=lambda args: __import__("subprocess").run(["git",*args],cwd=repo,check=True,stdout=__import__("subprocess").PIPE,stderr=__import__("subprocess").PIPE,text=True)
    run(["init","-q"]); run(["config","user.email","fixture@example.invalid"]); run(["config","user.name","Registry Fixture"])
    (repo/"A.swift").write_text("let a = 1\n"); run(["add","A.swift"]); run(["commit","-q","-m","fixture"])
    results=[]
    for n in (10,1000,10000):
        state=BASE/f"state-{n}"; results.append(measure(state,repo,n))
    malformed=BASE/"malformed"; (malformed/"repositories"/C.state_key(repo)/"protection"/"sessions").mkdir(parents=True)
    (malformed/"repositories"/C.state_key(repo)/"protection"/"sessions"/"bad.json").write_text("{")
    try: C._scan_legacy_v52_shared_writer_blockers(repo,malformed); malformed_result="unexpected_success"
    except Exception as e: malformed_result=type(e).__name__+":"+str(e)
    symlink=BASE/"symlink"; target=symlink/"target"; target.mkdir(parents=True)
    (symlink/"repositories").symlink_to(target, target_is_directory=True)
    try: C._scan_legacy_v52_shared_writer_blockers(repo,symlink); symlink_result="unexpected_success"
    except Exception as e: symlink_result=type(e).__name__+":"+str(e)
    print(json.dumps({"environment":{"platform":"macOS","python":sys.version.split()[0]},
                      "measurements":results,
                      "malformed_current_state":malformed_result,
                      "symlink_repositories_root":symlink_result,
                      "fixture_root":str(BASE)},indent=2,sort_keys=True))

if __name__=="__main__": main()
