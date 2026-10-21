# Приоритетный план после критического аудита

2026-10-19. Final proposed remediation plan after completed static audit with limits; implementation is not authorized. Active KB unchanged. A01-A12 OPEN; KB acceptance NOT_READY. Earlier dated additions remain provenance.

## Владельцы и общие условия

`V` = `/Users/Artem/.zenflow/worktrees/documentation-vault`; `W` = `/Users/Artem/.zenflow/worktrees/knowledge-base-next`. Владелец нормы — указанный canonical файл. Ответственный за будущий patch — исполнитель документационной KB после разрешения пользователя; окончательные решения о допустимом риске/области/публикации — Artem. Конкретный человек, принимающий техническую freshness, пока не назначен; не подменять его вымышленным owner.

Перед каждым будущим пакетом: актуальные SHA/dirty, точный контракт и входы, сохранение чужих изменений. Не переносить разрешения из migration-plan U9. Проверки ниже — минимальная предлагаемая стратегия; существующие ограниченные read-only проверки разрешены сейчас, создание/изменение/исполнение новых тестов требует отдельного открытия соответствующей фазы. Не считать fixtures «статическим анализом», чтобы обойти запрет тестов. Не выполнять broad checker, если он читает закрытые материалы.

Rollback каждого пакета: сохранить исходный diff и точные исходные hashes; отменять только собственные hunks после проверки последующих правок. Для уже опубликованного будущего пакета — отдельный revert по действующим Git-разрешениям. Никаких reset/clean, перезаписи архива или восстановления старых Library grants. Все зеркала откатывать вместе с owner, иначе сохраняется новое расхождение.

## Порядок работ

### R0 — завершить независимую доказательную базу (высокий приоритет)

Owner: task `migration-ledger.json`, frozen manifest/ZIP, текущие canonical destinations; результат только в audit directory. Не редактировать исторические статусы задним числом.

Действие: отдельно рассмотреть source→destination для всех полезных units, с полной исходной страницей, актуальным owner, условиями/исключениями/ограничениями и конкретным выводом. Exact-hash aliases можно объединять после полного чтения одного тела; сходство текста не позволяет объединение. Учитывать 37 copy units отдельно. Архивные инфраструктурные bodies с запрещёнными handler/host деталями оставить EXCLUDED там, где применим текущий запрет; это не active coverage. Непросмотренное остаётся UNVERIFIED.

Зависимости: текущий аудит; исправления KB для этой работы не нужны. Решения: только фактические конфликты owner/полезности; решаемые строки не блокировать.

Приёмка: полный per-unit независимый receipt либо честно ограниченный итог с точными оставшимися IDs; ни одна архивная disposition не числится active reviewed coverage. Для MIGRATED/ALREADY_COVERED — точный destination anchor и проверенная эквивалентность, не keywords. Для исключений — конкретная причина. Статические hash/link checks поддерживают смысловой review.

Стоимость: высокая, наибольшая часть остатка; 1 403 source rows и 4 322 units не равны 1 403 новым прочтениям из-за aliases, но 1 288 уникальных source hashes исключают обещание дешёвой полной перепроверки. Польза: обнаружение реальных потерь/ложного покрытия. Rollback: отдельные audit receipts можно пересмотреть без изменения оригинала.

### R1 — устранить противоречия полномочий и verdict (A01/A04/A09)

Owners: `V/reusable/local-ios-skills/ios-swift-runtime/SKILL.md`, `ios-performance-profiler/SKILL.md`, `ios-identity-authentication/SKILL.md`; `V/reusable/baseline/docs/IOS_PERFORMANCE_BUDGETS.md`, `IOS_RELEASE_CHECKLIST.md`; `V/reusable/agent-prompts/AI_iOS_MASTER_PROMPT.md`; `V/reusable/knowledge-global/ios/PERFORMANCE_OBSERVABILITY_AND_OPERATIONS.md` (Evidence / Optimization Workflow). Governing owners: baseline AGENTS, CURRENT_USER_OVERRIDES, UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.

Изменения: явно сохранить запрет unsafe annotations без исключения «audited promise»; выбирать только разрешённые evidence classes, исключённые hardware/VoiceOver/iPad checks не возвращать в планы; использовать пять canonical decisions либо явное преобразование legacy transport labels. Сохранить implementation accessibility/platform requirements и исторические результаты. Разделить на небольшие тематические patches, не массовую нормализацию всего корпуса.

Зависимости: актуальный user scope; DEC-001 — историческое доказательство принятой строгости, не новое разрешение редактировать. Решение пользователя: открыть реализацию плана; новой продуктовой политики не требуется. Исключение из строгой нормы, если пожелают его ввести, требует отдельного решения.

Приёмка: все перечисленные советы согласуются с owner; сценарий resumed task не выдаёт unsafe/device/bypass разрешение; недостающая evidence остаётся non-PASS. Разрешённые проверки: полное чтение изменённого owner и affected claims, точные ссылки/паритет; executable/device checks не нужны. Стоимость низкая–средняя; польза высокая для предотвращения неверных рекомендаций. Rollback по общему правилу, при возврате старого текста finding снова OPEN.

### R2 — обязательные входы resolver должны fail closed (A02)

Owner: `W/scripts/resolve_docs_route.py`; canonical counterpart `V/reusable/baseline/root-scripts/resolve_docs_route.py`. Сначала содержательно объединить local required/optional улучшения с canonical, не копировать ни одну сторону вслепую.

Изменения: статические Level 0 включить в mandatory set; отсутствие динамического task plan/handoff трактовать по отдельному контракту применимости; required побеждает optional; explicit optional selection не делает missing mandatory документ необязательным. Сохранять provenance root/overlay и диагностировать недоступный fallback.

Зависимости: подтверждение актуального Level 0 из router, разграничение canonical/local references. Приёмка: статический branch trace доказывает nonzero result для missing mandatory; отрицательные controls по отсутствию Level 0, required+optional collision и legitimately absent task docs нужны перед объявлением verifier proven. Их создание/запуск — отдельная test-фаза, пока NOT_RUN.

Стоимость средняя; польза высокая: устраняет ложный успешный startup. Rollback парой canonical/distributed versions; если откат возвращает defect, маршруты с неполной цепочкой остаются blocked.

### R3 — завершить согласованную доставку всех 31 путей (A03/A08)

Owners: точный список `drift-dispositions.json`: 28 skills, `docs/REUSABLE_BASELINE_POLICY.json`, resolver, context reporter. Primary skill owners находятся `V/reusable/local-ios-skills/`; distribution `V/reusable/baseline/.codex/skills/`; consumer `W/.codex/skills/`.

Изменения: после R1 распространить исправленные primary skills в governed mirrors; сохранить local DOC resolver contract; корректно quote YAML descriptions. Синхронизировать canonical_only template policy, сохраняя controlled portable behavior. Два скрипта объединить по R2/R4, а не устранить drift потерей local исправлений.

Зависимости: R1, R2, R4. Решения: нужна реализация; установки/host skill loading сюда не входят. Приёмка: все31 имеют semantic disposition и побайтное доказательство нужного паритета; legitimate overlays отдельно, ноль unexplained stale. Fresh drift checker + scoped index/link/schema review. Реальное skill loading и canonical-unavailable execution остаются UNVERIFIED без отдельного разрешённого окружения. Стоимость средняя, польза высокая для новых/portable consumers. Rollback атомарно по первоисточнику и mirrors.

### R4 — исправить измерение контекста и проверить экономию (A06/A10)

Owners: `W/scripts/report_documentation_context_cost.py`, canonical counterpart; `TASK_TYPE_DOCUMENTATION_ROUTER.md`, `TASK_DOCUMENT_ROUTES.json` только если измерение докажет необходимость изменения маршрутов.

Изменения: explicit actual canonical bootstrap/baseline AGENTS/router/Level0/project overlays/task docs; учитывать физический path и authority role, уникальное чтение и повторное отдельно; полные выбранные файлы; transitive обязательные reads, AI full/slice distinction, project memory и resume. Words/bytes отдельно от actual token telemetry. Не считать unavailable file нулевой ценой успешного startup.

Зависимости: R2 для правильной обязательности; текущие 12 recipes как regression baseline. Приёмка: ручной полный состав совпадает с отчётом для unrelated, task-doc, single domain, AI, exact project и multi-domain; повторное чтение выводится отдельной величиной. Отдельно показывать недоступную телеметрию. Стоимость средняя, польза: честный выбор оптимизаций; экономия не гарантируется. Rollback reporter не отменяет сохранённые измерения — они привязаны к SHA.

### R5 — dynamic app boundary discovery (A05)

Owner: `V/reusable/baseline/root-scripts/check_documentation_boundaries.py` и consumer `W/scripts/check_documentation_boundaries.py`; policy `V/DOCUMENTATION_ARCHITECTURE.md`.

Изменения: прямые non-hidden apps directories из actual root вместо четырёх hard-coded имён; явно обработать manifest/context/copy violations и symlink/out-of-root границы. Не читать app source или secrets. Не добавлять app-name специальные случаи без причины.

Приёмка: новая допустимая app directory включается; missing manifest/copied baseline не уходит из coverage; инфраструктурная папка исключается только явным правилом. Статический trace разрешён; negative fixture creation/execution требует отдельной test-фазы. Стоимость низкая–средняя; польза высокая при следующем app. Rollback не может сопровождаться утверждением exhaustive app discovery.

### R6 — обосновать maturity/freshness (A07)

Owners: `V/reusable/baseline/docs/IOS_KNOWLEDGE_COVERAGE_REGISTRY.json`, `IOS_PLATFORM_SCOPE_AND_KNOWLEDGE_POLICY.md`, 18 доменных owner sets.

Изменения: per-domain review receipt: source URL/revision, проверенная дата, применимая toolchain/availability, конкретные evidence units; устранить хронологическое несоответствие вместо простого продвижения даты. Maturity оценивать по принятому policy, не длине страниц. Если evidence нет — unknown/недоказано, не fabricated review. Никакого автоматического перехода проектов на указанную SDK.

Зависимости: R0 и техническая проверка owners; для актуальной внешней первичной проверки нужен разрешённый канал. Приёмка: каждый complete имеет требуемую цепочку rule/deep/example/review/evidence либо пересмотренный честный статус; изменчивые сведения помечены по доступности. Стоимость средняя–высокая; польза высокая в security/platform/release, умеренная для стабильных языковых основ. Rollback сохраняет прежние receipts как dated evidence.

### R7 — точечная экономия без потери условий

Owners: router/routes; `IOS_PROJECT_WORK_SYSTEM.md`; `apps/Tchop/PROJECT_CONTEXT.md`, `apps/BattleshipGame/PROJECT_CONTEXT.md`; AI router/master; common governance owners.

Предлагаемые изменения после R4: вынести исторические app receipts в адресуемые архивные документы с provenance и текущим кратким контрактом; разделить длинный AI master и project workflow по независимым triggers; отделить API schema от retry/offline маршрута там, где сценарии показывают независимость. Полностью читать выбранные новые документы. Не удалять ограничения, не заменять owner кратким пересказом и не делать неизвестный optional документ обязательным по одному resolver output.

Зависимости: R0 semantic preservation и R4 cost model. Решения: принять конкретное разбиение с до/после составом; политика полного чтения сохраняется. Приёмка: условия/исключения/provenance доступны обязательному consumer; negative controls не выбирают чужие domains; все existing relevant scenarios доставляют прежние полезные units. Words/bytes экономия измерена по exact file sets; quality и tokens не выводятся из неё. Стоимость средняя; ожидаемая польза правдоподобна, величина неизвестна. Rollback возвращает старые маршруты и owner files вместе.

### R8 — сценарии качества кода и отдельный U7

Owner: task-local scenario specification, не sealed holdout/oracle и не app test files. Сценарии перечислены в report/domain-review; добавить identity+logout+replay, migration+cleanup, background expiration, capability unavailability, commerce duplicate delivery, cache account switch и AI tool-output trust.

Сейчас допустимы спецификация, source/document trace и критерии отрицательных controls. Нельзя выдать их за исполненные тесты или незнакомый модели benchmark. До U7 нужен отдельный конкретный запрос: задачи, число запусков, модель/reasoning, способ изоляции, разрешённые инструменты, независимая оценка и доступная per-run telemetry, предел затрат. Старый эксперимент не открывается.

Приёмка будущей оценки: одинаковые условия A/B; сохранены failures/ties/retries; blinded/independent status честен; regression/false-positive controls обязательны; input/cached/output/reasoning tokens по одному источнику с явными missing fields. Subscription savings UNKNOWN без соответствующей телеметрии. Никаких универсальных обещаний из малой выборки. Стоимость высокая относительно статического аудита, польза неизвестна до опыта. Rollback: остановка эксперимента не меняет KB и не скрывает неудачные outcomes.

## Завершение и публикация

Итоговая приёмка аудита требует закрытого независимого охвата либо явно принятого пользователем ограниченного результата. Исправления потребуют отдельной полной проверки конечного diff; P0–P2 остаются blockers согласно действующей политике. Static PASS не закрывает semantic/freshness/runtime gaps. Коммит/публикация не выполняются этим планом и не наследуются из старого migration-plan.

При передаче: **перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**. Повторный startup не превращать в повторный полный аудит неизменённых тематических документов; сначала подтвердить bytes/authority и продолжить точный незавершённый блок.

## R0 precision additions — 2026-10-13

Owner: existing Documentation Vault knowledge/ledger maintainer (individual unassigned).
Files: canonical migration-ledger.json entries LIB-0006-U01, LIB-0855-U12,
LIB-0859-U01, LIB-0863-U01 and COPY-ROUTER-U10; existing scope policy,
project-work and engineering owners only if a genuine semantic gap is established.

- Cite Scope Policy Coverage Unit for LIB-0006's pointer-versus-coverage restriction.
- Cite Project Work System §3 for LIB-0859 provenance/freshness distinctions.
- Decide whether source-preservation-on-similarity is a reusable norm or only this
  migration's contract; exact same unresolved ownership affects LIB-0855-U12 and
  COPY-ROUTER-U10. Do not resolve it by counting archive preservation as active coverage.
- Locate a precise current owner for LIB-0863's nested-repository/input-time-envelope
  clauses; if none exists, classify the incremental condition before proposing a patch.

Dependencies: full selected source and owner reads (done), scope/owner decision where
needed; current user approval of implementation phase remains absent. Acceptance:
clause-to-owner proof or explicit unverified/accepted disposition, separate from route
and structural PASS. Permitted checks: static exact anchors and bounded ledger validation;
no new tests/runtime/U7. Rollback: revert only future owned ledger/owner edits while
preserving receipts/provenance. Cost: low for citation corrections, medium for owner
scope adjudication; benefit is more trustworthy coverage, not measured token savings.

## R0/A11 — exact AI coverage anchors

Priority P3, high confidence; owner Documentation Vault migration-ledger maintainer,
individual unassigned. Files: canonical task migration-ledger.json LIB-0181-U04
(destination_heading and coverage_locations); inspect the other LIB-0181 priority-item
references individually. AI_iOS_MASTER_PROMPT.md content needs no addition for this finding.
Replace the wrong priority-item anchors with `1. ОСНОВНАЯ ЦЕЛЬ`, which contains the
actual deterministic/specialized-framework decision. Preserve the source unit and provenance.

Dependencies: existing full source/master reads and exact current SHA/hash check before a
future edit. No product decision required; implementation phase remains unapproved.
Acceptance: each cited section directly supports the named unit clause, with no duplicate
norm added and no archive-to-active coverage inflation. Permitted verification: static
anchor/claim review and narrow ledger integrity check. A proposed negative control should
substitute an existing but irrelevant section: an existence-only validator must not be
reported as having proved semantic support. Do not implement/run that fixture or U7 here.
Rollback: revert only the future owned unit mapping, retaining audit evidence. Cost low;
benefit more reliable traceability and less wasted reviewer navigation, not measured tokens.

## R1 addition — A12 severity owner alignment

Owners/files: canonical `reusable/baseline/docs/IOS_PRODUCTION_AUDIT_MATRIX.md`,
`PRODUCTION_CODE_REVIEW_CHECKLIST.md`, `UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`;
implementation owner is the KB documentation maintainer, individual unassigned.
Align checklist examples to the existing matrix authority, then synchronize governed mirrors.
Dependency: preserve P0–P2 blocking semantics and current severity/confidence separation.
Decision needed only if maintainers intend to change the actual severity policy; otherwise
remove duplicate classification and clarify concrete impact versus cosmetic naming.
Acceptance: the same demonstrated impact yields the same P-level and blocking status across
all three documents; cosmetic inconsistency alone cannot become P2 solely by alternate wording.
Checks: scoped full-document review and two manual adjudication examples (cosmetic name versus
wrong-consumer contract), no app/test/runtime action. Cost low, benefit moderate: more consistent
gates and less false blocking. Rollback only this owned patch and mirrors together; retain A12
open if the conflicting text returns. Implementation remains unapproved.

## R0 citation precision — 2026-10-14

For LIB-0227-U01 cite Production Quality Gates / Severity Classification (failure likelihood); for LIB-1063-U01 cite Xcode Build / Targets And Build Phases (correct generator, not derived output). Content is already present. Owner: existing ledger maintainer; no new policy decision or duplicated prose needed. Acceptance: exact clause proves the subclaim; current owner hash retained. Static citation review only, low cost; rollback only own ledger hunk.

## R0 continuation precision — 2026-10-16

Extend the existing AI-trigger adjudication to LIB-0440-U02, LIB-0442-U02 and LIB-0445-U02;
find an exact owner for model/OS-change reevaluation before asserting complete preservation.
For LIB-0448-U02 cite existing IOS_MEMORY_CACHE_MEDIA_STANDARD.md / Required Rules for prefetch
ownership, cancellation, bounds and stale consumers. Owner: existing ledger maintainer, individual
unassigned. Files: these ledger rows; existing owners only if a genuine gap is established.
Acceptance: clause-to-anchor proof, without new duplicate guidance or test permission. Dependency:
R0 source/owner reads now recorded; active-KB implementation still unapproved. Cost low for citation,
medium for unresolved AI scope; benefit traceability, not measured quality/tokens. Rollback only
future owned mapping hunks; preserve these receipts and original provenance.

R0 persistence extension: LIB-0455/0457-U02 retain the existing AI-trigger qualification. For
LIB-0455–0458-U03, cite Persistence / Preferences And Derived Caches and locate an exact owner
for the conditional persistence DTO/model seam shielding domain from schema churn. Do not
replace that condition with universal layer creation or declare global loss from an imprecise map.
Owner/files, acceptance, cost and rollback are specified in persistence-deep-semantic-receipt.md.

## R0 continuation precision — 2026-10-18

Current audit checkpoint: 675/1403 source rows read; all original ledger dispositions remain historical claims, with audit qualifications in coverage.json. This addition synchronizes the proposed plan, not the active KB.

Owner: existing Documentation Vault ledger/knowledge maintainer, individual unassigned. Future files: only the exact qualified ledger units named in coverage.json and, if a real content gap is established, the existing canonical owner. Dependency: independent body/map/owner reads recorded in testing-, performance-, security-, accessibility-, platform-, ai-, build- and ci-release-deep-semantic-receipt.md. Implementation phase remains unapproved.

- Carry forward each repeated AI model/OS-change evaluation-trigger uncertainty. For AI deep LIB-0525–0534-U03, also adjudicate the explicit staged evaluation-threshold gate; general versioning/evaluation/rollback is not exact proof. LIB-0532-U02 has no AI-trigger sentence and must not receive that qualification merely by family membership.
- Resolve stateful-inference ownership/reset for LIB-0526-U01 together with the earlier LIB-0183-U01 qualification. Do not substitute Foundation Models session/KV-cache wording for every custom model's state contract.
- Correct exact citations where current content is present: prefetch in MemoryCacheMedia Required Rules; grounding/abstention in AI47 for LIB-0528-U01; package test structure via Build Model/Testing for LIB-0535-U01; Swift/concurrency-mode readiness via Xcode Configuration for LIB-0541-U01.
- Locate precise support for privacy tracking-domain review (0496-U01), Live Activities battery/resource wording (0513-U01), realtime background-transition semantics (0531-U02), and explicit accessibility/localization release linkage (0553-U01). Generic nearby guidance does not automatically prove the exact clause; none of these observations is a claim of global KB absence.
- Preserve existing persistence cache/schema-domain-seam qualifications and exact IDs in coverage.json. Keep A09 release verdict disagreement and A04 prohibited-hardware recommendations open; successful preservation elsewhere does not close them.

Acceptance: clause-to-owner evidence or an explicit unresolved/product-approved disposition; preserve permissions, provenance, current owner fingerprints and separate active/archive accounting. No duplicate norm just to make a keyword match, no new mandatory architecture/test/device action. Permitted checks for a future approved patch: static full affected-owner/claim review and bounded mapping integrity; tests/runtime/U7 remain separately governed. Cost low for citation corrections, medium for unresolved ownership/contract adjudication; benefit reliable traceability, not proven quality or token savings. Rollback only future owned hunks with original receipts retained.


### R0 precision continuation — 695-source checkpoint, 2026-10-18

The next bounded remediation proposal also includes LIB-0555–0564 U03: locate an exact current old/new metric-name transition mapping requirement or record/repair that narrow gap; generic metric semantic versioning is insufficient proof. LIB-0558/0563 U02 repeat the existing model/OS-change eval-trigger qualification. LIB-0565 U01 needs precise accessibility owner citations rather than claiming the cited general review areas state those requirements. Exact IDs and limitations are in coverage.json and the observability/review-refactor semantic receipts. Existing A04/A12 remain unresolved; no active KB edits or expanded execution scope are authorized by these audit proposals.


### R0 precision continuation — 735-source checkpoint, 2026-10-19

Future bounded coverage repair must also adjudicate Media 0595-U01 audio-graph construction, 0597-U01 export progress, 0599-U01 path drawing and 0596-U02 actor citations; source concerns remain explicit while their cited current sections are narrower. ML/spatial 0605–0614 U03 repeats exact old-model/schema retention until new quality and latency thresholds pass; 0608-U01 repeats threshold precision; 0605/0611/0614-U02 and workflow0592-U02 repeat model/OS-change eval-trigger qualification. Exact IDs/limits remain in coverage.json and thematic receipts. Locate existing exact authority before proposing added content; no global absence or active KB patch authorized. All post-switch rows retain GPT-6.1 Sol / medium provenance from the immutable 709-source boundary for any later repeat pass.


2026-10-19 system-integration audit qualification queue (proposals only): locate exact authority for LIB-0615-U01 asynchronous JS bridge completion/cancellation/ordering and LIB-0620-U01 NFC polling/read/write distinctions before asserting complete preservation; no global absence established. LIB-0617-U02 prefetch citation can be repaired by citing already-reviewed MemoryCacheMedia Required Rules. Exact AI model/OS-change eval-trigger qualifications also apply to 0620/0623/0624/0627-U02; retain conditional applicability and existing trust/auth/idempotency guards. No active KB edit authorized.

2026-10-19 proposed follow-up: preserve exact AI eval-trigger qualifications for ecosystem 0630/0635/0638-U02; locate direct field/aggregate-form and async-validation cancellation authority for 0644-U01, consistent with earlier 0355 qualification. Generic search cancellation is insufficient precise evidence. No global absence claim or active KB edit.

2026-10-19 team deep proposals: U03 of 0647–0654 should cite existing Operations Runtime Operations for exact incident-learning loop (0651/0654-U01 already cite it); 0649-U02 retains exact AI eval-trigger qualification; 0654-U02 needs direct MemoryCacheMedia prefetch citation. No new A finding or active-KB edit grant.

2026-10-19 P2 proposals: add direct UI Invalidation citation for 0656-U01; locate exact capture/generic Sendable review authority for 0665-U01, consistent with 0587 qualification. No active KB modifications.

2026-10-19 P2 continuation proposals: cite UI UIKit Lifecycle for 0690-U01 Auto Layout ambiguity/conflict/self-sizing; MemoryCacheMedia Required Rules for 0691-U01 prefetch. Locate precise phase-aware DNS versus connect diagnostic owner for 0700-U01, and check earlier related sources for consistency without presuming global loss. No active KB edits.

## Final R0-R8 reconciliation - 2026-10-19

R0 full reading is complete:1403 sources,1288 unique SHA and115 exact aliases with separately inspected mappings;4285 canonical units=2555 active+1730 archive.37 copy units are separate:36 supported with limits, COPY-ROUTER-U10 owner scope unresolved. This completes the audit, not semantic acceptance. All207 exact qualified canonical IDs and their limitations are authoritative in coverage.json/unverified_unit_claims, including every post-0700 qualification not individually enumerated in older additions. A11 is one confirmed mapping defect, not207 new findings.

Remaining R0 repair is targeted adjudication: (1) repair known citation gaps using existing exact owner anchors, without duplicate rules; (2) for unresolved subclaims locate the precise current contract, then explicitly decide retained useful delta versus retired/task-only condition; (3) decide owner scope and archive utility without counting ZIP preservation as active coverage. Families include AI reevaluation triggers/thresholds/model retention/stateful inference; persistence schema-domain seams; exact media/JS/NFC/DNS/Keychain/form/deprecation/risk-register contracts; prefetch/UI/observability citations; generated-context identity/reuse; nested scoped-rule design; actual exposed delegation schema and migration-review independence. Repeated clauses and alias maps are not independent losses. Each source row identifies its detailed audit receipt; original ledger preserves source meaning/conditions/locations.

Owner: Documentation Vault ledger/knowledge maintainer, individual unassigned. Future files: only the207 exact qualified canonical ledger units and COPY-ROUTER-U10; an existing canonical owner changes only after a real delta is established and implementation authorized. Acceptance per unit: direct clause-to-anchor evidence or explicit unresolved/approved disposition, preserving conditions/exceptions/provenance and active/archive distinction. Dependencies: these receipts and freshly checked source hashes before patch. Permitted future verification: affected full source/owner/consumer/mirror reads and bounded mapping checks; test creation/modification/execution, runtime/U7/host/Git remain separately authorized. Rollback only future owned hunks/mirrors; do not rewrite original frozen evidence. Cost low for a citation, medium for disputed contract/ownership, split into bounded thematic blocks. Full-reading cost already incurred is not automatically required again for repair. Quality/token benefits remain unmeasured.

R1 includes A12 with A01/A04/A09: preserve P0-P2 blocking and canonical severity authority. Coordinate R2 mandatory-input semantics with R4 full transitive cost; apply R3 after primary fixes without losing local-ahead improvements. R5 separately covers dynamic app boundaries. R6 needs external primary-source evidence/per-domain receipts; static audit does not certify freshness. R7 only follows measured complete routes and preserves full reading. R8/U7 remains a separate unopened phase: visible scenarios are specifications, never unseen holdout or executed tests. The previous closed experiment stays closed.

No P0-P2 finding is accepted risk in this report; P3 findings are disclosed. The deliverable is the audit and this proposed plan. Implementation, publication, pilot/mode transitions and experiments do not follow automatically from completion. Existing per-packet owner/files/dependencies/decisions/acceptance/checks/rollback/cost/benefit sections above remain applicable. Context transfer: reread all current documentation and rules for this worktree/task context as specified in plan.md.
