# 18 — Logging and Observability

## Logging

Prefer Apple unified logging (`Logger` / OSLog) over ad-hoc `print` in production paths.

## Privacy

Dynamic values that can identify a person/account/device or expose content/credentials MUST use appropriate privacy redaction or be omitted.

Never log:

- passwords;
- access/refresh tokens;
- authentication headers;
- private keys/secrets;
- full sensitive request/response bodies.

## Levels

Use log levels consistently:

- debug — development detail;
- info/notice — meaningful lifecycle/business events without noise;
- error/fault — failures requiring investigation.

Avoid per-frame/per-row logging storms.

## Correlation

For distributed/network flows, MAY use non-sensitive request/operation IDs to correlate events. Do not invent persistent identifiers that increase privacy tracking risk.

## Performance signposts

Use `OSSignposter`/signposts for meaningful intervals when profiling complex flows.

## Production diagnostics

For mature apps, SHOULD consider Xcode Organizer/MetricKit for field crash/hang/performance diagnostics. Diagnostic upload must follow privacy/product policy.

## Error evidence

Logs complement, not replace, user-facing recovery and tests.
