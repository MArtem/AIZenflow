# Сценарии качества: достаточность и отрицательные controls

2026-10-12. Спецификация аудита; ни один сценарий здесь не выполнен. Не U7, не новый эксперимент, не app tests и не oracle. Требования ниже допускают сейчас только документальный trace. Запуск, код/fixtures и внешняя оценка требуют своей конкретной области разрешения.

Исторические 12 cost recipes проверяют состав заранее выбранных файлов, но не результат решения задачи. PASS этих recipes не отвечает на вопросы ниже. Покрытие 18 доменов таблицей не означает, что для каждого домена уже есть outcome evidence.

| Сценарий | Что должно сохраняться в результате | Отрицательный control / признак провала | Owners |
|---|---|---|---|
| Замена async запроса, поздний успех и generic error | Проверка текущего invocation на обоих путях; old cleanup не теряет новый handle; конечная UX согласована | Синхронный код без outstanding work не получает token/task machinery. Настоящая текущая ошибка не скрывается | SWIFT_CONCURRENCY_DEEP_REFERENCE: Contract And Mechanism, Falsification Traces |
| Logout → другой account во время refresh и replay | Старый ответ не восстанавливает credentials и не повторяет действие от другого account; серверный idempotency contract отдельный | Обычный 403 не запускает бесконечный refresh; отсутствие сервера, поддерживающего ключ, не объявляется безопасным retry | IDENTITY_AUTHENTICATION_AND_APP_SECURITY: Session Lifecycle; NETWORKING_WEB_AND_REALTIME_SYSTEMS: Reliability |
| Миграция завершила transform, затем cleanup/disk failure | Recoverable исходник и domain invariants сохранены; cleanup не объявляется rollback; поддерживаемые исторические пути определены | Clean install не засчитывается upgrade evidence; disposable cache не получает ненужный user-data migration workflow | PERSISTENCE_DATA_AND_CLOUDKIT: Migration, Evidence |
| Durable offline delete + relaunch + account switch | Tombstone/operation identity и acknowledgment различимы; старый account не публикует и не replay-ит в новый | Optimistic UI не означает server success; недолговечный чисто UI toggle не получает outbox | Persistence: Offline And Sync, CloudKit; IOS_OFFLINE_SYNC_STANDARD |
| Background expiration во время shared-container mutation | Владелец и integrity boundary определены; extension не полагается на память основного процесса; завершение честное | Наличие entitlement или регистрации задачи не доказывает запуск/доставку | APPLE_CAPABILITIES_AND_EXTENSIONS; IOS_APP_LIFECYCLE_BACKGROUND_STANDARD |
| Reused cell, cache и смена identity | Stable item/account identity, bounded decode/cache и старый result guard; ошибки не оставляют ложный loading | Static asset не получает сетевую инфраструктуру; уменьшение строк не объявляется улучшением памяти | UI: UIKit Lifecycle And Reuse Review; MEDIA_SENSORS_AND_DEVICE_INTEGRATIONS |
| Новый DTO field, unknown enum, частичный ответ | Decode policy, бизнес-валидность и user-visible failure разделены; совместимость version-aware | HTTP 2xx и успешный decode не равны business success; намеренно forward-compatible поле не вызывает бессмысленную остановку | API_CONTRACT_AND_INTEGRATION_RULES; Networking: Boundary Model |
| AI unavailable + untrusted structured tool request | Availability/fallback честные; schema validation не заменяет текущую user/resource authorization; повтор действия ограничен | Текст модели не становится полномочием. Обычный локальный детерминированный сценарий не требует AI | AI master: Tool Calling, Structured Output, Security, Fallback |
| StoreKit redelivery, pending и revoked entitlement | Повтор не double-grant; pending не success; transaction evidence и server ownership ясны | Наличие кнопки restore не доказывает восстановление покупки; offline state не выдумывает entitlement | IOS_STOREKIT_PAYMENTS_STANDARD; App Store reference |
| SwiftUI ownership + localization/accessibility | Сохраняется выбранный архитектурный стиль; localization/Dynamic Type/семантика accessibility применимы | Passive view не получает ViewModel; actual VoiceOver/iPad/device checks не возвращаются в acceptance | UI state, architecture router, localization/accessibility standards |
| Source выглядит корректно, но target/config другой | Build membership/toolchain/dependency provenance не выводятся из текста; отсутствующее подтверждение явно unknown | Docs validator PASS не доказывает компиляцию и поставку; sample warning suppression не проходит как ownership fix | XCODE_BUILD_BINARY_AND_SUPPLY_CHAIN; Swift 6.x Discipline |
| Release/privacy и неизвестная текущая политика | Receipt привязан к candidate, current sources и canonical verdict; неизвестная evidence не становится READY/BYPASSED | Валидный manifest XML не доказывает правдивые declarations; upload floor не подменяет deployment target | App Store reference; quality governance; A07/A09 |

## Отрицательные controls доставки и validators

- Missing mandatory static Level 0 должен блокировать разрешение маршрута; отсутствие неприменимого task handoff — отдельный случай.
- Required/optional collision не понижает обязательность; обычная ссылка не становится обязательным read по одному наличию в тексте.
- Canonical unavailable требует валидного tracked portable marker и честного unavailable status; недоступный optional template не восстанавливается из другой app.
- Новая apps directory участвует в boundary discovery; разрешённая инфраструктурная папка не ошибочно считается app.
- Primary skill и distribution mirror проверяются отдельно; локальная исправленная копия не доказывает исправность нового consumer.
- Старые mode/runtime grants в memory/архиве не активируют действие при resume. Унаследованный режим эконом не сбрасывается молча.
- Исключённая проверка получает OMITTED_BY_USER; непроведённая разрешённая — UNVERIFIED/NOT_RUN по её контракту, никогда PASS.

Эти controls описывают ожидаемое поведение, а не доказанную способность checker обнаружить mutation. Ни один настоящий отрицательный fixture не создавался и не запускался.

## Оценка достаточности

Нужны раздельные оси: корректность выбранного маршрута; сохранность условий; качество конкретного результирующего кода; лишние механизмы; честность отчёта; стоимость доставки. Единого балла, скрывающего нарушение authority или data loss за экономией контекста, недостаточно. P0–P2 нельзя усреднять с успехами.

Для будущего разрешённого сравнения фиксировать input bytes/hashes и полный набор прочтённых файлов, условия задачи и критерий результата до запуска; сохранять failures, ties и retries. Сценарии, уже показанные исполнителю, не называть unseen holdout. Измерение words/bytes не заменяет input/cached/output/reasoning tokens и тем более subscription telemetry. Утверждения об улучшении качества или экономии пока UNVERIFIED.

## Скрытые повторные проходы

`IOS_PR_REVIEW_TEMPLATE.md`, PR Authority And Internal Gate и Review Receipt, требует полный candidate-range review после PR authorization, полный повтор после fixes и exact-committed-range review. Это условная стоимость PR, не startup любой документационной задачи. После изменения HEAD прежний exact-SHA receipt нельзя переиспользовать; неизменённые проверки можно сохранять согласно governing contract. Число реальных повторов в этой сессии не измерялось, PR не создавался. План экономии не должен молча отменить эту доказательную границу.
