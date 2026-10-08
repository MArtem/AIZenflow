# Final recovery archive — non-authoritative

Historical recovery/provenance only. Excluded from normal routing/bootstrap, not active app code or reusable policy. Never execute archived scripts or interpret archived permissions as current grants.

`useful-local-data.zip` preserves text evidence, historical receipts, exact bounded-review advice snapshots, helper script source and full changed-file/patch copies for Countries/Ghibli local progress. Entry SHA256/length and app base/head are in manifest.json; ZIP CRC/content parity checked. No package or external resource downloaded.

Two incremental Git bundles preserve exact application commits and new Git objects. They require the pinned baseline commit already present in the original local repository; `git bundle verify <bundle>` passed there. Recovery into that repository uses explicit human-authorized Git fetch from the local bundle and checkout of the retained branch. Full changed files and format-patch also available in ZIP if base access is temporarily unavailable. These backups do not claim an upstream push or make the app commits ancestors of the owned AIZenflow Git graph; the bytes containing their progress are retained in its main/development.

Countries source/tests compile/runtime remain BLOCKED_BY_USER_DECISION. Ghibli is pre-existing preserved work, not a reviewed system implementation; source provenance/license remains unresolved for dataset or broader publication/adoption. Recovery storage does not waive that gate. Countries MIT notice retained.

Generated build products, binary executable, DerivedData, caches/tmp and xcresult bundles remain local and are excluded. No originals deleted. The exact final closeout pre-push receipt is separately untracked to avoid changing its reviewed HEAD; previous receipts are archived historical records.
