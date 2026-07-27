# Source-Only Package Usage

## Purpose
This document explains the neutral source-only package integration mode used by iOS projects in this worktree.

It is reusable guidance, not source-app documentation.

## Current Integration Mode
Reusable infrastructure package code is integrated in **source-only local mode** unless a task-specific ADR explicitly chooses SwiftPM.

This keeps disk usage predictable while the reusable package library is under active review. Only source files from active packages are compiled into app targets.

## Folder Roles
- `./PackagesForReuse`: complete source-only package library/vault.
- `./PackagesInUse`: active source-only subset compiled into app targets.
- `./Packages`: SDK/package creation documentation, templates, reports, and optional copy-file helpers only.

## Runtime Target Ownership
- The app target compiles only the active package subset it needs from `./PackagesInUse`.
- Extensions compile only extension-relevant package source.
- Package source is not linked as SwiftPM products in this worktree unless explicitly approved for the current app.

## When To Use Package Code
Use package mechanics instead of duplicated app-local code when the package surface directly fits the app need:
- navigation/router primitives;
- file storage and file-protection mechanics;
- permissions;
- lifecycle;
- localization mechanics;
- validation;
- configuration/environment snapshots;
- logging/observability;
- networking/retry/upload/download primitives;
- database execution-boundary utilities;
- image/media/cache helpers;
- App Intents support primitives;
- on-device AI support primitives.

## What Stays In App Code
- product copy and localization strings;
- app routes and tab semantics;
- DTO/domain/UI mapping;
- session/auth policy;
- persistence schema and migration decisions;
- visual layout and semantic design roles;
- feature-specific UX behavior.

## Xcode Organization
Active package source files must appear in the Xcode project under a logical `PackagesInUse` group with one subgroup per package. New packages added to `./PackagesInUse` must keep that logical grouping and must not be left only in `Recovered References`.

Physical source layout remains under `./PackagesInUse/<PackageName>`.

## Future SwiftPM Use
Every reusable package should remain standalone enough to be copied and connected as a normal Swift Package in a future project when disk/build-cache cost is acceptable.
