# Change Risk Matrix

| Риск | Примеры | Обязательные меры |
|---|---|---|
| R0 | rename/local cleanup | build/static check |
| R1 | локальная бизнес-логика/UI | unit tests + target build |
| R2 | networking/persistence/navigation/concurrency/public API | integration + negative path + blast radius |
| R3 | Swift 6/module architecture/schema/security/CI migration | staged plan + regression + observability + rollback |
| R4 | destructive data/payment/auth/public SDK compatibility | explicit migration proof + containment + rollout + manual review |

## Risk multipliers
Повышай класс минимум на один, если:
- нет automated tests;
- third-party binary SDK;
- offline writes/user-generated data;
- background execution;
- multi-target shared code;
- Objective-C/C interop;
- concurrency escape hatch;
- app extension/watch/widget shares store/keychain;
- release непосредственно перед submission.
