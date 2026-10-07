# Accessibility and localization — curated copy-only route

Use for user-facing iOS code or resources after project-local rules. Select only checks relevant
to the changed flow and supported markets/devices; do not pretend a static review replaced manual
assistive-technology or device QA.

- Inspect the actual interactive flow: VoiceOver label/value/trait/hint, grouping, focus order,
  state announcements and accessible error presentation. A hidden destructive action or critical
  inaccessible action is blocking, not a style issue.
  Check accessible actions for custom gestures and focus/announcements after asynchronous or
  presentation transitions. Prefer existing semantic controls over recreating their behavior.
  Inspect semantic element boundaries, repeated labels, decorative content and modal focus;
  visual/view-tree order alone does not prove actual assistive traversal or action behavior.
- Check Dynamic Type at supported sizes, text truncation/expansion, contrast in relevant
  appearances, tap targets, Reduce Motion and keyboard/pointer where supported. Report impact
  on the user action, not only the implementation detail.
  Inspect wrapping/reflow and access to clipped content at supported size extremes; meaning
  must not depend solely on color, motion, sound or haptics. Check relevant transparency and
  alternative cues without inventing new product behavior.
- Keep user-facing copy and accessibility text in the project's localization resources. Check
  plural rules, locale-aware dates/numbers/currency/measurements, long translations and RTL
  where supported. Avoid English-length assumptions or concatenated locale-sensitive strings.
  Include translator context and grammatical variation where meaning depends on the value;
  trace calendar/time-zone and parsing boundaries, mirrored assets and mixed-direction text.
  For custom components, include keyboard/Switch Control actions when relevant to their consumers.
- For asset or string changes, verify file ownership, target/package bundle lookup and affected
  app/extension consumers. Review the whole code/resource/project diff, not Swift alone.
  During an approved UI rewrite, preserve required accessibility identifiers and semantics at
  actual consumers; localization-key changes must retain the project's translation workflow.
- Choose a risk-based manual QA matrix: affected flow and states × supported device/OS class ×
  relevant locale/RTL/accessibility setting. Build, Simulator, screenshot and VoiceOver/device
  verification require task permission; when absent, mark those observations unverified.

Figma or screenshot fidelity uses the separate
[../29_DESIGN_SYSTEM/COPY_ONLY_DESIGN_TO_IOS_ROUTE.md](../29_DESIGN_SYSTEM/COPY_ONLY_DESIGN_TO_IOS_ROUTE.md).
