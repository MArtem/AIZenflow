# Reuse Guide — AppBranding

## Package Kind

`root-package`

## Products

- `AppBranding`

## How To Connect Locally

1. Copy this folder into the target project under `./Packages/AppBranding`.
2. Run:

```zsh
cd ./Packages/AppBranding
./Scripts/verify_package.sh
```

3. Add the local Swift package path to Xcode or the host package manifest.
4. Link only the required product(s).
5. Keep app-specific policy, routes, DTOs, UI copy, persistence schema, and product decisions outside the package.

## When Not To Connect

Do not connect this package if the current app has no concrete use for the mechanism yet. Keep it in `./PackagesForReuse` until needed.
