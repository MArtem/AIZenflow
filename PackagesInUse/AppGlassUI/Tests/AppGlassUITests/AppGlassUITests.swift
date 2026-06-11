import SwiftUI
import XCTest
@testable import AppGlassUI

final class AppGlassUITests: XCTestCase {
    /// Verifies the reusable style stores host-owned fallback and native-glass values without app-specific policy.
    func testChromeStyleStoresHostProvidedValues() {
        let style = AppGlassChromeStyle(
            glassTint: .blue,
            glassStroke: .red,
            fallbackBackground: .white,
            fallbackShadowColor: .black,
            fallbackShadowRadius: 12,
            fallbackShadowX: 1,
            fallbackShadowY: 2,
            interactive: true
        )

        XCTAssertEqual(style.fallbackShadowRadius, 12)
        XCTAssertEqual(style.fallbackShadowX, 1)
        XCTAssertEqual(style.fallbackShadowY, 2)
        XCTAssertTrue(style.interactive)
    }
}
