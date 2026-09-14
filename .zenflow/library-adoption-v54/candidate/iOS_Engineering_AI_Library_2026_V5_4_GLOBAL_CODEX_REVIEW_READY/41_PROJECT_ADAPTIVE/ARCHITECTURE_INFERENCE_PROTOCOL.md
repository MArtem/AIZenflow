# Architecture Inference Protocol

Architecture inference is advisory. Inspect:
- source directory/module boundaries;
- suffix/type signals (`ViewModel`, `Reducer`, `Store`, `Coordinator`, `Router`, `Repository`, `UseCase`, `Interactor`, `Presenter`);
- imports (`SwiftUI`, `UIKit`, `ComposableArchitecture`, RxSwift, Combine, SwiftData/CoreData etc.);
- dependency direction visible in packages/projects;
- state/observation primitives;
- navigation ownership and dependency construction roots.

Output should prefer statements such as “Coordinator types are concentrated in X and Y” over “the app uses Coordinator architecture” unless project docs or structural evidence explicitly establish that claim.
