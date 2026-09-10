# Reuse Guide — AppLifecycle

## Package Kind

`root-package`

## Product

- `AppLifecycle`

## How To Connect Locally

1. Copy this standalone folder into the target project's package area.
2. Add `./PackagesForReuse/AppLifecycle` as a local Swift package or copy it into the consuming project's package root.
3. Link only the `AppLifecycle` product.
4. Keep background work, refresh, session and user-visible recovery policy in the host app.
5. Run `./Scripts/verify_package.sh` from the package folder before adoption.

## When Not To Connect

Do not adopt this package merely to wrap a single scene callback; use it when lifecycle state or observation is shared and testable.
