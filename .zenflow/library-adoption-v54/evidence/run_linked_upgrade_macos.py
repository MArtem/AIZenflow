from __future__ import annotations
import hashlib, json, os, shutil, subprocess, sys
from pathlib import Path

BASE=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/linked-upgrade-macos")
V52=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY")
V54=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY")
PY=sys.executable

def run(args,cwd=None,expect=None):
    env=dict(os.environ)
    env.update({"TMPDIR":str(BASE/"tmp"),"TMP":str(BASE/"tmp"),"TEMP":str(BASE/"tmp"),
                "PYTHONDONTWRITEBYTECODE":"1","GIT_CONFIG_GLOBAL":str(BASE/"empty-global-config"),
                "GIT_CONFIG_NOSYSTEM":"1"})
    p=subprocess.run([str(x) for x in args],cwd=str(cwd) if cwd else None,env=env,text=True,
                     stdout=subprocess.PIPE,stderr=subprocess.PIPE)
    if expect is not None and p.returncode!=expect:
        raise RuntimeError(json.dumps({"args":args,"code":p.returncode,"out":p.stdout,"err":p.stderr}))
    return p

def git(repo,*args):
    return run(["git",*args],cwd=repo,expect=0)

def cli(root,state,repo,*args,expect=None):
    return run([PY,str(root/"GLOBAL_CODEX/runtime/bin/ios_ai.py"),"--state-root",str(state),
                *args,"--repo",str(repo)] if args and args[0]=="protect" else
               [PY,str(root/"GLOBAL_CODEX/runtime/bin/ios_ai.py"),"--state-root",str(state),*args],
               cwd=repo if args and args[0]=="protect" else None,expect=expect)

def payload(p):
    return json.loads(p.stdout)

def session_file(state,sid):
    hits=list(state.rglob(sid+".json"))
    if len(hits)!=1: raise RuntimeError("expected one session file")
    return hits[0]

def make_repo():
    repo=BASE/"repo"; repo.mkdir()
    git(repo,"init","-q")
    git(repo,"config","user.email","fixture@example.invalid")
    git(repo,"config","user.name","Linked Fixture")
    (repo/"A.swift").write_text("let a = 1\n")
    git(repo,"add","A.swift"); git(repo,"commit","-q","-m","fixture")
    git(repo,"branch","linked")
    linked=BASE/"linked"; git(repo,"worktree","add","-q",linked,"linked")
    return repo,linked

def close_v52(repo,state):
    b=payload(cli(V52,state,repo,"protect","begin","--allow","A.swift",expect=0))
    sid=b["session_id"]; c=payload(cli(V52,state,repo,"protect","close","--session",sid,expect=0))
    return sid,c,session_file(state,sid)

def main():
    if BASE.exists(): shutil.rmtree(BASE)
    (BASE/"tmp").mkdir(parents=True); (BASE/"empty-global-config").write_text("")
    repo,linked=make_repo()
    state=BASE/"state"
    main_sid,main_close,main_path=close_v52(repo,state)
    linked_sid,linked_close,linked_path=close_v52(linked,state)
    main_before=main_path.read_bytes(); linked_before=linked_path.read_bytes()
    main_id=payload(cli(V54,state,linked,"protect","begin","--allow","B.swift",expect=0))
    linked_current_close=payload(cli(V54,state,linked,"protect","close","--session",main_id["session_id"],expect=0))
    closed_result={
        "main_and_linked_share_common_dir":True,
        "main_legacy":main_sid,"linked_legacy":linked_sid,
        "v54_linked_begin_ok":main_id["ok"],
        "v54_linked_close_ok":linked_current_close["ok"],
        "main_legacy_preserved":main_path.read_bytes()==main_before,
        "linked_legacy_preserved":linked_path.read_bytes()==linked_before,
    }
    blocked_state=BASE/"blocked-state"
    old=payload(cli(V52,blocked_state,repo,"protect","begin","--allow","A.swift",expect=0))
    blocked=cli(V54,blocked_state,linked,"protect","begin","--allow","B.swift")
    err=json.loads(blocked.stderr)
    cleanup=payload(cli(V52,blocked_state,repo,"protect","close","--session",old["session_id"],expect=0))
    closed_result["active_main_legacy_blocks_v54_linked"]={"returncode":blocked.returncode,
        "error_type":err["error_type"],"message":err["message"],"v52_cleanup_ok":cleanup["ok"]}
    print(json.dumps({"environment":{"platform":"macOS","python":sys.version.split()[0]},
                      "closed_history":closed_result,"fixture_root":str(BASE)},indent=2,sort_keys=True))

if __name__=="__main__": main()
