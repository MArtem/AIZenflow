# Reuse Guide — AppDeviceInfo

## Package Kind

`root-package`

## Product

- `AppDeviceInfo`

## How To Connect Locally

1. Copy this standalone folder into the target project's package area.
2. Add `./PackagesForReuse/AppDeviceInfo` as a local Swift package or copy it into the consuming project's package root.
3. Link only the `AppDeviceInfo` product.
4. Keep feature gating, telemetry fields, compatibility policy and privacy decisions in the host app.
5. Run `./Scripts/verify_package.sh` from the package folder before adoption.

## When Not To Connect

Do not adopt this package for a one-off platform check or to collect identifiers without an explicit privacy and compatibility contract.
