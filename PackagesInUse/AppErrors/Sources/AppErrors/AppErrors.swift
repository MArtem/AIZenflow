
public extension AppErrorManager {
    /// Creates an error manager with the standalone fallback mapper.
    ///
    /// This initializer intentionally has no networking-specific behavior so the package remains
    /// 100% single-folder standalone. Add `AppErrorsNetworkingIntegration.swift` to a host app when
    /// `AppNetworking` is also present and API errors should be mapped into `AppError` semantics.
    init(
        messageCatalog: any AppErrorMessageCatalog = DefaultAppErrorMessageCatalog(),
        reporter: (any AppErrorReporting)? = nil
    ) {
        self.init(
            mapper: UnknownAppErrorMapper(),
            messageCatalog: messageCatalog,
            reporter: reporter
        )
    }
}
