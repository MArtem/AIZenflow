# AppInputFormatting

Standalone user-input formatting primitives for Swift applications.

## Overview

`AppInputFormatting` provides app-independent mechanisms for transforming text entered by users while keeping cursor movement explicit and testable. The package contains only local formatting primitives and host-owned extension boundaries.

Use it for reusable input mechanics such as trimming, whitespace normalization, digit filtering, grouping, uppercase/lowercase ASCII transforms, length limits, and simple pattern formatting.

## Standalone Contract

The package has no sibling SDK dependencies, no remote dependencies, and no app-specific entities. It does not own persistence outside its in-memory store. Host applications may provide their own `InputFormattingStore` or custom `InputFormatter` implementations.

## Privacy

Diagnostics are redacted by default. Field identifiers, formatter identifiers, pattern content, allowed character sets, and input text are not exposed through `description` or `debugDescription`.
