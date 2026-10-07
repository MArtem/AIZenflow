# App Intents — copy-only reference route

Use when an app exposes an action/entity to system surfaces or changes its parameters,
availability or handoff. Apply current project and local platform rules first; verify any
specific API or OS-availability claim against current official documentation before relying on
it. This route does not enable capabilities, run Shortcuts or alter app configuration.

Trace the intent's discoverable name, stable entity identity, parameter source and validation,
authorization state, side effect and destination. Ask what happens on a repeated or stale
invocation, denied permission, missing entity, app/extension handoff, interruption and
unsupported OS/device. A mutating action needs an explicit owner and duplicate-action policy;
do not infer idempotency from the framework. Check that surfaced data respects privacy and that
failure is understandable to the user.

For an authorized edit, inspect the declaration, resolver, underlying domain operation, UI
handoff and all affected target memberships together. Recommend the smallest meaningful
verification; actual build, device and system-surface checks require separate permission.
`AUTO` performs in-scope static review; `ADVISORY` prioritizes scenarios and evidence. This
distills the former `ioslib-app-intents` checklist without its installed skill/runtime.
