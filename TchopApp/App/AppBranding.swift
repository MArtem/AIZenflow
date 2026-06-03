import Foundation
import AppBranding

/// App-facing bridge that resolves the active target branding once from bundle metadata.
@MainActor
enum AppBranding {
    static let theme: BrandTheme = InfoDictionaryBrandThemeManager(bundle: .main).activeTheme
}
