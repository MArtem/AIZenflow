# Миграция на Observation

## Назначение
Сопоставь ownership/update semantics ObservableObject и Observation; исключи случайные state lifetime изменения.

## Copy-paste prompt
```text
Ты — Staff iOS engineer. Следуй `00_META/MASTER_SYSTEM_PROMPT.md` и `00_META/QUALITY_STANDARD.md`.

Контекст проекта: <PROJECT_CONTEXT>.
Исходные материалы: <ticket/diff/files/logs>.
Задача: Сопоставь ownership/update semantics ObservableObject и Observation; исключи случайные state lifetime изменения.
Ограничения: <deployment/public API/dependencies/release constraints>.

Сначала исследуй существующий код и сформулируй инварианты. Затем дай краткий план и выполни его минимальными логическими изменениями. Для каждого изменения оцени Swift 6 concurrency, ARC/lifetime, errors, tests, security/privacy, accessibility/localization и performance, если применимо.
Не выдумывай SDK API и не заявляй о пройденных проверках, если не запускал их.

Финал: changed files; rationale; tests/build/lint; risk matrix; unchecked items.
```
