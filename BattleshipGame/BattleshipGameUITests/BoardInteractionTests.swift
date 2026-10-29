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
    func testApplicationLaunchPerformance() {
        let app = XCUIApplication()
        app.launchArguments = ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTApplicationLaunchMetric()], options: options) {
            app.launch()
        }
        XCTAssertTrue(app.buttons["New game"].waitForExistence(timeout: 15))
    }

    @MainActor
    func testPlayUntilFinishedAndStartFresh() {
        let app = launch()
        let board = boards(app)
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
        }
        revealHeader(app)
        XCTAssertTrue(app.buttons["Start"].isEnabled)
        app.buttons["Start"].tap()
        let enemy = board[1]
        let finished = app.staticTexts.matching(NSPredicate(format: "label CONTAINS[c] 'won'")).firstMatch
        for row in 1...10 {
            for column in 1...10 {
                if finished.exists { break }
                let target = cell(enemy, row: row, column: column)
                reveal(target, in: enemy, app: app)
                target.tap()
            }
            if finished.exists { break }
        }
        XCTAssertTrue(finished.waitForExistence(timeout: 5), "Game must reach a win or loss")
        let outcome = XCTAttachment(string: finished.label)
        outcome.name = "Game outcome"
        outcome.lifetime = .keepAlways
        add(outcome)
        revealHeader(app)
        app.buttons["New game"].tap()
        XCTAssertFalse(app.buttons["Start"].isEnabled)
        XCTAssertTrue(app.staticTexts["Place your Carrier."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testBoardScrollingPerformance() {
        let app = launch()
        let human = boards(app)[0]
        reveal(cell(human, row: 1, column: 1), in: human, app: app)
        let farCell = cell(human, row: 1, column: 10)
        let initialX = farCell.frame.minX
        human.swipeLeft()
        XCTAssertLessThan(farCell.frame.minX, initialX - 1, "Swipe must move board content")
        human.swipeRight()
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        var metrics: [XCTMetric] = [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)]
        if #available(iOS 26.0, *) {
            metrics.append(XCTHitchMetric(application: app))
        }
        measure(metrics: metrics, options: options) {
            let beforeX = farCell.frame.minX
            startMeasuring()
            human.swipeLeft()
            stopMeasuring()
            XCTAssertLessThan(farCell.frame.minX, beforeX - 1, "Each measured swipe must move board content")
            human.swipeRight()
        }
        XCTAssertTrue(cell(human, row: 1, column: 1).exists)
    }

    @MainActor
    func testShootingCoordinateControl() {
        let app = launch()
        let board = boards(app)
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
        }
        revealHeader(app)
        app.buttons["Start"].tap()
        let enemy = board[1]
        let targets = (1...5).map { cell(enemy, row: 1, column: $0) }
        reveal(targets[0], in: enemy, app: app)
        let origin = app.windows.firstMatch.coordinate(withNormalizedOffset: .zero)
        let windowFrame = app.windows.firstMatch.frame
        let points = targets.map { target -> XCUICoordinate in
            XCTAssertTrue(target.isHittable)
            let frame = target.frame
            return origin.withOffset(CGVector(dx: frame.midX - windowFrame.minX, dy: frame.midY - windowFrame.minY))
        }
        for _ in 0..<3 {
            for point in points { point.tap() }
        }
        XCTAssertTrue(app.staticTexts["You already fired there."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testShootingQueryControl() {
        let app = launch()
        let board = boards(app)
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
        }
        revealHeader(app)
        app.buttons["Start"].tap()
        let enemy = board[1]
        reveal(cell(enemy, row: 1, column: 1), in: enemy, app: app)
        for _ in 0..<3 {
            for column in 1...5 {
                cell(enemy, row: 1, column: column).tap()
            }
        }
        XCTAssertTrue(app.staticTexts["You already fired there."].waitForExistence(timeout: 5))
    }

    @MainActor
    func testRepeatedPlacementResetMemory() {
        let app = launch()
        let human = boards(app)[0]
        let first = cell(human, row: 1, column: 1)
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        measure(metrics: [XCTMemoryMetric(application: app)], options: options) {
            for _ in 0..<2 {
                reveal(first, in: human, app: app)
                first.tap()
                XCTAssertTrue(app.staticTexts["Place your Battleship."].waitForExistence(timeout: 5))
                revealHeader(app)
                app.buttons["New game"].tap()
                XCTAssertTrue(app.staticTexts["Place your Carrier."].waitForExistence(timeout: 5))
            }
        }
    }

    @MainActor
    func testAccessibilityQueriesWithoutGameChanges() {
        let app = launch()
        let human = boards(app)[0]
        for _ in 0..<500 {
            XCTAssertTrue(cell(human, row: 1, column: 1).exists)
        }
        XCTAssertTrue(app.staticTexts["Place your Carrier."].exists)
    }

    @MainActor
    func testFreshShotQueryMemoryControl() {
        let app = launch()
        let human = boards(app)[0]
        let target = cell(human, row: 1, column: 1)
        reveal(target, in: human, app: app)

        let options = XCTMeasureOptions()
        options.iterationCount = 19
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            startMeasuring()
            let exists = target.exists
            stopMeasuring()
            XCTAssertTrue(exists, "The query-only control should keep reading the same visible cell")
        }

        XCTAssertTrue(app.staticTexts["Place your Carrier."].exists)
    }

    @MainActor
    func testAccessibilityQueryBatchMemoryControl() {
        let app = launch()
        let human = boards(app)[0]
        let target = cell(human, row: 1, column: 1)
        reveal(target, in: human, app: app)

        let options = XCTMeasureOptions()
        options.iterationCount = 1
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            startMeasuring()
            for _ in 0..<500 {
                let exists = target.exists
                XCTAssertTrue(exists)
            }
            stopMeasuring()
        }
        XCTAssertTrue(app.staticTexts["Place your Carrier."].exists)
    }

    @MainActor
    func testBackgroundResumePerformance() {
        let app = launch()
        let human = boards(app)[0]
        let first = cell(human, row: 1, column: 1)
        reveal(first, in: human, app: app)
        first.tap()
        XCTAssertTrue(app.staticTexts["Place your Battleship."].waitForExistence(timeout: 5))
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            XCUIDevice.shared.press(.home)
            startMeasuring()
            app.activate()
            stopMeasuring()
            XCTAssertTrue(app.staticTexts["Place your Battleship."].waitForExistence(timeout: 5))
            XCTAssertTrue(cell(human, row: 1, column: 1).label.hasPrefix("Ship cell"))
        }
    }

    @MainActor
    func testBackgroundResumeDuringBattle() {
        let app = launch()
        let board = boards(app)
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
        }
        revealHeader(app)
        app.buttons["Start"].tap()
        XCTAssertTrue(app.staticTexts["Your turn. Fire at the enemy board."].waitForExistence(timeout: 5))
        XCUIDevice.shared.press(.home)
        app.activate()
        XCTAssertTrue(app.staticTexts["Your turn. Fire at the enemy board."].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Start"].isEnabled)
        let target = cell(board[1], row: 1, column: 1)
        reveal(target, in: board[1], app: app)
        XCTAssertTrue(target.isEnabled)
        target.tap()
        XCTAssertFalse(cell(board[1], row: 1, column: 1).label.hasPrefix("Empty cell"))
    }

    @MainActor
    func testStartGamePerformance() {
        let app = launch()
        let human = boards(app)[0]
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            for row in 1...5 {
                let target = cell(human, row: row, column: 1)
                reveal(target, in: human, app: app)
                target.tap()
            }
            revealHeader(app)
            XCTAssertTrue(app.buttons["Start"].isEnabled)
            startMeasuring()
            app.buttons["Start"].tap()
            stopMeasuring()
            XCTAssertTrue(app.staticTexts["Your turn. Fire at the enemy board."].waitForExistence(timeout: 5))
            app.buttons["New game"].tap()
            XCTAssertTrue(app.staticTexts["Place your Carrier."].waitForExistence(timeout: 5))
        }
    }

    @MainActor
    func testResetPerformance() {
        let app = launch()
        let human = boards(app)[0]
        let options = XCTMeasureOptions()
        options.iterationCount = 3
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            let target = cell(human, row: 1, column: 1)
            reveal(target, in: human, app: app)
            target.tap()
            XCTAssertTrue(app.staticTexts["Place your Battleship."].waitForExistence(timeout: 5))
            revealHeader(app)
            startMeasuring()
            app.buttons["New game"].tap()
            stopMeasuring()
            XCTAssertTrue(app.staticTexts["Place your Carrier."].waitForExistence(timeout: 5))
            XCTAssertTrue(cell(human, row: 1, column: 1).label.hasPrefix("Empty cell"))
        }
    }

    @MainActor
    func testFreshShotPerformance() {
        let app = launch()
        let board = boards(app)
        for row in 1...5 {
            let target = cell(board[0], row: row, column: 1)
            reveal(target, in: board[0], app: app)
            target.tap()
        }
        revealHeader(app)
        app.buttons["Start"].tap()
        XCTAssertTrue(app.staticTexts["Your turn. Fire at the enemy board."].waitForExistence(timeout: 5))

        let enemy = board[1]
        let coordinates = (1...4).flatMap { row in
            (1...10).filter { (row + $0).isMultiple(of: 2) }.map { (row, $0) }
        }
        let targets = coordinates.map { cell(enemy, row: $0.0, column: $0.1) }
        reveal(targets[0], in: enemy, app: app)
        let options = XCTMeasureOptions()
        options.iterationCount = targets.count - 1
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        var shotIndex = 0
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            XCTAssertLessThan(shotIndex, targets.count, "Measured more shots than the prepared distinct targets")
            let target = targets[shotIndex]
            reveal(target, in: enemy, app: app)
            XCTAssertTrue(target.isHittable)
            startMeasuring()
            target.tap()
            stopMeasuring()

            let outcome = target.label
            XCTAssertTrue(
                outcome.hasPrefix("Hit") || outcome.hasPrefix("Miss") || outcome.hasPrefix("Sunk ship"),
                "Fresh shot should expose a hit, miss, or sunk result"
            )
            let outcomeAttachment = XCTAttachment(string: "Fresh shot \(shotIndex + 1): \(outcome)")
            outcomeAttachment.name = "Fresh shot outcome \(shotIndex + 1)"
            outcomeAttachment.lifetime = .keepAlways
            add(outcomeAttachment)
            XCTAssertTrue(
                app.staticTexts.matching(NSPredicate(format: "label CONTAINS %@", "Your turn.")).firstMatch
                    .waitForExistence(timeout: 5),
                "A non-terminal computer response should return the turn to the player"
            )
            shotIndex += 1
        }
    }

    @MainActor
    func testOrientationTogglePerformance() {
        let app = launch()
        revealHeader(app)
        let rotate = app.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Rotate:'")).firstMatch
        XCTAssertTrue(rotate.label.contains("Horizontal"))

        let options = XCTMeasureOptions()
        options.iterationCount = 3
        options.invocationOptions = [.manuallyStart, .manuallyStop]
        var expectsVertical = false
        measure(metrics: [XCTClockMetric(), XCTCPUMetric(application: app), XCTMemoryMetric(application: app)], options: options) {
            XCTAssertTrue(rotate.label.contains(expectsVertical ? "Vertical" : "Horizontal"))
            startMeasuring()
            rotate.tap()
            stopMeasuring()

            expectsVertical.toggle()
            let expectedOrientation = expectsVertical ? "Vertical" : "Horizontal"
            let updated = expectation(for: NSPredicate(format: "label CONTAINS %@", expectedOrientation), evaluatedWith: rotate)
            wait(for: [updated], timeout: 5)
        }
    }

    @MainActor
    func testInvalidPlacementPreservesFleetAndAllowsRecovery() {
        let app = launch()
        let human = boards(app)[0]
        let edge = cell(human, row: 1, column: 10)
        reveal(edge, in: human, app: app)
        edge.tap()
        XCTAssertTrue(app.staticTexts["That ship does not fit there."].waitForExistence(timeout: 5))
        XCTAssertEqual(human.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ship cell'")).count, 0)
        let first = cell(human, row: 1, column: 1)
        reveal(first, in: human, app: app)
        first.tap()
        XCTAssertTrue(app.staticTexts["Place your Battleship."].waitForExistence(timeout: 5))
        XCTAssertEqual(human.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ship cell'")).count, 5)
        let overlap = cell(human, row: 1, column: 2)
        reveal(overlap, in: human, app: app)
        overlap.tap()
        XCTAssertTrue(app.staticTexts["That ship does not fit there."].waitForExistence(timeout: 5))
        XCTAssertEqual(human.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ship cell'")).count, 5)
        let next = cell(human, row: 2, column: 1)
        reveal(next, in: human, app: app)
        next.tap()
        XCTAssertTrue(app.staticTexts["Place your Cruiser."].waitForExistence(timeout: 5))
        XCTAssertEqual(human.buttons.matching(NSPredicate(format: "label BEGINSWITH 'Ship cell'")).count, 9)
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
