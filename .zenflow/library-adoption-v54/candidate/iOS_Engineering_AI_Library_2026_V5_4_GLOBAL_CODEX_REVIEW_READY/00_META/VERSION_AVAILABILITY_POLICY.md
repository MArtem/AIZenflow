# Version & Availability Policy

## Baseline
The library is 2026-oriented but project-aware. Never require the newest OS merely because a newer API exists.

## Rules
1. Read deployment target before suggesting API.
2. Prefer modern API when it reduces bugs/complexity **and** availability fits.
3. For newer API, define availability gate or fallback if older OS support remains required.
4. Beta SDK/API must be labeled beta and must not silently become production baseline.
5. Distinguish Swift language version from compiler version and SDK version.
6. Do not perform migration only to remove deprecation warnings unless business/maintenance value justifies it.
7. For iOS 27-era APIs, provide an older-OS path when the product still supports earlier systems.

## Current forward-looking examples (September 2026)
- Swift 6 strict concurrency remains a core safety target.
- Swift 6.4 is still upcoming in September 2026; development-snapshot features must not be treated as universally released production baseline.
- iOS 27-era APIs such as new MetricKit `MetricManager`/async sequences require availability handling if earlier OS versions are supported.
- Foundation Models behavior/model capabilities can change with OS updates; prompts and evaluations must be regression-tested per OS/model profile.
