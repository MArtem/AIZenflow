# Source-Only Package Usage

This file is a neutral source-only package integration guide. It must not contain source-app branding.

## Folder Roles
- `./PackagesForReuse`: complete source-only package library/vault.
- `./PackagesInUse`: active source-only subset compiled into app targets.
- `./Packages`: SDK/package creation documentation, templates, reports, and optional copy-file helpers only.

## Ownership
Reusable packages own generic mechanisms. App targets own product policy, routing, composition, DTO/domain mapping, persistence schema choices, UI, localization copy, and feature behavior.

## Xcode Organization
Active package source files should be grouped under a logical `PackagesInUse` group with one subgroup per package. Physical source layout remains under `./PackagesInUse/<PackageName>`.
