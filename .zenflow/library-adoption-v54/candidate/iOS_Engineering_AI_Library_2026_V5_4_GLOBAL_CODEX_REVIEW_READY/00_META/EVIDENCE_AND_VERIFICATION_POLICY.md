# Evidence & Verification Policy

## Уровни evidence
- **E0 — hypothesis:** предположение, ещё не проверено.
- **E1 — static evidence:** код/configuration/docs показывают контракт.
- **E2 — compile evidence:** relevant target успешно собирается.
- **E3 — test evidence:** targeted automated test подтверждает поведение.
- **E4 — runtime evidence:** repro/device/simulator/log/instrument подтверждает runtime behavior.
- **E5 — production evidence:** telemetry/MetricKit/crash-free/rollout metrics подтверждают результат в реальных условиях.

## Соответствие утверждения evidence
- «Компилируется» → минимум E2.
- «Баг исправлен» → E3, а для runtime-only проблемы предпочтительно E4.
- «Нет race» → compiler isolation/strict concurrency + relevant test/TSAN where meaningful; отсутствие TSAN warning само по себе недостаточно.
- «Нет memory leak» → lifecycle repro + Memory Graph/Allocations or deinit evidence.
- «Быстрее» → before/after measurement с одинаковым workload.
- «Миграция безопасна» → fixture from previous schema + migration test + failure/rollback story.

## Verification before explanation
Если агент может выполнить build/test/search, он делает это до финального заявления. Объяснение не заменяет проверку.

## Negative-path requirement
Для boundary-кода минимум один negative path:
- timeout/HTTP error;
- malformed data;
- cancellation;
- permission denial;
- migration failure;
- unavailable API;
- storage full;
- background interruption.
