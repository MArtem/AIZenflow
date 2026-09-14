# CP-17 — Parameterized Swift Testing

```swift
import Testing

@Test(arguments: [0, 1, 10, 100])
func feeNeverBecomesNegative(amount: Int) {
    let fee = FeeCalculator.fee(for: amount)
    #expect(fee >= 0)
}
```

Use representative semantic inputs, not parameterization for its own sake. Tests should remain independent under in-process parallel execution.
