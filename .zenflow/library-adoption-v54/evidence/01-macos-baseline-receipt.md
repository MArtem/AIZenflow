# macOS baseline receipt — V5.4

Date: 2026-09-11. Executor: GPT-5.6 Luna xhigh.

- Candidate: `library-adoption-v54/candidate/iOS_Engineering_AI_Library_2026_V5_4_GLOBAL_CODEX_REVIEW_READY`
- Platform: Darwin arm64, macOS 26.6.1
- Python: 3.9.6
- Git: 2.50.1 (Apple Git-155)
- Command: `env TMPDIR=<sandbox>/tmp TMP=<sandbox>/tmp TEMP=<sandbox>/tmp PYTHONDONTWRITEBYTECODE=1 python3 -B tests/run_all.py`
- Isolation: temporary fixtures were directed to the declared sandbox `tmp/`; the real Codex home was not supplied.
- Result: **134/134 PASS, 0 FAIL, 0 SKIP, exit 0, 26.32 seconds**
- Structural command: `python3 -B validate_package.py`
- Structural result: **files=1357, skills=60, sections=51, playbooks=288, errors=0**

An earlier attempt without a shell `env` wrapper was rejected as harness/environment misconfiguration:
Python retained macOS `/var/folders` temp and the candidate correctly refused the symlinked
`/var` path. It was not counted as a library result. No further run was made until the sandbox
temp root was confirmed.

This is independent macOS Python/synthetic evidence. It is not Xcode, Swift, device, production,
or global-install evidence.
