# AppInputFormatting Usage

## Format With Built-In Formatters

```swift
let fieldID = try InputFieldID("phone")
let digitsID = try InputFormatterID("digits")
let groupID = try InputFormatterID("group")

let digits = try BuiltInInputFormatter(id: digitsID, kind: .allowDecimalDigits)
let grouped = try BuiltInInputFormatter(id: groupID, kind: .grouped(groupSize: 3, separator: " "))
let pipeline = try InputFormattingPipeline(
    id: try InputFormatterID("phone.pipeline"),
    formatters: [digits, grouped]
)

let snapshot = try InputSnapshot(fieldID: fieldID, text: "+1 (555) 123", selection: .caret(at: 12))
let result = try await pipeline.format(snapshot)
```

## Use Store-Backed Plans

```swift
let store = InMemoryInputFormattingStore()
try await store.save(formatter: digits)
try await store.save(formatter: grouped)
try await store.save(plan: try InputFormattingPlan(fieldID: fieldID, formatterIDs: [digitsID, groupID]))

let engine = AppInputFormattingEngine(store: store)
let result = try await engine.format(snapshot)
```

## Custom Formatter

```swift
struct PrefixFormatter: InputFormatter {
    let id: InputFormatterID

    func format(_ snapshot: InputSnapshot) async throws -> InputFormattingResult {
        let text = "ID-" + snapshot.text
        let selection = try InputTextSelection.caret(at: text.count)
        return try InputFormattingResult(
            fieldID: snapshot.fieldID,
            text: text,
            selection: selection,
            appliedFormatterCount: 1,
            revision: snapshot.revision
        )
    }
}
```

Custom formatters must preserve privacy rules and avoid logging raw input text.
