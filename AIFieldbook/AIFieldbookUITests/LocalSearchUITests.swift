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

    func testWorkspaceCancelRenameRelaunchAndConfirmedDeletion() {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        // Exercise normal file-backed startup, not the in-memory search fixture.
        app.launchEnvironment["AI_FIELDBOOK_KB_UI"] = "0"
        let token = UUID().uuidString
        let initial = "KB-EVO-A-" + token
        let renamed = "KB-EVO-B-" + token
        let discarded = "KB-EVO-Draft-" + token
        app.launch()
        defer { app.terminate() }

        workspaceButton(["Create Workspace", "Создать пространство"], app: app).tap()
        let field = app.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 10), app.debugDescription)
        field.tap()
        field.typeText(discarded)
        workspaceButton(["Cancel", "Отмена"], app: app).tap()
        workspaceButton(["Discard Changes", "Отменить изменения"], app: app).tap()
        XCTAssertTrue(field.waitForNonExistence(timeout: 10))
        XCTAssertFalse(workspaceRow(discarded, app: app).exists)

        workspaceButton(["Create Workspace", "Создать пространство"], app: app).tap()
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        field.tap()
        field.typeText(initial)
        workspaceButton(["Save", "Сохранить"], app: app).tap()
        XCTAssertTrue(field.waitForNonExistence(timeout: 10))
        let initialRow = workspaceRow(initial, app: app)
        XCTAssertTrue(initialRow.waitForExistence(timeout: 10), app.debugDescription)
        initialRow.tap()
        XCTAssertTrue(app.navigationBars[initial].waitForExistence(timeout: 10))

        workspaceButton(["Workspace Actions"], app: app).tap()
        workspaceButton(["Rename", "Переименовать"], app: app).tap()
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        replaceWorkspaceName(initial, with: discarded, field: field)
        workspaceButton(["Cancel", "Отмена"], app: app).tap()
        workspaceButton(["Discard Changes", "Отменить изменения"], app: app).tap()
        XCTAssertTrue(field.waitForNonExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars[initial].exists)

        workspaceButton(["Workspace Actions"], app: app).tap()
        workspaceButton(["Rename", "Переименовать"], app: app).tap()
        XCTAssertTrue(field.waitForExistence(timeout: 10))
        XCTAssertEqual(field.value as? String, initial)
        replaceWorkspaceName(initial, with: renamed, field: field)
        XCTAssertEqual(field.value as? String, renamed, app.debugDescription)
        workspaceButton(["Save", "Сохранить"], app: app).tap()
        XCTAssertTrue(field.waitForNonExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars[renamed].waitForExistence(timeout: 10), app.debugDescription)

        app.terminate()
        app.launch()
        let renamedRow = workspaceRow(renamed, app: app)
        XCTAssertTrue(renamedRow.waitForExistence(timeout: 15), app.debugDescription)
        XCTAssertFalse(workspaceRow(initial, app: app).exists)
        XCTAssertFalse(workspaceRow(discarded, app: app).exists)
        renamedRow.tap()
        XCTAssertTrue(app.navigationBars[renamed].waitForExistence(timeout: 10))
        workspaceButton(["Workspace Actions"], app: app).tap()
        workspaceButton(["Delete Workspace", "Удалить пространство"], app: app).tap()
        let alert = app.alerts.firstMatch
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons.matching(NSPredicate(format: "label IN %@", ["Cancel", "Отмена"])).firstMatch.tap()
        XCTAssertTrue(alert.waitForNonExistence(timeout: 10))
        XCTAssertTrue(app.navigationBars[renamed].exists)
        workspaceButton(["Workspace Actions"], app: app).tap()
        workspaceButton(["Delete Workspace", "Удалить пространство"], app: app).tap()
        XCTAssertTrue(alert.waitForExistence(timeout: 10))
        alert.buttons.matching(NSPredicate(format: "label IN %@", ["Delete Workspace", "Удалить пространство"])).firstMatch.tap()
        XCTAssertTrue(app.navigationBars[renamed].waitForNonExistence(timeout: 10))
        XCTAssertFalse(workspaceRow(renamed, app: app).exists)
        // A further process restart must not restore the confirmed deletion.
        app.terminate()
        app.launch()
        let workspaceTab = app.tabBars.buttons.matching(NSPredicate(format: "label IN %@", ["Workspace", "Пространство"])).firstMatch
        XCTAssertTrue(workspaceTab.waitForExistence(timeout: 15))
        workspaceTab.tap()
        XCTAssertFalse(workspaceRow(renamed, app: app).exists)
    }

    private func workspaceButton(_ labels: [String], app: XCUIApplication) -> XCUIElement {
        let button = app.buttons.matching(NSPredicate(format: "label IN %@", labels)).firstMatch
        XCTAssertTrue(button.waitForExistence(timeout: 10), app.debugDescription)
        return button
    }

    private func workspaceRow(_ name: String, app: XCUIApplication) -> XCUIElement {
        app.buttons.matching(NSPredicate(format: "label BEGINSWITH %@", name)).firstMatch
    }

    private func replaceWorkspaceName(_ old: String, with new: String, field: XCUIElement) {
        // WorkspaceEditorScreen focuses this field on appearance, with the caret at the end.
        // Tapping a long existing value again moves the caret into the visible substring.
        XCTAssertEqual(field.value as? String, old)
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count))
        let emptyValue = field.value as? String ?? ""
        XCTAssertTrue(emptyValue.isEmpty || emptyValue == field.placeholderValue)
        field.typeText(new)
        XCTAssertEqual(field.value as? String, new)
    }

    private func replace(_ old: String, with new: String, field: XCUIElement) {
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: old.count) + new)
    }
}
