# 15_Anti_Patterns — Clean Architecture / Layered Architecture

## 1. Purpose

Этот документ описывает типовые ошибки Clean Architecture в iOS-проектах.

---

## 2. DTO in UI

Плохо:

```swift
struct ArticleCardView: View {
    let article: ArticleDTO
}
```

Почему плохо:

```text
- API contract leaks into UI
- backend changes break UI
- UI formatting depends on API shape
- DB/cache/offline harder to add
```

---

## 3. DBModel in UI

Плохо:

```swift
struct ArticleRow: View {
    let article: ArticleDBModel
}
```

Почему плохо:

```text
- persistence schema leaks into UI
- database changes affect rendering
- UI depends on storage technology
```

---

## 4. SwiftUI in Domain

Плохо:

```swift
import SwiftUI

struct Article {
    let titleColor: Color
}
```

Domain must be framework-independent.

---

## 5. UseCase Returns DTO

Плохо:

```swift
func execute() async throws -> [ArticleDTO]
```

UseCase should return Domain models/results.

---

## 6. Repository Returns ViewState

Плохо:

```swift
func fetchArticles() async throws -> [ArticleCardViewState]
```

Repository belongs to Data/Domain boundary, not UI formatting.

---

## 7. ViewModel Implements API

Плохо:

```swift
let request = URLRequest(url: ...)
let data = try await URLSession.shared.data(for: request)
let dto = try JSONDecoder().decode(ArticleDTO.self, from: data)
```

inside ViewModel.

---

## 8. Domain Depends on Data

Плохо:

```text
Domain imports Data
Domain uses ArticleDTO
Domain uses ArticleDBModel
```

Correct:

```text
Data imports Domain
Data maps DTO/DBModel to Domain
```

---

## 9. Repository as God Service

Симптомы:

```text
- 100+ methods
- unrelated domains
- API + DB + analytics + formatting + navigation
- impossible to test
```

Fix:

```text
- split by aggregate/feature
- split data sources
- split mappers
- move business rules to UseCases
```

---

## 10. UseCase Explosion

Плохо:

```text
GetArticleTitleUseCase
GetArticleSubtitleUseCase
FormatArticleDateUseCase
ToggleLocalExpandedStateUseCase
```

UseCase should represent meaningful application/business scenario, not every line of code.

---

## 11. Protocol Explosion

Плохо:

```text
Protocol for every class
Protocol with one implementation
Protocol not used in tests
Protocol not a boundary
```

Protocol is for boundary, substitution, testing, or multiple implementations.

---

## 12. Mapper Missing

Плохо:

```text
DTO fields manually accessed across ViewModel and View
```

Fix:

```text
central mapper per boundary
```

---

## 13. Cache Policy in View

Плохо:

```swift
if cache.exists {
    show(cache)
} else {
    fetchNetwork()
}
```

inside View.

Cache policy belongs to Repository/Data.

---

## 14. Navigation in Domain

Плохо:

```swift
enum UseCaseResult {
    case openLoginScreen
    case openDetailsScreen
}
```

Domain can return business outcomes, not screens.

---

## 15. Clean Architecture Everywhere

Плохо:

```text
Static legal text screen:
View → ViewModel → UseCase → Repository → DataSource → DTO → Domain → ViewState
```

Overkill.

Use SwiftUI Native State or MVVM light.

---

## 16. Clean Only in Folders

Если папки называются Presentation/Domain/Data, но:

```text
Domain imports DTO
View uses DBModel
Repository returns ViewState
ViewModel calls APIClient
```

это не Clean Architecture.

---

## 17. Final Rule

```text
Clean Architecture is about dependency direction and boundaries,
not about creating more files.
```
