# QualityControl — актуальный план продолжения

Обновлён 2026-09-08 по разрешённому полному аудиту на GPT-6 Astra. Это task recovery и operational index внедрения; он не заменяет reusable policy и не является разрешением запускать runtime/CI или менять apps без соответствующего блока. Предыдущий утверждённый план целиком сохранён в `audit-2026-09-05/before-universal-quality-control-plan.md`.

## Новое ограничение исполнения

Пользователь установил единственную модель для всего плана от начала до конца: **GPT-5.6 Luna xhigh**, включая проектирование, implementation, review и финальный аудит. Предыдущие модельные рекомендации отменены. Использовать `audit-2026-09-05/LUNA_EXECUTION_GUIDE.md`; при неоднозначности уточнять контракт, а не менять модель или снижать quality bar.

## Текущее решение

Сохранить QualityControl engine. Объединить лучшие человеческие правила нового ZIP с существующей системой после нормализации; shell runner ZIP не устанавливать. Исправить точность действующих gates перед массовым rollout. Полный подробный план с моделью/reasoning, dependencies, acceptance и rollback:

- `audit-2026-09-05/IMPLEMENTATION_ROADMAP.md`
- основания: `audit-2026-09-05/AUDIT_REPORT.md` и `FINDING_EVIDENCE.md`
- 67 решений по ZIP: `audit-2026-09-05/ARCHIVE_DECISIONS.md`
- покрытие/ограничения: `audit-2026-09-05/COVERAGE.md`

## Состояние внедрения — 2026-09-08

Статус: **implementation in progress**. Блоки 0.1–7.2 завершены task-level фиксацией границ,
baseline, сценариев, нормативного контракта, scoped Rule ID catalog, architecture invariants и
prompt/specialist-route normalization, package ownership, toolchain/profile contract, release/privacy/performance matrices и effective bootstrap inventory; это не означает готовность engine, пилотов или
release. Все блоки реализации, review и итоговая проверка выполняются на GPT-5.6 Luna xhigh.
Прогресс реализации: **22 из 30 блоков (73%)**; это не процент production readiness.

| Владелец | Источник истины и ответственность | Что сюда не переносится |
| --- | --- | --- |
| Documentation Vault | reusable human policy, prompts, skills, templates, registries и boundary rules | app facts, локальные исключения, task history и исполняемый engine |
| QualityControl | executable engine, schemas, adapters, fixtures, workflows и machine evidence | reusable human policy и product/app decisions |
| Project/app repository | project profile/facts, app code, thin launcher/workflow wiring, adoption state и local exceptions | глобальная policy и чужие app overlays |
| Task evidence | plan/handoff, implementation receipts, temporary decisions и recovery evidence | authority для reusable rules, engine или app behavior |

Глобальная активация инженерных правил и подключение QualityControl остаются разными
механизмами: bootstrap действует по canonical boundary, а engine adoption остаётся явным opt-in
с profile, permissions, receipt и rollback. Ручные GitHub/Codex Review, создание/изменение/запуск
тестов, UI/Simulator/Instruments, CI, branch protection и платные сервисы не активируются этим
статусом. Вердикты local readiness, merge readiness и release readiness не объединяются.

Evidence блока 0.1: `audit-2026-09-05/implementation/0.1-authority-boundary.md`.

## Свежий baseline блока 0.2 — 2026-09-08

Receipt `audit-2026-09-05/implementation/0.2-baseline-receipt.json` обновляет audit-era
identities. Documentation Vault, QualityControl main-active, AIZenflow development и AIZenflow
main проверены на чистое состояние; local HEAD совпадает с соответствующим remote ref. Старые
значения `28d11bb…` и `f60d5da…` в историческом audit baseline помечены stale относительно
текущей реализации и не используются как PASS evidence.

На QualityControl main зафиксированы текущие engine/policy inputs: `Package.swift`,
`policies/check-catalog.json` и `schemas/deterministic-check-result.schema.json`. Consumer profile
не подменяется engine revision и будет проверяться в соответствующем project/pilot scope.
Build, tests, toolchain и runtime evidence в этом read-only блоке не создавались.

## Нормативный контракт блока 1.1 — 2026-09-08

Канонический Documentation Vault обновлён и опубликован в коммите
`7dab2e7f4bb52bb02920030c7e14f3a879a53612`. Governance теперь задаёт единые оси
`severity/confidence/applicability/evidence status/decision`, разделяет local/merge/release
readiness, запрещает превращать отсутствующее evidence в normal `PASS`, и требует явного mapping
legacy transport labels. Authority hierarchy согласована с system/developer/user scope; exception
policy получила status, rule version, owner/approver, expiry, revalidation, rollback и containment.
Model-routing override остаётся scoped к named task/plan и не меняет глобальный default.

Evidence блока 1.1: `audit-2026-09-05/implementation/1.1-verdict-contract.md`.

## Scoped Rule ID catalog блока 1.2 — 2026-09-08

Documentation Vault получил `QUALITY_RULE_CATALOG.md` с 12 активными reusable нормами и
стабильными ID/version/owner/scope/strength/trigger/enforcement/limitations/exception/evidence/
source-date/revisit metadata. Catalog остаётся индексом: normative authority не дублируется.
Bootstrap, router, task routes и manifest обновлены; checklist и readiness prompt ссылаются на IDs.
Strict concurrency floor сохранён; generic exception flow не ослабляет его автоматически.

Evidence блока 1.2: `audit-2026-09-05/implementation/1.2-rule-catalog.md`.

## Architecture invariants блока 2.1 — 2026-09-08

Architecture router и UI/bootstrap/package guidance теперь отделяют reusable floor от style choice.
Обязательны ownership/state/IO/lifecycle/order/failure/availability и proportionate structure;
ViewModel, Renderer, Coordinator, reducer/store, repository protocol и package/module boundaries
выбираются по profile и текущему boundary pressure. Three desk examples зафиксированы в receipt;
app ADR и app source не менялись.

Evidence блока 2.1: `audit-2026-09-05/implementation/2.1-architecture-invariants.md`.

## Prompt/routing normalization блока 2.2 — 2026-09-08

Канонический Documentation Vault обновлён и опубликован в коммите
`b7a975b395e90937c38f86aa43c27a19c1108d29`. AI master больше не является default full-context:
`AI_iOS_TASK_ROUTER.md` задаёт стабильные route IDs и диапазоны разделов. Активные feature,
ADR, refactoring, CI/debug, SwiftUI design и test prompts используют профиль существующего
проекта, текущие design/localization tokens и permission-bounded verification; архитектурные
слои, ViewState, mocks, previews, flags и rollback не добавляются декоративно. API contracts,
network resilience, offline sync и testing получили primary-owner маршрутизацию с узкими
supplements. Swift runtime/concurrency skills получили local version/provenance metadata.

Старые prompt exports и ZIP остаются историческими данными и не являются authority. App source,
QualityControl engine, tests, runtime, CI и rollout в этом блоке не менялись.

Evidence блока 2.2: `audit-2026-09-05/implementation/2.2-prompt-routing.md`.

## Package ownership блока 2.3 — 2026-09-08

Канонический Documentation Vault обновлён и опубликован в коммите
`99124788b98faac34364704d3225be03b4bff777`. Добавлен `QC.PACKAGE.OWNERSHIP` и отдельный
`PACKAGE_OWNERSHIP_AND_ADOPTION_STANDARD.md`: reusable catalog описывает neutral capability,
revision/version policy и host-owned responsibilities; `PackagesInUse`, target membership,
adoption, migration, rollout и rollback принадлежат consuming app. Source-app adoption history
перенесена в `apps/Tchop/plans/package-adoption-audit.md`; старый 50-iteration roadmap оставлен
только historical reference. SDK/testing/privacy/verification templates теперь требуют risk-based
verification, explicit output/build/cache roots, permission state и URL classification.

App source, package source, QualityControl engine, tests, runtime, CI и rollout в этом блоке не
менялись.

Evidence блока 2.3: `audit-2026-09-05/implementation/2.3-package-ownership.md`.

## Toolchain/profile contract блока 3.1 — 2026-09-08

Documentation Vault опубликовал канонический commit
`aabeeb64a87801d12a31b896624f43c8769d7909`. Добавлен `IOS_TOOLCHAIN_PROFILE_STANDARD.md` с
project-owned профилем compiler/language mode/SDK/deployment/targets, strict concurrency и
default isolation, upcoming-feature stability, Observation, UIKit/SwiftUI bridge,
availability/fallback, iPhone/iPad/window scope и разрешённым verification route. В concurrency
правилах явно разделены async wait и CPU-bound work; `@MainActor` для UI-state не считается
нарушением сам по себе. Deployment target и beta API stable baseline автоматически не меняются.
Compatibility matrix, Rule ID catalog и active routes синхронизированы.

Evidence блока 3.1: `audit-2026-09-05/implementation/3.1-toolchain-profile.md`.

## Release/privacy/performance matrices блока 3.2 — 2026-09-08

Documentation Vault опубликовал канонический commit
`d88f1289772d5ed2abe06a8e44dd0d38f4d75208`. Добавлен
`IOS_RELEASE_PRIVACY_PERFORMANCE_MATRIX.md` с project-owned строками для upload floor и
deployment target, privacy manifest/API/SDK/data lifecycle, launch/interaction/frame/memory
budgets, iPhone/iPad/window и accessibility, а также отдельной experimental availability track
для Core AI/Foundation Models. Structural manifest PASS, screenshot, compilation и 250 ms hang
signal явно не считаются доказательством соответствующей готовности. Specialist docs и task routes
синхронизированы; cloud/infrastructure не добавлялись.

Evidence блока 3.2: `audit-2026-09-05/implementation/3.2-release-privacy-performance.md`.

## Global bootstrap/effective instruction inventory блока 4.1 — 2026-09-08

Documentation Vault опубликовал канонический commit
`35c3124ffc4025c0c9525e57a0c065032190ad33`. Bootstrap, portable snapshot, baseline и new-project
template теперь явно разделяют repository-root adoption, parent defense-in-depth, project-type
routing и opt-in QualityControl adoption. Read-only inventory
`audit-2026-09-05/implementation/4.1-effective-instruction-inventory.json` покрывает 15 текущих
worktrees: 14 markers, 10 portable markers, 0 nested overrides, 1 missing bootstrap и 3
marker-only worktrees без fallback. User-owned AGENTS не менялись; missing `panmodal-concurrency`
остаётся явным blocked adoption finding.

Evidence блока 4.1: `audit-2026-09-05/implementation/4.1-effective-instruction-inventory.md`.

## Manifest/boundary integrity блока 4.2 — 2026-09-08

Documentation Vault commits `48a0b88`, `c076ae3` and `398744c` перевели проверку app boundaries,
recovery evidence filtering and canonical quality metadata formatting на актуальный контракт:
каждый прямой non-hidden каталог `apps/<AppName>/` обязан иметь собственный `MANIFEST.md`, без
жёсткого списка имён. Root manifest остаётся результатом единственного генератора.

Активный consumer `/Users/Artem/.zenflow/worktrees/new-task-be0b` обновлён по missing/stale
baseline-файлам; overlays и local-only материал сохранены. После refresh: exact 177, overlays 31,
local-only 640, missing/stale/unexpected 0. Два проектных QC-скрипта классифицированы локальным
policy overlay, не promoted в reusable baseline.

Evidence блока 4.2: `audit-2026-09-05/implementation/4.2-manifest-boundary-integrity.md`.

## Neutral new-project scenario блока 4.3 — 2026-09-08

В ignored local-only runtime consumer пройден clean Git root → effective bootstrap → minimal
profile → neutral S01 request-ordering exercise → small cancellation change → static launcher →
routed handoff → continuation pass. Consumer `DisposableQualityScenario` не содержит Xcode target,
product backlog, backend, account, payment или release scope; quality-control adoption явно
`DEFERRED` до будущего реального consumer/pilot. Первоначальные routing gaps (top-level local docs
и отсутствующая governance link) исправлены локально без изменения reusable authority.

Evidence блока 4.3: `audit-2026-09-05/implementation/4.3-neutral-new-project.md`.

## QC source scope и membership блока 5.1 — 2026-09-08

QualityControl commit `1561dce56148e068bc1f682025ad984f55c9b64b2` сохранил explicit profile
`sourcePaths` отдельно от authenticated compiler membership. Build receipt теперь связывает
scheme/targets/configuration/destination, `declaredSourcePaths`, `compiledSourcePaths`, compiler
section count и bounded external source-looking input count с command identity. `QC.BUILD.MEMBERSHIP`
обязателен в build-evidence PASS; generated ownership остаётся отдельным gate, extension inputs
учитываются только по compiler evidence, package inputs считаются вне first-party списка. Empty,
unresolved, malformed, oversized, traversal/symlink escape и outside-scope состояния остаются
evidence-free `BLOCKED`. Acceptance cases записаны в QC `fixtures/build-membership/README.md`;
tests/build/runtime не запускались и test files не менялись.

Evidence блока 5.1: `audit-2026-09-05/implementation/5.1-scope-source-membership.md`.

## Swift lexical claims и disabled-test evidence блока 5.2 — 2026-09-08

QualityControl commit `0266873b68948b596903388eba28a125fcd8990e` заменил comment-only masking
bounded Swift lexical adapter. Он маскирует nested comments и normal/raw/multiline string text,
оставляет code inside interpolation видимым, сохраняет line positions и блокирует malformed
string/comment/interpolation вместо false PASS. `QC.STATIC.SWIFT_HOT_PATH` теперь явно является
lexical API policy ban: он не утверждает UI executor, runtime hot path или достаточность async
wrapper. `QC.TESTS.DISABLED` сообщает static disabled attributes и `XCTSkip` calls, а conditional
или platform scope помечает консервативно; target membership, known issues и selected/executed
runtime counts остаются отдельными evidence claims.

На clean QC `HEAD` обе Swift static checks дали PASS; passing disabled-test fixture дал PASS,
failing fixture дал ожидаемый FAIL с двумя findings. Прямые bounded lexer cases для comments,
strings, interpolation, nesting и malformed input прошли. Fixture directories не являются Git
roots, поэтому отдельный adapter invocation на них дал корректный BLOCKED и не был выдан за
fixture run. Test files, build, test runner, Xcode, Simulator, runtime и pilot не запускались.

Evidence блока 5.2: `audit-2026-09-05/implementation/5.2-swift-lexical-claims.md`.

## Catalog maturity и mode coverage блока 5.3 — 2026-09-08

QualityControl commit `d75a0d590836edb4dc0ed29ab9ccc5ad0ce9717b` поднял catalog version до
`1.1.0` и добавил обязательные `maturity.implemented`, `verified`, `wired`, `pilotEnabled` и
bounded `evidence` для всех 20 IDs. `implemented` больше не означает автоматически verification,
trusted mode wiring или pilot readiness. Wired отмечены только `QC.PROFILE.CONTRACT`,
`QC.STATIC.SOURCE_BOUNDARY`, `QC.STATIC.FORBIDDEN_ARTIFACT` и `QC.BUILD.MEMBERSHIP`; три Swift
deterministic gates verified на clean temporary Git fixture roots, остальные остаются pending, а
все pilot flags false до canary и consumer-pilot promotion.

New catalog validator blocks missing/malformed maturity, verified-without-evidence, and
pilot-enabled-without-verified-and-wired states. Six disposable fixture invocations produced the
expected PASS/FAIL exits. Это policy/metadata hardening; test runner, build, runtime, canary и pilot
не запускались.

Evidence блока 5.3: `audit-2026-09-05/implementation/5.3-catalog-maturity.md`.

## SwiftLint contract блока 6.1 — 2026-09-08

QualityControl commits `7b9958203f3c3b39d2e952aec36d4dced9462683` и corrective
`508381bd58ccf85580c89305c257d7ac351b7122` добавили отдельный `QC.LINT.SWIFTLINT` adapter. Он
проверяет pinned executable/version/digest, tracked YAML/digest, clean-HEAD source list,
`SCRIPT_INPUT_FILE_*`, JSON reporter, no-autocorrect, bounded timeout/output и path normalization.
Unapproved YAML suppressions и inline `swiftlint:disable/enable` не становятся PASS. Legacy
`QC.FORMAT.SWIFTFORMAT` явно означает Apple `swift-format`; SwiftFormat и SwiftLint остаются
отдельными инструментами. New gate implemented, но `verified=false`, `wired=false` и
`pilotEnabled=false` до real producer verification in 7.1 and consumer pilots in stage 8.

AST/JSON/diff и direct lexical/config contract checks PASS. Missing tool/config invocation корректно
BLOCKED с сохранённой source revision; SwiftLint executable не устанавливался и не запускался,
inert fixtures остаются unverified.

Evidence блока 6.1: `audit-2026-09-05/implementation/6.1-swiftlint-contract.md`.

## First-party warnings и concurrency diagnostics блока 6.2 — 2026-09-08

QualityControl local commit `6fde6fcac44371ce34c4d7e0fa3d520957d1e8d9` добавляет две проверки,
которые потребляют только стабильные structured `xcresult` reads из существующего authenticated
build boundary. `QC.BUILD.FIRST_PARTY_WARNINGS` и `QC.CONCURRENCY.DIAGNOSTICS` сопоставляют
selected target, exact source membership и toolchain-bound build artifacts. External/dependency,
generated и non-selected-target diagnostics не приписываются текущей revision; selected-target
diagnostic без подтверждённого membership даёт `BLOCKED`. Failed, partial, truncated, malformed,
empty-membership и unsafe-path cases остаются non-PASS. Text-log tail не является evidence.

В этой версии baseline предупреждений намеренно не создаётся и не угадывается: authenticated
first-party warning считается new и даёт `FAIL` до появления отдельного reviewed baseline
contract. Обе проверки catalog maturity имеют `implemented=true`, `wired=true`,
`verified=false`, `pilotEnabled=false`; engine verifier acceptance выполнена в 7.1, но real Xcode
wording, SwiftLint invocation и consumer/runtime verification остаются unverified.

Remote publication QC SHA пока не утверждена auto-review; local exact-SHA review и static checks
зафиксированы в receipt. Это не отменяет implementation evidence и не объявляет engine release.

Evidence блока 6.2: `audit-2026-09-05/implementation/6.2-first-party-warnings.md`.

## Verifier-test и bounded canary acceptance блока 7.1 — 2026-09-08

Пользователь отдельно разрешил создание, изменение и запуск engine tests для этой фазы. В QC
commit `b197bd5e8983b5c7cfd1d277dd2540d7bb352a15` исправлен unreachable precedence path для
concurrency-only diagnostics и добавлены только cases для новых invariants блока 6.2: source
normalization, external/non-selected/generated exclusion, malformed source, first-party warning,
concurrency-only failure, unattributed membership и public evidence-free terminal outcomes.

Baseline перед patch: 164 теста в 16 suites. Разрешённый итоговый QualityCore suite: **172 теста
в 16 suites, 0 failures**, Swift warnings-as-errors. `swiftc -parse` и `git diff --check` прошли;
exact diff review выполнен против `6fde6fc`. Synthetic canary ограничен authenticated engine
observations. Реальные `xcodebuild`, SwiftLint, app consumers, device/runtime, CI и external
review не запускались и остаются unverified до соответствующих pilot/review фаз.

Evidence блока 7.1: `audit-2026-09-05/implementation/7.1-verifier-test-acceptance.md`.

## Раздельная оценка генерации и detection блока 7.2 — 2026-09-08

Выполнены два отдельных Luna xhigh evaluation passes без передачи evaluator key generator или
blind detector. S01 использован как открытый пример: генератор получил PASS по initial correctness,
а blind detector обнаружил deliberate stale-write Gamma и не превратил Beta robustness concern в
ложный FAIL. S04 использован как holdout: ORBIT transactional replacement получил conditional
generation PASS, а blind detector правильно классифицировал ORBIT как PASS и NOVA с destructive
`delete → write` как FAIL. Evaluator key раскрыт только после фиксации findings.

Generation quality и detection quality записаны раздельно; combined score не создавался. Все
результаты desk/static: runtime, Swift compiler, persistence, UI, tests, build, consumer readiness
и production claims остаются unverified. S01/S04 receipts:
`audit-2026-09-05/implementation/7.2-s01-generation-detection.md` и
`audit-2026-09-05/implementation/7.2-s04-holdout-generation-detection.md`.

## Observations блока 0.3 — 2026-09-08

Таблица `audit-2026-09-05/implementation/0.3-luna-observations.md` — единственный компактный
task-level журнал наблюдений. Она не является telemetry platform и не превращает неизвестные
elapsed/usage в ноль. Для блоков 0.1–0.2 строки восстановлены из доступного task trace после
начала работы; поэтому эти два поля явно отмечены `unknown`, а будущие блоки должны записывать
их до patch, если runtime предоставляет значения.

## Проверенное состояние

- Documentation remote main до implementation: `28d11bb79457d62d7fd26cec2ccf5ab1edaccbc6`; SHA после блока 1.2: `9af48a9c61712fc66751e3c0270132f7f2aabb27`; текущий канонический SHA после блока 2.2: `b7a975b395e90937c38f86aa43c27a19c1108d29`.
- QC local main-active и remote `main`: `b197bd5e8983b5c7cfd1d277dd2540d7bb352a15`; remote SHA
  подтверждён после явного разрешения пользователя.
- Catalog: 16 implemented, 3 staged, 1 review-candidate. Наличие adapter не равно mode coverage/pilot readiness.
- Foundation, permissions, bounded evidence и canary существуют; не реализовывать их повторно.
- H format/privacy/signing/disabled-test уже реализованы; Swift source gates также добавлены. Остались scope/lexical accuracy, maturity/fixture mapping, SwiftLint, first-party warnings/concurrency diagnostics.
- I manual PR/governance сохраняется; per-change receipt — текущая операция, не одноразовый «готово».
- J: два разных consumer pilots, rollback/idempotence и rollout не завершены.
- Исторические app source blockers требуют свежей проверки в отдельном app scope.

## Сохраняемые ограничения

- Пользователь отдельно управляет созданием, изменением и запуском тестов, UI/Simulator/Instruments, CI/review. Отказ/отсутствие запуска не PASS.
- CI и Codex Review ручные, advisory; отсутствие запуска само по себе не вводит mandatory merge block. Branch protection отложена.
- Не использовать платные runners/API/services или автоматические расходы.
- Policy weakening, HIGH/CRITICAL exceptions, release/promotion и новые consumers требуют соответствующего пользовательского решения.
- Scope reset 2026-08-11 сохраняется по смыслу: новая engine сложность должна устранять реальный false-pass/false-fail/permission/usefulness gap. Hostile-runner attestation, hooks, automated scoring и telemetry platform не возобновляются автоматически.
- App facts/ADR/exceptions остаются у приложения; generic standards — в Documentation; исполняемый код — в QualityControl.
- Глобальные инженерные правила и opt-in adoption engine — отдельные механизмы.
- В текущем блоке разрешены аудит и план. Предыдущая история разрешений не используется для незапрошенной реализации вместо результата аудита.

## Нейтральные сценарии блока 0.4 — 2026-09-08

Спецификация и evaluator-only key разделены: `implementation/0.4-neutral-scenarios.md` можно
передавать generator/detector после удаления evaluator metadata, а
`implementation/0.4-scenario-answer-key.md` не входит в routed input. Сценарии не являются
тестовым кодом, benchmark runner или доказательством качества Luna. Holdout-варианты отмечены
отдельно и требуют свежего разрешённого контекста для слепого detector review.

## Следующие этапы

- [x] 0.1: authority/current state и четыре владельца — Luna xhigh.
- [x] 0.2: свежий baseline evidence — Luna xhigh.
- [x] 0.3: ранние observations работы Luna — Luna xhigh; первые два значения времени/usage unknown.
- [x] 0.4: пять нейтральных сценариев и отдельный evaluator key — Luna xhigh; runtime/test не выполнялись.
- [x] 1.1: единый severity/readiness/exception contract — Luna xhigh.
- [x] 1.2: Rule ID и минимальный exception metadata contract для активных норм — Luna xhigh.
- [x] 2.1: invariants и архитектурный выбор — Luna xhigh.
- [x] 2.2: prompts и specialist routes — Luna xhigh.
- [x] 2.3: architecture/prompts/skills/package ownership — Luna xhigh.
- [x] 3.1: toolchain/isolation/availability contract — Luna xhigh.
- [x] 3.2: release/privacy/performance matrices — Luna xhigh.
- [x] 4.1: global bootstrap/effective instruction inventory — Luna xhigh.
- [x] 4.2: manifest, ссылочная целостность и dynamic app boundaries — Luna xhigh.
- [x] 4.3: нейтральный new-project сценарий — Luna xhigh.
- [x] 5.1: QC source scope и source membership — Luna xhigh.
- [x] 5.2: Swift patterns и disabled-tests claims — Luna xhigh.
- [x] 5.3: catalog maturity и честное mode coverage — Luna xhigh.
- [x] 6.1: SwiftLint config/contract — Luna xhigh.
- [x] 6.2: first-party warnings и concurrency diagnostics — Luna xhigh; опубликовано в QC remote SHA `b197bd5`.
- [x] 7.1: разрешённая verifier-test/canary acceptance phase — Luna xhigh; 172/16 PASS, QC remote SHA `b197bd5` подтверждён.
- [x] 7.2: раздельная оценка генерации и detection ошибок — Luna xhigh; S01 open + S04 holdout, desk/static only.
- [x] 8.1: простой consumer pilot — Luna xhigh; MVVMExample static pin/adapters PASS, runtime/build не заявлены.
- [ ] 8.2: сложный multi-target consumer pilot — Luna xhigh.
- [ ] 8.3: готовность подготовки к будущему продуктовому проекту — Luna xhigh.
- [ ] 9.1: promotion/release contract — Luna xhigh.
- [ ] 9.2: existing/future project adoption — Luna xhigh.
- [ ] 10.1: context budget и повторное использование evidence — Luna xhigh.
- [ ] 10.2: калибровка процесса Luna xhigh — Luna xhigh.
- [ ] 11.1: итоговый semantic audit — Luna xhigh.
- [ ] 11.2: лёгкая поддержка и recovery — Luna xhigh.

Следующий implementation block: 8.2 — сложный multi-target consumer pilot.
Конкретика и критерии приёмки находятся в подробном roadmap. Ни один implementation checkbox не
помечается выполненным только потому, что написан план.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Pilot → promotion: каждый из двух consumers закрывает полную матрицу этапа 8 roadmap, включая разрешённый runtime mode, local/GitHub parity и pre-PR receipt. Missing/denied evidence оставляет pilot partial и блокирует обычный stable promotion; запуск этим требованием не разрешается. Более узкий release требует отдельного явного решения пользователя.

## Принятые улучшения подготовки — 2026-09-07
Продуктового проекта пока нет; текущие apps — испытательные consumers. План теперь содержит 30 блоков. Добавлены 0.3 (ранние observations Luna), 0.4 (нейтральные сценарии/критерии), 4.3 (new-project flow), 7.2 (generation и detection отдельно), 8.3 (готовность подготовки). Все исполняются Luna xhigh. Блоки 0.1 → 8.1 закрыты task-level evidence; следующий 8.2. 8.1 изменил только MVVMExample quality pinning и не создаёт build/runtime/release claim.

Готовность подготовки по 8.3 отделена от stable QC release: обязательные два pilots и вся матрица этапа 8 сохранены. Массовые миграции остальных пробных apps не являются автоматическим prerequisite начала будущего проекта. Этап 10 использует данные с 0.3, а не начинает измерения с нуля.
