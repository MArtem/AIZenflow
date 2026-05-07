# Feed Card Contract

## Card Types
- `text`
- `photo`
- `video`
- `audio`
- `pdf`

## Text Fields
Only these text fields exist:
- `text`
- `headline`
- `subheadline`
- `source`

Render order is always:
1. `text`
2. `headline`
3. `subheadline`
4. `source`

If a field is absent, order still stays fixed for the remaining fields.

## Draft Rules
- Empty draft is forbidden.
- Without media, `text` is required.
- With media, text fields can be removed if the remaining draft still satisfies the contract.
- If text and media both exist, either side can be removed, but whatever remains becomes the required content.
- `source` stores visible text plus an optional hidden URL.
- Published feed opens `source` only when that hidden URL exists.

## Media Rules
### `photo`
- Up to 10 photos
- Each photo can have:
  - caption
  - copyright

### `video`
- Single media item
- May have teaser image
- May have caption
- Teaser may have copyright

### `audio`
- Single media item
- May have teaser image
- May have caption
- Teaser may have copyright

### `pdf`
- Single media item
- May have teaser image
- May have caption
- Teaser may have copyright

## Composer Rules
- Do not add speculative actions or extra menus.
- Optional text/media metadata fields should be removable.
- Placeholder and real text should use one input surface, not duplicated layers.
- Local published cards should use the same card semantics as feed runtime.

## Publish And Feed Rules
- Composer starts from the currently selected feed channel.
- Draft channel selection may diverge from the currently visible feed channel.
- Publish writes to the selected draft channel.
- Local published cards appear only in their own channel feed scope.
- Search applies only to cards visible in the current channel, including local published cards.
