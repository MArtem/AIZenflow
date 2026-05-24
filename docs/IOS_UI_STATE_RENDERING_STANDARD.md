# iOS UI State And Rendering Standard

## Purpose
Make SwiftUI/UIKit UI predictable, performant, accessible, and maintainable.

## Required Rules
- Repeated rows receive narrow immutable input and explicit callbacks, not broad global state unless justified.
- Derived presentation state should be precomputed or memoized when it is read in hot paths.
- `ScrollView` + `LazyVStack`/`LazyHStack`/`LazyVGrid` lists should expose repeated items directly to the lazy container.
- Use stable identity; never use unstable indices for persisted/user-interactive rows.
- Avoid side effects in `body`, layout callbacks, and computed view properties.
- Avoid broad animations without a specific `value` and review repeated shadows, blurs, masks, and clips.
- Keep empty/loading/error/offline/permission states explicit.

## Review Checklist
- What state change invalidates this view?
- Which rows redraw for one item update?
- Is any map/sort/filter/formatting happening during render?
- Are gesture targets accessible and deterministic?
- Does layout stay stable while async content loads?

## Stop Rules
- No heavy sync work in render path.
- No hidden eager rendering inside an opaque section wrapper for large feeds/lists.
- No production screen without explicit failure/empty state.
