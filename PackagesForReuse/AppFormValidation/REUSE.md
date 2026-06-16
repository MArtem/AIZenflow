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

Vault-only. В текущем `TchopApp` есть небольшая product-specific login validation surface, а безопасная миграция потребовала бы изменения app runtime/tests. Сейчас активен запрет на изменение `./TchopAppTests`, поэтому подключение в `./PackagesInUse` было бы преждевременным.

## Проверка

```bash
./Scripts/verify_package.sh
```
