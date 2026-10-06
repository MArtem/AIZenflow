# V2: контракт слоёв и подготовка первого проверочного блока

2026-10-07. GPT-6.1 Sol/medium; эконом. Task design/evidence, не новая reusable норма.
V2 принят пользователем в ответе на P1.2. P1.2 ACCEPTED_SCOPED; P1.3 ACCEPTED_SCOPED как контракт дизайна. P2.1–P2.4 IN_PROGRESS/PENDING, полный dataset и независимая проверка не готовы.

## 1. Контракт V2

| Слой | Владелец и контракт | Что получает потребитель | Invalidation и failure |
|---|---|---|---|
| KB | Canonical bootstrap/baseline; mandatory authority, invariants, quality gates | Текущая обязательная норма по route | Смена user authority немедленно; missing authority блокирует зависимое действие; stale mirror не подменяет canonical |
| Library | Canonical reference-copy-only; applied mechanisms, примеры/контрпримеры | Короткий релевантный модуль до конкретного инженерного решения, детали по ссылке | Версия/инвариант/компилятор изменены — revalidation; missing optional material явно ограничивает claim |
| Project memory | Exact app/task boundary и project identity | Проверенные факты root/SHA, state owners, targets, grants, evidence | Root/SHA/consumer изменены — revalidate; никакого inherited ON/PASS |
| Delivery | Существующий router/entrypoint, без нового service | Выбранная тема, версия, момент получения, причина применения/отказа | Не дошёл до материала — delivery failure; не исключать из C outcome |
| Evaluation | Task protocol и oracle отдельно от implementation payload | Парные outcomes, FP/rework/cost, полный ledger | Leakage/смена версии/несимметричные tools — нарушение протокола; UNKNOWN не PASS |

Нормативный owner не переезжает в Library. Уникальные полезные нюансы нынешних маршрутов сохраняются до parity review. Mode handler, project key, status schema и host configuration для первого прототипа не меняются. Baseline A сохранён в published Git + hashes; новые live ссылки не могут менять A незаметно.

## 2. Три темы первого цикла

1. **Cancellation и stale publication — первый сквозной модуль.** Основание: D3 и H1/H2, TC-MP01 calibration; подготовленные code paths Countries/Ghibli/Firefox. Требования R3/R4/R5. Проверять успех, generic failure, cancellation, replacement и случаи, когда lifecycle уже исключает stale state.
2. **Evidence calibration и reachability.** Основание D3: два refinement без новых подтверждённых дефектов. Не самостоятельный framework: краткая decision card или раздел первого модуля. Проверять уменьшение FP и сохранение реальных findings.
3. **Persistence integrity / interruption.** Основание: существующая unique nuance data route и прошлое scoped cancellation/rollback evidence. Конкретную новую задачу ещё выбрать; тему не выпускать по одному историческому примеру. Проверять partial-write/retry/rollback и отличать cancellation от undo.

Media/resource envelopes остаются следующим кандидатом после workload evidence; отдельный четвёртый модуль пока не добавляется. Git preservation остаётся проверочным boundary scenario существующих quality gates, не новым инструментом. Это три выбранные темы дизайна, не три уже полезных доказанных модуля.

## 3. Контракт первого модуля CXL-01

**Проблема:** отмена может не остановить producer; после await старый success или generic error способен опубликовать state. Один pre-await check либо сравнение semantic query не всегда отличают повтор A→B→A.

**Trigger:** изменяется или проверяется публикация результата async операции с replacement, cancel, screen lifetime или shared owner. Не-trigger: read-only синхронный расчёт; lifecycle уже строго сериализует операции и не допускает replacement; слово Task без затронутого ownership не повод читать всё.

**Результат потребителя:** построить owner/lifetime trace и выбрать минимальный существующий boundary; проверить same-operation identity и cancellation перед publication success/error. Generic `CancellationError` propagation — не универсальный reset UI. Новое поколение/handle нужно только там, где текущая ownership модель не даёт необходимой гарантии.

**Обязательные invariants:**
- state имеет одного реального isolation owner;
- replacement invalidates право предыдущего producer публиковать результат;
- success и generic failure проходят одинаковую проверку актуальности;
- cancellation не объявляется успешным durable commit и не отменяет уже совершённый side effect;
- current genuine failure остаётся видимым;
- task/continuation/callback cleanup имеет конечную lifetime и не удаляет owner более новой операции;
- output/resource envelope не расширяется; unsafe concurrency annotations не предлагаются;
- product-specific terminal state при cancellation задаётся контрактом task, а не библиотекой.

**Содержимое будущего patch:** trigger card; краткий ownership algorithm; before/after с independently authored minimal code; таблица traces; контрпример корректного lifecycle; источники и toolchain assumptions. Не копировать Ghibli/Firefox код в reusable docs. До release пример должен получить разрешённую type/build проверку, если содержит Swift; иначе пометить как conceptual, не drop-in.

**Проверочные traces (пока статический oracle draft):**
1. A starts → B starts → B succeeds → A succeeds: итог B.
2. A starts → B starts → B succeeds → A fails generic: B не заменяется старой ошибкой.
3. A starts → cancel → producer ignores cancellation and returns: terminal cancellation contract сохраняется.
4. A→B→A, first A returns last: first A не принимается только из-за равенства query.
5. Current request genuinely fails without cancel/replacement: реальная ошибка публикуется.
6. Owner serializes calls and rejects overlaps: отсутствие generation counter само по себе не дефект.
7. Durable write committed before cancellation: cancel не выдаётся за rollback.
8. Old cleanup runs after replacement: новый handle/state owner не удаляется.

Oracle проверяет поведение, не имя переменной/token или конкретную архитектуру. Допустимы identity через existing handle, owner serialization, generation и другие доказуемые эквивалентные решения. Weak-self и blanket @MainActor не являются автоматически правильным patch.

## 4. Read-only проверка пригодности проектов

| Проект / HEAD | Настройки и состояние | Решение для подготовки |
|---|---|---|
| Countries / `9eca97b8cfff96a14084b564b1fefd949c93d232` | Чистый; MIT root LICENSE; app deployment 18.1, Swift 5 settings | Candidate development, 18.2/27 потенциально применимы; build compatibility пока NOT_RUN |
| Ghibli / `524c434882dcc22d95b1c5781f295d8fbfe0ced6` | Dirty FavoritesScreen/FilmsScreen + два test paths; app deployment 26.0, Swift 6, default MainActor, targeted strict concurrency; root license не найден | Использовать только committed HEAD для proposed cases; dirty work сохранить. 18.2 N/A, 27 potential. Не публиковать source copies; license/provenance eligibility требует отдельного выяснения до полного dataset freeze |
| Firefox / `0ac7cc9e98b81ac7ec68b18cd38ea6ab8a0ed071` | Чистый; MPL-2.0 root LICENSE; Client settings deployment 15.0, Swift 6; upstream AGENTS содержит build/lint commands | Candidate development, но full host build дорог/неподтверждён. Upstream commands не запускаются. Оценить isolated permitted check до выбора полной сборки |

Project roots: `/Users/Artem/.zenflow/library-acceptance-projects/{clean-architecture-swiftui,GhibliSwiftUIApp,firefox-ios}`. Каноническую app memory и bootstrap-adoption для экспериментальной изоляции определить P2, не менять original roots. Countries/Ghibli не имеют root AGENTS в прочитанном checkout; Firefox содержит upstream AGENTS без canonical adoption marker. Это intake facts, не повод сейчас редактировать проекты.

## 5. Development-кандидаты, ещё не frozen dataset

Достаточно шести конкретных кандидатов для первого механизма; оставшиеся шесть для полного плана и holdout отдельно. Не раздувать список повторными задачами из одного дефекта. Ни один кандидат ниже не считается результатом benchmark.

| ID / тип | Scope на зафиксированном HEAD | Проверяемый контракт / известное ограничение |
|---|---|---|
| DEV-C01 / review | `Utilities/CancelBag.swift`, `Utilities/Loadable.swift`, `Interactors/ImagesInteractor.swift` | CancelBag удаляет handles, но не вызывает `cancel()` явно; Loadable публикует success/error после await. Trace actual callers и lifetime; не утверждать current UI race без producer evidence |
| DEV-C02 / clean control | `Interactors/ImagesInteractor.swift` nil URL path | Nil URL переводит в notRequested без запуска producer. Не добавлять generation/Task/actor без причины; semantic acceptance — сохранить поведение |
| DEV-G01 / constrained implementation | committed `Networking/SearchFilmsViewModel.swift`, `Views/SearchScreen.swift`, `Services/GhibliService.swift` | Task(id: text) cancels предыдущий task; success после service await без post-await guard, error сверяет query. Заданный task contract: producer может игнорировать cancellation, A→B→A не должен принять first A. Product terminal cancellation state фиксируется до patch |
| DEV-G02 / clean control | same committed debounce path до service | После sleep проверяется isCancelled до обращения к service. Нельзя считать `try? sleep` само по себе подтверждённым broken cancellation; downstream gap оценивать отдельно |
| DEV-F01 / review | `Frontend/Reader/SchemeHandler/ReaderModeSchemeHandler.swift` + ограниченно route producer | Есть pre/post-await cancellation и отдельный CancellationError catch; generic error catch вызывает didFail без cancellation gate. Сценарий stop→generic failure — candidate; actual WebKit callback contract и producer errors пока UNKNOWN, не объявлять доказанный crash |
| DEV-F02 / clean control | selected ReaderModeSchemeHandler success path | После router await есть checkCancellation перед send. Не выдавать отсутствие ещё одного redundant check за missing success gate; full send/stop reentrancy из этого не доказана |

Три negative-control кандидатa есть; окончательный oracle потребует независимых правильных/неправильных решений и разрешённых deterministic checks. Ни один task здесь не даёт право чинить original app. Countries и Firefox — review для diagnosis, Ghibli — proposal явного adversarial contract в изоляции.

## 6. Протокол изоляции и ledger — draft

- Исполнители всех A/C: GPT-6.1 Sol/medium; fresh context без текущей истории автора и чужих результатов. Fork all запрещён для comparison; общий safety authority одинаков.
- Payload A восстанавливается по P0 hashes/commits. Experimental C — versioned draft до P6.3; в holdout только frozen final C. Mode transition original projects не нужен, пока user-approved isolation прямо выбирает exact knowledge payload и безопасный entrypoint; это ещё требует утверждённого execution envelope.
- Case prompt сообщает behavior/allowed scope/tools, не предполагаемые дефекты и oracle. Evidence/answers находятся вне normal routing и вне разрешённого чтения исполнителя; source SHA и selected file hashes совпадают для A/C.
- Короткая delivery-серия: 4 сценария × A/C. Два содержательных случая, negative non-trigger и missing/stale case. Draft предел: 5 минут на попытку, один completion, без source changes/runtime, без retry победного результата. Всё elapsed/logged; timeout — failure, не исключение.
- Implementation benchmark timeout/число исправлений определяется после подготовки задач. До этого не переносить 5 минут на Firefox host builds или coding tasks.
- Ledger fields: task/arm/repeat, model/effort, source/payload hash, order, authority/tools, actual read timing, output/checks, success/TP/FP/UNKNOWN, rework, elapsed/usage UNKNOWN, exclusions/adjudication.
- Randomization/balancing и точный statistical procedure фиксируются P2.3 до outcomes. Нельзя называть шесть похожих development-кандидатов доказательством полной usefulness или независимым holdout.

## 7. Следующий ограниченный запрос решения

Нужен независимый куратор задач: автор C уже видел development mechanisms, поэтому сам не может подготовить скрытые ответы holdout и затем честно заявить независимость. Предложение — **ровно один агент GPT-6.1 Sol/medium**, свежий контекст, read-only: выбрать 12 development и 12 не дублирующих holdout-кейсов на проверенных source SHA, сформулировать oracle и eligibility. Сам автор читает только development и summary eligibility, без holdout task bodies/answers. Куратор выдаёт summary, пути/хеши; holdout содержимое в закрытом task evidence и вне routed контекста. Это procedural isolation, не OS security guarantee; доступ benchmark executor должен быть ограничен allowed inputs.

Предлагаемый предел куратора: до 60 минут, один проход + один уточняющий запрос при конкретной неоднозначности; без source edits, builds/tests, network, mode transitions, MCP, новых дочерних агентов. Только `.zenflow`, outputs в отдельном task-local evidence. Нужны user authorization и решение по eligibility Ghibli; при license uncertainty не включать его source в распространяемый corpus, предложить допустимую замену/ограниченный local case.

Меньшая альтернатива: продолжить одним development-модулем здесь; независимая общая эффективность остаётся непроверенной. Рекомендация — независимая подготовка cases прежде дорогих pilots, а не ещё один observer review уже известного дефекта.

Бюджет следующего authored блока после P2: один CXL-01 module + минимальные entry/router изменения, до трёх active documentation files; не массовое переписывание core. Ориентир подготовки 30–60 минут; tokens и доля weekly limit UNKNOWN. Восемь delivery-запусков отдельно: максимум 40 минут worker wall-time + overhead/grading, конкретный механизм fresh-context запуска требует отдельного разрешения. Не создавать их в рамках grant одному куратору.

## 8. Приёмка и drift-check

- P1.2 выбор V2 записан; это design choice, не доказательство качества.
- P1.3 owners/contracts + три темы/backlog готовы. Изменений активного payload/source нет.
- P2.1: шесть development-кандидатов, 12 route questions из diagnosis-design; 12 holdout отсутствуют, полномочие независимой подготовки pending. Не отмечать P2.1 выполненным.
- P2.2: восемь traces и task contract draft; oracle ещё не проверен на correct/wrong implementations. Не отмечать PASS.
- P2.3: схема/ledger draft; isolation ещё не испытана. Не объявлять frozen protocol.
- P2.4: оценка ограниченного следующего блока предложена; полный экспериментальный бюджет не принят.
- Goal-drift: каждый шаг связан с D1–D3, R3/R4/R5/R6; не строится новый поиск/framework. Новый агент не создан; это конкретное предложение пользователю. Source/dirty state сохранены, test-writing/runtime не начаты.
