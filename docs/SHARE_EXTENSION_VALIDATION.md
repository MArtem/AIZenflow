# Share Extension Validation

## Purpose
This file is the runtime validation matrix for the share-extension rollout.

Use it to track:
- what share scenarios are already covered by code
- what still needs manual validation
- what still needs a product decision

## Current Status
Infrastructure, build wiring, shared storage, and composer reuse are in place.

What remains is runtime validation plus one explicit product decision for incompatible imports.

## Validation Matrix
### Supported By Current Code
- share text only
  - imported text is merged into the card `text` field
- share one image
  - imported image becomes a photo card item
- share multiple images
  - imported images become multiple photo items
- share one video
  - imported video becomes file media with `video` card kind
- share one audio file
  - imported audio becomes file media with `audio` card kind
- share one pdf
  - imported pdf becomes file media with `pdf` card kind
- share text plus one compatible attachment
  - attachment is primary
  - text is merged into the card text field
- add or remove more media after import
  - same composer rules as the main app apply
- publish from extension
  - publishes into app-group-backed shared storage
- app-side visibility after extension publish
  - app syncs extension-published cards on app activation
  - app syncs extension-published cards on pull-to-refresh
- unauthenticated extension state
  - shows reason text and `Open app`

### Explicitly Rejected By Current Code
- mixed media imports like `image + video`
  - current result: explicit failure
- multiple file attachments like `video + pdf`
  - current result: explicit failure
- incompatible imported media against existing draft media
  - current result: explicit failure
- unsupported provider types
  - current result: explicit failure instead of opening an empty composer

### Still Needs Manual Runtime Validation
- share text only from a real source app
- share one image
- share multiple images
- share one video
- share one audio file
- share one pdf
- share text plus image
- share text plus video
- delete imported primary media and verify card kind recalculates correctly
- publish from extension, re-enter app, verify sync into the correct channel
- publish from extension, then pull-to-refresh, verify sync still works
- unauthenticated path and `Open app` behavior on device/simulator

## Open Product Decision
### Incompatible Imports
Current behavior is explicit failure.

Still not decided:
- whether final UX should remain blocking failure
- or whether final UX should surface a friendlier message with a more guided explanation

No silent guessing should be added here.

## Current Risk Notes
- `Open app` from share extension is best-effort and should not be treated as guaranteed platform behavior
- app and extension are intentionally not directly coupled through shared in-memory runtime
- sync is entry/refresh-based by design
