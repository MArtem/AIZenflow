import XCTest

final class BoardInteractionTests: XCTestCase {
    @MainActor
    private func launch() -> XCUIApplication {
        continueAfterFailure = false
        XCUIDevice.shared.orientation = .portrait
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()
        XCTAssertTrue(app.buttons["New game"].waitForExistence(timeout: 15))
        let tree = XCTAttachment(string: app.debugDescription)
        tree.name = "Initial accessibility tree"
        tree.lifetime = .keepAlways
        add(tree)
        return app
    }

    @MainActor
    private func boards(_ app: XCUIApplication) -> [XCUIElement] {
        let result = app.scrollViews.allElementsBoundByIndex.filter { $0.buttons.count == 100 }
        XCTAssertEqual(result.count, 2, "Two separately queryable 100-cell board scroll views")
        return result
    }

    @MainActor
    private func cell(_ board: XCUIElement, row: Int, column: Int) -> XCUIElement {
        let query = board.buttons.matching(NSPredicate(format: "label ENDSWITH %@", "row \(row), column \(column)"))
        XCTAssertEqual(query.count, 1, "Coordinate must identify exactly one cell in this board")
        return query.firstMatch
    }

    @MainActor
    private func reveal(_ cell: XCUIElement, in board: XCUIElement, app: XCUIApplication) {
        let page = app.scrollViews.firstMatch
        for _ in 0..<10 {
            let frame = cell.frame
            let viewport = page.frame
            if frame.minY < viewport.minY + 4 {
                page.swipeDown()
            } else if frame.maxY > viewport.maxY - 4 {
                page.swipeUp()
            } else {
                break
            }
        }
        for _ in 0..<4 {
            let frame = cell.frame
            let visible = board.frame.intersection(app.scrollViews.firstMatch.frame)
            if frame.minX >= visible.minX && frame.maxX <= visible.maxX { break }
            XCTAssertFalse(visible.isEmpty, "Board must be vertically visible before horizontal scrolling")
            let goesLeft = frame.maxX > visible.maxX
            let startX = visible.minX + visible.width * (goesLeft ? 0.8 : 0.2)
            let endX = visible.minX + visible.width * (goesLeft ? 0.2 : 0.8)
            let window = app.windows.firstMatch
            let origin = window.coordinate(withNormalizedOffset: .zero)
            let start = origin.withOffset(CGVector(dx: startX - window.frame.minX, dy: visible.midY - window.frame.minY))
            let end = origin.withOffset(CGVector(dx: endX - window.frame.minX, dy: visible.midY - window.frame.minY))
            start.press(forDuration: 0.05, thenDragTo: end)
        }
        XCTAssertTrue(cell.isHittable, "Cell must be reachable after bounded vertical/horizontal scrolling")
        XCTAssertGreaterThanOrEqual(cell.frame.width, 43.9, "Minimum cell width")
        XCTAssertGreaterThanOrEqual(cell.frame.height, 43.9, "Minimum cell height")
    }

    @MainActor
    private func revealHeader(_ app: XCUIApplication) {
        let page = app.scrollViews.firstMatch
        for _ in 0..<10 {
            if app.buttons["New game"].isHittable { break }
            page.swipeDown()
        }
        XCTAssertTrue(app.buttons["New game"].isHittable)
    }

    @MainActor
    func testScrolledPlacementFireDuplicateAndReset() {
        let app = launch()
        let board = boards(app)
        XCTAssertFalse(app.buttons["Start"].isEnabled)
        // Check both horizontal edges at both vertical extremes on the enabled fleet board.
        for (row, column) in [(1, 1), (1, 10), (10, 10), (10, 1)] {
            reveal(cell(board[0], row: row, column: column), in: board[0], app: app)
        }
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
            let placed = expectation(for: NSPredicate(format: "label BEGINSWITH %@", "Ship cell"), evaluatedWith: target)
            wait(for: [placed], timeout: 5)
        }
        revealHeader(app)
        XCTAssertTrue(app.buttons["Start"].isEnabled)
        app.buttons["Start"].tap()
        let enemy = board[1]
        for (row, column) in [(1, 1), (1, 10), (10, 1), (10, 10)] {
            reveal(cell(enemy, row: row, column: column), in: enemy, app: app)
        }
        let shot = cell(enemy, row: 10, column: 10)
        shot.tap()
        XCTAssertTrue(shot.label.hasPrefix("Hit") || shot.label.hasPrefix("Miss"), "Scrolled fire selected wrong coordinate")
        let afterShot = shot.label
        shot.tap()
        XCTAssertEqual(shot.label, afterShot, "Duplicate shot must preserve cell")
        XCTAssertTrue(app.staticTexts["You already fired there."].exists)
        let screenshot = XCTAttachment(screenshot: app.screenshot())
        screenshot.name = "Enemy bottom-right after scrolling and duplicate fire"
        screenshot.lifetime = .keepAlways
        add(screenshot)
        revealHeader(app)
        app.buttons["New game"].tap()
        XCTAssertFalse(app.buttons["Start"].isEnabled)
        XCTAssertEqual(board[0].buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ship cell'")).count, 0)
        XCTAssertEqual(enemy.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Hit' OR label BEGINSWITH 'Miss'")).count, 0)
    }

    @MainActor
    private func waitForWindowOrientation(landscape: Bool, app: XCUIApplication) {
        let window = app.windows.firstMatch
        let geometry = NSPredicate { _, _ in
            let frame = window.frame
            return landscape ? frame.width > frame.height : frame.height > frame.width
        }
        let ready = expectation(for: geometry, evaluatedWith: window)
        wait(for: [ready], timeout: 10)
    }

    @MainActor
    func testRotationUpdatesGeometryAndRetainsCoordinateActions() {
        let app = launch()
        let human = boards(app)[0]
        reveal(cell(human, row: 10, column: 10), in: human, app: app)
        XCUIDevice.shared.orientation = .landscapeLeft
        defer { XCUIDevice.shared.orientation = .portrait }
        let landscapeTree = XCTAttachment(string: app.debugDescription)
        landscapeTree.name = "Landscape accessibility tree"
        landscapeTree.lifetime = .keepAlways
        add(landscapeTree)
        waitForWindowOrientation(landscape: true, app: app)
        let target = cell(human, row: 10, column: 6)
        reveal(target, in: human, app: app)
        target.tap()
        XCTAssertTrue(cell(human, row: 10, column: 10).label.hasPrefix("Ship cell"))
        XCUIDevice.shared.orientation = .portrait
        waitForWindowOrientation(landscape: false, app: app)
        reveal(cell(human, row: 10, column: 10), in: human, app: app)
        XCTAssertTrue(cell(human, row: 10, column: 10).label.hasPrefix("Ship cell"))
    }

    @MainActor
    func testLargeTextControlsAndBoardActions() throws {
        let app = launch()
        try app.performAccessibilityAudit(for: [.hitRegion, .sufficientElementDescription, .textClipped, .dynamicType])
        verifyLargeTextRotationAndPlacement(app)
        testScrolledPlacementFireDuplicateAndReset()
    }

    @MainActor
    private func verifyLargeTextRotationAndPlacement(_ app: XCUIApplication) {
        revealHeader(app)
        let rotate = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Rotate:'")).firstMatch
        XCTAssertTrue(rotate.isHittable)
        rotate.tap()
        let vertical = expectation(for: NSPredicate(format: "label CONTAINS 'Vertical'"), evaluatedWith: rotate)
        wait(for: [vertical], timeout: 5)
        let human = boards(app)[0]
        let target = cell(human, row: 6, column: 10)
        reveal(target, in: human, app: app)
        target.tap()
        let bottom = cell(human, row: 10, column: 10)
        let placed = expectation(for: NSPredicate(format: "label BEGINSWITH %@", "Ship cell"), evaluatedWith: bottom)
        wait(for: [placed], timeout: 5)
        revealHeader(app)
        app.buttons["New game"].tap()
        XCTAssertFalse(app.buttons["Start"].isEnabled)
    }

    @MainActor
    func testLargeTextRotationAndPlacementWithoutAudit() {
        verifyLargeTextRotationAndPlacement(launch())
    }

    @MainActor
    func testLargeTextHitRegionAudit() throws {
        try launch().performAccessibilityAudit(for: .hitRegion)
    }

    @MainActor
    func testLargeTextDescriptionAudit() throws {
        try launch().performAccessibilityAudit(for: .sufficientElementDescription)
    }

    @MainActor
    func testLargeTextClippingAudit() throws {
        try launch().performAccessibilityAudit(for: .textClipped)
    }

    @MainActor
    func testLargeTextDynamicTypeAudit() throws {
        try launch().performAccessibilityAudit(for: .dynamicType)
    }

    @MainActor
    func testVisibleAccessibilityHitRegionsAndDescriptions() throws {
        let app = launch()
        try app.performAccessibilityAudit(for: [.hitRegion, .sufficientElementDescription])
        let human = boards(app)[0]
        reveal(cell(human, row: 10, column: 10), in: human, app: app)
        try app.performAccessibilityAudit(for: [.hitRegion, .sufficientElementDescription])
    }
}
