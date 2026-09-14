# Common host / canonical bootstrap diff proposal

Date: 2026-09-14. Status: local proposal only; no canonical file or real host file was changed.

## Contract

The host-delivered layer is common and task-type neutral. It must run before the first project
operation for every project inside the explicit host scope, including new, imported, nested and
non-Git directories. It must preserve repository and nested overlays, route specialist material by
task type, and keep the iOS candidate runtime opt-in. A root `AGENTS.md` marker remains the
portable adoption mechanism for clones and hosts outside the explicit scope; it is not proof that
the current host entry was delivered.

## Minimal canonical changes

The exact canonical files to change after review are:

1. `reusable/GLOBAL_RULES_BOOTSTRAP.md`
   - define the common host entry as a delivery layer before root-marker checks;
   - state that host delivery covers the named scope even when a root marker is absent;
   - retain `AGENTS.md` as portable adoption for clones/out-of-scope hosts;
   - keep canonical-unavailable fallback explicit and non-PASS.
2. `reusable/baseline/docs/NEW_PROJECT_START_CONTRACT.md`
   - distinguish “host common baseline delivered” from “repository bootstrap marker installed”;
   - require the marker for portability, but do not treat its absence as evidence that the active
     host failed to deliver the common baseline;
   - keep iOS quality-control adoption, profile, launcher and workflow requirements conditional
     on an iOS consumer rather than globalizing them to non-iOS projects.
3. `reusable/baseline/docs/IOS_PROJECT_BOOTSTRAP_TEMPLATE.md` and
   `reusable/baseline/templates/AGENTS.template.md`
   - describe the root marker as the portable project layer;
   - state that a correctly configured host common entry can deliver the common baseline before
     the marker exists, while the marker is still required before claiming portable adoption;
   - preserve iOS-specific routing and explicit quality-control activation.
4. `reusable/baseline/root-scripts/check_bootstrap_contract.py`
   - validate both facts separately: common host delivery is an external host receipt, while the
     repository marker is a local portability contract;
   - never infer host delivery from marker text or infer missing host delivery from a missing
     marker;
   - keep existing required-file, fallback-marker and workflow checks unchanged.

## Proposed wording delta

Insert the following neutral contract into the canonical bootstrap and its templates, adapting
paths only through the existing canonical variables:

```text
Host delivery and repository portability are separate contracts. An explicitly configured host
entry may deliver this common baseline before a repository-root AGENTS.md exists. The root marker
is still required for portable adoption when the project is opened on another host, in a clean
clone, or outside the configured host scope. A marker alone does not prove that the current host
loaded the baseline; record actual startup evidence when claiming delivery. Route iOS, AI, release,
security and other specialist material only when the current task and project profile select it.
```

## Acceptance and authority boundary

The proposal is accepted only when the canonical diff, its checker, and the host block agree on
the same scope and fallback. Fresh-session evidence must cover existing, new empty, imported
without `AGENTS.md`, linked-worktree, nested, non-Git, unrelated non-iOS, and outside-scope flows
using ordinary prompts. Markers, doctor output, or a text-only inventory cannot substitute for
first-entry evidence. The current task has not read `/Users/Artem/.codex`; exact host read/write
authority remains a separate boundary. No host configuration change is included here.
