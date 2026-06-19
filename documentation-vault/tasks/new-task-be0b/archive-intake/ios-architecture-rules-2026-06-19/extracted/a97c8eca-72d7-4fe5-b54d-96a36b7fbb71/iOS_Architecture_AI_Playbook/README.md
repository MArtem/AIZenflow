# iOS Architecture AI Playbook

Production-level architecture playbook for iOS / Swift / SwiftUI projects and AI-assisted code generation.

This master archive contains all generated architecture packages from `00` to `14`.

## Sections

- `00_Global_Rules` — Global rules for all architecture packages (present)
- `01_MVVM` — MVVM architecture package (present)
- `02_Clean_Architecture_Layered` — Clean Architecture / Layered architecture package (present)
- `03_SwiftUI_Native_State` — SwiftUI Native State architecture package (present)
- `04_Coordinator_Flow_Architecture` — Coordinator / Flow architecture package (present)
- `05_Modular_Feature_Sliced` — Modular / Feature-Sliced architecture package (present)
- `06_Hexagonal_Ports_Adapters` — Hexagonal Architecture / Ports & Adapters package (present)
- `07_TCA` — TCA / The Composable Architecture package (present)
- `08_Redux_Elm_UDF` — Redux / Elm / Unidirectional Data Flow package (present)
- `09_ReactorKit_Reactor_Style` — ReactorKit / Reactor-style architecture package (present)
- `10_VIP_Clean_Swift` — VIP / Clean Swift package (present)
- `11_VIPER` — VIPER package (present)
- `12_MVP_Passive_View` — MVP / Passive View package (present)
- `13_RIBs` — RIBs package (present)
- `14_MVC_Massive_ViewController_Migration` — MVC / Massive ViewController / Migration package (present)

## Standard document structure

Most architecture sections contain:

1. Architecture Overview
2. When To Use And When Not
3. Module And Folder Structure
4. Data Flow Rules
5. State Management Rules
6. Navigation Rules
7. API DB Cache Rules
8. Error Loading Empty State Rules
9. Testing Strategy
10. Code Generation Rules For AI
11. Review Checklist
12. Master Prompt
13. Feature Implementation Prompt
14. Refactoring Prompt
15. Anti Patterns

## Intended usage

- Use `00_Global_Rules` as the base instruction layer for all AI/code-generation work.
- Pick one architecture section as the primary feature architecture.
- Combine with `04_Coordinator_Flow_Architecture` for navigation-heavy flows.
- Combine with `05_Modular_Feature_Sliced` for larger production codebases.
- Combine with `06_Hexagonal_Ports_Adapters` or `02_Clean_Architecture_Layered` when API/DB/cache/offline boundaries matter.

## Practical recommendation for the target app context

For a large SwiftUI production app with API, local JSON mock first, offline/cache/database later and a small team, the most practical baseline is:

```text
00_Global_Rules
+ 03_SwiftUI_Native_State for simple/local UI
+ 01_MVVM for ordinary screens
+ 02_Clean_Architecture_Layered for API/DB/cache boundaries
+ 04_Coordinator_Flow_Architecture for navigation
+ 05_Modular_Feature_Sliced for project structure
```

Use TCA/UDF/Reactor/VIP/VIPER/RIBs only for features where their specific benefits justify the ceremony.
