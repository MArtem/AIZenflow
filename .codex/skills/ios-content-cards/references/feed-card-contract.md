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
- Locally published cards should use the same card semantics as feed runtime.

## Publish And Feed Rules
- Composer starts from the currently selected feed channel.
- Draft channel selection may diverge from the currently visible feed channel.
- Publish writes to the selected draft channel.
- Locally published cards appear only in their own channel feed scope.
- Search applies only to cards visible in the current channel, including locally published cards.

## Published Feed Rendering Rules
- Media renders first when present.
- Text fields render below media in strict order:
  1. `text`
  2. `headline`
  3. `subheadline`
  4. `source`
- Missing fields are skipped without changing the order of remaining fields.
- If a card has media but no text fields, preserve correct spacing before the action toolbar and keep the divider visible.
- Translation action appears only when there is visible translatable text.
- The action toolbar belongs to the card, not to the media frame, and must remain tappable without opening card details.

## Published Media Rendering Rules
### Photo
- Photo media fills the published card media frame.
- Photo caption and copyright, when present, belong to a semi-transparent metadata area pinned to the bottom of the media frame.
- The metadata area must not change size because of full/compact display mode.

### Video
- Video renders as media at the top of the card.
- The feed preview uses the video thumbnail/first frame when available.
- A play affordance may appear over the video preview.
- Video caption belongs to the media metadata area.
- If a teaser image exists, it renders above the video content inside the media card structure.

### PDF
- PDF renders as media at the top of the card.
- The feed preview uses a PDF page preview when available.
- PDF caption belongs to the media metadata area.
- If a teaser image exists, it renders above the PDF content inside the media card structure.

### Audio
- Audio renders as media at the top of the card.
- If no teaser image exists, audio uses an audio placeholder/preview.
- Audio caption belongs to the media metadata area.
- If a teaser image exists, it renders above the audio content inside the media card structure.

## Display Mode Rules
- `expanded` and `compact` change the media/card presentation size, not the semantic content order.
- Switching display mode must not move text fields into the media frame.
- Switching display mode must not change the size of the caption/copyright metadata area.
- Switching display mode must preserve like/comment/display-mode state after restart.
