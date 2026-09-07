# 16 — Localization and Internationalization

## MUST

- user-facing text must use the project’s localization mechanism;
- do not concatenate localized sentence fragments when grammar/order can vary;
- format dates, numbers, currencies, measurements and lists using locale-aware APIs;
- handle pluralization with string-catalog variations/localization APIs rather than manual English-style conditionals;
- localize privacy purpose strings when the app supports those locales;
- avoid embedding developer/debug text in production UI.

## Modern projects

String Catalogs (`.xcstrings`) are preferred when compatible with project conventions. Xcode can extract localizable strings, manage plural/device variants, and generate type-safe localized symbols in modern toolchains.

## Layout

UI changes SHOULD consider:

- text expansion;
- right-to-left layout where supported;
- long translations;
- locale-specific formatting;
- accessibility text sizes combined with localization.

## Tests

For relevant UI changes, test at least one long-string locale/pseudolocalization strategy if project tooling supports it. Critical localization-sensitive workflows SHOULD have snapshot/UI checks when infrastructure exists.
