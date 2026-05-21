# TchopApp Feed And Composer Summary

## Card Types
- `text`
- `photo`
- `video`
- `audio`
- `pdf`

## Text Field Order
1. `text`
2. `headline`
3. `subheadline`
4. `source`

## Runtime Direction
- Locally created cards should converge with future API cards into the same feed-card semantics.
- Published feed cards must persist through SwiftData and durable media files.
- Feed rendering should not maintain permanent local-vs-remote split behavior unless product requires it.

## Canonical Detailed Contracts
- `../../../.codex/skills/tchop-feed-cards/references/feed-card-contract.md`
- `../../LOCAL_FEED_PERSISTENCE_CONTRACT.md`
