# Current Plan

## Goal

Reduce documentation-context cost only where evidence shows no material loss of quality, safety, or
task continuity.

## Active Constraints

- Keep reusable rules canonical in `MArtem/AIZenflowDocumentation`; app decisions remain app-local.
- Preserve archives and deep references; optimize routing and active task state instead.
- No product-code, build, test, Simulator, or project-PR work is in scope.

## Executable Steps

- [x] Route ordinary Figma work through the compact Figma intake; retain the deep prompt behind
  explicit triggers (`b257b52`).
- [x] Define the bounded meaning of the context-transfer rule (`0a5f9c7`).
- [x] Compact local and canonical active task state; retain recovery through Git history/archive.
- [ ] Extend the existing context-cost report with the complete instruction envelope, if a bounded
  read-only implementation remains worthwhile after review.

## Stop Conditions

Do not build a new documentation engine, automatically rewrite project copies, mass-delete archives,
or weaken sandbox, permission, quality, and semantic-review requirements.
