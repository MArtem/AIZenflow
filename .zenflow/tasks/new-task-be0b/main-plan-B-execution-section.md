## 13. Основной план B: реализация и приёмка раздельно

Принят пользователем 2026-10-03 вместе с предложениями review. S0–S12 сохраняются
как идентификаторы прежних требований/областей, а порядок оставшейся работы задают
W1–W5 ниже. Единственный основной план — этот файл; local plan/handoff — краткие
execution pointers. Архив старого плана — recovery, не конкурирующий authority.

### 13.1. Как оценивать каждый дискретный пункт

У leaf-пункта один наблюдаемый output и отдельная проверка/критерий в строке ниже.
Checkbox закрывается только для указанного output/scope. Не переносить его на весь
этап, другой проект, runtime или release. В task packet фиксировать фактический
результат, source/dirty identity, проверку, reused/not_run evidence и remaining gate.
Оценка качественная: выполнен критерий / не выполнен / требуется конкретная evidence
или решение. Пользоваться существующим governance vocabulary, без нового evaluator.
Планирование, написанный контракт, статическая проверка и наблюдённая приёмка —
отдельные факты; общий процент «готовности» из числа галочек не вычисляется.

Каждый подпункт наследует зависимости, authority, owner и bounds своей группы.
Если новые факты меняют их, обновить affected plan до зависимого продолжения.
Общий owner — integrator; user владеет product/verification choices и manual QA.
MODEL_ROUTING_RULE действует перед каждым значимым блоком. Один source-блок ≤3 файлов;
более широкий блок требует существующего scope/budget checkpoint. Не дробить работу
до отдельных поисков/команд ради числа пунктов: leaf закрывает полезный результат.

### 13.2. Пять групп и S-мapping

| Группа | S-области | Зависимость и результат | Критерий завершения |
|---|---|---|---|
| W1 — актуальный контракт/статус/evidence | S0–S3, preparation S12 | Текущие R01–R21, history, матрица gaps, truthful task state | Все требования связаны с механизмом/evidence/remaining gate; утраченное/выдуманное evidence отсутствует |
| W2 — общие механизмы | S2–S3, S7–S10 | W1; один packet, verification choice, scope guard, recovery/modes/freshness | Документальные механизмы согласованы/статически проверены; наблюдённая acceptance выделена в W3/W4 |
| W3 — первый сквозной пилот | S4–S11, один exact project | W2 и отдельные необходимые execution choices | Named scenario прошёл preparation→bounded change→permitted verification→memory→new-chat resume; omissions видимы |
| W4 — переносимость | S5/S9/S11, иной consumer graph | W2; полный final verdict после W3 | Shared consumers/другая структура и required negative cases имеют scoped evidence; нет app-backlog expansion |
| W5 — решение о готовности/эксплуатация | S12 | W3/W4 и актуальные identities | R01–R21 имеют disposition; core workflow/library/app verdicts раздельны, ограничения и user guide применимы |

S5/S6 — scope-appropriate анализ/аудит, не обязательный whole-project audit перед
каждой task. Непонятые affected flows/risks всё равно требуют анализа до изменений.
S9 KB cycle обязателен всегда; approved ON добавляет layer, OFF не требует adoption.
S10 review/evidence/memory применяется к каждому meaningful block с начала работы.
S11 наблюдает интеграцию реализованных W2 механизмов; его evidence не является
предусловием написать эти механизмы. W4 intake/preparation может идти при user-owned
W3 gate, но полной приёмки W3 не заменяет. Старые completed outputs переиспользуются
только в их recorded scope/identity; никто не запускает этапы заново ради нового номера.

### W1. Контракт и актуальность основного плана

Bounds: task/recovery docs и existing evidence, без app source/runtime/mode изменения.
Checks: complete owned diff, ссылки/R-ID coverage, exact archives, current fingerprints;
new tests/build/Simulator/device здесь не применимы. Последующее исполнение отдельное.

| Leaf | Output | Проверка / условие закрытия |
|---|---|---|
| [ ] W1.1.a | Принятые 8 предложений review сохранены | Решение B, цель, non-goals и owners явно записаны; не только ссылка на чат |
| [ ] W1.1.b | Старый основной план сохранён целиком | Byte-identical archive + SHA-256, текущий файл не теряет R01–R21 |
| [ ] W1.1.c | Pre-existing local/canonical plan/handoff сохранены | Все четыре exact snapshots доступны; roadmap/foreign source untouched |
| [ ] W1.2.a | Текущие permissions/model/source state едины | Human grants отделены от memory; no expired build replay, no inherited ON |
| [ ] W1.2.b | Устаревшие current statements устранены | Compile PASS и завершённый S1 совпадают с receipts; history отдельно |
| [ ] W1.3.a | R01–R21 связаны с реализацией и evidence | Для каждого ID есть механизм, scope проверки и remaining gate/owner |
| [ ] W1.3.b | Реализация и наблюдённая приёмка разведены | Documentation/static PASS не становится runtime/end-to-end PASS |
| [ ] W1.4.a | Зависимости S0–S12/W1–W5 определены | Нет обязательного whole audit для мелкой task или ON для OFF workflow |
| [ ] W1.4.b | Краткие active plan/handoff обновлены | Один main-plan pointer, актуальный next step, current grants и open risks; ≤3500 words |
| [ ] W1.5.a | Финальный W1 diff и сохранность проверены | Нет потери foreign edits/requirements; static checks actual results recorded |
| [ ] W1.5.b | Canonical W1 опубликован | Exact reviewed HEAD, trusted base/clean state, remote SHA receipt; не self-SHA loop |

### W2. Общие механизмы без развития пилотов

Bounds: existing workflow/template/task state; никакого backend/нового verifier.
Документальные outputs проверяются static/semantic review; execution/fault/mode
acceptance не закрывается формулировкой контракта и идёт в W3/W4 с user choice.

| Leaf | Output | Проверка / условие закрытия |
|---|---|---|
| [ ] W2.1.a | Одна compact task-card в existing template | Goal/acceptance, identity/freshness, consumers, risks, choices, contract/blocks/checks/evidence/next action вместе |
| [ ] W2.1.b | Plan/action table/memory ссылаются на card | Нет обязательных дублирующих reports или чтения всех docs для одного действия |
| [ ] W2.2.a | Analysis→choice→plan→decomposition→plan-review contract | Маленькая task может иметь один block; critical ambiguity не скрыта default |
| [ ] W2.2.b | Verification menu до implementation | Test writing/modification, build, tests, Simulator/device/static независимы; applicability/recommendation/limits показаны |
| [ ] W2.2.c | User selection и grant semantics однозначны | Precise explicit choice — grant; proposed ≠ performed; лишний повтор permission отсутствует |
| [ ] W2.2.d | Сопоставление проверок и claims | Minimum adequate recommendation + omitted-risk; no compile→UI или Simulator→device inference |
| [ ] W2.3.a | Достаточный task analysis/full-audit boundary | Affected-source/consumer coverage обязательна; whole-project claim требует соответствующей coverage |
| [ ] W2.3.b | KB-first и ON delta без ritual duplication | Один compact result в card на meaningful stage; unchanged exact advice reused, OFF cycle полный |
| [ ] W2.3.c | Multi-project mode/permission boundaries | Каждый consumer имеет exact scope; ON одного не активирует другого |
| [ ] W2.4.a | Permission failure/revocation/retry contract | Missing/denied action withheld; partial/failed actual state перед retry; expired grant не повторяется |
| [ ] W2.4.b | Environment/operator preflight | Declared roots, toolchain/runner/sandbox compatibility и user/agent operator до execution; no unauthorized probe |
| [ ] W2.4.c | Freshness/dirty/conflicting-memory protocol | Changed dependencies revalidated, foreign edits/decisions сохранены, timestamps alone не proof |
| [ ] W2.4.d | New-chat/detach recovery protocol | Exact scope/next step и startup reread; restore не восстанавливает grants/mode |
| [ ] W2.5.a | Scope-drift gate до и после block | Link к R-ID/system question, smallest action, authority/bounds, new evidence и exit проверяются |
| [ ] W2.5.b | Repeating-loop/low-value disposition | Scope expansion остановлен, known candidate P0–P2 не waived; fix/decision/backlog распределены честно |
| [ ] W2.6.a | Требования и complete final diff согласованы | Ссылки/template/action consumers и R19–R21 parity проверены; whole changed candidate reviewed |
| [ ] W2.6.b | W2 документальные outputs опубликованы | Exact-HEAD/remote receipt, acceptance gaps перенесены явно, no global ready claim |

### W3. Первый сквозной пилот — BattleshipGame

Exact selector BattleshipGame/BattleshipGame.xcodeproj в knowledge-base-next.
System question: связывает ли workflow fresh context/choice/owned diff с honest
verification, memory и resumed task без лишней app development? Existing BG-T01 A
и compile PASS переиспользуются в exact scope; BG-A01 interaction gate остаётся.

| Leaf | Output | Проверка / условие закрытия |
|---|---|---|
| [ ] W3.1.a | Fresh pilot identity/dirty receipt | Relevant hashes/selector/pin/grants совпадают; source PATCH не replay |
| [ ] W3.1.b | Bounded pilot card и exit criterion | Only BG-T01/system question; no localization/icon/performance backlog execution |
| [ ] W3.2.a | Current analysis/alternatives/plan review | A already selected; R19/R21 contract applied prospectively, historical absent step не выдуман |
| [ ] W3.2.b | Verification choice до следующего исполнения | Present existing compile PASS/reuse and independent test/UI/device options; actual user selection recorded |
| [ ] W3.3.a | Source/final diff review | Existing one-file A patch/current consumers checked; new source only for grounded blocker/accepted correction |
| [ ] W3.3.b | Narrow/wide/resized/scroll scenario evidence | All board rows/columns reachable and no ambiguous selection under selected environment/operator |
| [ ] W3.3.c | Gameplay/accessibility scenario evidence | Placement/rotate/start/fire/reset, Dynamic Type/VoiceOver results recorded, omissions remain open |
| [ ] W3.4.a | Memory/finding disposition refreshed | BG-A01 closes only from sufficient evidence; failure returns to bounded correction/decision |
| [ ] W3.4.b | Actual resumed-context observation | New chat/authorized observer reconstructs current scope/constraints/next step from canonical sources; same-session self-review not substitute |
| [ ] W3.5.a | Scoped canary receipt | Exact inputs/operator/evidence/omissions, no app release or library uplift assertion |

### W4. Второй consumer graph и общие adverse cases

Candidate TchopApp.xcodeproj: prepared structural intake, 8 targets, shared154 host
fileRefs. Delegated pilot use/owned registration authority available; no ON/test/runtime
inherited. Alternative project разрешён, если даст нужный graph с меньшим scope/cost.
System question — accurate shared-source/target memory и task consumer coverage.

| Leaf | Output | Проверка / условие закрытия |
|---|---|---|
| [ ] W4.1.a | Выбран самый малый подходящий pilot | Exact graph meets missing question; no artificial feature or arbitrary full app audit |
| [ ] W4.1.b | Fresh reviewed association/detach diff | Before hashes/foreign state checked; own additions only, no mode/profile activation |
| [ ] W4.2.a | Shared consumer/resource map | Affected source/resource→all shipping consumers; tests metadata separate, semantic scope explicit |
| [ ] W4.2.b | Real bounded task/card и user choices | Grounded accepted need, small output; отсутствующая legitimate task остаётся gap, не synthetic product feature |
| [ ] W4.2.c | Owned change и permitted verification | Appropriate checks для affected targets/resources, complete diff; no ungranted build/test/client Git |
| [ ] W4.3.a | OFF complete KB observation | Named task proceeds with first-layer preparation/review/memory; no library requirement |
| [ ] W4.3.b | ON/AUTO + ON/ADVISORY boundaries | Advice/useful delta actual scope, permission independence; reuse unchanged eligible receipts, no live transition by default |
| [ ] W4.3.c | UNKNOWN/invalid/ambiguous scope refusal | No ON, repair, fabricated identity/evidence; dependent uncertainty visible; fixtures only if authorized |
| [ ] W4.3.d | Different modes across consumers | Scope/cross-project permissions independent, shared change still covers every affected consumer |
| [ ] W4.4.a | Source change→freshness observation | Relevant fact/evidence invalidated and refreshed; other unchanged evidence reused |
| [ ] W4.4.b | Dirty/conflicting notes observation | Preserve human edits, fact-vs-decision conflict resolved from authority/source, no silent overwrite |
| [ ] W4.4.c | Denied/unavailable/partial/interrupted observation | Named action has actual result/withheld status, no repeated consumed grant/false success; prior BG failure/retry reused within scope |
| [ ] W4.4.d | Safe detach observation | Exact own entry removability and preservation; actual writes only when chosen, dry-run scope labelled |
| [ ] W4.5.a | Independent review decision | Need/benefit/risk and separate authority recorded; no auto agents, no self-review labelled independent |
| [ ] W4.5.b | Second scoped receipt и acceptance matrix | Each required case has exact evidence/gap/owner; synthetic tests never become real new-chat proof |

### W5. Решение о готовности и эксплуатация

| Leaf | Output | Проверка / условие закрытия |
|---|---|---|
| [ ] W5.1.a | R01–R21 final traceability | Each requirement has actual evidence and remaining gap/limitation; no checkbox percentage |
| [ ] W5.1.b | Core workflow verdict | Required named canaries/control cases complete or explicit bounded verdict; no silent narrowing of approved requirements |
| [ ] W5.1.c | Library verdict отдельно | LIB-004 remains OPEN unless its exact release criteria evidence/explicit requirement decision exists; core work не ждёт invented uplift |
| [ ] W5.1.d | App verdict отдельно | Pilot app's remaining findings/manual/release checks не становятся system PASS или закрытием app release |
| [ ] W5.2.a | Короткий user guide в existing workflow | Choose project→task card→approaches/check selection→bounded work→evidence→resume, без нового UI/service |
| [ ] W5.2.b | Maintenance/compatibility/invalidation | Named owners/events/review triggers and rollback/source precedence; no recurring automation |
| [ ] W5.3.a | Exact disposable cleanup decision | Only own proven outputs after useful receipts preserved; no broad root/user-state deletion |
| [ ] W5.3.b | Final diff/commit/remote receipt | Quality gates and current identities/permissions, no unresolved owned candidate P0–P2, exact remote SHA |
| [ ] W5.3.c | Bounded adoption proposal | Only supported scope after evidence; user chooses any expansion/Library activation/runtime/Git separately |

## 14. Scope guard — до и после каждого блока

В existing task card кратко ответить:

1. **Цель:** какой R-ID или accepted system question закрывается?
2. **Необходимость:** какая конкретная missing output/evidence оправдывает работу;
   можно ли переиспользовать существующий artifact/unchanged PASS вместо нового?
3. **Границы:** exact files/consumers/actions/owner/budget/end event остаются в grant?
4. **Польза:** какой новый проверяемый результат появится и какое exit criterion?
5. **После блока:** получен ли он, появились ли scope/failure contradictions;
   какая минимальная следующая работа реально нужна?

Нет обоснованного ответа → остановить именно expansion, сохранить actual result,
перенести unrelated idea в отдельный backlog/decision; продолжать independent allowed
работу. Новая high-risk ambiguity, повтор той же correction без новой evidence,
необходимость >3 source files или resource/scope change требуют reassessment/checkpoint.
No implementation theatre: не считать doc count, scans или количество skills прогрессом.
Current candidate P0–P2 требуют fix или explicit higher-authority exception; отсутствие
permission/evidence не закрывает их. Foreign app finding outside candidate остаётся OPEN
в app ledger и не блокирует unrelated truthful docs publication.

## 15. Финальная приёмка и дальнейшие специализированные сценарии

Обязательная текущая core matrix: W3 full cycle + W4 shared-consumer case, OFF full
first layer, approved ON profiles/UNKNOWN/different modes, freshness/dirty/conflicts,
withheld/failed/partial recovery, real resumed-context и safe detach within chosen scope.
Execution plan и permission для каждого case выбираются отдельно. No fabricated
production flaw, no automatic live transitions. Сначала reuse actual unchanged receipts,
новые проверки только при новом missing integration evidence/risk.

Figma, standalone packages, migrations/concurrency, CI/signing/device-specific release
и дополнительные platforms остаются task-relevant routes. Current core canaries не
доказывают их end-to-end acceptance. Любая заявленная поддержка сохраняет explicit gaps;
расширение release claim требует corresponding evidence или user-approved bounded scope.
Не удалять эти исходные requirements ради удобного PASS.

Метрики доступны только фактически: context reload/rework/actionable fixes/false positives,
unauthorized actions/false PASS, elapsed/tokens where observed. Unknown telemetry остаётся
unknown; bytes/tool calls не конвертируются в subscription savings. Нет обещания нулевых
ошибок навсегда или измеренного library uplift. Общий release не объявлять по двум
успешным сборкам или наличию этого плана.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**
