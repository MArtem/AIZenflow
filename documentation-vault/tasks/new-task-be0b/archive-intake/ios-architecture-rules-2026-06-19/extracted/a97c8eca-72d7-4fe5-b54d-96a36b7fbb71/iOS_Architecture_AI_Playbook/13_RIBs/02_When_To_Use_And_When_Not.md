# 02_When_To_Use_And_When_Not — RIBs

## 1. Purpose

Этот документ объясняет, когда использовать RIBs, а когда лучше Coordinator, MVVM, TCA, VIPER или Modular Architecture без RIBs.

---

## 2. Use RIBs When

Используй RIBs, если:

```text
- приложение большое
- много независимых flows
- сложный parent-child lifecycle
- features need strict isolation
- dependency propagation is complex
- teams work on separate app areas
- business flows can be modeled as tree
- attach/detach child flows matter
```

---

## 3. Strong Fit Scenarios

```text
- super app
- ride-sharing/marketplace
- finance app with many flows
- app with logged-in/logged-out trees
- app with nested business journeys
- multi-team enterprise app
```

---

## 4. Use Coordinator Instead When

Coordinator лучше, если:

```text
- главная проблема navigation
- flows not deeply business-tree based
- app medium size
- team wants less ceremony
```

---

## 5. Use TCA/UDF Instead When

TCA/UDF лучше, если:

```text
- main problem is state/effects
- SwiftUI-first
- strong reducer tests needed
- tree is UI state tree, not business lifecycle tree
```

---

## 6. Use Modular + MVVM Instead When

Если нужно просто разложить проект по features:

```text
Modular / Feature-Sliced + MVVM/Clean
```

будет легче, чем RIBs.

---

## 7. Do Not Use RIBs When

Не использовать RIBs для:

```text
- маленького приложения
- простого SwiftUI app
- prototype
- 2-3 screens
- static content
- team unfamiliar with architecture and no time to learn
```

---

## 8. Overengineering Signals

```text
- RIB for every tiny UI component
- 10 files for local screen with no child flows
- Component graph harder than feature
- attach/detach never used
- listeners only pass through trivial taps
```

---

## 9. Underengineering Signals

RIBs может быть нужен, если:

```text
- app flow is chaotic
- child flows leak into parent/siblings
- dependencies are passed randomly
- flow lifecycle bugs are common
- logged-in/logged-out tree is complex
- teams constantly break each other's modules
```

---

## 10. Decision Rule

```text
Use RIBs when business lifecycle tree and dependency isolation are more important than low boilerplate.
```
