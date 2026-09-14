# CP-25 — Cache needs a budget and invalidation policy

A cache is not just a dictionary. Define:
- key identity;
- memory/disk cost;
- TTL or server validators;
- eviction policy;
- invalidation on auth/account/schema change;
- thread/actor ownership;
- behavior under memory pressure.

For image caches, cache appropriately downsampled decoded representations rather than retaining full-resolution originals by accident.
