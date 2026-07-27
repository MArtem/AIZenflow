# 06_Navigation_Rules — VIPER

## 1. Purpose

Этот документ описывает navigation in VIPER.

---

## 2. Main Rule

```text
Router owns navigation mechanics.
Presenter asks Router to navigate.
```

---

## 3. Presenter Navigation

Presenter can decide:

```text
user selected article
operation succeeded
auth required
close tapped
```

and call Router:

```swift
router.openArticleDetails(id)
```

---

## 4. Router Responsibilities

Router:

```text
- creates destination module
- presents/pushes/dismisses
- passes route parameters
- handles UIKit navigation controller
```

---

## 5. Router Must Not

Router must not:

```text
- call API
- validate business rules
- format UI
- own business state
```

---

## 6. Route Payload

Use IDs/value objects:

```swift
func openDetails(articleID: ArticleID)
```

Avoid:

```swift
func openDetails(dto: ArticleDTO)
```

---

## 7. Builder Integration

Router should use Builder/Assembly:

```swift
let details = ArticleDetailsBuilder.build(articleID: id)
navigationController.pushViewController(details, animated: true)
```

---

## 8. Deep Links

AppCoordinator/DeepLinkRouter can route into VIPER module through Builder/Router.

Do not parse deep links in Presenter randomly.

---

## 9. SwiftUI

SwiftUI VIPER is possible but often awkward.

Use Router as navigation intent handler or external Coordinator.

---

## 10. Rule

```text
Presenter decides navigation intent. Router executes navigation.
```
