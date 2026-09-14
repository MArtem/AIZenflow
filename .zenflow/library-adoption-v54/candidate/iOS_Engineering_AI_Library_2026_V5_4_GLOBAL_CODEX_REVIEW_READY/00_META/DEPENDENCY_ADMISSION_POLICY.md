# Dependency Admission Policy

Before adding a dependency, answer:
1. What problem cannot be solved reasonably with system APIs/existing dependencies?
2. Maintenance cadence and ownership?
3. License?
4. Swift 6/concurrency readiness?
5. Minimum platforms?
6. Binary/build size impact?
7. Transitive dependencies?
8. Privacy manifest/data collection/tracking domains?
9. Security history and update path?
10. Exit strategy / wrapper boundary?

For listed third-party SDKs subject to Apple privacy-manifest/signature requirements, verify compliance before release.

Default: do not add a dependency for convenience-only syntax when platform APIs are sufficient.
