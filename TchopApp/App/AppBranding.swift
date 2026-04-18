import Foundation
import TchopBranding

/// App-facing bridge that resolves the active target branding once from bundle metadata.
enum AppBranding {
    static let themeManager: any BrandThemeManaging = InfoDictionaryBrandThemeManager(bundle: .main)

    static var theme: BrandTheme {
        themeManager.activeTheme
    }
}
