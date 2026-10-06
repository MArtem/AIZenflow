import Foundation
import Darwin

// Standalone, non-shipping regression executable compiled with the actual GameModel.swift.
// Runs on macOS without CoreSimulator. It does not test SwiftUI, hit testing or VoiceOver.
@MainActor
@main
struct ModelRegressionTests {
    private struct Failure: Error, CustomStringConvertible {
        let description: String
    }

    private static func check(_ condition: Bool, _ message: String) throws {
        if !condition { throw Failure(description: message) }
    }

    private static func count(_ state: CellState, in board: [[CellState]]) -> Int {
        board.flatMap { $0 }.filter { $0 == state }.count
    }

    private static func preparedGame() throws -> BattleshipGame {
        let game = BattleshipGame()
        for row in 0..<5 {
            game.placeShip(at: Coordinate(row: row, column: 0))
        }
        try check(game.canStart, "Nonoverlapping fleet must allow start")
        return game
    }

    private static func playingGame() throws -> BattleshipGame {
        let game = try preparedGame()
        game.startGame()
        try check(game.phase == .playing, "A complete fleet must enter playing")
        return game
    }

    private static func coordinate(for state: CellState, in board: [[CellState]]) throws -> Coordinate {
        for row in board.indices {
            for column in board[row].indices where board[row][column] == state {
                return Coordinate(row: row, column: column)
            }
        }
        throw Failure(description: "Required fixture coordinate not found: \(state)")
    }

    static func main() {
        let cases: [(String, @MainActor () throws -> Void)] = [
            ("initial boards and placement phase", {
                let game = BattleshipGame()
                try check(game.phase == .placing && !game.canStart, "Initial phase/start gate")
                try check(game.shipsToPlace.map(\.length) == [5, 4, 3, 3, 2], "Initial fleet")
                for board in [game.humanBoard, game.computerBoard, game.targetBoard] {
                    try check(board.count == 10 && board.allSatisfy { $0.count == 10 }, "10x10 board")
                    try check(count(.empty, in: board) == 100, "Initial cells must be empty")
                }
            }),
            ("start and fire are gated during placement", {
                let game = BattleshipGame()
                let human = game.humanBoard
                game.startGame()
                game.fire(at: Coordinate(row: 9, column: 9))
                try check(game.phase == .placing, "Premature start/fire changed phase")
                try check(game.humanBoard == human && count(.empty, in: game.targetBoard) == 100,
                          "Premature fire changed boards")
            }),
            ("valid placement consumes exactly one ship", {
                let game = BattleshipGame()
                game.placeShip(at: Coordinate(row: 0, column: 0))
                try check(game.shipsToPlace.map(\.length) == [4, 3, 3, 2], "Wrong remaining fleet")
                try check(count(.ship, in: game.humanBoard) == 5, "Wrong placement size")
                try check((0..<5).allSatisfy { game.humanBoard[0][$0] == .ship }, "Wrong row/columns")
            }),
            ("overflow placement preserves board and ship", {
                let game = BattleshipGame()
                let board = game.humanBoard
                let ship = game.currentShip
                game.placeShip(at: Coordinate(row: 0, column: 9))
                try check(game.humanBoard == board && game.currentShip == ship,
                          "Rejected placement partially committed")
                try check(game.shipsToPlace.count == 5 && !game.canStart, "Rejected placement consumed ship")
            }),
            ("overlap placement preserves prior fleet", {
                let game = BattleshipGame()
                game.placeShip(at: Coordinate(row: 0, column: 0))
                let board = game.humanBoard
                let ship = game.currentShip
                game.placeShip(at: Coordinate(row: 0, column: 1))
                try check(game.humanBoard == board && game.currentShip == ship, "Overlap mutated fleet")
            }),
            ("rotation selects vertical placement and rejects bottom overflow", {
                let game = BattleshipGame()
                game.toggleOrientation()
                try check(game.orientation == .vertical, "Rotation not applied")
                game.placeShip(at: Coordinate(row: 9, column: 9))
                try check(count(.ship, in: game.humanBoard) == 0, "Bottom overflow accepted")
                game.placeShip(at: Coordinate(row: 0, column: 9))
                try check((0..<5).allSatisfy { game.humanBoard[$0][9] == .ship }, "Vertical coordinates")
                try check(count(.ship, in: game.humanBoard) == 5, "Vertical placement size")
            }),
            ("complete fleet and start invariants", {
                let game = try preparedGame()
                try check(count(.ship, in: game.humanBoard) == 17, "Human fleet size")
                game.startGame()
                try check(game.phase == .playing && !game.canStart, "Playing/start gate")
                try check(count(.ship, in: game.computerBoard) == 17, "Generated fleet size")
                try check(count(.empty, in: game.targetBoard) == 100, "Enemy positions leaked into target board")
                let computer = game.computerBoard
                let human = game.humanBoard
                game.startGame()
                game.toggleOrientation()
                game.placeShip(at: Coordinate(row: 9, column: 9))
                try check(game.computerBoard == computer && game.humanBoard == human,
                          "Playing phase allowed restart/placement")
                try check(game.orientation == .horizontal, "Playing phase allowed rotation")
            }),
            ("water shot marks the requested cell and one retaliation", {
                let game = try playingGame()
                let shot = try coordinate(for: .empty, in: game.computerBoard)
                game.fire(at: shot)
                try check(game.targetBoard[shot.row][shot.column] == .miss, "Wrong water coordinate")
                try check(count(.miss, in: game.targetBoard) == 1, "Unexpected target mutations")
                try check(count(.hit, in: game.humanBoard) + count(.miss, in: game.humanBoard) == 1,
                          "A valid shot must trigger exactly one retaliation")
            }),
            ("ship shot marks the requested cell", {
                let game = try playingGame()
                let shot = try coordinate(for: .ship, in: game.computerBoard)
                game.fire(at: shot)
                try check(game.targetBoard[shot.row][shot.column] == .hit, "Wrong ship coordinate")
                try check(game.computerBoard[shot.row][shot.column] == .hit, "Board disagreement")
                try check(count(.hit, in: game.targetBoard) == 1, "First hit wrongly sank fleet")
            }),
            ("duplicate shot does not consume another turn", {
                let game = try playingGame()
                let shot = try coordinate(for: .empty, in: game.computerBoard)
                game.fire(at: shot)
                let human = game.humanBoard
                let target = game.targetBoard
                let computer = game.computerBoard
                game.fire(at: shot)
                try check(game.humanBoard == human && game.targetBoard == target && game.computerBoard == computer,
                          "Duplicate shot changed board or consumed retaliation")
                try check(game.phase == .playing, "Duplicate shot changed phase")
            }),
            ("sinking complete fleet wins and terminal actions are gated", {
                let game = try playingGame()
                // Discover this run's actual fleet; do not assume a random layout or seed.
                // Seventeen hits win before a seventeenth retaliation, so the computer
                // cannot have sunk the player's seventeen cells first.
                let ships = (0..<10).flatMap { row in
                    (0..<10).compactMap { column in
                        game.computerBoard[row][column] == .ship ? Coordinate(row: row, column: column) : nil
                    }
                }
                try check(ships.count == 17, "Fleet fixture incomplete")
                for shot in ships { game.fire(at: shot) }
                try check(game.phase == .finished(winner: .human), "Final ship hit must win")
                try check(count(.sunk, in: game.targetBoard) == 17, "All ship cells must become sunk")
                let human = game.humanBoard
                let target = game.targetBoard
                game.fire(at: try coordinate(for: .empty, in: game.targetBoard))
                game.startGame()
                game.toggleOrientation()
                game.placeShip(at: Coordinate(row: 9, column: 9))
                try check(game.humanBoard == human && game.targetBoard == target && !game.canStart,
                          "Finished phase accepted gameplay actions")
            }),
            ("reset clears boards and permits a fresh game", {
                let game = try playingGame()
                game.fire(at: Coordinate(row: 9, column: 9))
                game.reset()
                try check(game.phase == .placing && game.orientation == .horizontal && !game.canStart,
                          "Reset phase/orientation/start gate")
                try check(game.shipsToPlace.map(\.length) == [5, 4, 3, 3, 2], "Reset fleet")
                for board in [game.humanBoard, game.computerBoard, game.targetBoard] {
                    try check(count(.empty, in: board) == 100, "Reset retained old cells")
                }
                for row in 0..<5 { game.placeShip(at: Coordinate(row: row, column: 0)) }
                game.startGame()
                game.fire(at: Coordinate(row: 9, column: 9))
                try check(count(.empty, in: game.targetBoard) == 99, "Old shot blocked a fresh game")
                try check(count(.hit, in: game.humanBoard) + count(.miss, in: game.humanBoard) == 1,
                          "Reset retained prior computer turns")
            })
        ]

        var failures = 0
        for (name, run) in cases {
            do {
                try run()
                print("PASS: \(name)")
            } catch {
                failures += 1
                print("FAIL: \(name): \(error)")
            }
        }
        print("Model regression: \(cases.count - failures)/\(cases.count) passed; platform macOS, UI not exercised")
        if failures > 0 { exit(1) }
    }
}
