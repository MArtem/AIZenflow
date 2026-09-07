# 25 — Legacy Projects and Modernization

## Do not modernize incidentally

A feature/bug fix in a legacy project MUST NOT automatically:

- switch Swift language mode;
- replace ObservableObject with Observation globally;
- convert UIKit to SwiftUI;
- replace callbacks/GCD with async/await everywhere;
- replace persistence/network stacks;
- upgrade deployment target;
- reformat the repository.

## Incremental approach

When modernization is desired:

1. inventory current toolchain and constraints;
2. establish tests/baseline first;
3. migrate one module/boundary at a time;
4. enable stricter concurrency checking incrementally if full Swift 6 migration is not yet possible;
5. preserve behavioral compatibility;
6. separate mechanical and semantic changes where possible.

## Bridging

Legacy callbacks/delegates can coexist with structured concurrency. Continuations must resume exactly once; cancellation behavior must be designed rather than assumed.

## Exceptions

Temporary compatibility tools such as `@preconcurrency import` require an owner/reason/removal condition so they do not become permanent invisible debt.
