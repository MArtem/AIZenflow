# Как писать эффективные prompts для iOS coding agent

1. **Дай контекст репозитория, а не энциклопедию.** Укажи deployment target, Swift mode, UI stack, архитектуру и testing conventions.
2. **Сформулируй observable outcome.** Не "улучши код", а "устрани race, сохрани API, добавь тест, не меняй UI".
3. **Назови ограничения.** Не добавлять dependencies, не менять public API, minimum iOS, performance budget.
4. **Потребуй инспекцию существующего кода.** Агент должен найти аналоги и ownership перед созданием новых abstraction.
5. **Попроси проверку, не уверенность.** "Запусти build/tests" лучше, чем "убедись".
6. **Попроси минимальный diff.** Это резко снижает регрессионный риск.
7. **Дай тематический quality gate.** Для networking — cancellation/retry/idempotency; для SwiftUI — state/identity; для persistence — migrations/integrity.
8. **Зафиксируй формат результата.** Changed files, rationale, verification, risks.

## Универсальная оболочка
```text
Контекст: <project context>.
Задача: <observable outcome>.
Ограничения: <deployment/API/dependency/diff constraints>.
Перед кодом: изучи существующую реализацию и назови инварианты.
Реализация: следуй QUALITY_STANDARD.md и skill <ID>.
Проверка: build + релевантные tests + тематические checks.
Ответ: изменения по файлам, решения, проверки, риски/непроверенное.
```
