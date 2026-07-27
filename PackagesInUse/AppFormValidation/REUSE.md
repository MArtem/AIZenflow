# AppFormValidation Reuse Notes

## Назначение

`AppFormValidation` — standalone пакет для product-neutral валидации форм: безопасные идентификаторы, redacted field values, built-in rules, async custom rules, snapshot store boundary, in-memory store, and serialized form-state controller.

## Подключение через SwiftPM

```swift
.package(path: "PackagesForReuse/AppFormValidation")
```

```swift
.product(name: "AppFormValidation", package: "AppFormValidation")
```

## Source-only подключение

Если проект использует source-only режим, копируйте `Sources/AppFormValidation/**/*.swift` в нужный target. `Package.swift`, `Tests`, `Docs`, `PackageContract.md`, `README.md`, `REUSE.md` и `Scripts/verify_package.sh` должны оставаться рядом с пакетом для переносимости.

## Граница ответственности

Пакет владеет:

- безопасными form/field/rule/code identifiers;
- redacted diagnostics для значений и идентификаторов;
- deterministic local validation rules;
- async custom validation rule boundary;
- snapshot/store/controller primitives;
- сериализацией `FormStateController` операций через suspending store calls.

Host app владеет:

- localized/user-visible validation messages;
- field labels and accessibility phrasing;
- product-specific password/email/business policies;
- network-backed validation checks;
- analytics/logging/error presentation;
- durable storage implementation beyond in-memory store.

## Текущее решение для TchopApp

Connected source-only. `TchopApp` использует `./PackagesInUse/AppFormValidation` в `./TchopApp/ViewModels/LoginViewModel.swift` для product-neutral механики валидации login form.

App-owned остаются localized/user-visible сообщения, email format policy, default-password strength policy, ReqRes trimming behavior, auth callbacks, throttling, analytics/error presentation, и любые будущие backend-backed validation checks.

## Проверка

```bash
./Scripts/verify_package.sh
```
