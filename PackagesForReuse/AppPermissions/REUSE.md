# Reuse Guide — AppPermissions

## Package Kind

`root-package`

## Product

- `AppPermissions`

## How To Connect Locally

1. Copy this standalone folder into the target project's package area.
2. Add `./PackagesForReuse/AppPermissions` as a local Swift package or copy it into the consuming project's package root.
3. Link only the `AppPermissions` product.
4. Keep Info.plist copy, education screens, request timing, fallback UX and analytics in the host app.
5. Run `./Scripts/verify_package.sh` from the package folder before adoption.

## When Not To Connect

Do not request a capability without a current product need, a platform permission contract and an approved user education flow.
