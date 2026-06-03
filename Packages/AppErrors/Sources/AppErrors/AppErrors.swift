@_exported import AppErrorsCore
@_exported import AppNetworkingErrorAdapter

public extension AppErrorManager {
    /// Creates an error manager with the default networking-aware mapper used by app-facing layers.
    init(
        messageCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog(),
        reporter: (any AppErrorReporting)? = nil
    ) {
        self.init(
            mapper: DefaultAppErrorMapper(),
            messageCatalog: messageCatalog,
            reporter: reporter
        )
    }
}
