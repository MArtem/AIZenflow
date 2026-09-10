# Reuse Guide — AppEnvironment

## Package Kind

`root-package`

## Product

- `AppEnvironment`

## How To Connect Locally

1. Copy this standalone folder into the target project's package area.
2. Add `./PackagesForReuse/AppEnvironment` as a local Swift package or copy it into the consuming project's package root.
3. Link only the `AppEnvironment` product.
4. Keep environment names, URLs, secrets, entitlements and release policy in the host app.
5. Run `./Scripts/verify_package.sh` from the package folder before adoption.

## When Not To Connect

Do not adopt this package when a compile-time constant is sufficient or when environment selection would expose secrets through source or logs.
