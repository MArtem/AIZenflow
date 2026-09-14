# CP-12 — Typed HTTP endpoint boundary

```swift
protocol Endpoint {
    associatedtype Response: Decodable
    var request: URLRequest { get throws }
}

struct HTTPClient {
    let session: URLSession
    let decoder: JSONDecoder

    func send<E: Endpoint>(_ endpoint: E) async throws -> E.Response {
        let request = try endpoint.request
        let (data, response) = try await session.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw HTTPError.invalidResponse }
        guard 200..<300 ~= http.statusCode else { throw HTTPError.status(http.statusCode) }
        return try decoder.decode(E.Response.self, from: data)
    }
}
```

Real clients also need endpoint-specific timeout/cache/retry/auth/metrics policy. Do not hide every failure behind one generic error.
