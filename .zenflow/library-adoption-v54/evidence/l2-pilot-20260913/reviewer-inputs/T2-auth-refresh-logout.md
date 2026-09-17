# L2-T2 — auth refresh, replay and logout

Review this Swift snippet against the supplied canonical engineering review instructions. Return
only the required structured findings and explicitly state when the control case is conditional.

```swift
final class APIClient {
    private var accessToken: String
    private let auth: AuthService
    private let transport: Transport

    init(accessToken: String, auth: AuthService, transport: Transport) {
        self.accessToken = accessToken
        self.auth = auth
        self.transport = transport
    }

    func send(_ request: Request) async throws -> Response {
        let first = try await transport.send(request, accessToken: accessToken)
        guard first.statusCode == 401 else { return first }
        accessToken = try await auth.refresh()
        return try await transport.send(request, accessToken: accessToken)
    }

    func logout() async {
        await auth.logout()
        accessToken = ""
    }
}
```

Control: one retry after an authentication challenge can be valid when the backend contract
explicitly guarantees replay safety and token rotation. This snippet does not establish those
contracts, so separate the conditional contract gap from an unconditional claim.
