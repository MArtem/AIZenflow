---
name: ios-content-cards
description: Use this skill whenever the task touches iOS content cards, composer flows, card publishing, media card rendering, teaser handling, draft validation, or text/photo/video/audio/pdf card rules. Trigger even if the user only mentions a feed, composer, card creation, card types, media actions, card metadata, or locally published cards.
---

# iOS Content Cards

Use this skill for iOS app tasks involving:
- feed/composer card contracts
- card draft validation
- media asset rules
- card publishing behavior
- feed runtime rendering for `text/photo/video/audio/pdf`

## Read Order
Read these files first:

1. [references/feed-card-contract.md](./references/feed-card-contract.md)
2. [PROJECT_DOCUMENTATION.md](./PROJECT_DOCUMENTATION.md)
3. [handoff.md](./.zenflow/tasks/new-task-be0b/handoff.md) if resume state matters

Read code only after the contract is clear.

## Working Rules
- Treat the card contract as product truth.
- Do not invent extra fields, extra actions, or fallback UI.
- Keep composer draft rules and published feed behavior aligned.
- Prefer editing the shared card model before patching view-local behavior.
- If a card flow looks generic, check whether it belongs in the model layer instead of a screen convenience branch.

## Important Code
- app content/card models
- app shell or composition state owner
- composer UI
- feed/list/detail renderer UI

## Output Expectation
When changing this area:
- preserve the agreed card-type taxonomy
- preserve strict text-field ordering
- preserve draft validation rules
- keep feed/runtime and composer semantics consistent
