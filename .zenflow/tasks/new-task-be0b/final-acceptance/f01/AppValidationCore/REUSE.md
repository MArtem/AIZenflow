# AppValidationCore Reuse Notes

## Назначение

`AppValidationCore` — standalone пакет для product-neutral validation core: безопасные validation identifiers, redacted values, typed validation values, validation issues/results, async rules, built-in rules, rule sets, actor-based engine, and cross-value context.

## Подключение через SwiftPM

```swift
.package(path: "PackagesForReuse/AppValidationCore")
```

```swift
.product(name: "AppValidationCore", package: "AppValidationCore")
```

## Source-only подключение

Если проект использует source-only режим, копируйте `Sources/AppValidationCore/**/*.swift` в нужный target. `Package.swift`, `Tests`, `Docs`, `PackageContract.md`, `README.md`, `REUSE.md` и `Scripts/verify_package.sh` должны оставаться рядом с пакетом для переносимости.

## Граница ответственности

Пакет владеет:

- безопасными validation identifiers;
- redacted diagnostics для значений, identifiers, rule IDs, and codes;
- typed `ValidationValue` primitives;
- async custom validation rule boundary;
- built-in validation rules;
- rule-set validation and duplicate-rule rejection;
- bulk validation semantics for configured missing values;
- duplicate value-ID rejection in validation context.

Host app владеет:

- localized/user-visible validation messages;
- field labels and accessibility phrasing;
- product-specific form/session/business policy;
- network-backed validation checks;
- analytics/logging/error presentation;
- durable form state, touched/dirty metadata, and UI submission behavior.

## Текущее решение для TchopApp

Vault-only. `TchopApp` уже использует более высокий form-specific пакет `./PackagesInUse/AppFormValidation` для login form validation. Подключать `AppValidationCore` в `./PackagesInUse` сейчас не нужно: это создало бы параллельную validation surface без текущего app-level потребителя.

`AppValidationCore` сохранён как будущий reusable lower-level validation foundation для settings/domain/payload validation или для возможного будущего выделения generic core из form-specific validation пакета.

## Проверка

```bash
./Scripts/verify_package.sh
```
