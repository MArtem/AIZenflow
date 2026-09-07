# 06 — UIKit

## Main-thread contract

UIKit UI work is main-thread/MainActor work. Keep non-UI CPU or blocking work off the main thread.

## View controller lifecycle

MUST understand whether work belongs to:

- object initialization;
- `loadView` / view construction;
- `viewDidLoad` one-time view setup;
- appearance cycles (`viewWillAppear` / `viewDidAppear`);
- layout cycles;
- scene/app lifecycle.

Do not start repeatable operations in a lifecycle callback without defining cancellation/deduplication.

## Ownership and retain cycles

Review delegates, closures, timers, display links, notifications, KVO, Combine subscriptions, tasks and callbacks for ownership. Delegates are normally weak when the relationship allows it.

Any long-lived callback capturing a view controller strongly is a review trigger.

## Collection/table views

For modern collection view work, SHOULD prefer diffable data sources/compositional layout when they fit project deployment targets and conventions.

MUST use stable item/section identity and keep model mutations consistent with applied snapshots.

## Cell reuse

Reusable views MUST reset all reusable state. Async image/data loading must handle cancellation/reuse so stale completion cannot populate the wrong cell.

## Constraints/layout

- Avoid ambiguous/unsatisfiable constraints.
- Dynamic Type must be considered for user-facing text.
- Do not hardcode dimensions that break supported size classes/content sizes without design justification.

## Interop with SwiftUI

When using hosting/representable bridges:

- define ownership explicitly;
- avoid update loops between SwiftUI state and UIKit callbacks;
- keep coordinator/delegate lifetime aligned with bridge lifetime;
- ensure UIKit callbacks mutate SwiftUI-visible state on correct isolation.
