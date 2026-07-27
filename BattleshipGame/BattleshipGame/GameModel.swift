import Foundation
import Combine

enum CellState: Equatable {
    case empty
    case ship
    case hit
    case miss
}

enum GamePhase: Equatable {
    case placing
    case playing
    case finished(winner: Player)
}

enum Orientation: String {
    case horizontal = "Horizontal"
    case vertical = "Vertical"

    mutating func toggle() {
        self = self == .horizontal ? .vertical : .horizontal
    }
}

enum Player: String {
    case human = "Player"
    case computer = "Computer"
}

struct Coordinate: Hashable {
    let row: Int
    let column: Int
}

struct ShipDefinition: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let length: Int
}

@MainActor
final class BattleshipGame: ObservableObject {
    static let boardSize = 10

    @Published private(set) var phase: GamePhase = .placing
    @Published private(set) var humanBoard: [[CellState]]
    @Published private(set) var computerBoard: [[CellState]]
    @Published private(set) var targetBoard: [[CellState]]
    @Published private(set) var shipsToPlace: [ShipDefinition]
    @Published private(set) var statusText = "Place your Carrier."
    @Published var orientation: Orientation = .horizontal

    private var computerTargets: Set<Coordinate> = []
    private var humanShipCells: Set<Coordinate> = []
    private var computerShipCells: Set<Coordinate> = []

    init() {
        humanBoard = Self.emptyBoard()
        computerBoard = Self.emptyBoard()
        targetBoard = Self.emptyBoard()
        shipsToPlace = Self.defaultShips
    }

    var currentShip: ShipDefinition? {
        shipsToPlace.first
    }

    var canStart: Bool {
        shipsToPlace.isEmpty && phase == .placing
    }

    func placeShip(at coordinate: Coordinate) {
        guard phase == .placing, let ship = currentShip else { return }
        guard canPlaceShip(length: ship.length, at: coordinate, orientation: orientation, on: humanBoard) else {
            statusText = "That ship does not fit there."
            return
        }

        for cell in cells(for: ship.length, from: coordinate, orientation: orientation) {
            humanBoard[cell.row][cell.column] = .ship
            humanShipCells.insert(cell)
        }

        shipsToPlace.removeFirst()
        if let nextShip = currentShip {
            statusText = "Place your \(nextShip.name)."
        } else {
            statusText = "All ships placed. Start the battle."
        }
    }

    func toggleOrientation() {
        guard phase == .placing else { return }
        orientation.toggle()
    }

    func startGame() {
        guard canStart else { return }
        computerBoard = Self.emptyBoard()
        targetBoard = Self.emptyBoard()
        computerShipCells = []
        placeComputerShips()
        phase = .playing
        statusText = "Your turn. Fire at the enemy board."
    }

    func fire(at coordinate: Coordinate) {
        guard phase == .playing else { return }
        guard targetBoard[coordinate.row][coordinate.column] == .empty else {
            statusText = "You already fired there."
            return
        }

        if computerShipCells.contains(coordinate) {
            targetBoard[coordinate.row][coordinate.column] = .hit
            computerBoard[coordinate.row][coordinate.column] = .hit
            computerShipCells.remove(coordinate)
            if computerShipCells.isEmpty {
                phase = .finished(winner: .human)
                statusText = "You won!"
                return
            }
            statusText = "Hit! Computer turn."
        } else {
            targetBoard[coordinate.row][coordinate.column] = .miss
            statusText = "Miss. Computer turn."
        }

        computerTurn()
    }

    func reset() {
        phase = .placing
        humanBoard = Self.emptyBoard()
        computerBoard = Self.emptyBoard()
        targetBoard = Self.emptyBoard()
        shipsToPlace = Self.defaultShips
        orientation = .horizontal
        computerTargets = []
        humanShipCells = []
        computerShipCells = []
        statusText = "Place your Carrier."
    }

    private func computerTurn() {
        guard phase == .playing else { return }

        let available = allCoordinates().filter { !computerTargets.contains($0) }
        guard let coordinate = available.randomElement() else { return }
        computerTargets.insert(coordinate)

        if humanShipCells.contains(coordinate) {
            humanBoard[coordinate.row][coordinate.column] = .hit
            humanShipCells.remove(coordinate)
            if humanShipCells.isEmpty {
                phase = .finished(winner: .computer)
                statusText = "Computer won. Try again."
            } else {
                statusText = "Computer hit your ship. Your turn."
            }
        } else {
            humanBoard[coordinate.row][coordinate.column] = .miss
            statusText = "Computer missed. Your turn."
        }
    }

    private func placeComputerShips() {
        for ship in Self.defaultShips {
            var placed = false
            while !placed {
                let coordinate = Coordinate(
                    row: Int.random(in: 0..<Self.boardSize),
                    column: Int.random(in: 0..<Self.boardSize)
                )
                let randomOrientation: Orientation = Bool.random() ? .horizontal : .vertical

                if canPlaceShip(length: ship.length, at: coordinate, orientation: randomOrientation, on: computerBoard) {
                    for cell in cells(for: ship.length, from: coordinate, orientation: randomOrientation) {
                        computerBoard[cell.row][cell.column] = .ship
                        computerShipCells.insert(cell)
                    }
                    placed = true
                }
            }
        }
    }

    private func canPlaceShip(
        length: Int,
        at coordinate: Coordinate,
        orientation: Orientation,
        on board: [[CellState]]
    ) -> Bool {
        let shipCells = cells(for: length, from: coordinate, orientation: orientation)
        guard shipCells.count == length else { return false }
        return shipCells.allSatisfy { board[$0.row][$0.column] == .empty }
    }

    private func cells(for length: Int, from start: Coordinate, orientation: Orientation) -> [Coordinate] {
        (0..<length).compactMap { offset in
            let row = orientation == .horizontal ? start.row : start.row + offset
            let column = orientation == .horizontal ? start.column + offset : start.column
            guard row < Self.boardSize, column < Self.boardSize else { return nil }
            return Coordinate(row: row, column: column)
        }
    }

    private func allCoordinates() -> [Coordinate] {
        (0..<Self.boardSize).flatMap { row in
            (0..<Self.boardSize).map { column in
                Coordinate(row: row, column: column)
            }
        }
    }

    private static func emptyBoard() -> [[CellState]] {
        Array(
            repeating: Array(repeating: .empty, count: boardSize),
            count: boardSize
        )
    }

    private static var defaultShips: [ShipDefinition] {
        [
            ShipDefinition(name: "Carrier", length: 5),
            ShipDefinition(name: "Battleship", length: 4),
            ShipDefinition(name: "Cruiser", length: 3),
            ShipDefinition(name: "Submarine", length: 3),
            ShipDefinition(name: "Destroyer", length: 2)
        ]
    }
}
