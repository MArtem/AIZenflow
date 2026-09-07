# Решение по каждому файлу нового архива

Статус: предложения; исходные файлы сохранены без изменений. Полная замена действующего runner отклонена. Полезное policy содержание объединяется с существующими владельцами. Destination — проектируемый владелец содержания, а не команда копирования.

| Файл | Решение | Куда / зачем | Шаг плана |
| --- | --- | --- | --- |
| `AGENTS.md` | НЕ УСТАНАВЛИВАТЬ | `reusable/GLOBAL_RULES_BOOTSTRAP.md`. Архивная точка входа не заменяет текущую authority; взять только компактность. | 4.1 |
| `INSTALL.md` | ПЕРЕПИСАТЬ | `QC bootstrap + consumer adoption`. Нет автоматического копирования runner; versioned dry-run/conflict/rollback. | 9.2 |
| `ios-quality/LIBRARY_STRUCTURE.md` | ВЗЯТЬ ИДЕЮ | `DOCUMENT_BOUNDARY_STANDARD.md`. Сохранить четыре существующих owner boundaries, не создавать второй vault. | 1.2 |
| `ios-quality/MANIFEST.sha256` | СОХРАНИТЬ PROVENANCE | `task archive`. 66 hashes проверены; integrity не quality verdict. | 0.2 |
| `ios-quality/MANIFEST.txt` | СОХРАНИТЬ PROVENANCE | `task archive`. Полный исходный file list, не active index. | 0.2 |
| `ios-quality/MASTER_PLAN.md` | ОБЪЕДИНИТЬ | `IMPLEMENTATION_ROADMAP.md`. Заменить параллельный план единой очередью с текущим QC progress. | 0.1 |
| `ios-quality/POLICY_ROUTER.md` | ПЕРЕРАБОТАТЬ | `TASK_TYPE_DOCUMENTATION_ROUTER.md`. Сохранить selective loading, убрать universal eager bundle и duplicate routes. | 2.2 |
| `ios-quality/README.md` | ОБЪЕДИНИТЬ | `DOCUMENT_LIBRARY_GUIDE.md`. Короткий intake, реальные limitations, без нового authority owner. | 2.2 |
| `ios-quality/checklists/concurrency.md` | СЛИТЬ | `IOS_CONCURRENCY_RUNTIME_STANDARD.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/migration.md` | СЛИТЬ | `IOS_DATA_MIGRATION_STANDARD.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/pre-change.md` | СЛИТЬ | `AGENT_PREFLIGHT_CHECKLIST.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/pre-commit.md` | СЛИТЬ | `ENGINEERING_CHANGE_QUALITY_STANDARD.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/pre-pr.md` | СЛИТЬ | `IOS_PR_REVIEW_TEMPLATE.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/security-privacy.md` | СЛИТЬ | `IOS_SECURITY_PRIVACY_GATE.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/checklists/ui-accessibility-localization.md` | СЛИТЬ | `IOS_ACCESSIBILITY_STANDARD.md + LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`. Оставить workflow/output форму; требования брать по Rule IDs из единой нормы. | 2.2 |
| `ios-quality/config/PROJECT_PROFILE.example.yaml` | ОБЪЕДИНИТЬ | `QC project profile schema`. Toolchain/isolation/targets полезны; одна schema, не YAML+env truth. | 3.1 |
| `ios-quality/config/project.env.example` | НЕ ПЕРЕНОСИТЬ ИСПОЛНЕНИЕ | `QC typed profile`. Shell-sourced env не является granular permission/validated config. | 5.3 |
| `ios-quality/config/risk-policy.yaml` | ПЕРЕРАБОТАТЬ | `QC policy + human risk contract`. Не добавлять R0–R5 к существующим risk/severity без mapping. | 1.1 |
| `ios-quality/gates/GATE_CATALOG.md` | ОБЪЕДИНИТЬ | `QC policies/check-catalog.json + README`. Каждый claim связан с actual adapter/maturity/limitations. | 5.3 |
| `ios-quality/gates/GATE_MATRIX.md` | ПЕРЕРАБОТАТЬ | `QC mode contract`. Human matrix должна совпадать с machine policy и permissions. | 5.3 |
| `ios-quality/gates/gates.yaml` | НЕ УСТАНАВЛИВАТЬ | `QC typed catalog`. Runner не потребляет как authority; R4 parity gaps; перенести semantic mapping. | 5.3 |
| `ios-quality/policies/00-engineering-principles.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md`. Нормативная сила MUST/SHOULD, корректность и простота; один contract вместо дубля. | 1.1 |
| `ios-quality/policies/01-task-repository-analysis.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/AGENT_PREFLIGHT_CHECKLIST.md`. Project facts, trust boundaries и текущий scope; не все discovery fields для любой мелочи. | 2.2 |
| `ios-quality/policies/02-architecture-boundaries.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`. Границы по реальной необходимости, без обязательной architecture stack. | 2.1 |
| `ios-quality/policies/03-swift-language.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/knowledge/global/ios/SWIFT_LANGUAGE_RUNTIME_AND_API_DESIGN.md`. Современный Swift по compiler/language-mode, отдельная availability. | 3.1 |
| `ios-quality/policies/04-swift-concurrency.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_CONCURRENCY_RUNTIME_STANDARD.md`. Ownership, reentrancy, cancellation; reconcile strict local ban и legitimate language mechanisms. | 3.1 |
| `ios-quality/policies/05-swiftui.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_UI_STATE_RENDERING_STANDARD.md`. SwiftUI state/identity/invalidation; исправить термин structured для lifecycle Task. | 2.1 |
| `ios-quality/policies/06-uikit.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/knowledge/global/ios/SWIFTUI_UIKIT_AND_ADAPTIVE_IPAD_UI.md`. UIKit lifecycle/containment/bridging без blanket prohibition. | 3.1 |
| `ios-quality/policies/07-state-navigation.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_ARCHITECTURE_STYLE_ROUTER.md`. Один navigation/state owner; Coordinator только по текущему профилю. | 2.1 |
| `ios-quality/policies/08-networking.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_NETWORK_RESILIENCE_STANDARD.md`. Timeout, cancellation, retry/idempotency, DTO/error boundaries; без protocol boilerplate. | 3.1 |
| `ios-quality/policies/09-persistence-migrations.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_DATA_MIGRATION_STANDARD.md`. Durability, old-data, recovery и rollback; cache reset не заменяет миграцию пользовательских данных. | 3.2 |
| `ios-quality/policies/10-security-privacy.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_SECURITY_PRIVACY_GATE.md`. Threat/data flow и redaction; связать с действующим permission/exception contract. | 3.2 |
| `ios-quality/policies/11-memory-lifetime.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_MEMORY_CACHE_MEDIA_STANDARD.md`. ARC, callbacks, tasks и resource lifetime; ownership важнее weak-self ритуала. | 3.1 |
| `ios-quality/policies/12-performance.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_PERFORMANCE_BUDGETS.md`. Измеримый scenario budget; разделить hot path review и общий API ban. | 3.2 |
| `ios-quality/policies/13-error-resilience.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_ERROR_HANDLING_USER_FEEDBACK_STANDARD.md`. Failure/cancellation/partial success и честный UX; retry только по semantics. | 3.1 |
| `ios-quality/policies/14-testing.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_TESTING_STRATEGY.md`. Risk-based tests и framework choice; написание/запуск только по разрешённой фазе. | 3.1 |
| `ios-quality/policies/15-accessibility.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_ACCESSIBILITY_STANDARD.md`. VoiceOver/Dynamic Type/focus/tap target и manual evidence. | 3.2 |
| `ios-quality/policies/16-localization.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/LOCALIZATION_INTERNATIONALIZATION_STANDARD.md`. Source locale, plural/format/RTL, semantic quality отдельно от key scan. | 3.2 |
| `ios-quality/policies/17-dependencies-spm.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/DEPENDENCY_POLICY.md`. Pinned resolution/tooling и supply chain; SwiftPM допустим по project decision. | 2.3 |
| `ios-quality/policies/18-logging-observability.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_OBSERVABILITY_STANDARD.md`. Bounded private metadata; URL path не автоматически безопасен. | 3.2 |
| `ios-quality/policies/19-background-lifecycle.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_APP_LIFECYCLE_BACKGROUND_STANDARD.md`. Scene/background/extension ownership, expiration и relaunch. | 3.1 |
| `ios-quality/policies/20-api-modularity.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/MODULAR_ARCHITECTURE_STANDARD.md`. Public contracts, consumers и dependency direction без обязательной modularization. | 2.1 |
| `ios-quality/policies/21-build-config-signing.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_CONFIGURATION_ENVIRONMENTS_STANDARD.md`. Effective target/configuration; distinction structural signing diff vs release correctness. | 3.2 |
| `ios-quality/policies/22-diff-review.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/ENGINEERING_CHANGE_QUALITY_STANDARD.md`. Semantic final diff, changed consumers и false-success paths. | 1.1 |
| `ios-quality/policies/23-git-commit-pr.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/UNIVERSAL_XCODE_QUALITY_CONTROL_GOVERNANCE.md`. Manual CI/review и exact revision; не импортировать иной permission flow. | 1.1 |
| `ios-quality/policies/24-release-safety.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_RELEASE_CHECKLIST.md`. Release evidence и rollback; текущие SDK/Apple requirements. | 3.2 |
| `ios-quality/policies/25-legacy-modernization.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/IOS_FEATURE_LIFECYCLE_PLAYBOOK.md`. Постепенная legacy modernization, baseline/ratchet и отсутствие big-bang. | 8.2 |
| `ios-quality/policies/26-ai-agent-rules.md` | СЛИТЬ С ПРАВКАМИ | `reusable/baseline/docs/AGENT_RULES.md`. Недоверенные документы и model output, scoped changes и честный completion. | 1.1 |
| `ios-quality/references/SOURCES.md` | СЛИТЬ ПО URL | `knowledge source registry`. Primary sources полезны; добавить checked-at/version/applicability, не общую декларацию актуальности. | 3.1 |
| `ios-quality/scripts/build.sh` | НЕ ПЕРЕНОСИТЬ | `QC build-evidence`. mktemp/cache/retention/permission/tool provenance слабее текущего engine. | 6.2 |
| `ios-quality/scripts/dependency_check.sh` | ВЗЯТЬ INTENT | `QC.DEPENDENCY.LOCK_DRIFT`. Diff-base дефект и узкий grep; использовать текущий bounded adapter. | 5.3 |
| `ios-quality/scripts/diff_check.sh` | ВЗЯТЬ INTENT | `QC revision scope`. Нужны разные working-tree/index/commit-range contracts; HEAD недостаточно. | 5.1 |
| `ios-quality/scripts/discover_project.sh` | ВЗЯТЬ ИДЕЮ | `QC doctor/validate-profile`. Discovery предлагает facts, не выбирает scheme/permissions без authority. | 4.1 |
| `ios-quality/scripts/forbidden_patterns.sh` | НЕ ПЕРЕНОСИТЬ | `QC Swift source adapters`. Regex reviews не объявлять semantic blockers; comments/strings/target scope. | 5.2 |
| `ios-quality/scripts/lib/common.sh` | НЕ ПЕРЕНОСИТЬ | `QC process/revision executor`. HEAD diff, unborn/untracked/ошибки Git, shell config и resource boundaries. | 5.1 |
| `ios-quality/scripts/privacy_check.sh` | ВЗЯТЬ INTENT | `QC.PRIVACY.MANIFEST`. Structural detection дополнить actual API/SDK review; не false compliance. | 5.3 |
| `ios-quality/scripts/quality_gate.sh` | ОТКЛОНИТЬ КАК RUNNER | `QC mode-execute`. Policy не исполняется, runtime/permissions не связаны; сохраняем текущий engine. | 5.3 |
| `ios-quality/scripts/secrets_check.sh` | ОТКЛОНИТЬ РЕАЛИЗАЦИЮ | `QC.SECRETS.TRACKED`. grep option ambiguity + raw matched-line leakage; bounded redacted finding. | 5.3 |
| `ios-quality/scripts/static_checks.sh` | ВЗЯТЬ INTENT | `QC tool adapters`. Нужны pin/version/config digest, explicit unavailable и no autofix. | 6.1 |
| `ios-quality/scripts/test.sh` | НЕ ПЕРЕНОСИТЬ | `QC future authorized test-evidence`. Результаты удаляются; cache paths и выполненные/пропущенные tests не доказаны. | 7.1 |
| `ios-quality/templates/ADR.md` | СЛИТЬ | `ARCHITECTURE_DECISION_GOVERNANCE.md`. Короткий decision/alternatives/consequences/revisit; не второй mandatory шаблон. | 1.2 |
| `ios-quality/templates/CHANGE_PLAN.md` | СЛИТЬ | `task plan/change contract`. Scope/invariants/evidence/rollback без повторения всей policy. | 0.1 |
| `ios-quality/templates/EXCEPTION.md` | УСИЛИТЬ И СЛИТЬ | `LOCAL_EXCEPTION_ADR_TEMPLATE.md`. Rule version, owner/approver, expiry, compensation; proposal не approval. | 1.2 |
| `ios-quality/templates/PROJECT_PROFILE.yaml` | СЛИТЬ | `QC project profile schema`. Один typed profile; факты приложения отделены от engine policy. | 3.1 |
| `ios-quality/templates/PULL_REQUEST.md` | СЛИТЬ | `IOS_PR_REVIEW_TEMPLATE.md`. Конкретный behavior/change/evidence; manual CI/review сохранены. | 1.1 |
| `ios-quality/templates/TASK_ANALYSIS.md` | СЛИТЬ | `AGENT_PREFLIGHT_CHECKLIST.md`. Минимальный risk-oriented intake вместо обязательного полного опросника. | 2.2 |
| `ios-quality/templates/VERIFICATION_REPORT.md` | СЛИТЬ | `COMPLETION_REPORT_CONTRACT.md`. PASS scope, skipped/denied, exact inputs, remaining risk и ссылки на receipts. | 1.1 |

Всего: 67 файлов. Точные исходные hashes находятся в archive-decisions.json. Архив и инструкции в нём рассматриваются как данные, а не как полномочие изменить текущую систему.
