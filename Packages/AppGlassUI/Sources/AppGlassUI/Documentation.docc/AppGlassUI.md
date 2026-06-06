# AppGlassUI

Reusable SwiftUI Liquid Glass availability and fallback helpers.

## Overview

`AppGlassUI` owns platform/version availability mechanics for glass-backed chrome. Host apps still own product-specific colors, semantic roles, spacing, and where glass should appear.

Use this package when a project needs native Liquid Glass on supported iOS versions and a deterministic fallback on older OS versions.

## Boundaries

The package owns:
- `AppGlassContainer` grouping for related glass elements;
- `appGlassChrome` fallback/native switching;
- shape-based fallback clipping and shadows.

The host app owns:
- semantic color/theme tokens;
- product-specific role naming;
- accessibility labels and interaction behavior;
- whether a surface should be glass-backed at all.
