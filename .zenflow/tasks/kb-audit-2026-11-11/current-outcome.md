# Аудит КБ — итог текущего прохода на 2026-11-23

Каноническая база `documentation-vault` завершила этот блок коммитом `83644352cf19fc13242f140c23e192636c24ca9c` от `0f14065cdc34d2b17f81ddb27834798c5d19331b`. После push `git ls-remote` вернул тот же SHA для `origin/main`; canonical worktree чистый. KBN snapshot manifest обновлён на `8364435…` и `--check` прошёл. `knowledge-base-next` не коммитился и не пушился; весь существующий dirty state сохранён.

**Завершено:** активный reusable scope (общие правила, prompts, skills и выбранные package/SDK owners); bounded Phase 2 для восьми app boundaries и 35 текущих активных Markdown-файлов (~4,900 строк). Структурно проверено 73 распознанных относительных ссылки без missing целей. Исправлять app routing, переносить app-owned правила в reusable или удалять архивные дубликаты не потребовалось. 83 страницы PDF концептуально сопоставлены с действующими reusable owners; текст PDF в KB не переносился. Полный повторный семантический аудит всех архивов не заявляется.

**Новые проверки 2026-11-21:** два существующих synthetic scanner suites — 24/24 PASS из disposable копии; полные запуски static-gate launcher на чистом synthetic commit `9567ee5ab53640be4385815bdad8474e1f01360a` выдали по 8 квитанций с единым точным SHA, clean worktree и неизменным HEAD. `Sources`: 8 PASS; `Tests`: 5 PASS и 3 NOT_APPLICABLE. Отдельно проверены новый app-root token, отличный selector alias и fail-closed invalid UTF-8 manifest. Все scratch удалены. `check_documentation_vault.py`, `generate_manifest.py --check`, boundary checker и `git diff --check` прошли. Локальный `PACKAGE_SNAPSHOT_MANIFEST.json` обновлён и прошёл `--check` на canonical SHA.

**Reusable follow-up 2026-11-22/23:** Stage 4 завершён для пяти общих scanner gates и KBN mirrors: collectors считают severity до cap; receipt JSON содержит точные full/omitted severity totals, а advisory учитывает скрытые warnings. Canonical suite прошёл 8/8 на canonical scripts, KBN candidate suite — 16/16 на текущих KBN scripts; capped CLI, collector и пять synthetic parser scenarios проверены, тесты не менялись. Один прогон legacy baseline suite на KBN scripts выявил единственное ожидаемое расхождение: старый тест ждёт `[review-candidate]`, а KBN намеренно выдаёт `[warning]`; это не зачтено как PASS. Исправлены четыре stale ссылки reusable baseline index; `check_docs_index.py` — 34/34, документационная consistency/vault/manifest проверки прошли. Canonical commits `07d9dc8` (scanner/index), `3752e66` (AppValidationCore docs) и `0f14065` (plan dispositions) опубликованы; точный remote SHA подтверждён для последнего. Snapshot manifest проверен на `3752e66`; его structure/counts не изменились, обновлены canonical revision и content digests. Все disposable fixtures удалены.

**Продолжение аудита:** проверен migration ledger: 1 403 исходных записи, 4 285 уникальных units, все записи имеют `REVIEWED`, активные покрытые/перенесённые units не остались без canonical owner. Это подтверждает старый полный mapping review, но не новое построчное чтение каждого исторического архива. SHA-256 сверка 20 внешних групп нашла 11 точных совпадений с текущими локальными skill/plugin cache-файлами; лицензии старых bundle и права на знаки этим не установлены. Отдельно подтверждено, что commit `14045eb` убрал 71 файл ограниченного documents skill из текущего дерева, но его предок `768b8b7` сохраняет эти файлы в опубликованной истории. Условие LICENSE запрещает хранение вне Services. Force-push/переписывание истории не выполнялись.

**Остаётся открытым:** права, file-level license applicability, trademarks и remote distribution для внешних материалов остаются UNKNOWN; это не clearance. Независимая adjudication 51 route labels завершена без изменения активного router. Пользователь решил сохранять опубликованную историю без rewrite/deletion; restricted documents payload исключён из текущего дерева, task routes и bootstrap fallback. Zenflow Assistant service fallback остаётся UNKNOWN; опасный локальный API trace helper, PDF rights/validity, AI Fieldbook `1.26-S`/P1/runtime compatibility остаются отдельными follow-ups. AppValidationCore остаётся fail-closed и `UNAVAILABLE`; восстановление требует отдельно разрешённого lifecycle scenario. Исторический ledger reuse не считается новым чтением всех 4 285 фрагментов.

Не запускались app builds/tests/runtime, package verifiers, Simulator, Instruments, app-network, сервисы, сообщения или память. Один read-only reviewer был запущен после предварительного сообщения пользователю о цели и пользе; перед будущим использованием агентов сообщать пользователю заранее. Canonical diff из трёх task docs reviewed; P0–P2 в этом блоке не обнаружены. Passed: vault 5,055 files/8 boundaries, index 34/34, consistency, boundaries, canonical generated-manifest check, JSON parse, `git diff --check`, route resolver 35 IDs/94 required/2 optional/zero errors; remote SHA exact. KBN package snapshot manifest targets `8364435…` and `--check` passed. KBN не коммитился; dirty state сохранён. iPad, physical devices and actual VoiceOver remain `OMITTED_BY_USER`, never PASS.

## Предыдущая запись — состояние на 2026-11-20 (сохранена; актуальные статусы выше)

Каноническая база: `documentation-vault`, опубликованный и подтверждённый `origin/main` —
`f1b0d729b59d782ac4b380a8e892647eeb0f0d3c`. Общий маршрут остаётся единым; бывшая Library
сохранена как история, а не обязательный проход. Выборочные смысловые сверки восьми проектных
границ, основных доменов Library, исторического экспорта и всего извлечённого текста PDF
зафиксированы в отчётах канонической задачи. Это не независимая полная переоценка всех 4 285
исторических единиц и не проверка каждого архивного документа.

Общая reusable-фаза текущей задачи закрыта и опубликована коммитом `f1b0d729b59d782ac4b380a8e892647eeb0f0d3c`; `origin/main` подтверждён на том же SHA. В этот проход проверены активные общие правила, маршруты, prompts, skills, package-ownership и SDK-creation guidance. Это не утверждение о полной семантической проверке всех архивов и исходного кода пакетов.

Исправлены подтверждённые противоречия и пути, опасный HTTP trace и двусмысленности доказательств,
синхронизации, разрешений и проектных решений. Пользователь выбрал для AI Fieldbook iOS 18.2;
текущие проверенные настройки соответствуют этому выбору, но совместимость не доказана.
Историческое разрешение AI Fieldbook на Simulator 26.5 больше не обозначено как текущее;
исключённый физический gate не восстанавливается при появлении устройства.
Навык платформенных возможностей теперь учитывает исключённые проверки и требует действующего
разрешения на runtime, сборку, тесты и проверки сервисов.
В архиве MVVMExample отмечены унаследованные ссылки на Tchop как исторические, не действующие
правила проекта; исходный исторический документ сохранён.
Исторический onboarding Tchop и планы Tchop/MVVMExample прочитаны полностью; устаревшие
описания auth, trace и исходные предположения demo явно помечены в архивных указателях.
Полностью прочитаны старые handoff, два архивных плана, инструкция тестирования и описание
пакетов Tchop; старое удаление хранилища и неверное приравнивание trace к вызову приложения
помечены как исторические и не являющиеся разрешением или доказательством.
Пакетный чек-лист и соседние стандарты согласованы с запретом `@unchecked Sendable`,
ограничениями проверок и фактическим отключением просмотренных verifier-шаблонов.
Навыки проверки ввода, диагностики, доступности, QA, lifecycle и стратегии тестирования
согласованы с пользовательскими исключениями; навык профилирования учитывает более строгие
границы конкретной задачи и технического sandbox.
В коммите `9fbfaba` зафиксирована асинхронная граница Swift Testing `confirmation` со ссылкой
на Apple. Дополнительно полностью прочитаны длинные архивные карты, правила и план Tchop;
старые model/tool/build/test требования остаются только в неавторитетной истории. Полный старый
`ALL_DOCUMENTS_INVENTORY.md` и другие архивы ещё не прочитаны.
Прочитаны все 30 текущих iOS skill entrypoint и 10 обёрток внешних материалов. Все 10
вложенных `references/apple-source/SKILL.md` переименованы в `APPLE_SOURCE_REFERENCE.md`
с сохранением байтов; канонический bootstrap, два канонических дерева skills и активное
worktree-зеркало согласованы. Статический поиск больше не находит вложенных `SKILL.md`.
Перезапуск каталога клиента не наблюдался; лицензии/происхождение материалов и полная
актуальность API остаются неизвестны. SDK 27 календарные ярлыки сверены с Apple; подтверждено
расхождение в календарной формулировке, а не доказанная ошибка одного источника.

Небезопасные SDK-шаблоны и подтверждённые пути очистки package-verifier выведены из обращения
отказом; соответствующие изменения в двух проектных worktree не закоммичены. По 68 локальных
package-verifier в каждом worktree недоступны до безопасной замены. Статические снимки содержимого
пакетов синхронизированы с ревизией `8ff0dd4c45800cdbeff2390f68d1a93417d0a719`; они не подтверждают тесты или безопасность.
Оба локальных `scripts/verify.sh` также отключены до безопасной замены.

Открыто: безопасная замена verifier и её сценарная проверка (выполнение тестов сейчас запрещено);
права и дальнейшая судьба 20 сторонних файлов вне КБ и одного ранее отслеженного исторического
entrypoint в КБ; сквозная проверка сканеров, их лимиты и автоматическое обнаружение новых имён
проектов; локальные API trace helper с выводом чувствительных данных и системными временными файлами; runtime/fallback MVVMExample и Zenflow Assistant; качество поиска; отдельные смысловые,
источниковые и лицензионные вопросы PDF; не пересмотренные архивные документы. AI Fieldbook
`1.26-S`, P1 и фактическая совместимость на 18.2 остаются отдельными открытыми вопросами.
Отдельный риск — обнаружение вложенных Apple-source файлов как самостоятельных навыков:
правило bootstrap ограничивает интерпретацию, но не удаляет записи каталога и не доказывает
порядок загрузки в будущей сессии.

В этом продолжении не запускались сборки, тесты, Simulator, приложения, app-network checks или физические устройства; ранее разрешённые отдельные синтетические проверки сканеров сохраняют свою историческую область. iPad, физические проверки и фактический VoiceOver — `OMITTED_BY_USER`, не PASS. Проверены
AST трёх изменённых Python-скриптов, `bash -n` 64 изменённых shell-скриптов, canonical parity, vault/bootstrap/router/knowledge/boundary checks и `git diff --check`. Remote-state checker прошёл после публикации; текущий локальный package snapshot manifest обновлён и проверен на опубликованном SHA.
Проектный worktree не коммитился и не пушился; существовавшие изменения сохранены.

## Продолжение аудита — 2026-11-25

Завершена сверка оставшегося shared-export archive: 120 файловых путей сгруппированы в 107 уникальных SHA-256 payloads. Полная матрица по каждому SHA, текущему owner и disposition находится в canonical отчёте `documentation-vault/tasks/kb-audit-2026-11-11/shared-export-semantic-reconciliation-2026-11-25.md`. Итог: 92 covered, 11 obsolete, 2 no incremental value, 2 payloads выявили один общий gap. GAP исправлен: always-loaded `reusable/baseline/AGENTS.md` теперь требует полноты существенных concerns в аудитах и планировании, при этом явно удерживает реализацию в утверждённых границах; `AGENTS.template.md` согласован.

Canonical Documentation Vault опубликован коммитом `d6bd1cd01cd48012238e86f023809dc2e0e665bc`; `origin/main` вернул тот же SHA, canonical worktree чистый. Проверки прошли: docs vault (5,056 файлов, 8 app boundaries), индекс 34/34, consistency, boundaries, bootstrap contract для KBN, generated manifest, `git diff --check`, матрица совпадает с исходным inventory (107 SHA/120 путей). KBN `PACKAGE_SNAPSHOT_MANIFEST.json` обновлён на этот commit и его `--check` прошёл. KBN не коммитился и не пушился; весь прежний dirty state сохранён.

Этот результат закрывает конкретный 120-файловый архив и текущий документально-статический план; он не означает свежий построчный reread 4,285 ledger units, правовую/лицензионную очистку исторических материалов, внешнюю проверку актуальности API или runtime validation. iPad, physical devices и actual VoiceOver остаются `OMITTED_BY_USER`, никогда не PASS. Никакие архивные скрипты, сборки, тесты, Simulator, runtime или package verifiers не запускались.

## Публикационная квитанция reusable-фазы — 2026-11-20

- Диапазон: `8ff0dd4c45800cdbeff2390f68d1a93417d0a719..f1b0d729b59d782ac4b380a8e892647eeb0f0d3c`; `main` и `origin/main` равны опубликованному HEAD, canonical worktree чистый.
- Контракт изменений: reusable prompts не навязывают deployment target; пакетные templates не создают тесты без явного разрешения; общая package-документация отделяет выбранный mirror от точного исходника и факта verification; встроенные Apple references не регистрируются как самостоятельные top-level skills; boundary checker выводит app-имена из текущих manifests и ошибается закрыто на unreadable/invalid UTF-8 входах.
- Review: после финального diff review blocking P0–P2 defect в опубликованном патче не выявлен. Изменения отключили опасные просмотренные verifier paths отказом там, где безопасное владение cleanup не было доказано; восстановление функциональности отдельно не проектировалось.
- Проверки: `git diff --check` до commit и exact range после него; `check_documentation_vault.py`; bootstrap/router/iOS-knowledge и boundary validators; AST трёх Python-скриптов; `bash -n` 64 shell-скриптов; 53 prompt, 37 SDK-doc и 123 skill mirror; 10 Apple reference hash pairs; remote-state checker после push; текущий package snapshot manifest `--check`.
- Не выполнялось: builds, test suites, package verifiers, Simulator/UI, app runtime/network, физические устройства и actual VoiceOver. Их отсутствие не обозначено как PASS.
- Остаточный риск: права/происхождение imported reference material, полный API freshness и реальная skill-catalog rediscovery не подтверждены; safe verifier replacement, behavioral checks, source-code/package semantic review и все 4 285 historical items не входят в это завершение.

## Итоговая квитанция завершения плана — 2026-11-23

Документально-статический scope завершён. Canonical commit `c27bfd037914edd301076c3c20d2297d3d6956af` опубликован поверх `83644352cf19fc13242f140c23e192636c24ca9c`; `origin/main` сверён по точному SHA, canonical worktree чистый. Основной и смежный планы не содержат открытых чекбоксов; завершённые dispositions не превращают `UNKNOWN`, `UNAVAILABLE`, `NOT_RUN` или `DEFERRED` в PASS. KBN package snapshot manifest обновлён на `c27bfd0…` и проходит `--check`; KBN не коммитился и не пушился, прежние локальные изменения сохранены. Финальные статические документационные checks прошли; build, tests, Simulator, runtime, package verifiers, services, messages и memory не запускались/не открывались. Права и непроверенные copies, часть исторических архивов, PDF provenance/technical validity и service/runtime behavior остаются неизвестными. Для активного продолжения используйте `handoff.md`; прежний подробный текст handoff сохранён в `archive/handoff-before-final-disposition-2026-11-23.md` как неавторитетная история.

## Продолжение reusable-аудита — 2026-11-24

Закрыто конкретное противоречие в `docs/documentation-split/README.md`: строка называла неполный исторический `reusable/` каталог действующей iOS-базой, хотя там остались только external-environment assets/scripts. Теперь README запрещает практическое использование/перенос этого содержимого и оставляет права `UNKNOWN`. `docs/REUSABLE_BASELINE_POLICY.json` задаёт `documentation-split/**` как local-only; read-only поиск не нашёл старый export в canonical bootstrap/router/skill entrypoints. Все 20 retained files совпадают с inventory по SHA-256 и mode (`20/20`). Файлы и Git-история не удалялись и не перемещались. Проверка — `git diff --check`; build/tests/runtime не запускались. Это точечная граница архива, не заявление о полном семантическом аудите всех исторических материалов.
