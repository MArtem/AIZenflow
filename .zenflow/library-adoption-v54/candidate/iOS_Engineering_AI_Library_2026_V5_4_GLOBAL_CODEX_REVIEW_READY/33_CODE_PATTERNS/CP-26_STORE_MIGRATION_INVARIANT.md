# CP-26 — Migration tests assert semantic invariants

A useful migration test does more than "open store successfully". Given a fixture created by version N, after migration assert:
- stable IDs remain stable;
- required records remain present;
- relationships/counts satisfy domain rules;
- defaults are correct;
- no duplicate records were created;
- critical user-visible values preserve meaning.

Keep fixtures for every upgrade path the product promises to support.
