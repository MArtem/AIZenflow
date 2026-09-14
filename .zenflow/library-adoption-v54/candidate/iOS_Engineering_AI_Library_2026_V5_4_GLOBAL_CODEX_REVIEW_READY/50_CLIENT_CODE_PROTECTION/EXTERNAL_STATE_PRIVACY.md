# External State Privacy and Isolation

Project-adaptive state is local machine metadata, not a mirror of client source.

- State root must be outside the client repository and must not contain the client repository.
- State directories use private permissions where the OS supports them (`0700` directories, `0600` files).
- Generated context stores paths, counts, normalized settings, evidence labels, fingerprints and redacted command templates—not Swift/Obj-C source bodies.
- Raw `xcodebuild` stdout is not retained; only bounded structural summaries are cached.
- Raw remote URLs are not persisted; only host plus a one-way fingerprint are stored.
- State writes refuse symlink destinations.
- `clear` only removes a state directory carrying the expected repository marker.
