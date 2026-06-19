# 14_Refactoring_Prompt — MVVM

## 1. Purpose

Этот документ содержит промпт для рефакторинга существующего кода в MVVM.

---

## 2. Full Refactoring Prompt

```text
Ты Senior/Staff iOS Architect.

Нужно отрефакторить существующий iOS код в production MVVM.

Не переписывай все сразу. Сначала проанализируй код и найди:

1. Где нарушены MVVM boundaries:
   - View содержит business logic
   - View знает API/Repository/DTO/DBModel
   - ViewModel делает API/DB/cache mechanics
   - DTO используется в UI
   - DBModel используется в UI
   - navigation размазана по View/ViewModel

2. Где есть Massive ViewModel:
   - слишком много dependencies
   - слишком много public methods
   - loading/error/navigation/mapping/API в одном месте
   - слишком много lines

3. Где есть underengineering:
   - нет ViewState
   - нет explicit loading/error/empty
   - нет tests
   - нет repository boundary
   - нет route model

4. Где есть overengineering:
   - лишние protocols
   - лишние UseCases
   - лишние ViewModels
   - boilerplate без пользы

После анализа предложи incremental refactoring plan:

Step 1:
Стабилизировать поведение и добавить characterization tests.

Step 2:
Вынести DTO/DBModel из UI.

Step 3:
Создать ViewState.

Step 4:
Вынести data access в Repository/UseCase.

Step 5:
Вынести business logic из View.

Step 6:
Вынести navigation intent в Route.

Step 7:
Разбить Massive ViewModel, если нужно.

Step 8:
Добавить unit tests.

Правила:
- Не менять UI behavior без необходимости.
- Не делать big bang rewrite.
- Не менять API contracts без причины.
- Не переписывать все на TCA/VIPER, если задача именно MVVM.
- Каждый шаг должен быть компилируемым.
- Для каждого шага объясни риск и benefit.
```

---

## 3. Refactoring Checklist

```text
[ ] Сначала понять текущий behavior
[ ] Найти business logic в View
[ ] Найти data access в View/ViewModel
[ ] Найти DTO leakage
[ ] Найти DBModel leakage
[ ] Найти navigation coupling
[ ] Найти missing state model
[ ] Найти тестовые gaps
[ ] Предложить безопасную последовательность
```

---

## 4. Migration from Massive View

Если View содержит все:

```text
View
- API call
- JSON parsing
- loading bool
- error string
- navigation
- formatting
```

Миграция:

```text
1. Create ViewState
2. Create ViewModel
3. Move loading/error/content state to ViewModel
4. Move API call to Repository
5. Move JSON parsing to DTO/DataSource
6. Move formatting to ViewStateMapper
7. Move navigation to Route/Coordinator
8. Add tests
```

---

## 5. Migration from Massive ViewModel

Если ViewModel содержит все:

```text
ViewModel
- API
- DB
- cache
- mapping
- formatting
- navigation
- analytics
- business logic
```

Миграция:

```text
1. Extract DTO/DB/data access to Data layer
2. Extract business rules to UseCases
3. Extract Domain → ViewState mapping
4. Extract navigation route
5. Extract analytics abstraction
6. Split child feature state if needed
7. Add tests around each extraction
```

---

## 6. Migration from MVC to MVVM

```text
UIViewController/SwiftUI View
 → extract ViewState
 → extract ViewModel
 → extract Repository
 → extract UseCase if needed
 → add Route/Coordinator
 → add tests
```

---

## 7. Do Not

```text
- Do not rewrite entire feature in one commit
- Do not introduce 20 protocols at once
- Do not add Clean Architecture everywhere without need
- Do not change screen design while refactoring architecture
- Do not hide behavior changes under architecture refactor
```

---

## 8. Output Format

ИИ должен выдать:

```text
1. Current problems
2. Risk level
3. Target MVVM structure
4. Step-by-step migration plan
5. Files to create/change
6. Tests to add
7. Example refactored code
8. Final checklist
```
