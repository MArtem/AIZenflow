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
Прогресс реализации: **27 из 30 блоков (90%)**; это не процент production readiness.

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
- [ ] 8.2: сложный multi-target consumer pilot — Luna xhigh; unsupported German boundary, QC pin,
  семь clean-snapshot adapters, six-scheme Debug builds, app smoke launch, positive/negative QC
  fixtures, reversible bootstrap, structural schema-v2/profile validation, explicit-source static
  PASS, bounded host fixture build/install PASS и user-confirmed GitHub parity PASS for PR #24.
  Doctor effective-settings PASS, bounded Share provider/extension lifecycle/accessibility is
  PASS_WITH_LIMITATION, while graph-scoped static-evidence и pre-PR review остаются открыты; physical-device
  VoiceOver gate is closed by explicit owner decision because no physical device is available, with no
  hardware traversal claim; test-target compilation после authorized repair PASS.
- [x] 8.3: готовность подготовки — Luna xhigh; READY_WITH_ACCEPTED_RISK для начала требований/design, NOT_READY для stable QC, NOT_ASSESSABLE для продукта.
- [x] 9.1: promotion/release contract и bounded decision options — Luna xhigh; contract recorded,
  фактическая promotion/release операция не выполнялась.
- [x] 9.2: existing/future project adoption — Luna xhigh; bounded consumer-local adoption
  revalidated with exact QC pin and rollback boundary; PR #24 merged and GitHub parity user-confirmed
  PASS; sibling/remote mutation и broad bootstrap apply не выполнялись.
- [x] 10.1: context budget и повторное использование evidence — Luna xhigh; PASS_WITH_LIMITATION, route budget в норме, billed-token reduction не заявлена.
- [x] 10.2: калибровка процесса Luna xhigh — Luna xhigh; PASS_WITH_LIMITATION, targeted route default, broad route только для cross-cutting audit.
- [x] 11.1: итоговый semantic audit — Luna xhigh; PASS_WITH_LIMITATION, F01–F24 и 67 archive decisions mapped, stable promotion NOT_READY.
- [x] 11.2: лёгкая поддержка и recovery — Luna xhigh; PASS_WITH_LIMITATION, trigger-based без automation, stable release не активируется.

Все независимые preparation blocks 0.1–11.2 зафиксированы task-level evidence. Открытым
consumer/promotion gate остаётся 8.2 только до fresh current-head GitHub parity; 9.1 закрыт как contract/options artifact, а 9.2 закрыт
как bounded adoption revalidation с ограничениями. Фактическая promotion по-прежнему запрещена
до полного 8.2 и owner-selected release decision. Ни один implementation checkbox не помечается
выполненным только потому, что написан план.

**перечитать весь актуальный набор документации и правил для этого worktree и task-контекста**

Pilot → promotion: каждый из двух consumers закрывает полную матрицу этапа 8 roadmap, включая разрешённый runtime mode, local/GitHub parity и pre-PR receipt. Missing/denied evidence оставляет pilot partial и блокирует обычный stable promotion; запуск этим требованием не разрешается. Более узкий release требует отдельного явного решения пользователя.

## Graph-scoped static evidence и финальный review блока 8.2 — 2026-09-10

После merge QC PR #26 и consumer pin `802b4833c3c7cebb1c7e920b964451587a0bab42` graph-scoped
`quality graph-static-evidence` прошёл на consumer HEAD
`e201fc8a5e6aeffec2f0455225f9e50f81df815b`: Release / `TchopApp` / `generic/platform=iOS Simulator`,
profile SHA256 `4cbcfe62c8bb38388bd81db33f438a004ee38306410224bd36a298032eef9fbe`, engine CDHash
`d25b665789eeef1ec60f14b3ae2e8577f3bb62a8`, 159 compiled inputs, 26 compiler sections and 0 external
inputs. `QC.PROFILE.CONTRACT`, `QC.POLICY.CONTRACT`, `QC.STATIC.SCAN` и verifier `READY` — PASS.
Bounded doctor на том же pin подтверждает repository/source/sandbox boundaries, Xcode graph selection и
effective settings; его общий envelope остаётся BLOCKED только на отдельном membership gate, который
закрыт этой graph receipt. Independent pre-PR review cumulative engine diff `1035b95..802b4833` returned
no P0–P3 findings. Physical-device VoiceOver остаётся закрытым только explicit owner decision; hardware
traversal не заявляется.

Receipt: `audit-2026-09-05/implementation/8.2-graph-static-evidence-802b-2026-09-10.json` и
`audit-2026-09-05/implementation/8.2-doctor-802b-2026-09-10.json`. Block 8.2 now has no local implementation
or review blocker; it remains unchecked only until the user runs the manual GitHub workflow for the pushed
current HEAD and parity is recorded against that exact revision. No production promotion is implied.

## Runtime continuation блока 8.2 — 2026-09-09

Пользователь отдельно разрешил runtime/full matrix на Luna xhigh. Для Tchop HEAD
`e24b7c8be50aad8777c47116b8ccb1e4ab3a9977` последовательно собраны шесть Debug schemes на iPhone
17 Pro/iOS 26.5; clean signed-out и authenticated smoke launch прошли после исправления
`AppState` session-restore race. QC engine `b197bd5e` собран с CDHash
`84ba17cfe7fcc7fd3ea7d551b07bbaba4f6dd555`. Positive/negative static fixtures и synthetic
inventory → dry-run → apply → post-check → repeat → rollback lifecycle дали ожидаемые статусы.
Это расширяет evidence 8.2, но не закрывает block: app-local profile patch теперь согласован с
фактическими engine version/target graph и переносит QC cache внутрь `TchopApp` source boundary.
Explicit-source static scan PASS; supervised exact-SHA `build-evidence` PASS с
`QC.BUILD.MEMBERSHIP`, first-party warnings и concurrency diagnostics. `validate-profile` и
`static-evidence` всё ещё останавливаются на `QC.PROFILE.XCODE_GRAPH_RESOLUTION_REQUIRED` /
`QC.STATIC_EVIDENCE.INVALID_PROFILE`; bounded doctor aggregate остаётся blocked на effective
settings. Authorized test-source repairs применены, unit tests и все 7 UI tests проходят.
Extension lifecycle, VoiceOver, GitHub parity и pre-PR review ещё не выполнены. Поэтому 8.2, 9.1
и 9.2 остаются открытыми; production readiness или stable QC promotion не заявляются.

## Authorized test-source repair — 2026-09-09

Пользователь разрешил bounded изменение только test-source файлов:
`TchopAppTests/TestDoubles/TestAppContentRepository.swift` и
`TchopAppTests/NewsFeedViewModelTests.swift`, а затем
`TchopAppUITests/TchopAppUITests.swift`. Test double приведён к user-scoped
`FeedCardPersisting`; затронутые store tests активируют `test-user`, а direct repository tests
передают user identifier. `git diff --check`, stale-signature search, parse-only Swift syntax
validation и affected call-site audit дали PASS: все четыре direct store setup активируют
`test-user`.

Повторный xcodebuild дал unit-test PASS (`TchopAppTests`), UI-test build PASS и UI execution PASS:
7 из 7 UI tests завершились без failures после обновления test helper для Create → New post.
Production source и Xcode project не менялись. Это закрывает test verification gate, но не 8.2 целиком.

## Promotion/release contract блока 9.1 — 2026-09-09

Receipt: `audit-2026-09-05/implementation/9.1-promotion-release-contract.md`. Contract shape,
compatibility/support/rollback rows and current Apple compliance inputs are recorded. Verdict is
`BLOCKED / NOT_READY`: 8.2 is still partial, no exact approved release candidate exists, the
implementation commit has not been re-authenticated as a release candidate, and no
promotion/release approval was requested. No tag, signing, archive upload, TestFlight delivery or
App Store action was performed.

## Existing/future adoption contract блока 9.2 — 2026-09-09

Receipt: `audit-2026-09-05/implementation/9.2-adoption-inventory-receipt.json`. The historical
inventory grouped 15 worktrees into 6 canonical Git identities; the latest bounded recheck is
bound to consumer HEAD `87d6ce2e`. The tracked consumer state is clean and the read-only result groups
the roots into
canonical Git identities and separates Documentation Vault,
QualityControl engine/canary repositories, current AIZenflow consumers, MVVMExample and PanModal,
and confirmed that global rules are distinct from explicit QC profile adoption. Verdict is
`PASS_WITH_LIMITATION`: inventory, conflict boundary, and consumer-local opt-in adoption are
complete; cross-repository apply, idempotence and rollback for sibling/future roots remain
unexecuted because no broad mutation was authorized. No sibling worktree or remote repository was
changed.

## Принятые улучшения подготовки — 2026-09-07
Продуктового проекта пока нет; текущие apps — испытательные consumers. План теперь содержит 30 блоков. Добавлены 0.3 (ранние observations Luna), 0.4 (нейтральные сценарии/критерии), 4.3 (new-project flow), 7.2 (generation и detection отдельно), 8.3 (готовность подготовки). Все исполняются Luna xhigh. Блоки 0.1 → 8.1, 8.3, 10.1, 10.2, 11.1 и 11.2 закрыты task-level evidence; 8.2 расширен runtime/build/QC/bootstrap evidence, но остаётся partial из-за Xcode graph/build-evidence, extension/accessibility и parity blockers; test-target compilation после authorized repair PASS. 8.3, 10.1, 10.2, 11.1 и 11.2 не обходят phase-8/9 promotion gates и не создают product/build/runtime claim.

Готовность подготовки по 8.3 отделена от stable QC release: обязательные два pilots и вся матрица этапа 8 сохранены. Массовые миграции остальных пробных apps не являются автоматическим prerequisite начала будущего проекта. Этап 10 использует данные с 0.3, а не начинает измерения с нуля.

## Latest continuation — 2026-09-09

Consumer branch `codex/tchop-qc-gates` теперь содержит bounded standalone Share host fixture and
accessibility identifiers in commit `6a96f97d88a1486b9976c7e72d5c97273c24048b`. Host fixture and
TchopApp Debug builds, installation, structural `validate-profile`, and explicit-source static
scan pass. Targeted UI execution was attempted twice with `TCHOP_SHARE_HOST_FIXTURE=1` and remains
blocked at exit 70 because CoreSimulatorService made the known booted destination unavailable;
Share activation and VoiceOver are not claimed.

QC schema-v2/doctor changes are pinned to engine `bc2072b76df41a653f204861d60d9d602ac999af` and
are pushed on `codex/schema-v2-doctor`. Doctor now fails only at effective Xcode settings in this
environment; the profile/repository/source/sandbox checks pass. At that pre-merge point the
consumer branch was not yet pushed and GitHub workflow parity was manual-only; the post-merge
continuation below records the completed publication and run.

Promotion/release options are recorded in
`audit-2026-09-05/implementation/9.1-promotion-release-options-2026-09-09.md`. No release action
is authorized by those options. 9.2 is closed as `PASS_WITH_LIMITATION` for bounded consumer-local
adoption revalidation; sibling mutation and broad bootstrap apply remain unexecuted. GitHub parity
is recorded in the post-merge continuation below.

## Post-merge continuation — 2026-09-09

PR #23 was merged into `main` as `16ae3f4ff7892d567eb0b4c89f775cd1d3685880`. The manually
dispatched GitHub Actions `Repository static gate` for consumer head
`0be8a1728cb8e6d2737bf12cae0c03bd45ac1e4e` completed with `success` (run `34390669850`).
Therefore `parity.local-github` is now PASS. The implementation plan has 29 of 30 checkboxes
closed; the only open block is 8.2, with four remaining sub-gates: graph-scoped static-evidence,
doctor effective settings, Share Extension/VoiceOver runtime, and pre-PR independent review.
The QC engine branch `codex/schema-v2-doctor` was merged through PR #25:
https://github.com/MArtem/AIZenflowQualityControl/pull/25, producing merge commit
`1035b95273795bee8be242239036b45ec7e7ceff`; the tested tree head is
`c0e7eb3d1badde0d11894e5ec1fccdd2c2c21880`. Independent re-review after the symlink fix returned no
findings, and local QC verification is 176 tests / 16 suites PASS. The consumer pin update is
prepared separately on the continuation branch; merge does not make 8.2 complete.

## QC engine adoption continuation — 2026-09-09

Consumer commit `b2f1bfe2e6b89ab7e98499e1c9f9a6a3a581e071` updates `.quality-control/profile.json`
and `.github/workflows/manual-quality.yml` from the pre-fix engine revision to merged-and-tested
`c0e7eb3d1badde0d11894e5ec1fccdd2c2c21880`. JSON validation, old-pin absence, and `git diff --check`
pass. The pin update is pushed in consumer PR #24:
https://github.com/MArtem/AIZenflow/pull/24. After the user dispatches its manual workflow,
that run is the next parity check. Graph-scoped static-evidence, doctor effective settings, and Share
Extension/VoiceOver runtime remain blocked in the local environment.

## Runtime/QC continuation — 2026-09-09

Merged-engine doctor `c0e7eb3d1badde0d11894e5ec1fccdd2c2c21880` now passes effective Xcode settings;
source membership remains a separate BLOCKED evidence boundary. Graph-scoped static-evidence remains
BLOCKED at `QC.PROFILE.XCODE_GRAPH_RESOLUTION_REQUIRED`; receipts are recorded in the 8.2 audit
implementation directory.

The bounded Share host UI test repair is committed at `6ce1073cb5c4b4b015d745e7dc92bfc5f359a3d1`.
The test now follows the actual system hierarchy (`Cell` and `More`). A fresh installed app and a
rebooted iPhone 17 Pro Simulator still expose only `Reminders` and `TchopApp` in the Apps list;
`Tchop Share` is not registered. Share lifecycle and VoiceOver remain BLOCKED, with no false PASS.
The current head requires a fresh manual workflow dispatch before the previous parity result can be
reused. Pre-PR independent review remains open.

## Runtime/QC continuation — 2026-09-09 follow-up

The bounded Share host fixture was re-run after consumer commit
`52a6af81a33de6c21b6e434ada93eb5d5752fbdc`. The system activity provider is rendered with the
containing-app label `TchopApp`; selecting it launched `com.example.TchopApp.share`, exposed the
extension screen, and exposed a non-empty/hittable Close control that completed the request.
Build-for-testing and the targeted UI test passed. The authoritative receipt is
`audit-2026-09-05/implementation/8.2-share-extension-runtime-receipt-2026-09-09.json` and the
result bundle is `runtime/tchop-8-2/share-host-fixture/ShareExtensionAccessibilityContract.xcresult`.

The extension lifecycle/accessibility row is now `PASS_WITH_LIMITATION`: Simulator hierarchy and
interaction are verified, while physical-device VoiceOver traversal remains required because
Apple does not provide VoiceOver on iOS Simulator. Block 8.2 remains open only for graph-scoped
static-evidence, source-membership evidence, physical-device VoiceOver, and independent pre-PR
review. The current consumer head still requires a fresh manual workflow dispatch before GitHub
parity evidence can be reused.

## QC evidence continuation — 2026-09-09 current head

Current consumer HEAD `8fc0fae84b3c847c1f891a9e742b69d568cb4f70` passed authenticated merged-engine
`build-evidence` for the declared `TchopApp` Debug / iPhone 17 Pro selection. `QC.BUILD`,
`QC.BUILD.MEMBERSHIP`, `QC.BUILD.FIRST_PARTY_WARNINGS`, and `QC.CONCURRENCY.DIAGNOSTICS` all pass;
the receipt reports 159 in-repository compiled inputs, 210 compiler sections, and 0 external inputs:
`audit-2026-09-05/implementation/8.2-build-evidence-c0e7-current-2026-09-09.json`.

Current-head graph-scoped `static-evidence` was re-run and remains blocked only at
`QC.PROFILE.XCODE_GRAPH_RESOLUTION_REQUIRED`. The separate build/source-membership evidence is now
PASS. Receipt:
`audit-2026-09-05/implementation/8.2-static-evidence-c0e7-current-2026-09-09.json`.

The remaining 8.2 gates are graph-scoped static-evidence, physical-device VoiceOver traversal,
and independent pre-PR review. A fresh manual GitHub workflow dispatch is still required before
the prior parity result can be reused for the current head.

## Merge continuation — 2026-09-10

The user confirmed that the Manual Quality Check for consumer PR #24 completed successfully.
GitHub confirms PR #24 merged into `main` as `ad0e3c545ff3a9918ced9829b4de344ee5c1ca71` from
reviewed head `da41b11a7fc7bb1bd555c97d0b40f74cf58925c7`. The bounded consumer-local adoption and
manual parity step are therefore closed as user-confirmed PASS; the workflow run identifier was
not captured in the local task receipts. The plan remains 29 of 30 checkboxes closed, with 8.2 as
the only open block. Its remaining gates are graph-scoped static-evidence, physical-device
VoiceOver traversal, and independent pre-PR review. No promotion, release, archive, signing,
TestFlight, App Store, or stable QC promotion is claimed.

## Owner decision continuation — 2026-09-10

The user explicitly accepted the physical-device VoiceOver gate as complete for this task because no
physical iOS device is available. The authoritative receipt is
`audit-2026-09-05/implementation/8.2-voiceover-owner-decision-2026-09-10.json`. The bounded Simulator
fixture remains `PASS_WITH_LIMITATION`; no physical traversal, VoiceOver focus/announcement/rotor
claim, or production accessibility readiness claim is made. 8.2 therefore remains open only for
graph-scoped schema-v2 static-evidence acceptance and independent pre-PR review.

The QC engine graph-static implementation is committed and pushed at
`MArtem/AIZenflowQualityControl` commit `f974ef58ec3ba0b13341e4ac59e617dd5ea97ce3` on branch
`codex/graph-static-evidence`; [PR #26](https://github.com/MArtem/AIZenflowQualityControl/pull/26)
is open against `main`. The consumer pin/adoption and graph receipt must follow engine merge; no
graph PASS is claimed from the implementation commit alone.
