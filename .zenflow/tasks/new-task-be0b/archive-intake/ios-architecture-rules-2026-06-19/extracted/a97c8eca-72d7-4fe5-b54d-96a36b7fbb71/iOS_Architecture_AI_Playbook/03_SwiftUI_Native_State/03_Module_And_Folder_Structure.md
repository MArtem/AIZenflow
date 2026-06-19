# 03_Module_And_Folder_Structure — SwiftUI Native State Architecture

## 1. Purpose

Этот документ задает структуру файлов для фич, где используется SwiftUI Native State.

---

## 2. Minimal Structure

Для простого UI-only компонента:

```text
ComponentName/
└── ComponentNameView.swift
```

Пример:

```text
ExpandableText/
└── ExpandableTextView.swift
```

---

## 3. Simple Screen Structure

```text
FeatureName/
├── FeatureNameView.swift
├── FeatureNameViewState.swift
└── Components/
    ├── HeaderView.swift
    ├── EmptyView.swift
    └── ErrorView.swift
```

Использовать, если screen state приходит извне или очень простой.

---

## 4. Native State + Observable Model

```text
FeatureName/
├── FeatureNameView.swift
├── FeatureNameModel.swift
├── FeatureNameViewState.swift
├── FeatureNameAction.swift
└── Components/
```

`FeatureNameModel` может быть `@Observable`, если это lightweight screen model.

---

## 5. Native State + MVVM/Clean

Если появляется data/business complexity:

```text
FeatureName/
├── Presentation/
│   ├── FeatureNameView.swift
│   ├── FeatureNameViewModel.swift
│   ├── FeatureNameViewState.swift
│   └── Components/
├── Domain/
├── Data/
└── Assembly/
```

---

## 6. Components Folder

`Components/` содержит dumb/reusable views:

```text
- SearchFieldView
- ArticleCardView
- EmptyStateView
- ErrorStateView
- LoadingFooterView
```

Components should receive:

```text
- primitive props
- ViewState
- Binding for controlled local inputs
- callbacks/actions
```

Components should not receive:

```text
- Repository
- APIClient
- DTO
- DBModel
- giant parent object without reason
```

---

## 7. ViewState Location

Even in SwiftUI Native State, non-trivial UI should use ViewState:

```text
FeatureNameViewState.swift
ArticleCardViewState.swift
ErrorViewState.swift
EmptyViewState.swift
```

---

## 8. Local State Naming

Use descriptive names:

```swift
@State private var isSearchPresented = false
@State private var selectedSegment: Segment = .all
@State private var isExpanded = false
```

Avoid:

```swift
@State private var flag = false
@State private var show = false
@State private var data = []
```

---

## 9. Environment Location

Custom environment definitions should live in:

```text
Shared/Environment/
Core/Environment/
FeatureName/Environment/ only if feature-specific
```

Avoid scattering environment keys across random files.

---

## 10. Preview/Test Fixtures

For SwiftUI components:

```text
PreviewFixtures/
ViewState+Fixtures.swift
```

or:

```swift
extension ArticleCardViewState {
    static let preview = ArticleCardViewState(...)
}
```

---

## 11. Navigation Structure

For simple NavigationStack:

```text
FeatureName/
├── FeatureNameView.swift
└── FeatureNameRoute.swift
```

For complex flow:

```text
Navigation/
├── FeatureNameRoute.swift
└── FeatureNameCoordinator.swift
```

---

## 12. Forbidden Structure

Avoid:

```text
FeatureName/
├── FeatureNameView.swift
├── APIClient.swift
├── Database.swift
├── DTO.swift
└── EverythingState.swift
```

if View directly uses them.

---

## 13. Folder Decision Rule

```text
If a file represents UI rendering, keep it near the View.
If a file represents business/data/infrastructure, do not hide it under SwiftUI View folder.
```
