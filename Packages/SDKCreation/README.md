# App Infrastructure SDK — Iteration 00

This archive is the **baseline standard** for building a large set of app-independent iOS infrastructure packages.

Iteration 00 created the reusable **package template, rules, policies, verification scripts, and roadmap** that every future package must follow. The current repository has since adopted production runtime packages through `./Packages/AppObservability`.

## Goal

Every root package created in future iterations must be:

- **single-folder standalone**;
- copyable into any new project as one Swift Package folder;
- free from sibling path dependencies;
- free from app-specific product logic, routes, screens, strings, and features;
- testable in isolation;
- documented with a package contract;
- safe by default with respect to privacy, telemetry, and concurrency.

## Folder structure

```text
InfrastructureSDK_Iteration00/
├── Catalog/
├── Sources/<Module>/Documentation.docc/
├── Scripts/
├── Templates/
│   ├── IntegrationHelperTemplate/
│   └── PackageTemplate/
└── README.md
```

## How to use this baseline

For every new package:

1. Copy `Templates/PackageTemplate`.
2. Replace all `{{PackageName}}` placeholders.
3. Fill in `PackageContract.md` before writing implementation.
4. Add tests before considering the package complete.
5. Run `Scripts/verify_package_structure.sh <PackagePath>`.
6. Run the package-local `Scripts/verify_package.sh`.
7. If the package needs cross-package integration, create an optional helper using `Templates/IntegrationHelperTemplate`.

## Current roadmap

The planned SDK contains 50 package iterations plus final hardening. See:

```text
Catalog/SDK_PACKAGE_ROADMAP_50.md
```

## Status

```text
Iteration: 00
Status: SDK standard/template created
Production packages adopted in this repository: 4
Latest adopted production package: AppObservability
Next planned iteration: AppSession or another user-approved infrastructure package
```


## TchopApp adaptation note

This baseline was adopted from `InfrastructureSDK_Iteration00.zip` and hardened to match the current repository contract:

- DocC lives under `Sources/<Module>/Documentation.docc/` so docs travel with the source target.
- Template verification uses temporary or externally supplied SwiftPM build paths and cleans package-local generated state.
- Creation scripts validate Swift identifier names before writing files.
- Structure verification checks target folders, source DocC, unresolved placeholders, sibling dependencies, unsafe flags, and archive hygiene.


## Multi-target note

Multi-target packages are allowed when the targets are inside the same package folder and remain app-independent. The standalone verifier requires at least one source target, at least one test target, and source-owned DocC, but it does not require every package to have exactly one target named after the package.
