# L2 code-review utility pilot packets

Date: **2026-09-12**. Status: **PACKETS_READY / PILOT_PENDING**.

This file prepares the external blind comparison required by L2. It is not a result of
the comparison and does not claim that the library improves review quality. The candidate
is evaluated as a bounded reference subset only; the runtime is not part of the pilot.

## Fixed comparison contract

Run two fresh, isolated review contexts per task:

- **A — baseline:** the canonical engineering rules available to our process, without the
  candidate library subset.
- **B — baseline + subset:** the same canonical rules plus the pinned, reviewed subset from
  `evidence/11-knowledge-semantic-review.md` for concurrency, networking, SwiftUI state and
  identity.

Keep model, reasoning level, permissions, repository scope, input bytes, task wording, time
budget and output schema equal. Run A and B in randomized order. Do not provide the expected
answer key or the other run's output to either reviewer. Record input hashes, actual model/effort,
wall time and token usage; if token usage is unavailable, record `UNKNOWN`.

Required output fields for each finding:

`task_id`, `finding_id_or_none`, `severity`, `file_or_symbol`, `evidence_quote_or_span`,
`why_it_is_a_defect`, `recommended_change`, `confidence`, `authority_or_scope_note`.

The evaluator scores a finding as confirmed only when it identifies the relevant code path and
the stated consequence. A generic warning without a code anchor is not a confirmed finding.

## Review tasks and answer key

The following snippets are deliberately small and self-contained. The evaluator must receive
the task packet, code and canonical review instructions, but not this answer key.

### L2-T1 — cancellation and stale response

```swift
@MainActor
final class SearchViewModel: ObservableObject {
    @Published private(set) var results: [Result] = []
    @Published private(set) var isLoading = false
    private let service: SearchService

    init(service: SearchService) { self.service = service }

    func reload(query: String) {
        isLoading = true
        Task {
            let value = try? await service.search(query: query)
            guard !Task.isCancelled else { return }
            results = value ?? []
            isLoading = false
        }
    }
}
```

Expected review targets:

- `reload` does not retain/cancel/replace the previous task, so an older response can overwrite
  a newer query's result.
- `try?` converts transport failure into an empty successful-looking result; the state contract
  has no explicit failure path. Cancellation is checked only after the await and is not an
  ordering gate for a newer request.

Control case that must not be reported as a defect: checking `Task.isCancelled` after an async
  boundary is appropriate as one cooperative cancellation checkpoint; the issue is the missing
  replacement/generation gate and failure semantics, not the existence of the check.

### L2-T2 — auth refresh, replay and logout

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

Expected review targets:

- Mutable token state and refresh are unsynchronized; concurrent 401 responses can trigger
  multiple refreshes and lose a rotated token. The client also has no single-flight ownership.
- Every request is replayed after 401, including a potentially non-idempotent request, without
  an explicit replay/idempotency contract or retry budget.
- A refresh can complete after logout and publish a fresh token, violating session termination;
  logout/refresh generation or cancellation semantics are absent.

Control case that must not be reported as a defect: a single retry after an authentication
challenge can be valid when the backend contract explicitly guarantees replay safety and token
rotation, but those contracts are not established by this snippet.

### L2-T3 — SwiftUI ownership and view identity

```swift
struct DetailView: View {
    let itemID: UUID
    @ObservedObject var model: DetailModel

    var body: some View {
        Form {
            TextField("Name", text: $model.name)
        }
        .task {
            await model.load(itemID: itemID)
        }
    }
}

struct ParentView: View {
    @State private var selectedID: UUID?

    var body: some View {
        if let selectedID {
            DetailView(itemID: selectedID, model: DetailModel())
        }
    }
}
```

Expected review targets:

- `ParentView` creates the reference model during body evaluation while `DetailView` declares
  it as externally owned; the model is not stably owned by the parent or child and can reset or
  restart work across renders. Ownership must be explicit (`@StateObject`/modern equivalent in
  the owning view, or injection of a stable instance).
- The task has no identity key. When the same view identity receives a different `itemID`, the
  load lifecycle is not explicitly tied to the item and stale work can update the new screen.
  Use an identity-aware task and a cancellation/generation gate in the model.

Control case that must not be reported as a defect: a child may legitimately use
`@ObservedObject` when its parent owns and injects one stable instance; the problem here is the
unstable construction at the call site, not the property wrapper in isolation.

## Scoring and gate

The evaluator records per task:

| Metric | Definition |
|---|---|
| Confirmed recall | Expected findings confirmed with code-specific evidence / expected findings |
| False positives | Findings not supported by the snippet or canonical contract |
| Dangerous advice | Advice that expands authority, suppresses required checks, loses user data, or asserts an unsupported guarantee |
| Control precision | Correctly leaves the control case unflagged |
| Review cost | Wall time and actual tokens; `UNKNOWN` when unavailable |

L2 requires at least six confirmed substantial findings across T1–T3, all three controls left
unflagged, no dangerous advice or authority expansion, no material regression in baseline recall,
and no more than 50% measured input/time overhead for B versus A. A single independent holdout
must be run after any subset correction. Four tasks are not a statistical claim; they are a
release gate for this candidate only.

## Holdout packet (answer key withheld until both runs finish)

Run a fourth fresh task using the same A/B procedure. Use a small Swift sample involving an
actor-isolated repository method called from a view-model task, where the intended issue is a
missing cancellation check after a retrying async call and a control case is a properly scoped
`Task {}` whose owner cancels it in `deinit`/lifecycle teardown. Do not tune the subset against
the holdout before scoring. Record the exact sample, hashes and answer key only after A/B outputs
are sealed.

## Current verdict

The packets satisfy the preparation fallback in L2, but the utility gate remains **PENDING**:
no external blind A/B run, timing/token receipt, or holdout receipt is present in this workspace.
L3–L5 local work may proceed independently; no accepted knowledge/utility claim may be inferred
from the 12-document semantic review or the 139/139 runtime suite.
