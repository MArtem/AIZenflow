# AppIntentSupport Usage

```swift
let text = try AppIntentTextNormalizer.requiredText(
    rawParameter,
    fieldName: "Text",
    maximumCharacterCount: 200
)
```

Use the normalized value in a host-app-owned `AppIntent` implementation. Keep the product action and persistence in the host app.
