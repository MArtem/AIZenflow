# CP-18 — Test the negative path explicitly

```swift
@Test
func malformedPayloadIsMappedToDecodingFailure() async {
    let client = HTTPClient(session: .stub(data: Data("{".utf8)))

    await #expect(throws: DecodingError.self) {
        _ = try await client.send(ProfileEndpoint())
    }
}
```

The stub helper is project-specific. The important rule is to test the boundary's actual error contract, including cancellation where relevant.
