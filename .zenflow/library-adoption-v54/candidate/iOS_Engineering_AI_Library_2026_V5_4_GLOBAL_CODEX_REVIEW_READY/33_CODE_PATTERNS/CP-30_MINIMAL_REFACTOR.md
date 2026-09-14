# CP-30 — Characterize → refactor → compare

Safe sequence:
1. Add/identify behavior tests around the boundary.
2. Capture baseline metric if performance-sensitive.
3. Move one responsibility or dependency at a time.
4. Keep public contract stable unless change is intentional.
5. Run tests after each coherent step.
6. Review the final diff for accidental semantic changes.

A smaller diff is easier to prove correct than a cleaner-looking rewrite with no behavior evidence.
