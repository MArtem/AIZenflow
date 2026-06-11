/// Umbrella database module re-exporting only database backend contracts and concrete database adapters.
///
/// Boundary rule:
/// This module must not re-export navigation, sync, analytics, or app feature modules. Consumers that
/// need those packages should import them explicitly so database dependencies stay transparent.
@_exported import AppCoreDataDatabase
@_exported import AppDatabaseComposition
@_exported import AppDatabaseCore
@_exported import AppSwiftDataDatabase
