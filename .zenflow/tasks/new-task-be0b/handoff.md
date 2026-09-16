# Handoff — приёмка библиотеки для Luna Xhigh

Task new-task-be0b, 2026-09-16; режим эконом. Исполнитель Luna Xhigh.

## Начало

Применить canonical bootstrap и текущий Level 0. Затем читать plan.md и
[luna-final-acceptance-runbook.md](luna-final-acceptance-runbook.md): это актуальная
последовательность, включая конкретные задачи приложений и нейтральные first-entry prompts.
Не передавать сам runbook в новую first-entry задачу: он подсказывает ожидаемые инструкции.

## Статус

Astra follow-up выявила и Luna исправляет два harness-дефекта: manual test больше не зависит от
позиции bash-блоков, а rollback test принимает явный `IOSLIB_LEGACY_ARCHIVE` при сохранении SHA.
R3 всё ещё `BLOCKED_ENVIRONMENT`: положительный `.6` round trip требует разрешённого root вне
Git boundary. Свежий suite после follow-up ещё должен быть выполнен.
Evidence: `../../library-adoption-v54/evidence/final-acceptance/final-acceptance-summary.md`.
Fresh-entry остаётся `NOT_RUN`, потому что saved-project catalog не содержит три downloaded pilot
roots. Ghibli source diff есть, но он выполнен до доказанного first-entry observation. Firefox и
Countries остаются read-only; Countries получил подтверждённый P2 cancellation finding.
Новые plan/handoff/evidence правки локальные до следующего commit/push.

## Проекты и задачи

Корень /Users/Artem/.zenflow/library-acceptance-projects:
- GhibliSwiftUIApp @ 524c434882dcc22d95b1c5781f295d8fbfe0ced6: кнопка Retry в Movies error state.
- firefox-ios @ 0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071: read-only review поисковых подсказок.
- clean-architecture-swiftui @ 9eca97b8cfff96a14084b564b1fefd949c93d232: read-only сеть/DB/UI страны.
Три depth-1 clone занимают около 348 МиБ, без зависимостей/сборок; upstream source не менялся.
Astra прочитала только материал для выбора задач, не выполняла сами пилоты.
Firefox имеет upstream AGENTS.md; остальные два — без него. Наш bootstrap не добавлен;
adoption отложен до наблюдения first-entry. Не объявлять PROJECT/GUIDED entry автоматическим.

## Границы

Сначала library R1–R3, затем host→fresh-entry→pilots→final release. Независимые проверки
продолжать при недоступности host. Не переносить диагностику и сбор всех receipts на пользователя.
Все локальные данные внутри .zenflow; внешние host files только по точной authority.
Library tests и T/V commits/push разрешались ранее; app test-writing/runs/Xcode/Simulator,
зависимости и upstream commits/push этим не разрешены. Новых задач сейчас не создавали.
Проектная реализация Ghibli завершена в bounded static scope Luna; app build/UI verification
не выполнялась согласно runbook. Upstream project commits/push не делать.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
