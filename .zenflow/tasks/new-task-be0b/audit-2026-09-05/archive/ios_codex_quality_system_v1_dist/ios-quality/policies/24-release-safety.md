# 24 — Release Safety

## Scope

Applied to R4/R5 changes, release candidates, migrations, signing/capability changes, and features with wide user impact.

## Release gate SHOULD include as applicable

- clean checkout/reproducible dependency resolution;
- Release configuration build/archive when practical;
- full relevant test plan;
- migration matrix;
- privacy manifest/required-reason review;
- entitlements/capabilities/signing diff;
- localization completeness for changed user-facing strings;
- accessibility smoke/audit for changed critical screens;
- performance regression checks for hot paths;
- crash/hang diagnostics review strategy;
- rollback/feature-flag/server-compatibility strategy.

## Backward compatibility

When app and backend versions can coexist, verify the compatibility matrix. A mobile release cannot assume every user upgrades immediately.

## Feature flags

Feature flags may reduce blast radius but create dual code paths. Define default, rollout, failure, cleanup, and offline behavior.

## Database/API migration

Prefer expand/migrate/contract sequencing when old and new app versions must coexist with a backend/schema.

## Human signoff

R4/R5 release-critical changes require human acknowledgement of residual risk even when automated gates pass.
