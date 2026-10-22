import XCTest

@MainActor
final class LocalSearchUITests: XCTestCase {
    func testSearchChangeClearReturnAndRetry() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launchEnvironment["AI_FIELDBOOK_KB_UI"] = "1"
        app.launch()
        defer { app.terminate() }
        let searchTab = app.tabBars.buttons.matching(NSPredicate(format: "label IN %@", ["Search", "Поиск"])).firstMatch
        XCTAssertTrue(searchTab.waitForExistence(timeout: 15), app.debugDescription)
        searchTab.tap()
        let field = app.searchFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), app.debugDescription)
        field.tap()
        field.typeText("Alpha")
        XCTAssertTrue(app.staticTexts["Alpha Note"].waitForExistence(timeout: 10))
        replace("Alpha", with: "Beta", field: field)
        XCTAssertTrue(app.staticTexts["Beta Note"].waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Alpha Note"].exists)
        field.typeText("\n")
        app.tabBars.buttons.matching(NSPredicate(format: "label IN %@", ["Workspace", "Пространство"])).firstMatch.tap()
        searchTab.tap()
        XCTAssertTrue(app.staticTexts["Beta Note"].waitForExistence(timeout: 10))
        let clear = app.buttons.matching(NSPredicate(format: "label IN %@", ["Clear Search", "Очистить поиск"])).firstMatch
        XCTAssertTrue(clear.waitForExistence(timeout: 10))
        clear.tap()
        XCTAssertTrue(app.staticTexts.matching(NSPredicate(format: "label IN %@", ["Search Local Content", "Поиск по локальным данным"])).firstMatch.waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Beta Note"].exists)
        field.tap()
        field.typeText("Failure\n")
        let retry = app.buttons.matching(NSPredicate(format: "label IN %@", ["Try Again", "Повторить"])).firstMatch
        XCTAssertTrue(retry.waitForExistence(timeout: 10))
        XCTAssertFalse(app.staticTexts["Failure Note"].exists)
        retry.tap()
        XCTAssertTrue(app.staticTexts["Failure Note"].waitForExistence(timeout: 10))
        XCTAssertFalse(retry.exists)
    }

    private func replace(_ old: String, with new: String, field: XCUIElement) {
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + new)
    }
}
