# iOS Architecture Style Router

## Purpose
Use this router when reviewing or planning iOS code that may follow different architecture styles.

This document is a **selection and review aid**, not a mandate to convert a project. The current project rules still win:

- Do not add speculative UI, business logic, wrappers, protocols, factories, adapters, use cases, or per-view models.
- MVVM ViewModels expose explicit intent methods by default; generic `send(_:)`, `dispatch(_:)`, and UI action enums require explicit reducer/state-machine architecture approval and rationale.
- Tests are opt-in unless the user explicitly opens a test-writing phase or a current task policy allows them.
- Fixture/mock/local JSON data is allowed only as an explicit dev/test seam, never as a silent production-shaped fallback.
- App-specific policy stays out of reusable docs and packages.

## How To Use
1. Identify the architecture already present in the code before judging it.
2. Apply the architecture-specific gate below only where the code truly uses that style.
3. Prefer the simplest architecture that preserves correctness, ownership, maintainability, and verification.
4. If a proposed rule conflicts with active project rules, do not apply it. Report the conflict and ask the user if a deliberate architecture change is desired.
5. For broad or irreversible architecture changes, use `./docs/ARCHITECTURE_DECISION_GOVERNANCE.md`.

## Architecture Detection And Review Gates

| Style | Detection cues | Use when | Do not use when | Review gate |
|---|---|---|---|---|
| SwiftUI Native State / MV | `@State`, `@Binding`, simple value state in `View` | local visual state, simple controls, simple screens without data/business complexity | API/DB/cache/business rules/shared feature state are involved | single owner for state; cheap `body`; no DTO/DB/API in view; no side effects in `body`; promote to model only for real lifecycle/ownership need |
| MVVM | `View`, `ViewModel`, `ViewState`, explicit intent methods | screen state, forms/lists, loading/error/empty/content, moderate async behavior | complex reducer/effect graph, team chose TCA/UDF, or local visual state is enough | explicit intent methods; dependencies via init; ViewModel does not own API/DB implementation; no DTO/DB in UI; child rows get narrow state/callbacks |
| Clean / Layered | presentation/domain/data split, DTO/domain/view-state mapping | real API/cache/DB/offline/business rules and long-lived feature boundaries | trivial screens or when layers would be pass-through ceremony | dependency direction inward; use cases only for meaningful scenarios; repository protocols only at real seams; DTO/DB never leak into UI |
| Coordinator / Flow | `Route`, `Coordinator`, navigation path/router, deep link parser | multi-screen flows, auth/onboarding/tabs, deep links, modal/push combinations | one local `NavigationLink` or simple local destination is enough | route carries IDs/value objects; no DTO/DB/view/viewmodel in route; coordinator owns navigation only, not API/business/data work |
| Modular / Feature-Sliced | packages/modules/features/shared/core folders, dependency graph | multiple features, teams, build/dependency ownership, reusable package boundaries | structure exists only for symmetry or every tiny feature becomes a package | no circular dependencies; no app policy in reusable modules; stable public APIs only; package extraction solves a real current problem |
| Hexagonal / Ports & Adapters | domain ports, adapters, driven/driving boundaries | multiple interchangeable infrastructure edges or domain core needs isolation | one concrete implementation with no boundary pressure | ports represent real external variability; adapters do not leak DTO/framework types; no protocol explosion |
| TCA | `State`, `Action`, `Reducer`, `Effect`, `Store`, dependency clients | explicit reducer/effect architecture is approved and gives testability/composition value | ordinary MVVM screen, local UI state, or no team commitment to TCA | actions are events, not commands; reducer is pure/synchronous; effects use dependencies and cancellation; no DTO/DB in state; no giant app reducer |
| Redux / Elm / UDF | feature store, state/action/reducer/effect loop | state transitions, action traceability, replay/debugging, complex optimistic/pagination/search behavior justify ceremony | local visual state or moderate MVVM is enough | feature-level state, not global by default; no side effects in reducer; actions are events; no global store for local toggles |
| ReactorKit / Reactor-style | RxSwift/RxCocoa, Action/Mutation/State, `mutate`/`reduce` | Rx-based projects with stream-heavy UI and testable reactive transitions | SwiftUI/async-await project without Rx need | view binds only; side effects in `mutate`; `reduce` pure; dispose/lifecycle safe; no Reactor for tiny components |
| VIP / Clean Swift | View/Interactor/Presenter/Router/Worker, Request/Response/ViewModel | complex UIKit scene, enterprise workflow, legacy ViewController refactor | SwiftUI-first moderate screen or simple static content | roles have real work; presenter formats only; interactor owns business; router navigates only; no empty pass-through VIP |
| VIPER | View/Interactor/Presenter/Entity/Router/Builder | complex legacy UIKit/enterprise modules with real role separation | SwiftUI-first app, simple screens, or team does not need ceremony | no Presenter god object; protocols only at real seams; builder owns assembly; router has no business/API work |
| MVP Passive View | View protocol + Presenter display commands | UIKit legacy screens where passive view/testable presenter is valuable | SwiftUI declarative state is natural or screen has no presenter decisions | view protocol stays small; presenter owns presentation decisions; no API/DB implementation in presenter |
| RIBs | Router/Interactor/Builder/Component tree, attach/detach lifecycle | very large apps with business lifecycle trees and strict dependency propagation | navigation-only problem, medium apps, simple SwiftUI screens | tree depth justified; detach path for every attach; no sibling coupling; component is not a service locator |
| MVC / Massive ViewController Migration | legacy ViewController owns UI/data/navigation/business | incremental migration from legacy UIKit/MVC | greenfield SwiftUI or big-bang rewrite temptation | preserve behavior; extract smallest safe responsibility; avoid moving massive VC into massive VM/helper |

## Architecture-Specific Interaction Rule
- MVVM uses explicit methods such as `refresh()`, `publish()`, `selectChannel(id:)`, `toggleLike(id:)`.
- TCA/UDF/Reactor-style architectures may use actions only when that architecture is explicitly chosen and documented.
- Coordinator/Router boundaries handle navigation intents, not business or data work.
- VIP/VIPER/MVP presenters/interactors are justified only when their roles are non-empty and testable.

## Architecture Selection Priorities
1. Local SwiftUI state for local visual behavior.
2. MVVM with explicit intent methods for normal screen-level state.
3. Coordinator when navigation flow becomes a real boundary.
4. Clean/Layered/Hexagonal only where data/domain/infrastructure boundaries are real.
5. TCA/UDF/Reactor only when explicit state-transition/effect architecture is the product/team decision.
6. VIP/VIPER/MVP/RIBs mainly for legacy UIKit, enterprise, lifecycle-tree, or team-standard contexts.

## Stop List
Do not integrate or generate:

- Architecture style changes without user approval.
- Generic `send(_:)` as MVVM boilerplate.
- UseCase/protocol/adapter/factory/builder layers without a current boundary problem.
- Tests merely because an external architecture prompt says to generate them.
- Local JSON/mock/stub fallback as production-shaped runtime.
- Routes carrying DTOs, DB models, SwiftUI views, or ViewModels.
- Reusable package rules that embed app-specific product policy.
- Full VIPER/RIBs/TCA/UDF scaffolding for trivial screens.

## Review Output Contract
When using this router, report:

1. Detected architecture style or mixed styles.
2. Evidence from files/types/data flow.
3. Applicable architecture gate.
4. Conflicts with active project rules.
5. Must-fix findings and do-not-do overengineering risks.
6. Whether an ADR is needed.
7. Verification needed for the approved scope.
