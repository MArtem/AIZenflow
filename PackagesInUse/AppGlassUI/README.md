# AppGlassUI

`AppGlassUI` is a single-folder standalone Swift Package for reusable SwiftUI Liquid Glass availability handling.

## What it owns

- Native Liquid Glass usage behind availability checks.
- Older-OS fallback chrome mechanics.
- Shape-based chrome styling helpers.
- Package-owned tests and DocC overview.

## What the app owns

- Product-specific colors and semantic visual tokens.
- Which surfaces use glass.
- Accessibility labels and interaction behavior.
- Screen layout and design decisions.

## Usage

```swift
import AppGlassUI
import SwiftUI

AppGlassContainer(spacing: 12) {
    Button("Action") {}
        .appGlassChrome(
            in: Capsule(),
            glassTint: .blue,
            fallbackBackground: .blue.opacity(0.2),
            interactive: true
        )
}
```

## Verification

```bash
./Scripts/verify_package.sh
```


## Usage guide

See `./USAGE.md` for package/app boundary rules and host integration guidance.
