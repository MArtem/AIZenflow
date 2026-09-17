from __future__ import annotations
import hashlib, json, os, shutil, subprocess, sys, tempfile
from pathlib import Path

BASE=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/fixtures/cross-version-macos")
V52=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-review-v52-aPK9Wh/iOS_Engineering_AI_Library_2026_V5_2_GLOBAL_CODEX_REVIEW_READY")
V54=Path("/Users/Artem/.zenflow/worktrees/new-task-be0b/.zenflow/library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY")
PY=sys.executable

def run(args, cwd=None, expect=None):
    env=dict(os.environ)
    env.update({
        "TMPDIR": str(BASE/"tmp"),
        "TMP": str(BASE/"tmp"),
        "TEMP": str(BASE/"tmp"),
        "PYTHONDONTWRITEBYTECODE": "1",
        "GIT_CONFIG_GLOBAL": str(BASE/"empty-global-config"),
        "GIT_CONFIG_NOSYSTEM": "1",
    })
    p=subprocess.run([str(x) for x in args], cwd=str(cwd) if cwd else None, env=env,
                     text=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    if expect is not None and p.returncode != expect:
        raise RuntimeError(json.dumps({"args":args,"returncode":p.returncode,"stdout":p.stdout,"stderr":p.stderr}))
    return p

def cli(root, state, *args, **kwargs):
    return run([PY, str(root/"GLOBAL_CODEX/runtime/bin/ios_ai.py"), "--state-root", str(state), *args], **kwargs)

def git(repo, *args):
    return run(["git", *args], cwd=repo, expect=0)

def json_stdout(p):
    return json.loads(p.stdout)

def state_files(state):
    return sorted(state.rglob("*.json"))

def main():
    if BASE.exists():
        shutil.rmtree(BASE)
    (BASE/"tmp").mkdir(parents=True)
    (BASE/"empty-global-config").write_text("")
    repo=BASE/"repo"
    repo.mkdir()
    git(repo, "init", "-q")
    git(repo, "config", "user.email", "fixture@example.invalid")
    git(repo, "config", "user.name", "Cross Version Fixture")
    (repo/"A.swift").write_text("let a = 1\n")
    git(repo, "add", "A.swift")
    git(repo, "commit", "-q", "-m", "fixture")
    state=BASE/"state"

    begin=json_stdout(cli(V52,state,"protect","begin","--repo",repo,"--allow","A.swift",expect=0))
    legacy_sid=begin["session_id"]
    verify=json_stdout(cli(V52,state,"protect","verify","--repo",repo,"--session",legacy_sid,expect=0))
    close=json_stdout(cli(V52,state,"protect","close","--repo",repo,"--session",legacy_sid,expect=0))
    legacy_paths=[p for p in state_files(state) if p.name == legacy_sid+".json"]
    if len(legacy_paths)!=1:
        raise RuntimeError("expected one legacy session JSON")
    legacy_path=legacy_paths[0]
    legacy_before=legacy_path.read_bytes()
    legacy_sha=hashlib.sha256(legacy_before).hexdigest()

    listing=json_stdout(cli(V54,state,"protect","list","--repo",repo,expect=0))
    legacy_row=next(x for x in listing["sessions"] if x["session_id"]==legacy_sid)
    archival=json_stdout(cli(V54,state,"protect","status","--repo",repo,"--session",legacy_sid,expect=0))
    current=json_stdout(cli(V54,state,"protect","begin","--repo",repo,"--allow","B.swift",expect=0))
    current_close=json_stdout(cli(V54,state,"protect","close","--repo",repo,"--session",current["session_id"],expect=0))
    legacy_after=legacy_path.read_bytes()

    blocked_state=BASE/"blocked-state"
    blocked_begin=json_stdout(cli(V52,blocked_state,"protect","begin","--repo",repo,"--allow","A.swift",expect=0))
    blocked_sid=blocked_begin["session_id"]
    blocked=cli(V54,blocked_state,"protect","begin","--repo",repo,"--allow","B.swift")
    blocked_payload=json.loads(blocked.stderr)
    v52_cleanup=json_stdout(cli(V52,blocked_state,"protect","close","--repo",repo,"--session",blocked_sid,expect=0))

    result={
        "environment":{"platform":"macOS","python":sys.version.split()[0],"git":git(repo,"--version").stdout.strip()},
        "legacy":{"session_id":legacy_sid,"verify_status":verify["status"],"close_status":close["status"],
                  "archival_row":legacy_row,"archival_status":archival["status"],
                  "historical_evidence_only":archival["historical_evidence_only"],
                  "verification_is_none":archival["verification"] is None,
                  "sha256_before":legacy_sha,"sha256_after":hashlib.sha256(legacy_after).hexdigest(),
                  "bytes_preserved":legacy_before==legacy_after},
        "current_v54":{"begin_ok":current["ok"],"writer_model":current["writer_model"],
                       "close_ok":current_close["ok"]},
        "active_legacy_block":{"v52_begin_ok":blocked_begin["ok"],"v54_returncode":blocked.returncode,
                               "v54_error_type":blocked_payload["error_type"],
                               "v54_message":blocked_payload["message"],
                               "v52_cleanup_ok":v52_cleanup["ok"]},
        "fixture_root":str(BASE),
    }
    print(json.dumps(result,indent=2,sort_keys=True))

if __name__=="__main__":
    main()
